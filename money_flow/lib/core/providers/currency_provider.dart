import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
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

  Future<void> initialize() async {
    _setDetecting(true);

    try {
      await CurrencyService.fetchCatalogFromBackend();

      final savedCurrency = await CurrencyService.getSavedCurrency();
      _selectedCurrency = savedCurrency;

      // Si el usuario no tiene moneda guardada, detectar por IP automáticamente
      // (sin pedir ningún permiso al usuario).
      if (_selectedCurrency.code == CurrencyService.defaultCurrency.code) {
        await _detectCurrencyFromIP();
      }

      _clearError();
    } catch (e) {
      _setError('Error al cargar configuracion de divisa: $e');
    }

    _setDetecting(false);
  }

  Future<void> _detectCurrencyFromIP() async {
    try {
      final currencyCode = await CurrencyService.detectCurrencyFromIP();
      if (currencyCode != null) {
        final currency = CurrencyService.getCurrencyByCode(currencyCode);
        if (currency != null && currency.code != CurrencyService.defaultCurrency.code) {
          _selectedCurrency = currency;
          _hasDetectedLocation = true;
          await CurrencyService.saveCurrency(currency);
          notifyListeners();
        }
      }
    } catch (_) {
      // Silencioso: si falla la detección por IP, el usuario elige manualmente.
    }
  }

  // Llamado explícitamente desde el selector cuando el usuario toca "Detectar por ubicación GPS"
  Future<void> _detectCurrencyFromLocation() async {
    try {
      final detectedCurrency = await CurrencyService.detectCurrencyFromLocation();

      if (detectedCurrency.code != CurrencyService.defaultCurrency.code) {
        _selectedCurrency = detectedCurrency;
        _hasDetectedLocation = true;
        await CurrencyService.saveCurrency(detectedCurrency);
      }
    } catch (e) {
      _setError('No se pudo detectar tu ubicacion para la divisa');
    }
  }

  Future<void> setCurrency(CurrencyInfo currency) async {
    try {
      _selectedCurrency = currency;
      await CurrencyService.saveCurrency(currency);
      _clearError();
      notifyListeners();

      // Sincronizar con el backend
      try {
        await AuthRepository.updateProfile({'currency': currency.code});
      } catch (e) {
        debugPrint('Error syncing currency to backend: $e');
      }
    } catch (e) {
      _setError('Error al guardar divisa: $e');
    }
  }

  /// Carga la moneda desde el perfil del usuario del backend.
  /// Llamar despues de login o refreshProfile.
  Future<void> syncFromUser(String currencyCode) async {
    if (currencyCode.isEmpty) return;
    final info = CurrencyService.getCurrencyByCode(currencyCode);
    if (info != null && info.code != _selectedCurrency.code) {
      _selectedCurrency = info;
      await CurrencyService.saveCurrency(info);
      notifyListeners();
    }
  }

  String formatAmount(double amount) {
    return CurrencyService.formatAmount(amount, _selectedCurrency);
  }

  String formatAmountCompact(double amount) {
    if (amount >= 1000000) {
      return '${_selectedCurrency.symbol}${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${_selectedCurrency.symbol}${(amount / 1000).toStringAsFixed(1)}K';
    }
    return CurrencyService.formatAmount(amount, _selectedCurrency);
  }

  /// Formatea un monto usando el codigo ISO del recurso (cuenta/transaccion),
  /// no la preferencia global del usuario.
  String formatAmountWithCode(double amount, String currencyCode) {
    return CurrencyService.formatAmountByCode(amount, currencyCode);
  }

  /// Obtiene el simbolo correcto para un codigo ISO dado.
  String symbolForCode(String code) {
    final info = CurrencyService.getCurrencyByCode(code);
    if (info != null) return info.symbol;
    try {
      return NumberFormat.simpleCurrency(name: code).currencySymbol;
    } catch (_) {
      return code;
    }
  }

  String get currencySymbol => _selectedCurrency.symbol;
  String get currencyCode => _selectedCurrency.code;
  String get currencyDisplayName {
    final flag = _selectedCurrency.flag ?? CurrencyService.getFlagForCode(_selectedCurrency.code) ?? '';
    return '$flag ${_selectedCurrency.name}'.trim();
  }

  bool get isNoDecimalCurrency => _selectedCurrency.decimals == 0;

  bool isNoDecimalForCode(String code) {
    final info = CurrencyService.getCurrencyByCode(code);
    return info?.decimals == 0;
  }

  double roundAmount(double amount) {
    if (isNoDecimalCurrency) {
      return amount.roundToDouble();
    }
    return double.parse(amount.toStringAsFixed(2));
  }

  Future<void> retryLocationDetection() async {
    _setDetecting(true);
    await _detectCurrencyFromLocation();
    _setDetecting(false);
  }

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

  void setTestCurrency(CurrencyInfo currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }
}
