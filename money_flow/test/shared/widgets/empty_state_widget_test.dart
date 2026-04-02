import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_flow/shared/widgets/empty_state_widget.dart';

void main() {
  testWidgets('EmptyStateWidget renderiza título y acción', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget(
            icon: Icons.info_outline,
            title: 'Sin datos',
            subtitle: 'No hay elementos para mostrar',
            actionLabel: 'Reintentar',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Sin datos'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
