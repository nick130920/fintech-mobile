import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:money_flow/features/bank_accounts/data/repositories/automatic_transactions_repository.dart';
import 'preferences_service.dart';

/// Servicio para escuchar notificaciones en tiempo real
/// Este servicio captura notificaciones de bancos y las procesa automáticamente
class NotificationListenerService {
  static final NotificationListenerService _instance = NotificationListenerService._internal();
  factory NotificationListenerService() => _instance;
  NotificationListenerService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static const MethodChannel _platform = MethodChannel('notification_listener');
  
  static const String _notificationChannelId = 'transaction_notifications';
  static const String _notificationChannelName = 'Transacciones Automáticas';
  static const String _notificationChannelDescription = 
      'Notificaciones de transacciones bancarias procesadas automáticamente';
  
  static const String _listenerEnabledKey = 'notification_listener_enabled';
  static const String _backgroundTaskName = 'process_bank_notification';
  
  bool _isInitialized = false;
  StreamController<String>? _notificationStreamController;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Configuración para Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configuración para iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Configurar MethodCallHandler para recibir eventos de Android
    _platform.setMethodCallHandler(_handleMethodCall);

    // Crear canal de notificaciones para Android
    await _createNotificationChannel();
    
    // Inicializar Workmanager para tareas en background
    await Workmanager().initialize(
      callbackDispatcher,
    );

    _isInitialized = true;
    debugPrint('✅ NotificationListenerService inicializado');
  }

  /// Maneja las llamadas desde el código nativo
  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onNotificationReceived') {
      final String title = call.arguments['title'] ?? '';
      final String body = call.arguments['body'] ?? '';
      final String packageName = call.arguments['packageName'] ?? '';
      
      print('📱 Notificación recibida desde Android (Service):');
      print('   Title: $title');
      print('   Body: $body');
      print('   Package: $packageName');
      
      // Notificar a listeners (streams)
      _notificationStreamController?.add('$title|$body|$packageName');

      // Procesar la notificación
      await processNotification(title, body, packageName);
    }
  }

  /// Crea el canal de notificaciones para Android
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: _notificationChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Solicita permisos necesarios para escuchar notificaciones
  Future<bool> requestPermissions() async {
    // Solicitar permiso de notificaciones
    final notificationStatus = await Permission.notification.request();
    
    if (!notificationStatus.isGranted) {
      debugPrint('❌ Permiso de notificaciones denegado');
      return false;
    }

    debugPrint('✅ Permisos de notificación concedidos');
    return true;
  }

  /// Activa el listener de notificaciones
  Future<bool> enableListener() async {
    if (!_isInitialized) {
      await initialize();
    }

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      return false;
    }

    // Guardar estado habilitado
    await PreferencesService.setBool(_listenerEnabledKey, true);

    // Registrar tarea de background
    await _registerBackgroundTask();

    debugPrint('✅ Listener de notificaciones activado');
    return true;
  }

  /// Desactiva el listener de notificaciones
  Future<void> disableListener() async {
    await PreferencesService.setBool(_listenerEnabledKey, false);
    await Workmanager().cancelAll();
    debugPrint('⏹️ Listener de notificaciones desactivado');
  }

  /// Verifica si el listener está habilitado
  Future<bool> isListenerEnabled() async {
    return await PreferencesService.getBool(_listenerEnabledKey) ?? false;
  }

  /// Registra la tarea de background para procesar notificaciones
  Future<void> _registerBackgroundTask() async {
    await Workmanager().registerPeriodicTask(
      _backgroundTaskName,
      _backgroundTaskName,
      frequency: const Duration(minutes: 15), // Mínimo permitido por Android
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }

  /// Procesa una notificación push bancaria con IA.
  Future<void> processNotification(String title, String body, String packageName) async {
    debugPrint('📱 Notificación bancaria recibida — Package: $packageName');

    final isEnabled = await isListenerEnabled();
    if (!isEnabled) {
      debugPrint('⏸️ Listener deshabilitado, ignorando notificación');
      return;
    }

    await processRawMessage('$title\n$body');
  }

  /// Punto de convergencia de ambos flujos (SMS y push).
  /// Llama al backend con IA y muestra la notificación de resultado al usuario.
  ///
  /// [silent]: no muestra notificaciones locales (útil al procesar muchos SMS seguidos).
  Future<void> processRawMessage(String rawMessage, {bool silent = false}) async {
    debugPrint('🤖 Procesando mensaje con IA: ${rawMessage.length > 80 ? '${rawMessage.substring(0, 80)}…' : rawMessage}');

    try {
      final result = await AutomaticTransactionsRepository.processSMSWithAI(rawMessage);

      final transactionCreated = result['transaction_created'] == true;
      final aiDetected = result['success'] == true;

      if (transactionCreated) {
        final extracted = result['extracted_data'] as Map<String, dynamic>?;
        if (!silent) {
          await _showSuccessNotification(extracted);
        }
        debugPrint('✅ Transacción registrada correctamente por IA');
      } else if (aiDetected) {
        // AI extracted data but confidence < 0.8 → requires manual validation
        final extracted = result['extracted_data'] as Map<String, dynamic>?;
        if (!silent) {
          await _showValidationNotification(extracted);
        }
        debugPrint('⚠️ Transacción detectada por IA, requiere validación manual');
      } else {
        debugPrint('ℹ️ La IA no identificó una transacción en el mensaje');
      }
    } catch (e) {
      debugPrint('❌ Error procesando mensaje con IA: $e');
      if (!silent) {
        await _showErrorNotification();
      }
    }
  }

  /// Resumen tras procesar un lote de SMS en el servidor (una sola notificación).
  Future<void> showBatchSummaryNotification({
    required int created,
    required int totalAnalyzed,
  }) async {
    if (created <= 0) {
      return;
    }
    final title = created == 1
        ? '💳 Transacción registrada automáticamente'
        : '💳 $created transacciones registradas';
    final body = totalAnalyzed > 0
        ? 'Según $totalAnalyzed SMS analizados en lote'
        : 'Sincronización por lote completada';
    await _showNotification(title, body);
  }

  /// Notificación de éxito: transacción guardada.
  Future<void> _showSuccessNotification(Map<String, dynamic>? extracted) async {
    final type = extracted?['type'] as String?;
    final amount = extracted?['amount'];
    final merchant = extracted?['merchant'] as String?;
    final description = extracted?['description'] as String?;

    final emoji = type == 'income' ? '💰' : '💳';
    final notifTitle = '$emoji Transacción registrada automáticamente';

    String notifBody;
    if (amount != null) {
      final label = merchant ?? description ?? 'Transacción';
      notifBody = '$label · \$${(amount as num).toStringAsFixed(0)}';
    } else {
      notifBody = 'Guardada en tus movimientos';
    }

    await _showNotification(notifTitle, notifBody);
  }

  /// Notificación cuando la IA detectó una transacción pero requiere validación manual.
  Future<void> _showValidationNotification(Map<String, dynamic>? extracted) async {
    final amount = extracted?['amount'];
    String body;
    if (amount != null) {
      body = 'Monto: \$${(amount as num).toStringAsFixed(0)} · Revisa en la app';
    } else {
      body = 'Revisa la transacción en la app';
    }
    await _showNotification('🔍 Transacción pendiente de validación', body);
  }

  /// Notificación de error al procesar.
  Future<void> _showErrorNotification() async {
    await _showNotification(
      '⚠️ Error al procesar notificación',
      'No se pudo registrar la transacción. Revisa tu conexión.',
    );
  }

  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      _notificationChannelId,
      _notificationChannelName,
      channelDescription: _notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Transacción registrada',
      icon: '@mipmap/ic_launcher',
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  /// Callback cuando el usuario toca la notificación
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notificación tocada: ${response.payload}');
    // Aquí puedes navegar a una pantalla específica si es necesario
  }

  /// Stream de notificaciones recibidas
  Stream<String> get notificationStream {
    _notificationStreamController ??= StreamController<String>.broadcast();
    return _notificationStreamController!.stream;
  }

  /// Limpia los recursos
  Future<void> dispose() async {
    await _notificationStreamController?.close();
    _notificationStreamController = null;
  }
}

/// Callback dispatcher para tareas en background
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('🔄 Ejecutando tarea en background: $task');
    
    try {
      // Aquí puedes sincronizar notificaciones pendientes o realizar otras tareas
      // Por ahora, solo registramos que se ejecutó
      debugPrint('✅ Tarea en background completada');
      return Future.value(true);
    } catch (e) {
      debugPrint('❌ Error en tarea de background: $e');
      return Future.value(false);
    }
  });
}




