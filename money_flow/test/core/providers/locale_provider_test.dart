import 'package:flutter_test/flutter_test.dart';
import 'package:money_flow/core/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocaleProvider', () {
    test('carga locale persistido y actualiza preferencia', () async {
      SharedPreferences.setMockInitialValues({'app_locale_code': 'en'});

      final provider = LocaleProvider();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(provider.locale.languageCode, 'en');

      await provider.setLocale('es');
      expect(provider.locale.languageCode, 'es');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale_code'), 'es');
    });
  });
}
