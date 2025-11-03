import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final String country;
  final String flag;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.country,
    required this.flag,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'symbol': symbol,
    'name': name,
    'country': country,
    'flag': flag,
  };

  factory CurrencyInfo.fromJson(Map<String, dynamic> json) => CurrencyInfo(
    code: json['code'],
    symbol: json['symbol'],
    name: json['name'],
    country: json['country'],
    flag: json['flag'],
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
  
  // Mapa de países/regiones a divisas principales
  static final Map<String, CurrencyInfo> _currencyByCountry = {
    // América del Norte
    'US': const CurrencyInfo(code: 'USD', symbol: '\$', name: 'Dólar Estadounidense', country: 'Estados Unidos', flag: '🇺🇸'),
    'CA': const CurrencyInfo(code: 'CAD', symbol: 'C\$', name: 'Dólar Canadiense', country: 'Canadá', flag: '🇨🇦'),
    'MX': const CurrencyInfo(code: 'MXN', symbol: '\$', name: 'Peso Mexicano', country: 'México', flag: '🇲🇽'),
    
    // América del Sur
    'CO': const CurrencyInfo(code: 'COP', symbol: '\$', name: 'Peso Colombiano', country: 'Colombia', flag: '🇨🇴'),
    'AR': const CurrencyInfo(code: 'ARS', symbol: '\$', name: 'Peso Argentino', country: 'Argentina', flag: '🇦🇷'),
    'BR': const CurrencyInfo(code: 'BRL', symbol: 'R\$', name: 'Real Brasileño', country: 'Brasil', flag: '🇧🇷'),
    'PE': const CurrencyInfo(code: 'PEN', symbol: 'S/', name: 'Sol Peruano', country: 'Perú', flag: '🇵🇪'),
    'CL': const CurrencyInfo(code: 'CLP', symbol: '\$', name: 'Peso Chileno', country: 'Chile', flag: '🇨🇱'),
    
    // Europa
    'ES': const CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro', country: 'España', flag: '🇪🇸'),
    'FR': const CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro', country: 'Francia', flag: '🇫🇷'),
    'DE': const CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro', country: 'Alemania', flag: '🇩🇪'),
    'IT': const CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro', country: 'Italia', flag: '🇮🇹'),
    'GB': const CurrencyInfo(code: 'GBP', symbol: '£', name: 'Libra Esterlina', country: 'Reino Unido', flag: '🇬🇧'),
    
    // Asia
    'JP': const CurrencyInfo(code: 'JPY', symbol: '¥', name: 'Yen Japonés', country: 'Japón', flag: '🇯🇵'),
    'CN': const CurrencyInfo(code: 'CNY', symbol: '¥', name: 'Yuan Chino', country: 'China', flag: '🇨🇳'),
    'IN': const CurrencyInfo(code: 'INR', symbol: '₹', name: 'Rupia India', country: 'India', flag: '🇮🇳'),
    'KR': const CurrencyInfo(code: 'KRW', symbol: '₩', name: 'Won Surcoreano', country: 'Corea del Sur', flag: '🇰🇷'),
  };

  // Divisas más populares para el selector
  static List<CurrencyInfo> get popularCurrencies => [
    _currencyByCountry['US']!,    // Dólar Estadounidense
    _currencyByCountry['ES']!,    // Euro
    _currencyByCountry['MX']!,    // Peso Mexicano
    _currencyByCountry['CO']!,    // Peso Colombiano
    _currencyByCountry['AR']!,    // Peso Argentino
    _currencyByCountry['BR']!,    // Real Brasileño
    _currencyByCountry['GB']!,    // Libra Esterlina
    _currencyByCountry['JP']!,    // Yen Japonés
  ];

  // Obtener todas las divisas disponibles (sin duplicados por código)
  static List<CurrencyInfo> get allCurrencies {
    final uniqueCurrencies = <String, CurrencyInfo>{};
    
    for (final currency in _currencyByCountry.values) {
      uniqueCurrencies[currency.code] = currency;
    }
    
    return uniqueCurrencies.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // Divisa por defecto (USD)
  static const CurrencyInfo defaultCurrency = CurrencyInfo(
    code: 'USD',
    symbol: '\$',
    name: 'Dólar Estadounidense',
    country: 'Estados Unidos',
    flag: '🇺🇸',
  );

  // Detectar divisa basada en ubicación
  static Future<CurrencyInfo> detectCurrencyFromLocation() async {
    try {
      // Verificar permisos
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        return defaultCurrency;
      }

      // Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Usar geocoding inverso para obtener el país
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final countryCode = placemarks.first.isoCountryCode?.toUpperCase();
        if (countryCode != null && _currencyByCountry.containsKey(countryCode)) {
          return _currencyByCountry[countryCode]!;
        }
      }
    } catch (e) {
      // En caso de error, usar divisa por defecto
      debugPrint('Error detecting currency from location: $e');
    }

    return defaultCurrency;
  }

  // Solicitar permisos de ubicación
  static Future<bool> _requestLocationPermission() async {
    try {
      final status = await Permission.location.status;
      
      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.location.request();
        return result.isGranted;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Guardar divisa seleccionada
  static Future<void> saveCurrency(CurrencyInfo currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, jsonEncode(currency.toJson()));
  }

  // Obtener divisa guardada
  static Future<CurrencyInfo> getSavedCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currencyJson = prefs.getString(_currencyKey);
      
      if (currencyJson != null) {
        final currencyData = jsonDecode(currencyJson);
        return CurrencyInfo.fromJson(currencyData);
      }
    } catch (e) {
      debugPrint('Error loading saved currency: $e');
    }

    return defaultCurrency;
  }

  // Formatear cantidad según divisa
  static String formatAmount(double amount, CurrencyInfo currency) {
    try {
      // Obtener el número de decimales según la divisa
      final int decimalDigits;
      switch (currency.code) {
        case 'JPY':
        case 'KRW':
        case 'COP':
          decimalDigits = 0;
          break;
        default:
          decimalDigits = 2;
      }

      // Formatear el número sin símbolo de moneda
      final NumberFormat numberFormatter = NumberFormat.decimalPattern();
      numberFormatter.minimumFractionDigits = decimalDigits;
      numberFormatter.maximumFractionDigits = decimalDigits;
      
      final formattedNumber = numberFormatter.format(amount);
      
      // Retornar con símbolo al lado izquierdo con espacio
      return '${currency.symbol} $formattedNumber';
    } catch (e) {
      // Fallback a formato simple
      final decimals = (currency.code == 'JPY' || currency.code == 'KRW' || currency.code == 'COP') ? 0 : 2;
      return '${currency.symbol} ${amount.toStringAsFixed(decimals)}';
    }
  }

  // Obtener divisa por código
  static CurrencyInfo? getCurrencyByCode(String code) {
    return _currencyByCountry.values
        .where((currency) => currency.code == code)
        .firstOrNull;
  }

  // Buscar divisas por nombre o país
  static List<CurrencyInfo> searchCurrencies(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _currencyByCountry.values
        .where((currency) => 
            currency.name.toLowerCase().contains(lowercaseQuery) ||
            currency.country.toLowerCase().contains(lowercaseQuery) ||
            currency.code.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Verificar si la ubicación está disponible
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
}
