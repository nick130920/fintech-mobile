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
        final List<dynamic> data = responseData['data'] ?? [];
        return data.map((json) => TransactionModel.fromJson(json)).toList();
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
      final uri = Uri.parse('${ApiService.baseUrl}/transactions/automatic-stats').replace(
        queryParameters: queryParams,
      );

      final token = await StorageService.getAccessToken();
      final response = await ApiService.getUri(uri, token: token);

      if (response.statusCode == 200) {
        final responseData = ApiService.handleResponse(response);
        return AutomaticTransactionStats.fromJson(responseData);
      } else {
        throw Exception('Error al obtener estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  /// Obtiene el conteo de transacciones pendientes
  static Future<int> getPendingTransactionsCount() async {
    try {
      final queryParams = {
        'validation_status': 'pending_review',
      };

      // Construir URI con query parameters
      final uri = Uri.parse('${ApiService.baseUrl}/transactions/count').replace(
        queryParameters: queryParams,
      );

      final token = await StorageService.getAccessToken();
      final response = await ApiService.getUri(uri, token: token);

      if (response.statusCode == 200) {
        final responseData = ApiService.handleResponse(response);
        return responseData['count'] ?? 0;
      } else {
        throw Exception('Error al obtener conteo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener conteo: $e');
    }
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

