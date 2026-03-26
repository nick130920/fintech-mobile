import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

/// Servicio de tasas de cambio via backend (Frankfurter v2).
/// El backend cachea las tasas 24h; este servicio cachea localmente 1h.
class ExchangeRateService {
  static const String _cacheKey = 'fx_rates_cache';
  static const String _cacheTimestampKey = 'fx_rates_ts';
  static const Duration _cacheDuration = Duration(hours: 1);

  static Future<Map<String, double>> getExchangeRates({
    String baseCurrency = 'USD',
    List<String>? targetCurrencies,
  }) async {
    try {
      final cached = await _getCachedRates(baseCurrency);
      if (cached != null) return cached;

      var endpoint = '/exchange-rates?base=$baseCurrency';
      if (targetCurrencies != null && targetCurrencies.isNotEmpty) {
        endpoint += '&symbols=${targetCurrencies.join(",")}';
      }

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> ratesList = body['rates'] ?? [];
        final rates = <String, double>{};
        for (final item in ratesList) {
          final quote = item['quote'] as String?;
          final rate = item['rate'];
          if (quote != null && rate != null) {
            rates[quote] = (rate as num).toDouble();
          }
        }

        await _cacheRates(baseCurrency, rates);
        debugPrint('Exchange rates updated: ${rates.length} currencies');
        return rates;
      } else {
        final fallback = await _getCachedRates(baseCurrency, ignoreExpiry: true);
        return fallback ?? {};
      }
    } catch (e) {
      debugPrint('Error fetching exchange rates: $e');
      final fallback = await _getCachedRates(baseCurrency, ignoreExpiry: true);
      if (fallback != null) return fallback;
      rethrow;
    }
  }

  static Future<double> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return amount;

    final rates = await getExchangeRates(baseCurrency: fromCurrency);
    if (rates.containsKey(toCurrency)) {
      return amount * rates[toCurrency]!;
    }
    throw Exception('Exchange rate not found for $toCurrency');
  }

  /// Convierte un monto si tiene tasa; si falla, devuelve null.
  static Future<double?> tryConvert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return amount;
    try {
      return await convertCurrency(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
    } catch (_) {
      return null;
    }
  }

  static bool isApiKeyConfigured() => true;

  // Cache local
  static Future<Map<String, double>?> _getCachedRates(
    String baseCurrency, {
    bool ignoreExpiry = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('${_cacheKey}_$baseCurrency');
      final ts = prefs.getInt('${_cacheTimestampKey}_$baseCurrency');
      if (data == null || ts == null) return null;

      if (!ignoreExpiry) {
        final age = DateTime.now().millisecondsSinceEpoch - ts;
        if (age > _cacheDuration.inMilliseconds) return null;
      }

      final Map<String, dynamic> parsed = jsonDecode(data);
      return parsed.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (e) {
      debugPrint('Error reading cached rates: $e');
      return null;
    }
  }

  static Future<void> _cacheRates(String baseCurrency, Map<String, double> rates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_cacheKey}_$baseCurrency', jsonEncode(rates));
      await prefs.setInt('${_cacheTimestampKey}_$baseCurrency', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error caching rates: $e');
    }
  }

  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where(
        (k) => k.startsWith(_cacheKey) || k.startsWith(_cacheTimestampKey),
      );
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  static Future<CacheInfo?> getCacheInfo(String baseCurrency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getInt('${_cacheTimestampKey}_$baseCurrency');
      if (ts == null) return null;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(ts);
      final age = DateTime.now().difference(cacheTime);

      return CacheInfo(
        lastUpdate: cacheTime,
        age: age,
        isExpired: age > _cacheDuration,
      );
    } catch (e) {
      return null;
    }
  }
}

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
      return 'Hace ${age.inDays} dias';
    }
  }
}
