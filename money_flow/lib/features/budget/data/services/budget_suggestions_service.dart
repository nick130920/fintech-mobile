import 'package:money_flow/core/services/sms_service.dart';
import 'package:money_flow/features/bank_accounts/data/repositories/automatic_transactions_repository.dart';
import 'package:money_flow/features/budget/data/models/sms_budget_suggestion.dart';

/// Servicio que obtiene sugerencias de presupuesto desde SMS (últimos 3 meses) o extracto bancario.
class BudgetSuggestionsService {
  final SmsService _smsService = SmsService();

  /// Analiza los SMS de los últimos 3 meses y devuelve sugerencias (solo en este dispositivo, no crea transacciones).
  Future<SmsBudgetSuggestion> analyzeLast3Months() async {
    final minDate = DateTime.now().subtract(const Duration(days: 90));
    final messages = <Map<String, dynamic>>[];

    await _smsService.syncInbox(
      (_) {},
      onSmsWithDateReceived: (body, date) {
        if (body != null && body.trim().isNotEmpty) {
          messages.add({
            'body': body,
            'date': date?.toIso8601String() ?? '',
          });
        }
      },
      minDate: minDate,
      autoMode: false,
    );

    final response = await AutomaticTransactionsRepository.analyzeSmsBatch(messages);
    return _responseToSuggestion(response);
  }

  /// Analiza un archivo de extracto bancario (PDF o imagen) por ruta y devuelve sugerencias.
  Future<SmsBudgetSuggestion> analyzeStatement(String filePath) async {
    final response = await AutomaticTransactionsRepository.analyzeStatement(filePath);
    return _responseToSuggestion(response);
  }

  static SmsBudgetSuggestion _responseToSuggestion(BudgetSuggestionsResponse response) {
    final total = response.totalExpense3m;
    final byCategory = <SmsBudgetSuggestionCategory>[];

    if (total > 0) {
      for (final item in response.byCategory) {
        final percentage = (item.total / total) * 100.0;
        if (percentage > 0) {
          byCategory.add(SmsBudgetSuggestionCategory(
            categoryId: item.categoryId,
            categoryName: item.categoryName,
            total: item.total,
            percentage: percentage,
          ));
        }
      }
    }

    return SmsBudgetSuggestion(
      totalSuggested: total,
      byCategory: byCategory,
    );
  }
}
