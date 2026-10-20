import 'package:flutter_test/flutter_test.dart';
import 'package:money_flow/core/services/sms_service.dart';
import 'package:money_flow/features/budget/data/services/budget_suggestions_service.dart';

void main() {
  test(
    'filters before the cap and returns newest financial messages first',
    () {
      final start = DateTime.utc(2026, 1, 1);
      final transactions = List.generate(
        105,
        (i) => SmsInboxItem(
          body: 'Compraste \$${i + 1}.000 en TIENDA.',
          date: start.add(Duration(minutes: i)),
        ),
      );
      final noise = List.generate(
        110,
        (i) => SmsInboxItem(
          body: 'Tu código de verificación es 123456.',
          date: start.add(Duration(days: 1, minutes: i)),
        ),
      );
      final items = [...transactions, ...noise];
      final original = List<SmsInboxItem>.of(items);

      final result = BudgetSuggestionsService.prepareSmsMessages(items);

      expect(result, hasLength(BudgetSuggestionsService.maxSmsForSuggestions));
      expect(
        result.map((m) => m['body']),
        transactions.reversed.take(100).map((m) => m.body),
      );
      expect(items, orderedEquals(original));
    },
  );

  test('payload preserves original body/date and has exactly those keys', () {
    const body = '  Recibiste una transferencia de \$1.234.567,89.  ';
    final date = DateTime.utc(2026, 2, 3, 12, 34);
    final result = BudgetSuggestionsService.prepareSmsMessages([
      SmsInboxItem(body: body, date: date),
      const SmsInboxItem(body: 'Pago recibido de 45000 COP.'),
      const SmsInboxItem(body: null),
      const SmsInboxItem(body: ' '),
    ]);

    expect(result, [
      {'body': body, 'date': date.toIso8601String()},
      {'body': 'Pago recibido de 45000 COP.', 'date': ''},
    ]);
    for (final message in result) {
      expect(message.keys, unorderedEquals(['body', 'date']));
    }
  });

  test('empty or entirely irrelevant inbox produces an empty payload', () {
    expect(BudgetSuggestionsService.prepareSmsMessages([]), isEmpty);
    expect(
      BudgetSuggestionsService.prepareSmsMessages([
        const SmsInboxItem(body: 'Promoción: compra hoy por \$50.000.'),
        const SmsInboxItem(body: 'Tu OTP es 123456.'),
      ]),
      isEmpty,
    );
  });
}
