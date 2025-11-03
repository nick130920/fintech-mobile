import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

/// Servicio para obtener tasas de cambio de divisas usando freecurrencyapi.com
/// 
/// API Documentation: https://freecurrencyapi.com/docs/
/// 
/// Características:
/// - Tasas de cambio en tiempo real
/// - Cache local para reducir llamadas API
/// - Soporte para modo offline con últimas tasas conocidas
class ExchangeRateService {
  // API Configuration
  static String get _apiKey => ApiConfig.freeCurrencyApiKey;
  static String get _baseUrl => ApiConfig.freeCurrencyApiBaseUrl;
  
  static const String _cacheKey = 'exchange_rates_cache';
  static const String _cacheTimestampKey = 'exchange_rates_timestamp';
  static const Duration _cacheDuration = Duration(hours: 1);

  /// Obtener tasas de cambio actuales
  /// 
  /// [baseCurrency] - Divisa base (default: USD)
  /// [targetCurrencies] - Lista de divisas objetivo. Si está vacío, obtiene todas.
  /// 
  /// Returns: Map de código de divisa a tasa de cambio
  static Future<Map<String, double>> getExchangeRates({
    String baseCurrency = 'USD',
    List<String>? targetCurrencies,
  }) async {
    try {
      // Verificar cache primero
      final cachedRates = await _getCachedRates(baseCurrency);
      if (cachedRates != null) {
        debugPrint('💰 Using cached exchange rates');
        return cachedRates;
      }

      // Construir URL
      final uri = Uri.parse('$_baseUrl/latest').replace(queryParameters: {
        'apikey': _apiKey,
        'base_currency': baseCurrency,
        if (targetCurrencies != null && targetCurrencies.isNotEmpty)
          'currencies': targetCurrencies.join(','),
      });

      debugPrint('📡 Fetching exchange rates from API');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // La API retorna: { "data": { "EUR": 0.85, "GBP": 0.73, ... } }
        final rates = <String, double>{};
        final dataMap = data['data'] as Map<String, dynamic>;
        
        dataMap.forEach((key, value) {
          rates[key] = (value as num).toDouble();
        });

        // Guardar en cache
        await _cacheRates(baseCurrency, rates);
        
        debugPrint('✅ Exchange rates updated: ${rates.length} currencies');
        return rates;
      } else if (response.statusCode == 429) {
        // Rate limit excedido
        debugPrint('⚠️ API rate limit exceeded, using cached data');
        final fallbackRates = await _getCachedRates(baseCurrency, ignoreExpiry: true);
        return fallbackRates ?? {};
      } else {
        throw Exception('Failed to load exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching exchange rates: $e');
      
      // Intentar usar cache aunque esté expirado
      final fallbackRates = await _getCachedRates(baseCurrency, ignoreExpiry: true);
      if (fallbackRates != null) {
        debugPrint('💾 Using expired cache as fallback');
        return fallbackRates;
      }
      
      rethrow;
    }
  }

  /// Convertir cantidad de una divisa a otra
  /// 
  /// [amount] - Cantidad a convertir
  /// [fromCurrency] - Código de divisa origen
  /// [toCurrency] - Código de divisa destino
  static Future<double> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) {
      return amount;
    }

    try {
      final rates = await getExchangeRates(baseCurrency: fromCurrency);
      
      if (rates.containsKey(toCurrency)) {
        final rate = rates[toCurrency]!;
        return amount * rate;
      } else {
        throw Exception('Exchange rate not found for $toCurrency');
      }
    } catch (e) {
      debugPrint('Error converting currency: $e');
      rethrow;
    }
  }

  /// Obtener lista de todas las divisas soportadas
  static Future<List<String>> getSupportedCurrencies() async {
    try {
      final uri = Uri.parse('$_baseUrl/currencies').replace(queryParameters: {
        'apikey': _apiKey,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final currencies = <String>[];
        
        // La API retorna: { "data": { "USD": {...}, "EUR": {...}, ... } }
        final dataMap = data['data'] as Map<String, dynamic>;
        currencies.addAll(dataMap.keys);
        
        return currencies;
      } else {
        throw Exception('Failed to load currencies');
      }
    } catch (e) {
      debugPrint('Error fetching supported currencies: $e');
      return [];
    }
  }

  /// Verificar si la API key está configurada
  static bool isApiKeyConfigured() {
    return ApiConfig.isFreeCurrencyApiConfigured;
  }

  // CACHE MANAGEMENT

  static Future<Map<String, double>?> _getCachedRates(
    String baseCurrency, {
    bool ignoreExpiry = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('${_cacheKey}_$baseCurrency');
      final timestamp = prefs.getInt('${_cacheTimestampKey}_$baseCurrency');

      if (cachedData == null || timestamp == null) {
        return null;
      }

      // Verificar si el cache ha expirado
      if (!ignoreExpiry) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        
        if (now.difference(cacheTime) > _cacheDuration) {
          debugPrint('🕐 Cache expired, will fetch new rates');
          return null;
        }
      }

      final Map<String, dynamic> data = jsonDecode(cachedData);
      final rates = <String, double>{};
      
      data.forEach((key, value) {
        rates[key] = (value as num).toDouble();
      });

      return rates;
    } catch (e) {
      debugPrint('Error reading cached rates: $e');
      return null;
    }
  }

  static Future<void> _cacheRates(
    String baseCurrency,
    Map<String, double> rates,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(rates);
      
      await prefs.setString('${_cacheKey}_$baseCurrency', data);
      await prefs.setInt(
        '${_cacheTimestampKey}_$baseCurrency',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Error caching rates: $e');
    }
  }

  /// Limpiar todo el cache de tasas de cambio
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_cacheKey) || key.startsWith(_cacheTimestampKey)) {
          await prefs.remove(key);
        }
      }
      
      debugPrint('🗑️ Exchange rate cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Obtener información de las tasas de cambio cacheadas
  static Future<CacheInfo?> getCacheInfo(String baseCurrency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('${_cacheTimestampKey}_$baseCurrency');
      
      if (timestamp == null) return null;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final age = DateTime.now().difference(cacheTime);
      final isExpired = age > _cacheDuration;
      
      return CacheInfo(
        lastUpdate: cacheTime,
        age: age,
        isExpired: isExpired,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Información sobre el cache de tasas de cambio
class CacheInfo {
  final DateTime lastUpdate;
  final Duration age;
  final bool isExpired;

  CacheInfo({
    required this.lastUpdate,
    required this.age,
    required this.isExpired,
  });

  String get formattedAge {
    if (age.inMinutes < 60) {
      return 'Hace ${age.inMinutes} minutos';
    } else if (age.inHours < 24) {
      return 'Hace ${age.inHours} horas';
    } else {
      return 'Hace ${age.inDays} días';
    }
  }
}

