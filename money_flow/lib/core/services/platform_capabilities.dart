import 'dart:io';

import 'package:flutter/foundation.dart';

/// Centraliza capacidades por plataforma para evitar ejecutar flujos no soportados.
class PlatformCapabilities {
  const PlatformCapabilities._();

  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  static bool get supportsSmsInbox => isAndroid;
  static bool get supportsRealtimeSmsListener => isAndroid;
  static bool get supportsBankNotificationListener => isAndroid;

  /// iOS no permite leer SMS/notifications de terceros como en Android.
  static bool get supportsAutomaticBankCapture => isAndroid;
}
