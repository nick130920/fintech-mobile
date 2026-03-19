import 'package:money_flow/core/services/sms_service.dart';
import 'package:money_flow/features/bank_accounts/data/repositories/automatic_transactions_repository.dart';
import 'package:money_flow/features/budget/data/models/sms_budget_suggestion.dart';

/// Servicio que obtiene sugerencias de presupuesto desde SMS (últimos 3 meses) o extracto bancario.
class BudgetSuggestionsService {
  final SmsService _smsService = SmsService();

  /// Máximo de SMS enviados al backend (los más recientes): respuesta rápida y muestra suficiente para sugerencias.
  static const int maxSmsForSuggestions = 100;

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

    _sortMessagesNewestFirst(messages);
    final toSend = messages.length > maxSmsForSuggestions
        ? messages.sublist(0, maxSmsForSuggestions)
        : messages;

    final response = await AutomaticTransactionsRepository.analyzeSmsBatch(toSend);
    return _responseToSuggestion(response);
  }

  /// Analiza un archivo de extracto bancario (PDF o imagen) por ruta y devuelve sugerencias.
  Future<SmsBudgetSuggestion> analyzeStatement(String filePath) async {
    final response = await AutomaticTransactionsRepository.analyzeStatement(filePath);
    return _responseToSuggestion(response);
  }

  static void _sortMessagesNewestFirst(List<Map<String, dynamic>> list) {
    int ts(Map<String, dynamic> m) {
      final raw = m['date'];
      if (raw is! String || raw.isEmpty) return 0;
      return DateTime.tryParse(raw)?.millisecondsSinceEpoch ?? 0;
    }

    list.sort((a, b) => ts(b).compareTo(ts(a)));
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
            transactionCount: item.count,
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
