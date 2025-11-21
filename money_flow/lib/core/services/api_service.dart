import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../app/app_wrapper.dart';

class ApiService {
  static const String _baseUrl = 'https://fintech-production-5841.up.railway.app';
  static const String _apiVersion = '/api/v1';
  
  static GlobalKey<NavigatorState>? _navigatorKey;
  
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
  
  // Wrapper para manejar todas las peticiones y sus errores
  static Future<http.Response> _handleRequest(Future<http.Response> Function() request) async {
    try {
      final response = await request();
      if (response.statusCode == 401) {
        // Token expirado o inválido
        await _handleUnauthorized();
        // Lanzar una excepción para que la lógica de negocio no continúe
        throw Exception('Sesión expirada');
      }
      return response;
    } on SocketException {
      throw Exception('No hay conexión a internet');
    } on HttpException {
      throw Exception('Error en la conexión');
    } catch (e) {
      // Re-lanzar la excepción si ya es del tipo correcto
      if (e.toString().contains('Sesión expirada')) {
        throw Exception('Sesión expirada');
      }
      throw Exception('Error inesperado: $e');
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
        
        // Si estamos en proceso de carga/inicialización, no necesitamos navegar
        // porque el AppWrapper manejará el cambio de estado automáticamente
        // y evitaremos un bucle de navegación/animación
        if (authProvider.status == AuthStatus.loading || 
            authProvider.status == AuthStatus.initial) {
          await authProvider.logout();
          return;
        }

        await authProvider.logout();
        
        // Asegurarse de que el widget está montado antes de navegar
        if (_navigatorKey?.currentState != null) {
           _navigatorKey?.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AppWrapper()),
            (route) => false,
          );
        }
      }
    } finally {
      // Reset flag after a delay to prevent bouncing
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
}
