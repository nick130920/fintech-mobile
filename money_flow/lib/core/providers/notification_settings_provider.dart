import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  static const String _pushEnabledKey = 'notif_push_enabled';
  static const String _soundEnabledKey = 'notif_sound_enabled';
  static const String _budgetAlertsEnabledKey = 'notif_budget_alerts_enabled';
  static const String _dailySummaryEnabledKey = 'notif_daily_summary_enabled';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _pushEnabled = true;
  bool get pushEnabled => _pushEnabled;

  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  bool _budgetAlertsEnabled = true;
  bool get budgetAlertsEnabled => _budgetAlertsEnabled;

  bool _dailySummaryEnabled = false;
  bool get dailySummaryEnabled => _dailySummaryEnabled;

  NotificationSettingsProvider() {
    initialize();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _pushEnabled = prefs.getBool(_pushEnabledKey) ?? true;
    _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
    _budgetAlertsEnabled = prefs.getBool(_budgetAlertsEnabledKey) ?? true;
    _dailySummaryEnabled = prefs.getBool(_dailySummaryEnabledKey) ?? false;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setPushEnabled(bool value) async {
    _pushEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushEnabledKey, value);
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
  }

  Future<void> setBudgetAlertsEnabled(bool value) async {
    _budgetAlertsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_budgetAlertsEnabledKey, value);
  }

  Future<void> setDailySummaryEnabled(bool value) async {
    _dailySummaryEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailySummaryEnabledKey, value);
  }
}
