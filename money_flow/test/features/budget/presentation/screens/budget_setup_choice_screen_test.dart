import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_flow/features/budget/presentation/providers/budget_suggestions_provider.dart';
import 'package:money_flow/features/budget/presentation/screens/budget_setup_choice_screen.dart';
import 'package:provider/provider.dart';

void main() {
  Widget buildChoiceScreen({
    required Future<bool> Function() onSkip,
    required VoidCallback onSetupComplete,
  }) {
    return ChangeNotifierProvider(
      create: (_) => BudgetSuggestionsProvider(),
      child: MaterialApp(
        home: BudgetSetupChoiceScreen(
          onSkip: onSkip,
          onSetupComplete: onSetupComplete,
        ),
      ),
    );
  }

  testWidgets('Skip for now completes only after persistence resolves', (
    tester,
  ) async {
    final persistence = Completer<bool>();
    var completionCount = 0;

    await tester.pumpWidget(
      buildChoiceScreen(
        onSkip: () => persistence.future,
        onSetupComplete: () => completionCount++,
      ),
    );

    await tester.tap(find.text('Skip for now'));
    await tester.pump();

    expect(completionCount, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    persistence.complete(true);
    await tester.pump();
    await tester.pump();

    expect(completionCount, 1);
  });

  testWidgets('Skip for now keeps setup available when persistence fails', (
    tester,
  ) async {
    var completionCount = 0;

    await tester.pumpWidget(
      buildChoiceScreen(
        onSkip: () async => false,
        onSetupComplete: () => completionCount++,
      ),
    );

    await tester.tap(find.text('Skip for now'));
    await tester.pump();
    await tester.pump();

    expect(completionCount, 0);
    expect(
      find.text('No pudimos guardar tu decisión. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(find.text('Skip for now'), findsOneWidget);
  });
}
