import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_flow/features/legal/presentation/screens/contact_screen.dart';
import 'package:money_flow/features/legal/presentation/screens/privacy_policy_screen.dart';
import 'package:money_flow/features/legal/presentation/screens/terms_of_service_screen.dart';

void main() {
  Widget buildSubject(Widget child) {
    return MaterialApp(home: child);
  }

  testWidgets('terms screen shows its legal draft status and scrolls', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(const TermsOfServiceScreen()));

    expect(find.text('Términos de Servicio'), findsWidgets);
    expect(
      find.text('Borrador pendiente de revisión jurídica'),
      findsOneWidget,
    );
    expect(find.textContaining('Última actualización'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('privacy screen shows its legal draft status and scrolls', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(const PrivacyPolicyScreen()));

    expect(find.text('Política de Privacidad'), findsWidgets);
    expect(
      find.text('Borrador pendiente de revisión jurídica'),
      findsOneWidget,
    );
    expect(find.textContaining('Estado del documento'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets(
    'contact screen launches the support email through its callback',
    (tester) async {
      Uri? launchedUri;
      await tester.pumpWidget(
        buildSubject(
          ContactScreen(
            emailLauncher: (uri) async {
              launchedUri = uri;
              return true;
            },
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Enviar correo a soporte'));
      await tester.pump();

      expect(find.text('support@tatacode.com'), findsOneWidget);
      expect(launchedUri, Uri.parse('mailto:support@tatacode.com'));
    },
  );

  testWidgets(
    'contact screen explains when the email application cannot open',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(ContactScreen(emailLauncher: (_) async => false)),
      );

      await tester.tap(find.bySemanticsLabel('Enviar correo a soporte'));
      await tester.pump();

      expect(
        find.text('No se pudo abrir tu aplicación de correo.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('contact screen explains when the email launcher throws', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        ContactScreen(
          emailLauncher: (_) async => throw Exception('sin correo'),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Enviar correo a soporte'));
    await tester.pump();

    expect(
      find.text('No se pudo abrir tu aplicación de correo.'),
      findsOneWidget,
    );
  });
}
