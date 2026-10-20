import 'package:money_flow/core/services/sms_service.dart';
import 'package:money_flow/core/services/platform_capabilities.dart';
import 'package:money_flow/features/bank_accounts/data/repositories/automatic_transactions_repository.dart';
import 'package:money_flow/features/budget/data/models/sms_budget_suggestion.dart';

import 'sms_budget_message_classifier.dart';

/// Servicio que obtiene sugerencias de presupuesto desde SMS (últimos 3 meses) o extracto bancario.
class BudgetSuggestionsService {
  final SmsService _smsService = SmsService();

  /// Máximo de SMS enviados al backend (los más recientes): respuesta rápida y muestra suficiente para sugerencias.
  static const int maxSmsForSuggestions = 100;

  /// Filtra localmente antes del límite; el payload conserva solo body/date.
  static List<Map<String, dynamic>> prepareSmsMessages(
    List<SmsInboxItem> items,
  ) {
    const classifier = SmsBudgetMessageClassifier();
    final messages = items
        .where((item) => classifier.shouldInclude(item.body))
        .map(
          (item) => <String, dynamic>{
            'body': item.body,
            'date': item.date?.toIso8601String() ?? '',
          },
        )
        .toList();
    _sortMessagesNewestFirst(messages);
    return messages.take(maxSmsForSuggestions).toList();
  }

  /// Analiza los SMS de los últimos 3 meses y devuelve sugerencias (solo en este dispositivo, no crea transacciones).
  Future<SmsBudgetSuggestion> analyzeLast3Months() async {
    if (!PlatformCapabilities.supportsSmsInbox) {
      throw Exception(
        'La lectura de SMS no está disponible en iPhone. Usa extracto bancario o conexión por email.',
      );
    }

    final minDate = DateTime.now().subtract(const Duration(days: 90));
    final messages = <SmsInboxItem>[];

    await _smsService.syncInbox(
      onSmsWithDateReceived: (body, date) {
        messages.add(SmsInboxItem(body: body, date: date));
      },
      minDate: minDate,
      autoMode: false,
    );

    final toSend = prepareSmsMessages(messages);

    final response = await AutomaticTransactionsRepository.analyzeSmsBatch(
      toSend,
    );
    return _responseToSuggestion(response);
  }

  /// Analiza un archivo de extracto bancario (PDF o imagen) por ruta y devuelve sugerencias.
  Future<SmsBudgetSuggestion> analyzeStatement(String filePath) async {
    final response = await AutomaticTransactionsRepository.analyzeStatement(
      filePath,
    );
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

  static SmsBudgetSuggestion _responseToSuggestion(
    BudgetSuggestionsResponse response,
  ) {
    final total = response.totalExpense3m;
    final byCategory = <SmsBudgetSuggestionCategory>[];

    if (total > 0) {
      for (final item in response.byCategory) {
        final percentage = (item.total / total) * 100.0;
        if (percentage > 0) {
          byCategory.add(
            SmsBudgetSuggestionCategory(
              categoryId: item.categoryId,
              categoryName: item.categoryName,
              total: item.total,
              percentage: percentage,
              transactionCount: item.count,
            ),
          );
        }
      }
    }

    return SmsBudgetSuggestion(totalSuggested: total, byCategory: byCategory);
  }
}
