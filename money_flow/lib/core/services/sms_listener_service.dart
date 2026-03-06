import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';

/// Callback para cuando se recibe un SMS en tiempo real
typedef OnSmsReceivedCallback = void Function(SmsMessage message);

/// Service for real-time SMS listening using the telephony package.
/// This enables processing bank notifications as soon as they arrive.
class SmsListenerService {
  static final SmsListenerService _instance = SmsListenerService._internal();
  factory SmsListenerService() => _instance;
  SmsListenerService._internal();

  final Telephony _telephony = Telephony.instance;
  
  bool _isListening = false;
  OnSmsReceivedCallback? _onSmsReceived;

  /// Whether the service is currently listening for SMS
  bool get isListening => _isListening;

  /// Start listening for incoming SMS messages.
  /// 
  /// [onSmsReceived] - Callback that fires when a new SMS arrives
  /// Returns true if listening started successfully
  Future<bool> startListening(OnSmsReceivedCallback onSmsReceived) async {
    // Only supported on Android
    if (!Platform.isAndroid) {
      debugPrint('SMS listening is only supported on Android');
      return false;
    }

    // Skip on web
    if (kIsWeb) {
      debugPrint('SMS listening is not supported on web');
      return false;
    }

    // Check if already listening
    if (_isListening) {
      debugPrint('SMS listener is already active');
      return true;
    }

    // Request permissions
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint('SMS permissions not granted');
      return false;
    }

    _onSmsReceived = onSmsReceived;

    // Start listening with foreground and background support
    _telephony.listenIncomingSms(
      onNewMessage: _handleIncomingSms,
      onBackgroundMessage: _onBackgroundMessage,
      listenInBackground: true,
    );

    _isListening = true;
    debugPrint('SMS listener started successfully');
    return true;
  }

  /// Handle incoming SMS in foreground
  void _handleIncomingSms(SmsMessage message) {
    debugPrint('New SMS received from: ${message.address}');
    debugPrint('SMS body preview: ${_truncate(message.body ?? '', 50)}');
    
    _onSmsReceived?.call(message);
  }

  /// Stop listening for SMS messages
  void stopListening() {
    if (!_isListening) return;
    
    // Note: telephony package doesn't have an explicit stop method
    // We just clear our callback
    _onSmsReceived = null;
    _isListening = false;
    debugPrint('SMS listener stopped');
  }

  /// Request necessary permissions for SMS
  Future<bool> requestPermissions() async {
    if (kIsWeb || !Platform.isAndroid) {
      return false;
    }

    // Request SMS permission
    final smsStatus = await Permission.sms.request();
    if (!smsStatus.isGranted) {
      debugPrint('SMS permission denied: $smsStatus');
      return false;
    }

    // Also request phone permission for better SMS handling
    final phoneStatus = await Permission.phone.request();
    debugPrint('Phone permission: $phoneStatus');

    return true;
  }

  /// Check if we have SMS permissions
  Future<bool> hasPermissions() async {
    if (kIsWeb || !Platform.isAndroid) {
      return false;
    }

    final smsStatus = await Permission.sms.status;
    return smsStatus.isGranted;
  }

  /// Get all SMS messages from inbox
  Future<List<SmsMessage>> getInboxMessages({int? limit}) async {
    if (kIsWeb || !Platform.isAndroid) {
      return [];
    }

    final hasPermission = await hasPermissions();
    if (!hasPermission) {
      return [];
    }

    final messages = await _telephony.getInboxSms(
      columns: [
        SmsColumn.ADDRESS,
        SmsColumn.BODY,
        SmsColumn.DATE,
        SmsColumn.TYPE,
      ],
      sortOrder: [
        OrderBy(SmsColumn.DATE, sort: Sort.DESC),
      ],
    );

    if (limit != null && messages.length > limit) {
      return messages.take(limit).toList();
    }

    return messages;
  }

  /// Helper to truncate strings
  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(SmsMessage message) async {
  debugPrint('Background SMS received from: ${message.address}');
  
  // In background, we can store the message for later processing
  // or send it to a local notification
  // The actual processing will happen when the app comes to foreground
  
  // Note: Heavy processing in background is limited on Android
  // Consider using WorkManager for complex background tasks
}
