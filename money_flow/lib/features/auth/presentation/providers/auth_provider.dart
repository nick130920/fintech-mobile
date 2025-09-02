import 'package:flutter/foundation.dart';

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
    try {
      _setStatus(AuthStatus.loading);
      
      final isLoggedIn = await AuthRepository.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await AuthRepository.getCurrentUser();
        if (user != null) {
          _user = user;
          _setStatus(AuthStatus.authenticated);
        } else {
          _setStatus(AuthStatus.unauthenticated);
        }
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      _setError('Error al inicializar: $e');
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
      _user = user;
      notifyListeners();
    } catch (e) {
      _setError('Error al actualizar perfil: $e');
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
