import 'dart:convert'; // Added import for jsonEncode

import 'package:flutter/foundation.dart';

import '../../../../core/services/biometric_service.dart';
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
      debugPrint("Usuario cargado desde caché.");
      
      // 2. Luego, refrescar el perfil desde el servidor en segundo plano
      await refreshProfile();
      debugPrint("Perfil de usuario actualizado desde el servidor.");
    } else {
      // Si no hay usuario en caché, verificar si hay tokens para intentar un refresh
      final hasTokens = await AuthRepository.isLoggedIn();
      if (hasTokens) {
        debugPrint("Tokens encontrados, intentando refrescar perfil...");
        await refreshProfile();
        if (_user == null) {
           _setStatus(AuthStatus.unauthenticated);
        }
      } else {
        _setStatus(AuthStatus.unauthenticated);
        debugPrint("No hay sesión activa.");
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
    bool saveBiometricCredentials = false,
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
      
      // Guardar credenciales si el usuario habilitó biometría
      if (saveBiometricCredentials) {
        await StorageService.saveBiometricCredentials(
          email: email,
          password: password,
        );
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Login con biometría
  Future<bool> loginWithBiometric() async {
    try {
      _setStatus(AuthStatus.loading);

      // Verificar si la biometría está disponible
      final isBiometricAvailable = await BiometricService.isBiometricAvailable();
      if (!isBiometricAvailable) {
        _setError('La autenticación biométrica no está disponible en este dispositivo');
        return false;
      }

      // Verificar si hay credenciales guardadas
      final email = await StorageService.getSavedEmail();
      final password = await StorageService.getSavedPassword();

      if (email == null || password == null) {
        _setError('No hay credenciales guardadas para login biométrico');
        return false;
      }

      // Autenticar con biometría
      final authenticated = await BiometricService.authenticate(
        localizedReason: 'Autentica para iniciar sesión en MoneyFlow',
      );

      if (!authenticated) {
        _setError('Autenticación biométrica cancelada o fallida');
        return false;
      }

      // Si la biometría fue exitosa, hacer login con las credenciales guardadas
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

  // Verificar si el login biométrico está disponible y habilitado
  Future<bool> isBiometricLoginAvailable() async {
    try {
      final isEnabled = await StorageService.isBiometricEnabled();
      final hasCredentials = await StorageService.getSavedEmail() != null;
      final isBiometricAvailable = await BiometricService.isBiometricAvailable();

      return isEnabled && hasCredentials && isBiometricAvailable;
    } catch (e) {
      return false;
    }
  }

  // Habilitar/deshabilitar login biométrico
  Future<void> toggleBiometricLogin(bool enable) async {
    try {
      if (enable) {
        await StorageService.enableBiometric();
      } else {
        await StorageService.disableBiometric();
      }
      notifyListeners();
    } catch (e) {
      _setError('Error al configurar login biométrico: $e');
    }
  }

  // Logout
  Future<void> logout({bool keepBiometricCredentials = false}) async {
    try {
      _setStatus(AuthStatus.loading);
      
      await AuthRepository.logout();
      
      // Si el usuario no quiere mantener las credenciales biométricas, eliminarlas
      if (!keepBiometricCredentials) {
        await StorageService.disableBiometric();
      }
      
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
      // Permitir refresh si está autenticado o cargando (durante inicialización)
      if (_status != AuthStatus.authenticated && _status != AuthStatus.loading) return;
      
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
