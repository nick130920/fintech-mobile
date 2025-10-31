import 'dart:convert'; // Added import for jsonEncode

import 'package:flutter/foundation.dart';

import '../../../../core/services/storage_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // Initialize - check if user is already logged in
  Future<void> initialize() async {
    _setStatus(AuthStatus.loading);
    
    // 1. Cargar el usuario desde el caché local primero para una carga rápida
    final cachedUser = await AuthRepository.getCurrentUser();
    if (cachedUser != null) {
      _user = cachedUser;
      _setStatus(AuthStatus.authenticated);
      print("Usuario cargado desde caché.");
      
      // 2. Luego, refrescar el perfil desde el servidor en segundo plano
      await refreshProfile();
      print("Perfil de usuario actualizado desde el servidor.");
    } else {
      // Si no hay usuario en caché, verificar si hay tokens para intentar un refresh
      final hasTokens = await AuthRepository.isLoggedIn();
      if (hasTokens) {
        print("Tokens encontrados, intentando refrescar perfil...");
        await refreshProfile();
        if (_user == null) {
           _setStatus(AuthStatus.unauthenticated);
        }
      } else {
        _setStatus(AuthStatus.unauthenticated);
        print("No hay sesión activa.");
      }
    }
  }

  // Register
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      _setStatus(AuthStatus.loading);
      
      final request = RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      
      final response = await AuthRepository.register(request);
      
      _user = response.user;
      _setStatus(AuthStatus.authenticated);
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setStatus(AuthStatus.loading);
      
      final request = LoginRequest(
        email: email,
        password: password,
      );
      
      final response = await AuthRepository.login(request);
      
      _user = response.user;
      _setStatus(AuthStatus.authenticated);
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _setStatus(AuthStatus.loading);
      
      await AuthRepository.logout();
      
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      // Even if logout fails on server, clear local state
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
      _setError('Error al cerrar sesión: $e');
    }
  }

  // Get current user profile from server
  Future<void> refreshProfile() async {
    try {
      if (_status != AuthStatus.authenticated) return;
      
      final user = await AuthRepository.getProfile();
      // ignore: unnecessary_null_comparison
      if (user != null) {
        _user = user;
        // Guardar el usuario actualizado en el caché
        await StorageService.saveUserData(jsonEncode(user.toJson()));
        notifyListeners();
      }
    } catch (e) {
      _setError('Error al actualizar perfil: $e');
      // Si el refresh falla (ej. token inválido), la sesión será cerrada por el ApiService
      // await logout();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Private methods
  void _setStatus(AuthStatus status) {
    _status = status;
    if (status != AuthStatus.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = AuthStatus.error;
    notifyListeners();
  }
}
