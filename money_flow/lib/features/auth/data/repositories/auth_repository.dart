import 'dart:convert';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/user_model.dart';

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
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
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

  // Refresh access token
  static Future<void> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      
      if (refreshToken == null) {
        throw Exception('No hay refresh token');
      }
      
      final response = await ApiService.post('auth/refresh', {
        'refresh_token': refreshToken,
      });
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        await StorageService.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
      } else {
        throw Exception('Error al renovar token');
      }
    } catch (e) {
      // If refresh fails, logout user
      await StorageService.clearAll();
      throw Exception('Sesión expirada. Por favor, inicia sesión de nuevo.');
    }
  }
}
