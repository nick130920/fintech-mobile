import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

/// Servicio para manejar autenticación biométrica (huella dactilar, Face ID, etc.)
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Verifica si el dispositivo tiene capacidades biométricas
  static Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  /// Verifica si el dispositivo está configurado para usar biometría
  static Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Obtiene la lista de biometrías disponibles en el dispositivo
  /// (fingerprint, face, iris, etc.)
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  /// Verifica si el dispositivo tiene biometría configurada y disponible
  static Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await canCheckBiometrics();
      final isSupported = await isDeviceSupported();
      final availableBiometrics = await getAvailableBiometrics();

      return canCheck && isSupported && availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Autentica al usuario usando biometría
  /// Retorna true si la autenticación fue exitosa
  static Future<bool> authenticate({
    String localizedReason = 'Por favor, autentica para continuar',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      
      if (!isAvailable) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason: localizedReason,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Autenticación requerida',
            cancelButton: 'Cancelar',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancelar',
          ),
        ],
        // AuthenticationOptions no existe en esta versión de local_auth para authenticate()
        // Se usan parámetros directos
        biometricOnly: false, // Permite PIN/patrón como fallback
      );
    } on PlatformException catch (e) {
      // Manejar errores específicos
      if (e.code == 'NotAvailable' || e.code == 'NotEnrolled') {
        return false;
      }
      return false;
    }
  }

  /// Detiene la autenticación biométrica en curso
  static Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } on PlatformException {
      // Ignorar errores al detener
    }
  }

  /// Obtiene un mensaje descriptivo de la biometría disponible
  static Future<String> getBiometricTypeDescription() async {
    final biometrics = await getAvailableBiometrics();
    
    if (biometrics.isEmpty) {
      return 'Sin biometría configurada';
    }
    
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    }
    
    if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Huella dactilar';
    }
    
    if (biometrics.contains(BiometricType.iris)) {
      return 'Reconocimiento de iris';
    }
    
    return 'Biometría';
  }

  /// Obtiene un ícono apropiado para el tipo de biometría disponible
  static Future<String> getBiometricIconName() async {
    final biometrics = await getAvailableBiometrics();
    
    if (biometrics.isEmpty) {
      return 'fingerprint';
    }
    
    if (biometrics.contains(BiometricType.face)) {
      return 'face';
    }
    
    if (biometrics.contains(BiometricType.fingerprint)) {
      return 'fingerprint';
    }
    
    if (biometrics.contains(BiometricType.iris)) {
      return 'remove_red_eye';
    }
    
    return 'fingerprint';
  }
}

