import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_flow/features/auth/presentation/providers/auth_provider.dart';
import 'package:money_flow/features/auth/presentation/screens/register_screen.dart';
import 'package:provider/provider.dart';

class _RecordingAuthProvider extends AuthProvider {
  int registerCalls = 0;
  String? firstName;
  String? lastName;
  String? email;
  String? password;

  @override
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    registerCalls++;
    this.firstName = firstName;
    this.lastName = lastName;
    this.email = email;
    this.password = password;
    return true;
  }
}

void main() {
  Widget buildSubject(_RecordingAuthProvider provider) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: provider,
      child: const MaterialApp(home: RegisterScreen()),
    );
  }

  Future<void> enterValidRegistration(
    WidgetTester tester, {
    required String confirmation,
  }) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ana');
    await tester.enterText(fields.at(1), 'García');
    await tester.enterText(fields.at(2), 'ana@example.com');
    await tester.enterText(fields.at(3), 'secreta');
    await tester.enterText(fields.at(4), confirmation);
  }

  testWidgets('shows password and confirmation labels', (tester) async {
    await tester.pumpWidget(buildSubject(_RecordingAuthProvider()));

    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Confirmar contraseña'), findsOneWidget);
  });

  testWidgets('blocks registration when confirmation is empty', (tester) async {
    final provider = _RecordingAuthProvider();
    await tester.pumpWidget(buildSubject(provider));
    await enterValidRegistration(tester, confirmation: '');

    final createAccount = find.text('Crear Cuenta');
    await tester.ensureVisible(createAccount);
    await tester.tap(createAccount);
    await tester.pump();

    expect(
      find.text('La confirmación de contraseña es requerida'),
      findsOneWidget,
    );
    expect(provider.registerCalls, 0);
  });

  testWidgets('blocks registration when passwords do not match', (
    tester,
  ) async {
    final provider = _RecordingAuthProvider();
    await tester.pumpWidget(buildSubject(provider));
    await enterValidRegistration(tester, confirmation: 'distinta');

    final createAccount = find.text('Crear Cuenta');
    await tester.ensureVisible(createAccount);
    await tester.tap(createAccount);
    await tester.pump();

    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(provider.registerCalls, 0);
  });

  testWidgets('registers matching passwords with the existing payload', (
    tester,
  ) async {
    final provider = _RecordingAuthProvider();
    await tester.pumpWidget(buildSubject(provider));
    await enterValidRegistration(tester, confirmation: 'secreta');

    final createAccount = find.text('Crear Cuenta');
    await tester.ensureVisible(createAccount);
    await tester.tap(createAccount);
    await tester.pump();

    expect(provider.registerCalls, 1);
    expect(provider.firstName, 'Ana');
    expect(provider.lastName, 'García');
    expect(provider.email, 'ana@example.com');
    expect(provider.password, 'secreta');
  });

  testWidgets('uses a 56 pixel wrapper for the registration button', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(_RecordingAuthProvider()));

    final button = find.widgetWithText(ElevatedButton, 'Crear Cuenta');
    await tester.ensureVisible(button);

    expect(tester.getSize(button).height, 56);
  });

  testWidgets('keeps the complete form reachable on a compact viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject(_RecordingAuthProvider()));

    final confirmation = find.text('Confirmar contraseña');
    final createAccount = find.text('Crear Cuenta');
    await tester.ensureVisible(confirmation);
    await tester.ensureVisible(createAccount);

    expect(confirmation, findsOneWidget);
    expect(createAccount, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
