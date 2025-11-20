import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'notification_parser_service.dart';
import 'automatic_transaction_service.dart';
import 'preferences_service.dart';

/// Servicio para escuchar notificaciones en tiempo real
/// Este servicio captura notificaciones de bancos y las procesa automáticamente
class NotificationListenerService {
  static final NotificationListenerService _instance = NotificationListenerService._internal();
  factory NotificationListenerService() => _instance;
  NotificationListenerService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
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

    // Crear canal de notificaciones para Android
    await _createNotificationChannel();
    
    // Inicializar Workmanager para tareas en background
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    _isInitialized = true;
    print('✅ NotificationListenerService inicializado');
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
      print('❌ Permiso de notificaciones denegado');
      return false;
    }

    print('✅ Permisos de notificación concedidos');
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

    print('✅ Listener de notificaciones activado');
    return true;
  }

  /// Desactiva el listener de notificaciones
  Future<void> disableListener() async {
    await PreferencesService.setBool(_listenerEnabledKey, false);
    await Workmanager().cancelAll();
    print('⏹️ Listener de notificaciones desactivado');
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
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  /// Procesa una notificación bancaria
  Future<void> processNotification(String title, String body, String packageName) async {
    print('📱 Procesando notificación: $title - $body');
    print('📦 Package: $packageName');

    // Verificar si el listener está habilitado
    final isEnabled = await isListenerEnabled();
    if (!isEnabled) {
      print('⏸️ Listener deshabilitado, ignorando notificación');
      return;
    }

    // Parsear la notificación para extraer información de transacción
    final transactionData = NotificationParserService.parseNotification(
      title: title,
      body: body,
      packageName: packageName,
    );

    if (transactionData == null) {
      print('❌ No se pudo extraer información de transacción de la notificación');
      return;
    }

    print('✅ Información de transacción extraída: $transactionData');

    // Guardar la transacción automáticamente
    final success = await AutomaticTransactionService.saveTransaction(
      transactionData: transactionData,
      rawNotification: '$title\n$body',
    );

    if (success) {
      // Mostrar notificación de confirmación al usuario
      await _showConfirmationNotification(transactionData);
      print('✅ Transacción guardada exitosamente');
    } else {
      print('❌ Error al guardar la transacción');
    }
  }

  /// Muestra una notificación de confirmación al usuario
  Future<void> _showConfirmationNotification(Map<String, dynamic> transactionData) async {
    final type = transactionData['type'] as String;
    final amount = transactionData['amount'] as double;
    final merchant = transactionData['merchant'] as String?;
    final description = transactionData['description'] as String;

    final emoji = type == 'expense' ? '💳' : '💰';
    final typeText = type == 'expense' ? 'Gasto' : 'Ingreso';
    
    final title = '$emoji $typeText registrado automáticamente';
    final body = '${merchant ?? description} - \$${amount.toStringAsFixed(2)}';

    const androidDetails = AndroidNotificationDetails(
      _notificationChannelId,
      _notificationChannelName,
      channelDescription: _notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Transacción registrada',
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  /// Callback cuando el usuario toca la notificación
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notificación tocada: ${response.payload}');
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
    print('🔄 Ejecutando tarea en background: $task');
    
    try {
      // Aquí puedes sincronizar notificaciones pendientes o realizar otras tareas
      // Por ahora, solo registramos que se ejecutó
      print('✅ Tarea en background completada');
      return Future.value(true);
    } catch (e) {
      print('❌ Error en tarea de background: $e');
      return Future.value(false);
    }
  });
}




