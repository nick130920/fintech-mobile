import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

import 'preferences_service.dart';

// Callback to be executed when a message is processed
typedef OnSmsCallback = void Function(String? message);

class SmsService {
  final SmsQuery _query = SmsQuery();
  static const String _lastSmsSyncKey = 'last_sms_sync_timestamp';

  Future<void> syncInbox(OnSmsCallback onSmsReceived) async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      print("No se tienen permisos de SMS para sincronizar.");
      return;
    }

    final lastSyncTimestamp = await PreferencesService.getInt(_lastSmsSyncKey);
    final allSms = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      sort: true,
    );

    final newMessages = allSms.where((sms) {
      // Filtrar mensajes que son más recientes que el último timestamp
      return sms.date != null && (lastSyncTimestamp == null || sms.date!.millisecondsSinceEpoch > lastSyncTimestamp);
    }).toList();

    if (newMessages.isNotEmpty) {
      print("${newMessages.length} nuevos SMS encontrados para procesar.");
      for (final message in newMessages) {
        onSmsReceived(message.body);
      }

      // Guardar el timestamp del mensaje más reciente procesado
      final latestTimestamp = newMessages.first.date!.millisecondsSinceEpoch;
      await PreferencesService.setInt(_lastSmsSyncKey, latestTimestamp);
      print("Último timestamp de SMS guardado: $latestTimestamp");
    } else {
      print("No hay nuevos SMS para procesar.");
    }
  }

  Future<bool> requestPermissions() async {
    final status = await Permission.sms.request();
    if (status.isGranted) {
      return true;
    }
    print("Permiso de SMS: $status");
    return false;
  }
}
