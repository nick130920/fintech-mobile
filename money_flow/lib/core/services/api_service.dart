import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://fintech-production-5841.up.railway.app';
  static const String _apiVersion = '/api/v1';
  
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET request
  static Future<http.Response> get(String endpoint, {String? token}) async {
    // Asegurar que no haya doble barra
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$_baseUrl$_apiVersion$cleanEndpoint');
    
    final headers = Map<String, String>.from(_defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(url, headers: headers);
      return response;
    } on SocketException {
      throw Exception('No hay conexión a internet');
    } on HttpException {
      throw Exception('Error en la conexión');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
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

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      
      return response;
    } on SocketException {
      throw Exception('No hay conexión a internet. Verifica tu conexión.');
    } on HttpException {
      throw Exception('Error en la conexión con el servidor.');
    } on FormatException catch (e) {
      throw Exception('Error en el formato de datos: $e');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
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

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } on SocketException {
      throw Exception('No hay conexión a internet');
    } on HttpException {
      throw Exception('Error en la conexión');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // DELETE request
  static Future<http.Response> delete(String endpoint, {String? token}) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$_baseUrl$_apiVersion$cleanEndpoint');
    
    final headers = Map<String, String>.from(_defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.delete(url, headers: headers);
      return response;
    } on SocketException {
      throw Exception('No hay conexión a internet');
    } on HttpException {
      throw Exception('Error en la conexión');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // Helper para manejar respuestas de error
  static Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        throw Exception('Respuesta vacía del servidor');
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

    try {
      final response = await http.get(uri, headers: headers);
      
      // Convert to expected format
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        String errorMessage = 'Error en el servidor (${response.statusCode})';
        
        try {
          if (response.body.isNotEmpty) {
            final errorBody = jsonDecode(response.body);
            errorMessage = errorBody['message'] ?? errorMessage;
          }
        } catch (e) {
          errorMessage = 'Error de comunicación con el servidor';
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Base URL getter for external use
  static String get baseUrl => _baseUrl + _apiVersion;
}
