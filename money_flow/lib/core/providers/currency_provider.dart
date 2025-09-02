import 'package:flutter/foundation.dart';

import '../services/currency_service.dart';

class CurrencyProvider with ChangeNotifier {
  CurrencyInfo _selectedCurrency = CurrencyService.defaultCurrency;
  CurrencyInfo get selectedCurrency => _selectedCurrency;

  bool _isDetecting = false;
  bool get isDetecting => _isDetecting;

  bool _hasDetectedLocation = false;
  bool get hasDetectedLocation => _hasDetectedLocation;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Inicializar provider
  Future<void> initialize() async {
    _setDetecting(true);
    
    try {
      // Primero intentar cargar divisa guardada
      final savedCurrency = await CurrencyService.getSavedCurrency();
      _selectedCurrency = savedCurrency;
      
      // Si es la divisa por defecto, intentar detectar por ubicación
      if (_selectedCurrency.code == CurrencyService.defaultCurrency.code) {
        await _detectCurrencyFromLocation();
      }
      
      _clearError();
    } catch (e) {
      _setError('Error al cargar configuración de divisa: $e');
    }
    
    _setDetecting(false);
  }

  // Detectar divisa basada en ubicación
  Future<void> _detectCurrencyFromLocation() async {
    try {
      final detectedCurrency = await CurrencyService.detectCurrencyFromLocation();
      
      // Solo cambiar si se detectó una divisa diferente
      if (detectedCurrency.code != CurrencyService.defaultCurrency.code) {
        _selectedCurrency = detectedCurrency;
        _hasDetectedLocation = true;
        
        // Guardar automáticamente la divisa detectada
        await CurrencyService.saveCurrency(detectedCurrency);
      }
    } catch (e) {
      _setError('No se pudo detectar tu ubicación para la divisa');
    }
  }

  // Cambiar divisa manualmente
  Future<void> setCurrency(CurrencyInfo currency) async {
    try {
      _selectedCurrency = currency;
      await CurrencyService.saveCurrency(currency);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Error al guardar divisa: $e');
    }
  }

  // Formatear cantidad con la divisa actual
  String formatAmount(double amount) {
    return CurrencyService.formatAmount(amount, _selectedCurrency);
  }

  // Formatear cantidad compacta (para espacios pequeños)
  String formatAmountCompact(double amount) {
    if (amount >= 1000000) {
      return '${_selectedCurrency.symbol}${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${_selectedCurrency.symbol}${(amount / 1000).toStringAsFixed(1)}K';
    }
    return CurrencyService.formatAmount(amount, _selectedCurrency);
  }

  // Obtener símbolo de divisa actual
  String get currencySymbol => _selectedCurrency.symbol;

  // Obtener código de divisa actual
  String get currencyCode => _selectedCurrency.code;

  // Obtener nombre completo de divisa
  String get currencyDisplayName => '${_selectedCurrency.flag} ${_selectedCurrency.name}';

  // Verificar si es una divisa sin decimales
  bool get isNoDecimalCurrency => 
      _selectedCurrency.code == 'JPY' || _selectedCurrency.code == 'KRW' || _selectedCurrency.code == 'COP';

  // Redondear cantidad según tipo de divisa
  double roundAmount(double amount) {
    if (isNoDecimalCurrency) {
      return amount.roundToDouble();
    }
    return double.parse(amount.toStringAsFixed(2));
  }

  // Reintentar detección de ubicación
  Future<void> retryLocationDetection() async {
    _setDetecting(true);
    await _detectCurrencyFromLocation();
    _setDetecting(false);
  }

  // Helpers de estado
  void _setDetecting(bool detecting) {
    _isDetecting = detecting;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Método para testing/desarrollo
  void setTestCurrency(CurrencyInfo currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }
}
