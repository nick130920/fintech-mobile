import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys para almacenamiento
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';

  // Generic data methods
  static Future<void> saveData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getData(String key) async {
    return await _storage.read(key: key);
  }

  // Token methods
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  // User data methods
  static Future<void> saveUserData(String userData) async {
    await _storage.write(key: _userDataKey, value: userData);
  }

  static Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }

  static Future<void> clearUserData() async {
    await _storage.delete(key: _userDataKey);
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  // Biometric authentication methods
  
  /// Guarda las credenciales del usuario de forma segura para login biométrico
  static Future<void> saveBiometricCredentials({
    required String email,
    required String password,
  }) async {
    await Future.wait([
      _storage.write(key: _savedEmailKey, value: email),
      _storage.write(key: _savedPasswordKey, value: password),
      _storage.write(key: _biometricEnabledKey, value: 'true'),
    ]);
  }

  /// Obtiene el email guardado para login biométrico
  static Future<String?> getSavedEmail() async {
    return await _storage.read(key: _savedEmailKey);
  }

  /// Obtiene la contraseña guardada para login biométrico
  static Future<String?> getSavedPassword() async {
    return await _storage.read(key: _savedPasswordKey);
  }

  /// Verifica si el login biométrico está habilitado
  static Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  /// Habilita el login biométrico
  static Future<void> enableBiometric() async {
    await _storage.write(key: _biometricEnabledKey, value: 'true');
  }

  /// Deshabilita el login biométrico y elimina las credenciales guardadas
  static Future<void> disableBiometric() async {
    await Future.wait([
      _storage.delete(key: _biometricEnabledKey),
      _storage.delete(key: _savedEmailKey),
      _storage.delete(key: _savedPasswordKey),
    ]);
  }

  /// Limpia las credenciales biométricas guardadas
  static Future<void> clearBiometricCredentials() async {
    await Future.wait([
      _storage.delete(key: _savedEmailKey),
      _storage.delete(key: _savedPasswordKey),
    ]);
  }
}
