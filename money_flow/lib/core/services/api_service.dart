import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:provider/provider.dart';

import '../config/api_security_config.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../app/app_wrapper.dart';
import '../exceptions/temporary_auth_failure_exception.dart';

class ApiService {
  static const String _baseUrl = 'https://fintech-production-5841.up.railway.app';
  static const String _apiVersion = '/api/v1';
  static final http.Client _client = _buildPinnedClient();
  
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// Una sola renovación en vuelo para no invalidar tokens con carreras.
  static Future<TokenRefreshResult>? _refreshInFlight;
  
  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }
  
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static http.Client _buildPinnedClient() {
    final securityContext = SecurityContext(withTrustedRoots: false);
    securityContext.setTrustedCertificatesBytes(
      Uint8List.fromList(
        utf8.encode(ApiSecurityConfig.pinnedLeafCertificatePem),
      ),
    );

    final client = HttpClient(context: securityContext);
    return IOClient(client);
  }

  // GET request
  static Future<http.Response> get(
    String endpoint, {
    String? token,
    Duration? timeout,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$_baseUrl$_apiVersion$cleanEndpoint');
    
    final headers = Map<String, String>.from(_defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    Future<http.Response> doGet() {
      final future = _client.get(url, headers: headers);
      if (timeout != null) {
        return future.timeout(timeout);
      }
      return future;
    }

    return await _handleRequest(doGet);
  }

  /// Timeout por defecto para POST (p. ej. login, crear recurso).
  static const Duration defaultPostTimeout = Duration(seconds: 30);

  // POST request
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
    Duration? timeout,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$_baseUrl$_apiVersion$cleanEndpoint');
    final effectiveTimeout = timeout ?? defaultPostTimeout;

    final headers = Map<String, String>.from(_defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await _handleRequest(() => _client.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    ).timeout(effectiveTimeout));
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

    return await _handleRequest(() => _client.put(
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

    return await _handleRequest(() => _client.delete(url, headers: headers));
  }

  /// POST multipart/form-data with a single file by path (e.g. for analyze-statement). Mobile only.
  static Future<http.Response> postMultipartFile(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    String? token,
    Duration? timeout,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$_baseUrl$_apiVersion$cleanEndpoint');
    final effectiveTimeout = timeout ?? defaultPostTimeout;

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
      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed).timeout(effectiveTimeout);
      return response;
    });
  }
  
  // Wrapper para manejar todas las peticiones y sus errores
  static Future<http.Response> _handleRequest(Future<http.Response> Function() request, {bool isRetry = false}) async {
    try {
      final response = await request();
      if (response.statusCode == 401 && !isRetry) {
        debugPrint('🔄 Token expirado, intentando renovar...');
        final outcome = await _tryRefreshToken();
        if (outcome == TokenRefreshResult.success) {
          debugPrint('✅ Token renovado, reintentando petición...');
          return await _handleRequest(request, isRetry: true);
        }
        if (outcome == TokenRefreshResult.invalidRefreshToken) {
          debugPrint('❌ Refresh inválido, cerrando sesión...');
          await _handleUnauthorized();
          throw Exception('Sesión expirada');
        }
        debugPrint('⚠️ Renovación temporalmente no disponible (red/servidor)');
        throw TemporaryAuthFailureException(
          'No se pudo renovar la sesión. Comprueba tu conexión e inténtalo de nuevo.',
        );
      } else if (response.statusCode == 401 && isRetry) {
        await _handleUnauthorized();
        throw Exception('Sesión expirada');
      }
      return response;
    } on SocketException {
      throw Exception('No hay conexión a internet');
    } on HttpException {
      throw Exception('Error en la conexión');
    } on TimeoutException {
      throw Exception(
        'Tiempo de espera agotado. Si estabas analizando SMS o un extracto, '
        'puede tardar varios minutos; comprueba tu conexión e inténtalo de nuevo.',
      );
    } catch (e) {
      if (e is TemporaryAuthFailureException) {
        rethrow;
      }
      if (e.toString().contains('Sesión expirada')) {
        throw Exception('Sesión expirada');
      }
      throw Exception('Error inesperado: $e');
    }
  }

  static Future<TokenRefreshResult> _tryRefreshToken() {
    _refreshInFlight ??=
        AuthRepository.attemptTokenRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
    return _refreshInFlight!;
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

    return await _handleRequest(() => _client.get(uri, headers: headers));
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
      return await _client.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(defaultPostTimeout);
    } on SocketException {
      throw Exception('No hay conexión a internet');
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }
}
