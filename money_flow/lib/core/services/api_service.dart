import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../app/app_wrapper.dart';
import 'storage_service.dart';

class ApiService {
  static const String _baseUrl = 'https://fintech-production-5841.up.railway.app';
  static const String _apiVersion = '/api/v1';
  
  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _isRefreshing = false;
  
  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }
  
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET request
  static Future<http.Response> get(String endpoint, {String? token}) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$_baseUrl$_apiVersion$cleanEndpoint');
    
    final headers = Map<String, String>.from(_defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await _handleRequest(() => http.get(url, headers: headers));
  }

  // POST request
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$_baseUrl$_apiVersion$cleanEndpoint');
    
    final headers = Map<String, String>.from(_defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await _handleRequest(() => http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 30)));
  }

  // PUT request
  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$_baseUrl$_apiVersion$cleanEndpoint');
    
    final headers = Map<String, String>.from(_defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await _handleRequest(() => http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    ));
  }

  // DELETE request
  static Future<http.Response> delete(String endpoint, {String? token}) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$_baseUrl$_apiVersion$cleanEndpoint');
    
    final headers = Map<String, String>.from(_defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await _handleRequest(() => http.delete(url, headers: headers));
  }

  /// POST multipart/form-data with a single file by path (e.g. for analyze-statement). Mobile only.
  static Future<http.Response> postMultipartFile(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    String? token,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$_baseUrl$_apiVersion$cleanEndpoint');

    return await _handleRequest(() async {
      final request = http.MultipartRequest('POST', url);
      request.headers['Accept'] = 'application/json';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      final filename = filePath.split(Platform.pathSeparator).last;
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, filePath, filename: filename),
      );
      final streamed = await request.send();
      return await http.Response.fromStream(streamed);
    });
  }
  
  // Wrapper para manejar todas las peticiones y sus errores
  static Future<http.Response> _handleRequest(Future<http.Response> Function() request, {bool isRetry = false}) async {
    try {
      final response = await request();
      if (response.statusCode == 401 && !isRetry) {
        // Token expirado - intentar renovar
        debugPrint('🔄 Token expirado, intentando renovar...');
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          // Reintentar la petición original con el nuevo token
          debugPrint('✅ Token renovado, reintentando petición...');
          return await _handleRequest(request, isRetry: true);
        } else {
          // No se pudo renovar, cerrar sesión
          debugPrint('❌ No se pudo renovar el token, cerrando sesión...');
          await _handleUnauthorized();
          throw Exception('Sesión expirada');
        }
      } else if (response.statusCode == 401 && isRetry) {
        // Si falla después del retry, cerrar sesión
        await _handleUnauthorized();
        throw Exception('Sesión expirada');
      }
      return response;
    } on SocketException {
      throw Exception('No hay conexión a internet');
    } on HttpException {
      throw Exception('Error en la conexión');
    } catch (e) {
      if (e.toString().contains('Sesión expirada')) {
        throw Exception('Sesión expirada');
      }
      throw Exception('Error inesperado: $e');
    }
  }

  // Intenta renovar el access token usando el refresh token
  static Future<bool> _tryRefreshToken() async {
    if (_isRefreshing) {
      // Ya hay un refresh en progreso, esperar
      await Future.delayed(const Duration(milliseconds: 500));
      final token = await StorageService.getAccessToken();
      return token != null;
    }

    _isRefreshing = true;
    try {
      await AuthRepository.refreshToken();
      debugPrint('✅ Token renovado exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error renovando token: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  static bool _isHandlingAuth = false;

  static Future<void> _handleUnauthorized() async {
    if (_isHandlingAuth) return;
    _isHandlingAuth = true;

    try {
      final context = _navigatorKey?.currentContext;
      if (context != null && context.mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        if (authProvider.status == AuthStatus.loading || 
            authProvider.status == AuthStatus.initial) {
          await authProvider.logout();
          return;
        }

        await authProvider.logout();
        
        if (_navigatorKey?.currentState != null) {
           _navigatorKey?.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AppWrapper()),
            (route) => false,
          );
        }
      }
    } finally {
      await Future.delayed(const Duration(seconds: 1));
      _isHandlingAuth = false;
    }
  }

  // Helper para manejar respuestas de error
  static dynamic handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null; // O un valor por defecto apropiado
      }
      
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('Error al procesar respuesta: ${e.toString()}');
      }
    } else {
      String errorMessage = 'Error en el servidor (${response.statusCode})';
      
      try {
        if (response.body.isNotEmpty) {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        }
      } catch (e) {
        // Si no se puede parsear el error, usar mensaje genérico
        errorMessage = 'Error de comunicación con el servidor';
      }
      
      throw Exception(errorMessage);
    }
  }

  // GET request with URI (for query parameters)
  static Future<http.Response> getUri(Uri uri, {String? token}) async {
    final headers = Map<String, String>.from(_defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await _handleRequest(() => http.get(uri, headers: headers));
  }

  // Base URL getter for external use
  static String get baseUrl => _baseUrl + _apiVersion;

  // POST sin manejo automático de 401 (para refresh token)
  static Future<http.Response> postWithoutRetry(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$_baseUrl$_apiVersion$cleanEndpoint');
    
    final headers = Map<String, String>.from(_defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      return await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
    } on SocketException {
      throw Exception('No hay conexión a internet');
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }
}
