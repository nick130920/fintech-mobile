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

  // Logout user
  static Future<void> logout() async {
    try {
      final accessToken = await StorageService.getAccessToken();
      
      if (accessToken != null) {
        await ApiService.post('auth/logout', {}, token: accessToken);
      }
      
      // Clear local storage regardless of API call result
      await StorageService.clearAll();
    } catch (e) {
      // Even if API call fails, clear local storage
      await StorageService.clearAll();
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

  /// Renueva tokens. No usa [clearAll]: errores temporales no borran biometría ni sesión.
  static Future<TokenRefreshResult> attemptTokenRefresh() async {
    final refreshToken = await StorageService.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      await StorageService.clearTokens();
      await StorageService.clearUserData();
      return TokenRefreshResult.invalidRefreshToken;
    }

    try {
      final response = await ApiService.postWithoutRetry('auth/refresh', {
        'refresh_token': refreshToken,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final access = data['access_token'];
        final refresh = data['refresh_token'];
        if (access is! String ||
            refresh is! String ||
            access.isEmpty ||
            refresh.isEmpty) {
          return TokenRefreshResult.transientFailure;
        }
        await StorageService.saveTokens(
          accessToken: access,
          refreshToken: refresh,
        );
        return TokenRefreshResult.success;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        await StorageService.clearTokens();
        await StorageService.clearUserData();
        return TokenRefreshResult.invalidRefreshToken;
      }

      return TokenRefreshResult.transientFailure;
    } on SocketException {
      return TokenRefreshResult.transientFailure;
    } on TimeoutException {
      return TokenRefreshResult.transientFailure;
    } catch (_) {
      return TokenRefreshResult.transientFailure;
    }
  }
}
