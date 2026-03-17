import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:money_flow/core/services/api_service.dart';
import 'package:money_flow/core/services/storage_service.dart';
import 'package:money_flow/features/bank_accounts/data/models/transaction_model.dart';

class AutomaticTransactionsRepository {
  /// Obtiene transacciones pendientes de revisión
  static Future<List<TransactionModel>> getPendingTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = {
        'validation_status': 'pending_review',
        'limit': limit.toString(),
        'offset': offset.toString(),
        'order_by': 'created_at',
        'order_dir': 'DESC',
      };

      // Construir URI con query parameters
      final uri = Uri.parse('${ApiService.baseUrl}/transactions').replace(
        queryParameters: queryParams,
      );

      final token = await StorageService.getAccessToken();
      final response = await ApiService.getUri(uri, token: token);

      if (response.statusCode == 200) {
        final responseData = ApiService.handleResponse(response);
        
        // La API puede devolver una lista directamente o un mapa con 'data'
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          final List<dynamic> data = responseData['data'] ?? [];
          return data.map((json) => TransactionModel.fromJson(json)).toList();
        } else if (responseData is List) {
          return responseData.map((json) => TransactionModel.fromJson(json as Map<String, dynamic>)).toList();
        } else {
          return []; // Devolver lista vacía si la respuesta no es lo esperado
        }
      } else {
        throw Exception('Error al obtener transacciones pendientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener transacciones pendientes: $e');
    }
  }

  /// Obtiene transacciones automáticas (de notificaciones)
  static Future<List<TransactionModel>> getAutomaticTransactions({
    int limit = 50,
    int offset = 0,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final queryParams = {
        'source': 'notification',
        'limit': limit.toString(),
        'offset': offset.toString(),
        'order_by': 'created_at',
        'order_dir': 'DESC',
      };

      if (fromDate != null) queryParams['from_date'] = fromDate;
      if (toDate != null) queryParams['to_date'] = toDate;

      // Construir URI con query parameters
      final uri = Uri.parse('${ApiService.baseUrl}/transactions').replace(
        queryParameters: queryParams,
      );

      final token = await StorageService.getAccessToken();
      final response = await ApiService.getUri(uri, token: token);

      if (response.statusCode == 200) {
        final responseData = ApiService.handleResponse(response);
        final List<dynamic> data = responseData['data'] ?? [];
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener transacciones automáticas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener transacciones automáticas: $e');
    }
  }

  /// Aprueba una transacción pendiente
  static Future<TransactionModel> approveTransaction(int transactionId) async {
    try {
      final token = await StorageService.getAccessToken();
      final response = await ApiService.put(
        '/transactions/$transactionId/validate',
        {
          'validation_status': 'manual_validated',
          'action': 'approve',
        },
        token: token,
      );

      if (response.statusCode == 200) {
        final responseData = ApiService.handleResponse(response);
        return TransactionModel.fromJson(responseData);
      } else {
        throw Exception('Error al aprobar transacción: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al aprobar transacción: $e');
    }
  }

  /// Rechaza una transacción pendiente
  static Future<void> rejectTransaction(int transactionId, {String? reason}) async {
    try {
      final token = await StorageService.getAccessToken();
      final response = await ApiService.put(
        '/transactions/$transactionId/validate',
        {
          'validation_status': 'rejected',
          'action': 'reject',
          'reason': reason,
        },
        token: token,
      );

      if (response.statusCode != 200) {
        throw Exception('Error al rechazar transacción: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al rechazar transacción: $e');
    }
  }

  /// Edita una transacción pendiente antes de aprobarla
  static Future<TransactionModel> editAndApproveTransaction(
    int transactionId, {
    double? amount,
    String? description,
    int? categoryId,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'validation_status': 'manual_validated',
        'action': 'approve',
      };

      if (amount != null) body['amount'] = amount;
      if (description != null) body['description'] = description;
      if (categoryId != null) body['category_id'] = categoryId;
      if (notes != null) body['notes'] = notes;

      final token = await StorageService.getAccessToken();
      final response = await ApiService.put(
        '/transactions/$transactionId/validate',
        body,
        token: token,
      );

      if (response.statusCode == 200) {
        final responseData = ApiService.handleResponse(response);
        return TransactionModel.fromJson(responseData);
      } else {
        throw Exception('Error al editar y aprobar transacción: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al editar y aprobar transacción: $e');
    }
  }

  /// Obtiene estadísticas de transacciones automáticas
  static Future<AutomaticTransactionStats> getAutomaticTransactionStats({
    int days = 30,
  }) async {
    try {
      final queryParams = {
        'days': days.toString(),
      };

      // Construir URI con query parameters
      final uri = Uri.parse('${ApiService.baseUrl}/notification-patterns/statistics').replace(
        queryParameters: queryParams,
      );

      final token = await StorageService.getAccessToken();
      final response = await ApiService.getUri(uri, token: token);

      if (response.statusCode == 200) {
        final responseData = ApiService.handleResponse(response);
        if (responseData is Map<String, dynamic>) {
          return AutomaticTransactionStats.fromJson(responseData);
        } else {
          // Si la respuesta no es un mapa, devolver estadísticas por defecto para evitar crash
          return const AutomaticTransactionStats.empty();
        }
      } else {
        throw Exception('Error al obtener estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  /// Obtiene el conteo de transacciones pendientes
  static Future<int> getPendingTransactionsCount() async {
    // TODO: Implementar el endpoint /transactions/count en el backend.
    // Por ahora, devolvemos 0 para evitar errores 400.
    return 0;
  }

  /// Procesa múltiples transacciones en lote
  static Future<BatchProcessResult> processBatchTransactions(
    List<int> transactionIds,
    String action, // 'approve' o 'reject'
  ) async {
    try {
      final token = await StorageService.getAccessToken();
      final response = await ApiService.post(
        '/transactions/batch-process',
        {
          'transaction_ids': transactionIds,
          'action': action,
        },
        token: token,
      );

      if (response.statusCode == 200) {
        final responseData = ApiService.handleResponse(response);
        return BatchProcessResult.fromJson(responseData);
      } else {
        throw Exception('Error en procesamiento en lote: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en procesamiento en lote: $e');
    }
  }

  /// Analiza un lote de SMS para sugerencias de presupuesto (no crea transacciones).
  /// [messages] lista de mapas con "body" y "date" (date en ISO8601 opcional).
  static Future<BudgetSuggestionsResponse> analyzeSmsBatch(
    List<Map<String, dynamic>> messages,
  ) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.post(
        '/notification-patterns/analyze-sms-batch',
        {'messages': messages},
        token: token,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return BudgetSuggestionsResponse.fromJson(data);
      } else {
        final errorBody = _parseErrorBody(response);
        throw Exception(
          'Error analizando SMS: ${errorBody['error'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error analizando SMS para sugerencias: $e');
    }
  }

  /// Analiza un extracto bancario (PDF o imagen) por ruta de archivo.
  static Future<BudgetSuggestionsResponse> analyzeStatement(String filePath) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.postMultipartFile(
        '/notification-patterns/analyze-statement',
        filePath,
        fieldName: 'file',
        token: token,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return BudgetSuggestionsResponse.fromJson(data);
      } else {
        final errorBody = _parseErrorBody(response);
        throw Exception(
          'Error analizando extracto: ${errorBody['error'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error analizando extracto bancario: $e');
    }
  }

  static Map<String, dynamic> _parseErrorBody(http.Response response) {
    try {
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'error': response.body};
    }
  }

  /// Procesa un SMS con IA para detectar y crear transacciones automáticamente.
  static Future<Map<String, dynamic>> processSMSWithAI(String message) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.post(
        '/notification-patterns/process-sms',
        {'message': message},
        token: token,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        Map<String, dynamic> errorBody;
        try {
          errorBody = json.decode(response.body) as Map<String, dynamic>;
        } catch (_) {
          errorBody = {'error': response.body};
        }
        throw Exception(
          'Error procesando SMS con IA: ${errorBody['error'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error procesando SMS con IA: $e');
    }
  }
}

/// Modelo para estadísticas de transacciones automáticas
class AutomaticTransactionStats {
  final int totalAutomatic;
  final int totalPending;
  final int totalApproved;
  final int totalRejected;
  final double averageConfidence;
  final double approvalRate;
  final List<DailyTransactionStat> dailyStats;

  const AutomaticTransactionStats({
    required this.totalAutomatic,
    required this.totalPending,
    required this.totalApproved,
    required this.totalRejected,
    required this.averageConfidence,
    required this.approvalRate,
    required this.dailyStats,
  });

  const AutomaticTransactionStats.empty()
      : totalAutomatic = 0,
        totalPending = 0,
        totalApproved = 0,
        totalRejected = 0,
        averageConfidence = 0.0,
        approvalRate = 0.0,
        dailyStats = const [];

  factory AutomaticTransactionStats.fromJson(Map<String, dynamic> json) {
    return AutomaticTransactionStats(
      totalAutomatic: json['total_automatic'] ?? 0,
      totalPending: json['total_pending'] ?? 0,
      totalApproved: json['total_approved'] ?? 0,
      totalRejected: json['total_rejected'] ?? 0,
      averageConfidence: (json['average_confidence'] ?? 0.0).toDouble(),
      approvalRate: (json['approval_rate'] ?? 0.0).toDouble(),
      dailyStats: (json['daily_stats'] as List<dynamic>? ?? [])
          .map((e) => DailyTransactionStat.fromJson(e))
          .toList(),
    );
  }
}

/// Estadística diaria de transacciones
class DailyTransactionStat {
  final String date;
  final int count;
  final int approved;
  final int rejected;
  final double totalAmount;

  const DailyTransactionStat({
    required this.date,
    required this.count,
    required this.approved,
    required this.rejected,
    required this.totalAmount,
  });

  factory DailyTransactionStat.fromJson(Map<String, dynamic> json) {
    return DailyTransactionStat(
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
      approved: json['approved'] ?? 0,
      rejected: json['rejected'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
    );
  }
}

/// Resultado de procesamiento en lote
class BatchProcessResult {
  final int totalProcessed;
  final int successful;
  final int failed;
  final List<String> errors;

  const BatchProcessResult({
    required this.totalProcessed,
    required this.successful,
    required this.failed,
    required this.errors,
  });

  factory BatchProcessResult.fromJson(Map<String, dynamic> json) {
    return BatchProcessResult(
      totalProcessed: json['total_processed'] ?? 0,
      successful: json['successful'] ?? 0,
      failed: json['failed'] ?? 0,
      errors: List<String>.from(json['errors'] ?? []),
    );
  }
}

/// Respuesta de analyze-sms-batch y analyze-statement (sugerencias de presupuesto).
class BudgetSuggestionsResponse {
  final double totalExpense3m;
  final List<BudgetSuggestionCategoryItem> byCategory;

  const BudgetSuggestionsResponse({
    required this.totalExpense3m,
    required this.byCategory,
  });

  factory BudgetSuggestionsResponse.fromJson(Map<String, dynamic> json) {
    final suggestions = json['suggestions'] as Map<String, dynamic>? ?? {};
    final list = suggestions['by_category'] as List<dynamic>? ?? [];
    return BudgetSuggestionsResponse(
      totalExpense3m: (suggestions['total_expense_3m'] ?? 0.0).toDouble(),
      byCategory: list
          .map((e) => BudgetSuggestionCategoryItem.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BudgetSuggestionCategoryItem {
  final int categoryId;
  final String categoryName;
  final double total;
  final int count;

  const BudgetSuggestionCategoryItem({
    required this.categoryId,
    required this.categoryName,
    required this.total,
    required this.count,
  });

  factory BudgetSuggestionCategoryItem.fromJson(Map<String, dynamic> json) {
    return BudgetSuggestionCategoryItem(
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      total: (json['total'] ?? 0.0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}

