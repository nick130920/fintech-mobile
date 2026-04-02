import 'package:flutter_test/flutter_test.dart';
import 'package:money_flow/features/bank_accounts/data/models/transaction_model.dart';

void main() {
  group('TransactionModel', () {
    test('fromJson convierte tags string a lista', () {
      final json = {
        'id': 1,
        'type': 'expense',
        'status': 'pending',
        'amount': 45.5,
        'description': 'Supermercado',
        'transaction_date': '2026-01-10T12:00:00Z',
        'currency': 'USD',
        'source': 'manual',
        'validation_status': 'pending_review',
        'ai_confidence': 0.4,
        'needs_review': true,
        'created_at': '2026-01-10T12:00:00Z',
        'tags': 'hogar, comida',
      };

      final model = TransactionModel.fromJson(json);
      expect(model.tags, ['hogar', 'comida']);
      expect(model.isExpense, isTrue);
      expect(model.isPendingReview, isTrue);
    });

    test('signedAmount respeta el tipo de transacción', () {
      const income = TransactionModel(
        id: 1,
        type: TransactionType.income,
        status: TransactionStatus.completed,
        amount: 100,
        description: 'Salario',
        transactionDate: '2026-01-10T12:00:00Z',
        currency: 'USD',
        source: TransactionSource.manual,
        validationStatus: ValidationStatus.auto,
        aiConfidence: 0,
        needsReview: false,
        createdAt: '2026-01-10T12:00:00Z',
      );
      const expense = TransactionModel(
        id: 2,
        type: TransactionType.expense,
        status: TransactionStatus.completed,
        amount: 40,
        description: 'Taxi',
        transactionDate: '2026-01-10T12:00:00Z',
        currency: 'USD',
        source: TransactionSource.manual,
        validationStatus: ValidationStatus.auto,
        aiConfidence: 0,
        needsReview: false,
        createdAt: '2026-01-10T12:00:00Z',
      );

      expect(income.signedAmount, 100);
      expect(expense.signedAmount, -40);
    });
  });

  group('TransactionFilter', () {
    test('toQueryParams incluye defaults y filtros opcionales', () {
      const filter = TransactionFilter(
        accountId: 10,
        categoryId: 3,
        search: 'uber',
        limit: 25,
        offset: 50,
      );

      final params = filter.toQueryParams();
      expect(params['account_id'], '10');
      expect(params['category_id'], '3');
      expect(params['search'], 'uber');
      expect(params['limit'], '25');
      expect(params['offset'], '50');
      expect(params['order_by'], 'transaction_date');
      expect(params['order_dir'], 'DESC');
    });
  });
}
