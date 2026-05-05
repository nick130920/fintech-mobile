import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:money_flow/features/budget/presentation/providers/budget_suggestions_provider.dart';
import 'package:money_flow/features/budget/presentation/screens/budget_setup_choice_screen.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('muestra opciones de sugerencias para onboarding', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BudgetSuggestionsProvider(),
        child: MaterialApp(
          home: BudgetSetupChoiceScreen(
            onSetupComplete: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Configura tu presupuesto'), findsOneWidget);
    expect(find.text('Subir un extracto (PDF o imagen)'), findsOneWidget);
  });
}
