import 'dart:convert';
import 'package:money_flow/core/services/api_service.dart';
import 'package:money_flow/core/services/storage_service.dart';
import 'package:money_flow/features/bank_accounts/data/models/transaction_model.dart';

/// Servicio para guardar transacciones automáticas desde notificaciones
class AutomaticTransactionService {
  /// Guarda una transacción extraída de una notificación
  static Future<bool> saveTransaction({
    required Map<String, dynamic> transactionData,
    required String rawNotification,
  }) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        print('❌ No hay token de autenticación');
        return false;
      }

      // Obtener la cuenta bancaria predeterminada o la primera disponible
      // TODO: Mejorar esto para que el usuario pueda configurar qué cuenta usar
      final accountId = await _getDefaultAccountId(token);
      if (accountId == null) {
        print('❌ No se encontró cuenta bancaria');
        return false;
      }

      // Convertir el tipo de transacción
      final transactionType = _convertTransactionType(transactionData['type'] as String);
      
      // Preparar el cuerpo de la solicitud
      final body = {
        'type': transactionType,
        'amount': transactionData['amount'],
        'description': transactionData['description'],
        'account_id': accountId,
        'transaction_date': transactionData['transaction_date'],
        'merchant': transactionData['merchant'],
        'source': 'notification',
        'raw_notification': rawNotification,
        'ai_confidence': transactionData['ai_confidence'],
        'currency': 'COP', // Peso Colombiano
        'notes': 'Transacción automática desde notificación (${transactionData['bank_name']})',
      };

      print('📤 Enviando transacción al servidor...');
      print('Body: $body');

      final response = await ApiService.post('/transactions', body, token: token);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Transacción guardada exitosamente: ${responseData['id'] ?? 'Sin ID'}');
        
        // Guardar localmente la última transacción procesada
        await _saveLastProcessedTransaction(transactionData);
        
        return true;
      } else {
        print('❌ Error al guardar transacción: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error al guardar transacción: $e');
      return false;
    }
  }

  /// Convierte el tipo de transacción del parser al formato de la API
  static String _convertTransactionType(String type) {
    switch (type) {
      case 'expense':
        return 'expense';
      case 'income':
        return 'income';
      case 'transfer':
        return 'transfer';
      default:
        return 'expense'; // Por defecto asumimos que es un gasto
    }
  }

  /// Obtiene el ID de la cuenta bancaria predeterminada
  /// TODO: Permitir al usuario configurar qué cuenta usar para transacciones automáticas
  static Future<int?> _getDefaultAccountId(String token) async {
    try {
      // Intentar obtener cuentas bancarias
      final response = await ApiService.get('/bank-accounts', token: token);
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> accounts = responseData['data'] ?? responseData;
        
        if (accounts.isNotEmpty) {
          // Por ahora, usar la primera cuenta
          // TODO: Mejorar para usar una cuenta configurada o detectar por el banco
          final firstAccount = accounts.first;
          return int.tryParse(firstAccount['id'].toString());
        }
      }

      // Si no hay cuentas bancarias, intentar con cuentas de presupuesto
      final accountsResponse = await ApiService.get('/accounts', token: token);
      
      if (accountsResponse.statusCode == 200) {
        final accountsData = json.decode(accountsResponse.body);
        final List<dynamic> budgetAccounts = accountsData['data'] ?? accountsData;
        
        if (budgetAccounts.isNotEmpty) {
          final firstAccount = budgetAccounts.first;
          return int.tryParse(firstAccount['id'].toString());
        }
      }

      return null;
    } catch (e) {
      print('❌ Error al obtener cuenta predeterminada: $e');
      return null;
    }
  }

  /// Guarda información de la última transacción procesada (para estadísticas)
  static Future<void> _saveLastProcessedTransaction(Map<String, dynamic> transactionData) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await StorageService.saveData('last_auto_transaction_timestamp', timestamp.toString());
      await StorageService.saveData('last_auto_transaction_amount', transactionData['amount'].toString());
      await StorageService.saveData('last_auto_transaction_type', transactionData['type'].toString());
      print('📊 Última transacción guardada localmente');
    } catch (e) {
      print('⚠️ Error al guardar última transacción localmente: $e');
    }
  }

  /// Obtiene estadísticas de transacciones automáticas procesadas hoy
  static Future<Map<String, dynamic>> getTodayStats() async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) return {'count': 0, 'total': 0.0};

      final today = DateTime.now();
      final fromDate = DateTime(today.year, today.month, today.day).toIso8601String();
      final toDate = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

      final queryParams = {
        'source': 'notification',
        'from_date': fromDate,
        'to_date': toDate,
      };

      final uri = Uri.parse('${ApiService.baseUrl}/transactions').replace(
        queryParameters: queryParams,
      );

      final response = await ApiService.getUri(uri, token: token);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> transactions = responseData['data'] ?? [];

        double total = 0.0;
        for (final transaction in transactions) {
          total += (transaction['amount'] as num).toDouble();
        }

        return {
          'count': transactions.length,
          'total': total,
        };
      }

      return {'count': 0, 'total': 0.0};
    } catch (e) {
      print('❌ Error al obtener estadísticas de hoy: $e');
      return {'count': 0, 'total': 0.0};
    }
  }

  /// Verifica si una notificación ya fue procesada (para evitar duplicados)
  static Future<bool> isNotificationProcessed(String notificationText) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) return false;

      // Buscar transacciones con la misma notificación en las últimas 24 horas
      final yesterday = DateTime.now().subtract(const Duration(hours: 24)).toIso8601String();
      
      final queryParams = {
        'source': 'notification',
        'from_date': yesterday,
        'limit': '100',
      };

      final uri = Uri.parse('${ApiService.baseUrl}/transactions').replace(
        queryParameters: queryParams,
      );

      final response = await ApiService.getUri(uri, token: token);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> transactions = responseData['data'] ?? [];

        // Buscar si alguna transacción tiene la misma notificación
        for (final transaction in transactions) {
          final rawNotification = transaction['raw_notification'] as String?;
          if (rawNotification != null && rawNotification.trim() == notificationText.trim()) {
            print('⚠️ Notificación ya procesada anteriormente');
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      print('⚠️ Error al verificar duplicados: $e');
      return false; // En caso de error, permitir procesar
    }
  }

  /// Guarda múltiples transacciones en lote
  static Future<Map<String, dynamic>> saveBatchTransactions(
    List<Map<String, dynamic>> transactions,
  ) async {
    int successful = 0;
    int failed = 0;
    final List<String> errors = [];

    for (final transaction in transactions) {
      try {
        final rawNotification = transaction['raw_notification'] as String? ?? 'Notificación desconocida';
        final success = await saveTransaction(
          transactionData: transaction,
          rawNotification: rawNotification,
        );

        if (success) {
          successful++;
        } else {
          failed++;
          errors.add('Error al guardar transacción: ${transaction['description']}');
        }
      } catch (e) {
        failed++;
        errors.add('Error: $e');
      }
    }

    return {
      'total': transactions.length,
      'successful': successful,
      'failed': failed,
      'errors': errors,
    };
  }
}


