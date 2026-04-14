import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_flow/core/providers/locale_provider.dart';
import 'package:money_flow/features/settings/presentation/screens/language_settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('LanguageSettingsScreen muestra opciones de idioma', (tester) async {
    SharedPreferences.setMockInitialValues({'app_locale_code': 'es'});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const MaterialApp(
          home: LanguageSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Español'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });
}
