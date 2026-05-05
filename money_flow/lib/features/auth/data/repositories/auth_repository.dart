import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/exceptions/temporary_auth_failure_exception.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/user_model.dart';

/// Resultado de intentar renovar tokens con el servidor.
enum TokenRefreshResult {
  /// Nuevos access/refresh guardados.
  success,

  /// Refresh inválido o ausente: hay que iniciar sesión de nuevo.
  invalidRefreshToken,

  /// Red, timeout o error del servidor: no se borra la sesión local.
  transientFailure,
}

/// Resultado de [attemptTokenRefresh] con mensaje opcional del API (p. ej. 401).
typedef TokenRefreshOutcome = ({
  TokenRefreshResult result,
  String? serverMessage,
});

class AuthRepository {
  // Register user
  static Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await ApiService.post('/auth/register', request.toJson());
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        
        // Save tokens securely
        await StorageService.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );
        
        // Save user data
        await StorageService.saveUserData(jsonEncode(authResponse.user.toJson()));
        
        return authResponse;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error en el registro');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // Login user
  static Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await ApiService.post('/auth/login', request.toJson());
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        
        // Save tokens securely
        await StorageService.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );
        
        // Save user data
        await StorageService.saveUserData(jsonEncode(authResponse.user.toJson()));
        
        return authResponse;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Credenciales inválidas');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  /// Cierra sesión en el servidor y borra almacenamiento local.
  ///
  /// Si [keepQuickLogin] es true, **no** se llama a `auth/logout` (el backend revocaría
  /// el refresh y el inicio con huella dejaría de funcionar). Solo se borran access token
  /// y datos de usuario en caché; se conservan refresh token y la preferencia biométrica.
  static Future<void> logout({bool keepQuickLogin = false}) async {
    try {
      final accessToken = await StorageService.getAccessToken();
      final refreshToken = await StorageService.getRefreshToken();

      if (keepQuickLogin) {
        await StorageService.clearAccessAndUserCache();
        return;
      }

      if (accessToken != null) {
        await ApiService.post(
          'auth/logout',
          refreshToken != null ? {'refresh_token': refreshToken} : {},
          token: accessToken,
        );
      }

      await StorageService.clearAll();
    } catch (e) {
      if (keepQuickLogin) {
        await StorageService.clearAccessAndUserCache();
      } else {
        await StorageService.clearAll();
      }
      throw Exception('Error en el logout: $e');
    }
  }

  // Get current user profile
  static Future<UserModel> getProfile() async {
    try {
      final accessToken = await StorageService.getAccessToken();
      
      if (accessToken == null) {
        throw Exception('No hay token de acceso');
      }
      
      final response = await ApiService.get('users/profile', token: accessToken);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al obtener perfil');
      }
    } on TemporaryAuthFailureException {
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }

  // Update user profile
  static Future<UserModel> updateProfile(Map<String, dynamic> fields) async {
    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No hay token de acceso');
      }

      final response = await ApiService.put('users/profile', fields, token: accessToken);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);
        await StorageService.saveUserData(jsonEncode(user.toJson()));
        return user;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al actualizar perfil');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // Validate current token
  static Future<bool> validateToken() async {
    try {
      final accessToken = await StorageService.getAccessToken();
      
      if (accessToken == null) {
        return false;
      }
      
      final response = await ApiService.get('auth/validate', token: accessToken);
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get current user from local storage
  static Future<UserModel?> getCurrentUser() async {
    try {
      final userData = await StorageService.getUserData();
      
      if (userData != null) {
        final userMap = jsonDecode(userData);
        return UserModel.fromJson(userMap);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in (local check only)
  static Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }

  static Future<void> requestPasswordReset(String email) async {
    final response = await ApiService.post('/auth/forgot-password', {
      'email': email,
    });
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('No se pudo iniciar la recuperación de contraseña');
    }
  }

  static Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await ApiService.post('/auth/reset-password', {
      'token': token,
      'new_password': newPassword,
    });
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('No se pudo restablecer la contraseña');
    }
  }

  /// Renueva tokens. No usa [clearAll]: errores temporales no borran biometría ni sesión.
  static Future<TokenRefreshOutcome> attemptTokenRefresh() async {
    final rawRefresh = await StorageService.getRefreshToken();
    final refreshToken = rawRefresh?.trim();

    if (refreshToken == null || refreshToken.isEmpty) {
      await StorageService.clearTokens();
      await StorageService.clearUserData();
      await StorageService.disableBiometric();
      return (
        result: TokenRefreshResult.invalidRefreshToken,
        serverMessage: null,
      );
    }

    try {
      final response = await ApiService.postWithoutRetry('auth/refresh', {
        'refresh_token': refreshToken,
      });

      if (response.statusCode == 200) {
        final parsed = _decodeJsonObject(response.body);
        if (parsed == null) {
          return (
            result: TokenRefreshResult.transientFailure,
            serverMessage: null,
          );
        }
        final tokens = _readAccessRefreshFromJson(parsed);
        if (tokens == null) {
          return (
            result: TokenRefreshResult.transientFailure,
            serverMessage: null,
          );
        }
        await StorageService.saveTokens(
          accessToken: tokens.$1,
          refreshToken: tokens.$2,
        );
        return (result: TokenRefreshResult.success, serverMessage: null);
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        final serverMessage = _parseErrorMessage(response.body);
        await StorageService.clearTokens();
        await StorageService.clearUserData();
        await StorageService.disableBiometric();
        return (
          result: TokenRefreshResult.invalidRefreshToken,
          serverMessage: serverMessage,
        );
      }

      return (
        result: TokenRefreshResult.transientFailure,
        serverMessage: null,
      );
    } on SocketException {
      return (
        result: TokenRefreshResult.transientFailure,
        serverMessage: null,
      );
    } on TimeoutException {
      return (
        result: TokenRefreshResult.transientFailure,
        serverMessage: null,
      );
    } catch (_) {
      return (
        result: TokenRefreshResult.transientFailure,
        serverMessage: null,
      );
    }
  }

  static Map<String, dynamic>? _decodeJsonObject(String body) {
    if (body.isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// Lee access/refresh desde raíz o desde `data`, aceptando snake_case y camelCase.
  static (String, String)? _readAccessRefreshFromJson(Map<String, dynamic> root) {
    Map<String, dynamic> map = root;
    final nested = root['data'];
    if (nested is Map<String, dynamic>) {
      map = nested;
    }
    final access = map['access_token'] ?? map['accessToken'];
    final refresh = map['refresh_token'] ?? map['refreshToken'];
    if (access is! String || refresh is! String) return null;
    final a = access.trim();
    final r = refresh.trim();
    if (a.isEmpty || r.isEmpty) return null;
    return (a, r);
  }

  static String? _parseErrorMessage(String body) {
    final map = _decodeJsonObject(body);
    if (map == null) return null;
    final msg = map['message'] ?? map['Message'] ?? map['error'];
    if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    return null;
  }
}
