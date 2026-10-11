import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_flow/features/budget/presentation/screens/dashboard_widgets/dashboard_content_widget.dart';
import 'package:money_flow/features/budget/presentation/widgets/budget_setup_reminder_card.dart';

void main() {
  testWidgets('does not render when hidden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BudgetSetupReminderCard(
            isVisible: false,
            onSetupBudget: () {},
          ),
        ),
      ),
    );

    expect(find.text('Configura tu presupuesto cuando estés listo'), findsNothing);
  });

  testWidgets('hides A reminder while B visibility lookup is pending',
      (tester) async {
    final bVisibility = Completer<bool>();
    var userId = 101;

    Widget buildSlot() {
      return MaterialApp(
        home: Scaffold(
          body: BudgetSetupReminderSlot(
            identity: userId,
            loadVisibility: () => userId == 101 ? Future.value(true) : bVisibility.future,
          ),
        ),
      );
    }

    await tester.pumpWidget(buildSlot());
    await tester.pump();
    expect(find.text('Configura tu presupuesto cuando estés listo'), findsOneWidget);

    userId = 202;
    await tester.pumpWidget(buildSlot());
    await tester.pump();

    expect(find.text('Configura tu presupuesto cuando estés listo'), findsNothing);

    bVisibility.complete(false);
    await tester.pump();
  });

  testWidgets('named setup navigation refreshes and hides the original reminder',
      (tester) async {
    var visible = true;

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/budget-setup': (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () {
                      visible = false;
                      Navigator.of(context).pop();
                    },
                    child: const Text('Finish setup'),
                  ),
                ),
              ),
        },
        home: Scaffold(
          body: BudgetSetupReminderSlot(
            identity: 101,
            loadVisibility: () async => visible,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Configura tu presupuesto cuando estés listo'), findsOneWidget);

    await tester.tap(find.text('Configurar presupuesto'));
    await tester.pumpAndSettle();
    expect(find.text('Finish setup'), findsOneWidget);

    await tester.tap(find.text('Finish setup'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Configura tu presupuesto cuando estés listo'), findsNothing);
  });
}
