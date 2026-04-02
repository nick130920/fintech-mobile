import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke test renderiza scaffold base', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Money Flow'),
        ),
      ),
    );

    expect(find.text('Money Flow'), findsOneWidget);
  });
}
