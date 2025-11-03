import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

import 'preferences_service.dart';

// Callback to be executed when a message is processed
typedef OnSmsCallback = void Function(String? message);

class SmsService {
  final SmsQuery _query = SmsQuery();
  static const String _lastSmsSyncKey = 'last_sms_sync_timestamp';

  /// Sincronizar inbox de SMS
  /// 
  /// [onSmsReceived] - Callback que se ejecuta por cada mensaje
  /// [minDate] - Fecha mínima desde la cual procesar mensajes (opcional)
  /// [autoMode] - Si es true, solo procesa mensajes nuevos. Si es false, procesa todos desde minDate
  Future<void> syncInbox(
    OnSmsCallback onSmsReceived, {
    DateTime? minDate,
    bool autoMode = true,
  }) async {
    // SMS no está soportado en web
    if (kIsWeb) {
      debugPrint("SMS no está soportado en la plataforma web.");
      return;
    }

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint("No se tienen permisos de SMS para sincronizar.");
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
      messagesToProcess = allSms.where((sms) {
        if (sms.date == null) return false;
        
        // Debe ser más reciente que el último sync
        final isNewer = lastSyncTimestamp == null || 
                        sms.date!.millisecondsSinceEpoch > lastSyncTimestamp;
        
        // Y debe cumplir con la fecha mínima si está configurada
        final meetsMinDate = minDate == null || 
                             sms.date!.isAfter(minDate) || 
                             sms.date!.isAtSameMomentAs(minDate);
        
        return isNewer && meetsMinDate;
      }).toList();
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
      
      for (final message in messagesToProcess) {
        onSmsReceived(message.body);
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

  Future<bool> requestPermissions() async {
    // En web, los permisos SMS no están soportados
    if (kIsWeb) {
      return false;
    }
    
    final status = await Permission.sms.request();
    if (status.isGranted) {
      return true;
    }
    debugPrint("Permiso de SMS: $status");
    return false;
  }
}
