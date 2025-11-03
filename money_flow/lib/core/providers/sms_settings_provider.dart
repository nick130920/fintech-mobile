import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/sms_settings.dart';
import '../services/preferences_service.dart';

class SmsSettingsProvider with ChangeNotifier {
  static const String _settingsKey = 'sms_settings';
  
  SmsSettings _settings = SmsSettings();
  bool _isInitialized = false;

  SmsSettings get settings => _settings;
  bool get isInitialized => _isInitialized;

  // Getters convenientes
  bool get autoProcessEnabled => _settings.autoProcessEnabled;
  bool get requireActiveBankAccounts => _settings.requireActiveBankAccounts;
  DateTime? get minProcessDate => _settings.minProcessDate;
  SmsProcessMode get processMode => _settings.processMode;
  DateTime? get lastManualSync => _settings.lastManualSync;

  // Inicializar y cargar configuración guardada
  Future<void> initialize() async {
    await loadSettings();
    _isInitialized = true;
    notifyListeners();
  }

  // Cargar configuración desde preferencias
  Future<void> loadSettings() async {
    try {
      final settingsJson = await PreferencesService.getString(_settingsKey);
      if (settingsJson != null && settingsJson.isNotEmpty) {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        _settings = SmsSettings.fromJson(json);
      } else {
        // Usar configuración por defecto
        _settings = SmsSettings();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading SMS settings: $e');
      _settings = SmsSettings();
    }
  }

  // Guardar configuración en preferencias
  Future<void> saveSettings() async {
    try {
      final settingsJson = jsonEncode(_settings.toJson());
      await PreferencesService.setString(_settingsKey, settingsJson);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving SMS settings: $e');
    }
  }

  // Activar/Desactivar procesamiento automático
  Future<void> setAutoProcessEnabled(bool enabled) async {
    _settings = _settings.copyWith(autoProcessEnabled: enabled);
    await saveSettings();
  }

  // Requerir cuentas bancarias activas
  Future<void> setRequireActiveBankAccounts(bool required) async {
    _settings = _settings.copyWith(requireActiveBankAccounts: required);
    await saveSettings();
  }

  // Cambiar modo de procesamiento
  Future<void> setProcessMode(SmsProcessMode mode) async {
    _settings = _settings.copyWith(processMode: mode);
    
    // Actualizar la fecha mínima basada en el modo
    final effectiveDate = _settings.getEffectiveMinDate();
    _settings = _settings.copyWith(minProcessDate: effectiveDate);
    
    await saveSettings();
  }

  // Establecer fecha mínima personalizada
  Future<void> setMinProcessDate(DateTime? date) async {
    _settings = _settings.copyWith(
      minProcessDate: date,
      processMode: date != null ? SmsProcessMode.customDate : SmsProcessMode.all,
    );
    await saveSettings();
  }

  // Registrar sincronización manual
  Future<void> recordManualSync() async {
    _settings = _settings.copyWith(lastManualSync: DateTime.now());
    await saveSettings();
  }

  // Verificar si debe procesar un mensaje basado en configuración
  bool shouldProcessMessage(DateTime messageDate) {
    return _settings.shouldProcessMessage(messageDate);
  }

  // Verificar si el procesamiento automático está habilitado y cumple condiciones
  bool canAutoProcess(bool hasBankAccounts) {
    if (!_settings.autoProcessEnabled) {
      return false;
    }
    
    if (_settings.requireActiveBankAccounts && !hasBankAccounts) {
      return false;
    }
    
    return true;
  }

  // Restablecer a configuración por defecto
  Future<void> resetToDefault() async {
    _settings = SmsSettings();
    await saveSettings();
  }

  // Obtener resumen de configuración
  String getConfigSummary() {
    final lines = <String>[];
    
    if (!_settings.autoProcessEnabled) {
      lines.add('Procesamiento automático: DESACTIVADO');
    } else {
      lines.add('Procesamiento automático: ACTIVADO');
    }
    
    if (_settings.requireActiveBankAccounts) {
      lines.add('Requiere cuentas bancarias activas');
    }
    
    lines.add('Modo: ${_settings.processMode.displayName}');
    
    final effectiveDate = _settings.getEffectiveMinDate();
    if (effectiveDate != null) {
      lines.add('Desde: ${effectiveDate.day}/${effectiveDate.month}/${effectiveDate.year}');
    }
    
    return lines.join('\n');
  }
}

