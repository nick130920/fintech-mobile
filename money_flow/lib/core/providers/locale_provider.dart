import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale_code';
  static const List<String> supportedLanguageCodes = ['es', 'en'];

  Locale _locale = const Locale('es');
  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey) ?? 'es';
    _locale = Locale(_normalizeCode(code));
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    final normalized = _normalizeCode(languageCode);
    if (_locale.languageCode == normalized) return;

    _locale = Locale(normalized);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, normalized);
  }

  String _normalizeCode(String code) {
    return supportedLanguageCodes.contains(code) ? code : 'es';
  }
}
