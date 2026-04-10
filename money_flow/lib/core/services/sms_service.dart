import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

import 'preferences_service.dart';

enum SmsPermissionResult { granted, denied, permanentlyDenied }

/// Callback that receives both body and date (e.g. for budget suggestions analysis).
typedef OnSmsWithDateCallback = void Function(String? body, DateTime? date);

/// Un SMS del inbox para procesamiento por lote (body + fecha del dispositivo).
class SmsInboxItem {
  final String? body;
  final DateTime? date;

  const SmsInboxItem({this.body, this.date});
}

class SmsService {
  final SmsQuery _query = SmsQuery();
  static const String _lastSmsSyncKey = 'last_sms_sync_timestamp';

  /// Sincronizar inbox de SMS
  ///
  /// [onInboxBatch] - Si se define, se entrega **toda la lista** de una vez (ideal: una petición batch al backend).
  /// [onMessage] - Por cada SMS (body), con **await** entre mensajes.
  /// [onSmsWithDateReceived] - Opcional: callback síncrono (body, date) para recopilar mensajes (ej. sugerencias).
  /// [minDate] - Fecha mínima desde la cual procesar mensajes (opcional)
  /// [autoMode] - Si es true, solo procesa mensajes nuevos. Si es false, procesa todos desde minDate
  Future<void> syncInbox({
    Future<void> Function(List<SmsInboxItem> items)? onInboxBatch,
    Future<void> Function(String? message)? onMessage,
    OnSmsWithDateCallback? onSmsWithDateReceived,
    DateTime? minDate,
    bool autoMode = true,
  }) async {
    // SMS no está soportado en web
    if (kIsWeb) {
      debugPrint("SMS no está soportado en la plataforma web.");
      return;
    }

    final permissionResult = await requestPermissions();
    if (permissionResult != SmsPermissionResult.granted) {
      debugPrint("No se tienen permisos de SMS para sincronizar.");
      return;
    }

    if (onInboxBatch == null && onMessage == null && onSmsWithDateReceived == null) {
      debugPrint('SmsService.syncInbox: sin callbacks; no se procesará ningún mensaje.');
      return;
    }

    final allSms = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      sort: true,
    );

    List<SmsMessage> messagesToProcess = [];

    if (autoMode) {
      // Modo automático: solo mensajes nuevos
      final lastSyncTimestamp = await PreferencesService.getInt(_lastSmsSyncKey);

      if (lastSyncTimestamp == null) {
        // Si es la primera vez (o se borraron datos), NO procesar el historial completo.
        // Simplemente marcamos el momento actual como punto de partida.
        final now = DateTime.now().millisecondsSinceEpoch;
        await PreferencesService.setInt(_lastSmsSyncKey, now);
        debugPrint("SmsService: Inicializando sincronización. Se ignoran mensajes previos a: $now");
        messagesToProcess = [];
      } else {
        messagesToProcess = allSms.where((sms) {
          if (sms.date == null) return false;
          
          // Debe ser más reciente que el último sync
          final isNewer = sms.date!.millisecondsSinceEpoch > lastSyncTimestamp;
          
          // Y debe cumplir con la fecha mínima si está configurada
          final meetsMinDate = minDate == null || 
                               sms.date!.isAfter(minDate) || 
                               sms.date!.isAtSameMomentAs(minDate);
          
          return isNewer && meetsMinDate;
        }).toList();
      }
    } else {
      // Modo manual: todos los mensajes desde minDate
      messagesToProcess = allSms.where((sms) {
        if (sms.date == null) return false;
        
        if (minDate == null) return true;
        
        return sms.date!.isAfter(minDate) || sms.date!.isAtSameMomentAs(minDate);
      }).toList();
    }

    if (messagesToProcess.isNotEmpty) {
      debugPrint("${messagesToProcess.length} SMS encontrados para procesar.");
      debugPrint("Rango: ${minDate != null ? 'Desde ${minDate.toString().split(' ')[0]}' : 'Sin límite'}");

      if (onInboxBatch != null) {
        final batch = messagesToProcess
            .map((m) => SmsInboxItem(body: m.body, date: m.date))
            .toList();
        await onInboxBatch(batch);
      } else {
        for (final message in messagesToProcess) {
          if (onSmsWithDateReceived != null) {
            onSmsWithDateReceived(message.body, message.date);
          }
          if (onMessage != null) {
            await onMessage(message.body);
          }
        }
      }

      // Guardar el timestamp del mensaje más reciente procesado
      if (autoMode && messagesToProcess.isNotEmpty) {
        final latestTimestamp = messagesToProcess.first.date!.millisecondsSinceEpoch;
        await PreferencesService.setInt(_lastSmsSyncKey, latestTimestamp);
        debugPrint("Último timestamp de SMS guardado: $latestTimestamp");
      }
    } else {
      debugPrint("No hay SMS para procesar con los filtros actuales.");
    }
  }
  
  /// Resetear el timestamp de sincronización
  Future<void> resetSyncTimestamp() async {
    await PreferencesService.remove(_lastSmsSyncKey);
    debugPrint("Timestamp de sincronización reseteado");
  }

  Future<SmsPermissionResult> requestPermissions() async {
    if (kIsWeb) {
      return SmsPermissionResult.denied;
    }

    final status = await Permission.sms.request();
    debugPrint("Permiso de SMS: $status");
    if (status.isGranted) return SmsPermissionResult.granted;
    if (status.isPermanentlyDenied) return SmsPermissionResult.permanentlyDenied;
    return SmsPermissionResult.denied;
  }
}
