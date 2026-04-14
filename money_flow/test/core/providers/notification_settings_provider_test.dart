import 'package:flutter_test/flutter_test.dart';
import 'package:money_flow/core/providers/notification_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('NotificationSettingsProvider', () {
    test('carga y persiste toggles de notificaciones', () async {
      SharedPreferences.setMockInitialValues({
        'notif_push_enabled': true,
        'notif_sound_enabled': false,
        'notif_budget_alerts_enabled': true,
        'notif_daily_summary_enabled': false,
      });

      final provider = NotificationSettingsProvider();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(provider.pushEnabled, isTrue);
      expect(provider.soundEnabled, isFalse);
      expect(provider.budgetAlertsEnabled, isTrue);
      expect(provider.dailySummaryEnabled, isFalse);

      await provider.setDailySummaryEnabled(true);
      expect(provider.dailySummaryEnabled, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notif_daily_summary_enabled'), isTrue);
    });
  });
}
