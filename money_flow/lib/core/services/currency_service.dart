import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final int decimals;
  final String? country;
  final String? flag;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    this.decimals = 2,
    this.country,
    this.flag,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'symbol': symbol,
    'name': name,
    'decimals': decimals,
    'country': country ?? '',
    'flag': flag ?? '',
  };

  factory CurrencyInfo.fromJson(Map<String, dynamic> json) => CurrencyInfo(
    code: json['iso_code'] ?? json['code'] ?? '',
    symbol: json['symbol'] ?? '',
    name: json['name'] ?? '',
    decimals: json['decimals'] ?? 2,
    country: json['country'] as String?,
    flag: json['flag'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyInfo &&
      runtimeType == other.runtimeType &&
      code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class CurrencyService {
  static const String _currencyKey = 'selected_currency';
  static const String _catalogCacheKey = 'currency_catalog_cache';
  static const String _catalogCacheTimestamp = 'currency_catalog_ts';

  static List<CurrencyInfo>? _cachedCatalog;

  static const _countryToCurrency = <String, String>{
    'US': 'USD', 'CA': 'CAD', 'MX': 'MXN',
    'CO': 'COP', 'AR': 'ARS', 'BR': 'BRL', 'PE': 'PEN', 'CL': 'CLP',
    'UY': 'UYU', 'PY': 'PYG', 'BO': 'BOB', 'EC': 'USD', 'VE': 'VES',
    'CR': 'CRC', 'PA': 'USD', 'GT': 'GTQ', 'HN': 'HNL', 'NI': 'NIO',
    'DO': 'DOP', 'CU': 'CUP', 'JM': 'JMD', 'TT': 'TTD',
    'ES': 'EUR', 'FR': 'EUR', 'DE': 'EUR', 'IT': 'EUR', 'PT': 'EUR',
    'NL': 'EUR', 'BE': 'EUR', 'AT': 'EUR', 'IE': 'EUR', 'FI': 'EUR',
    'GR': 'EUR', 'SK': 'EUR', 'SI': 'EUR', 'EE': 'EUR', 'LV': 'EUR',
    'LT': 'EUR', 'CY': 'EUR', 'MT': 'EUR', 'LU': 'EUR',
    'GB': 'GBP', 'CH': 'CHF', 'SE': 'SEK', 'NO': 'NOK', 'DK': 'DKK',
    'PL': 'PLN', 'CZ': 'CZK', 'HU': 'HUF', 'RO': 'RON', 'BG': 'BGN',
    'HR': 'HRK', 'RS': 'RSD', 'UA': 'UAH', 'RU': 'RUB', 'TR': 'TRY',
    'JP': 'JPY', 'CN': 'CNY', 'IN': 'INR', 'KR': 'KRW', 'TH': 'THB',
    'ID': 'IDR', 'MY': 'MYR', 'SG': 'SGD', 'PH': 'PHP', 'VN': 'VND',
    'TW': 'TWD', 'HK': 'HKD', 'PK': 'PKR', 'BD': 'BDT', 'LK': 'LKR',
    'KH': 'KHR', 'MM': 'MMK', 'NP': 'NPR', 'KZ': 'KZT',
    'AU': 'AUD', 'NZ': 'NZD', 'FJ': 'FJD',
    'ZA': 'ZAR', 'NG': 'NGN', 'KE': 'KES', 'EG': 'EGP', 'MA': 'MAD',
    'GH': 'GHS', 'TZ': 'TZS', 'UG': 'UGX', 'ET': 'ETB', 'DZ': 'DZD',
    'SA': 'SAR', 'AE': 'AED', 'QA': 'QAR', 'KW': 'KWD', 'BH': 'BHD',
    'OM': 'OMR', 'JO': 'JOD', 'IQ': 'IQD', 'IL': 'ILS', 'LB': 'LBP',
  };

  static final _countryFlags = <String, String>{
    'US': '\u{1F1FA}\u{1F1F8}', 'CA': '\u{1F1E8}\u{1F1E6}', 'MX': '\u{1F1F2}\u{1F1FD}',
    'CO': '\u{1F1E8}\u{1F1F4}', 'AR': '\u{1F1E6}\u{1F1F7}', 'BR': '\u{1F1E7}\u{1F1F7}',
    'PE': '\u{1F1F5}\u{1F1EA}', 'CL': '\u{1F1E8}\u{1F1F1}', 'GB': '\u{1F1EC}\u{1F1E7}',
    'JP': '\u{1F1EF}\u{1F1F5}', 'CN': '\u{1F1E8}\u{1F1F3}', 'IN': '\u{1F1EE}\u{1F1F3}',
    'KR': '\u{1F1F0}\u{1F1F7}', 'AU': '\u{1F1E6}\u{1F1FA}', 'CH': '\u{1F1E8}\u{1F1ED}',
    'ES': '\u{1F1EA}\u{1F1F8}', 'DE': '\u{1F1E9}\u{1F1EA}', 'FR': '\u{1F1EB}\u{1F1F7}',
    'ZA': '\u{1F1FF}\u{1F1E6}', 'TR': '\u{1F1F9}\u{1F1F7}',
  };

  static final _popularCodes = [
    'USD', 'EUR', 'MXN', 'COP', 'ARS', 'BRL', 'GBP', 'JPY',
    'CAD', 'CLP', 'PEN', 'CRC', 'DOP',
  ];

  static const CurrencyInfo defaultCurrency = CurrencyInfo(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    decimals: 2,
    country: 'Estados Unidos',
    flag: '\u{1F1FA}\u{1F1F8}',
  );

  static List<CurrencyInfo> get popularCurrencies {
    if (_cachedCatalog != null) {
      final byCode = <String, CurrencyInfo>{};
      for (final c in _cachedCatalog!) {
        byCode[c.code] = c;
      }
      return _popularCodes
          .where((code) => byCode.containsKey(code))
          .map((code) => byCode[code]!)
          .toList();
    }
    return _fallbackPopular;
  }

  static List<CurrencyInfo> get allCurrencies {
    if (_cachedCatalog != null) {
      return List.unmodifiable(_cachedCatalog!);
    }
    return _fallbackPopular;
  }

  static Future<List<CurrencyInfo>> fetchCatalogFromBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getInt(_catalogCacheTimestamp) ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - ts;

      if (age < const Duration(hours: 24).inMilliseconds && _cachedCatalog != null) {
        return _cachedCatalog!;
      }

      final cachedJson = prefs.getString(_catalogCacheKey);
      if (age < const Duration(hours: 24).inMilliseconds && cachedJson != null) {
        _cachedCatalog = _parseCatalog(cachedJson);
        return _cachedCatalog!;
      }

      final response = await ApiService.get('/currencies');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> items = body['data'] ?? [];
        _cachedCatalog = items.map((e) => CurrencyInfo.fromJson(e as Map<String, dynamic>)).toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        await prefs.setString(_catalogCacheKey, jsonEncode(items));
        await prefs.setInt(_catalogCacheTimestamp, DateTime.now().millisecondsSinceEpoch);

        return _cachedCatalog!;
      }

      if (cachedJson != null) {
        _cachedCatalog = _parseCatalog(cachedJson);
        return _cachedCatalog!;
      }
    } catch (e) {
      debugPrint('Error fetching currency catalog: $e');
    }
    return _fallbackPopular;
  }

  static List<CurrencyInfo> _parseCatalog(String jsonStr) {
    final List<dynamic> items = jsonDecode(jsonStr);
    return items.map((e) => CurrencyInfo.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Detecta la moneda según la IP del cliente consultando el backend.
  /// No requiere ningún permiso. Devuelve null si falla.
  static Future<String?> detectCurrencyFromIP() async {
    try {
      final response = await ApiService.get('/geo/country', timeout: const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final currencyCode = data['currency_code'] as String?;
        if (currencyCode != null && currencyCode != 'USD') return currencyCode;
      }
    } catch (_) {}
    return null;
  }

  static Future<CurrencyInfo> detectCurrencyFromLocation() async {
    try {
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) return defaultCurrency;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final countryCode = placemarks.first.isoCountryCode?.toUpperCase();
        if (countryCode != null) {
          final currencyCode = _countryToCurrency[countryCode];
          if (currencyCode != null) {
            return getCurrencyByCode(currencyCode) ?? defaultCurrency;
          }
        }
      }
    } catch (e) {
      debugPrint('Error detecting currency from location: $e');
    }
    return defaultCurrency;
  }

  static Future<bool> _requestLocationPermission() async {
    try {
      final status = await Permission.location.status;
      if (status.isGranted) return true;
      if (status.isDenied) {
        final result = await Permission.location.request();
        return result.isGranted;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> saveCurrency(CurrencyInfo currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, jsonEncode(currency.toJson()));
  }

  static Future<CurrencyInfo> getSavedCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currencyJson = prefs.getString(_currencyKey);
      if (currencyJson != null) {
        final data = jsonDecode(currencyJson) as Map<String, dynamic>;
        return CurrencyInfo.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error loading saved currency: $e');
    }
    return defaultCurrency;
  }

  static String formatAmount(double amount, CurrencyInfo currency) {
    try {
      final formatter = NumberFormat.currency(
        symbol: currency.symbol,
        decimalDigits: currency.decimals,
      );
      return formatter.format(amount);
    } catch (e) {
      return '${currency.symbol} ${amount.toStringAsFixed(currency.decimals)}';
    }
  }

  static String formatAmountByCode(double amount, String code) {
    final info = getCurrencyByCode(code);
    if (info != null) {
      return formatAmount(amount, info);
    }
    try {
      final formatter = NumberFormat.simpleCurrency(name: code);
      return formatter.format(amount);
    } catch (_) {
      return '${amount.toStringAsFixed(2)} $code';
    }
  }

  static CurrencyInfo? getCurrencyByCode(String code) {
    if (_cachedCatalog != null) {
      for (final c in _cachedCatalog!) {
        if (c.code == code) return c;
      }
    }
    for (final c in _fallbackPopular) {
      if (c.code == code) return c;
    }
    return null;
  }

  static String? getFlagForCode(String code) {
    for (final entry in _countryToCurrency.entries) {
      if (entry.value == code && _countryFlags.containsKey(entry.key)) {
        return _countryFlags[entry.key];
      }
    }
    return null;
  }

  static List<CurrencyInfo> searchCurrencies(String query) {
    final lq = query.toLowerCase();
    final source = _cachedCatalog ?? _fallbackPopular;
    return source
        .where((c) =>
            c.name.toLowerCase().contains(lq) ||
            c.code.toLowerCase().contains(lq) ||
            (c.country?.toLowerCase().contains(lq) ?? false))
        .toList();
  }

  static Future<bool> isLocationAvailable() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
             permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  static final _fallbackPopular = <CurrencyInfo>[
    const CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar', decimals: 2, country: 'Estados Unidos', flag: '\u{1F1FA}\u{1F1F8}'),
    const CurrencyInfo(code: 'EUR', symbol: '\u{20AC}', name: 'Euro', decimals: 2, country: 'Europa', flag: '\u{1F1EA}\u{1F1FA}'),
    const CurrencyInfo(code: 'MXN', symbol: '\$', name: 'Mexican Peso', decimals: 2, country: 'M\u{00E9}xico', flag: '\u{1F1F2}\u{1F1FD}'),
    const CurrencyInfo(code: 'COP', symbol: '\$', name: 'Colombian Peso', decimals: 0, country: 'Colombia', flag: '\u{1F1E8}\u{1F1F4}'),
    const CurrencyInfo(code: 'ARS', symbol: '\$', name: 'Argentine Peso', decimals: 2, country: 'Argentina', flag: '\u{1F1E6}\u{1F1F7}'),
    const CurrencyInfo(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real', decimals: 2, country: 'Brasil', flag: '\u{1F1E7}\u{1F1F7}'),
    const CurrencyInfo(code: 'GBP', symbol: '\u{00A3}', name: 'British Pound', decimals: 2, country: 'Reino Unido', flag: '\u{1F1EC}\u{1F1E7}'),
    const CurrencyInfo(code: 'JPY', symbol: '\u{00A5}', name: 'Japanese Yen', decimals: 0, country: 'Jap\u{00F3}n', flag: '\u{1F1EF}\u{1F1F5}'),
    const CurrencyInfo(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar', decimals: 2, country: 'Canad\u{00E1}', flag: '\u{1F1E8}\u{1F1E6}'),
    const CurrencyInfo(code: 'CLP', symbol: '\$', name: 'Chilean Peso', decimals: 0, country: 'Chile', flag: '\u{1F1E8}\u{1F1F1}'),
    const CurrencyInfo(code: 'PEN', symbol: 'S/', name: 'Peruvian Sol', decimals: 2, country: 'Per\u{00FA}', flag: '\u{1F1F5}\u{1F1EA}'),
    const CurrencyInfo(code: 'CRC', symbol: '\u{20A1}', name: 'Costa Rican Col\u{00F3}n', decimals: 2, country: 'Costa Rica', flag: '\u{1F1E8}\u{1F1F7}'),
    const CurrencyInfo(code: 'DOP', symbol: 'RD\$', name: 'Dominican Peso', decimals: 2, country: 'Rep\u{00FA}blica Dominicana', flag: '\u{1F1E9}\u{1F1F4}'),
    const CurrencyInfo(code: 'INR', symbol: '\u{20B9}', name: 'Indian Rupee', decimals: 2, country: 'India', flag: '\u{1F1EE}\u{1F1F3}'),
    const CurrencyInfo(code: 'KRW', symbol: '\u{20A9}', name: 'South Korean Won', decimals: 0, country: 'Corea del Sur', flag: '\u{1F1F0}\u{1F1F7}'),
    const CurrencyInfo(code: 'CNY', symbol: '\u{00A5}', name: 'Chinese Yuan', decimals: 2, country: 'China', flag: '\u{1F1E8}\u{1F1F3}'),
  ];
}
