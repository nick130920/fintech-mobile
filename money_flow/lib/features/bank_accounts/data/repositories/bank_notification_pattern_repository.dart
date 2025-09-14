import 'dart:convert';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/bank_notification_pattern_model.dart';

class BankNotificationPatternRepository {
  BankNotificationPatternRepository();

  // Obtener todos los patrones del usuario
  Future<List<BankNotificationPatternModel>> getPatterns() async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.get('/notification-patterns', token: token);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BankNotificationPatternModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notification patterns: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching notification patterns: $e');
    }
  }

  // Obtener un patrón por ID
  Future<BankNotificationPatternModel> getPattern(int id) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.get('/notification-patterns/$id', token: token);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BankNotificationPatternModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Notification pattern not found');
      } else {
        throw Exception('Failed to load notification pattern: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching notification pattern: $e');
    }
  }

  // Obtener patrones de una cuenta bancaria específica
  Future<List<BankNotificationPatternModel>> getBankAccountPatterns(
    int bankAccountId, {
    bool activeOnly = false,
  }) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      String endpoint = '/notification-patterns/bank-account/$bankAccountId';
      if (activeOnly) {
        endpoint += '?active_only=true';
      }
      final response = await ApiService.get(endpoint, token: token);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BankNotificationPatternModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bank account patterns: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bank account patterns: $e');
    }
  }

  // Crear nuevo patrón
  Future<BankNotificationPatternModel> createPattern(
    CreateBankNotificationPatternRequest request,
  ) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.post('/notification-patterns', request.toJson(), token: token);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return BankNotificationPatternModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Bank account not found');
      } else {
        throw Exception('Failed to create notification pattern: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating notification pattern: $e');
    }
  }

  // Actualizar patrón
  Future<BankNotificationPatternModel> updatePattern(
    int id,
    UpdateBankNotificationPatternRequest request,
  ) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.put('/notification-patterns/$id', request.toJson(), token: token);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BankNotificationPatternModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Notification pattern not found');
      } else {
        throw Exception('Failed to update notification pattern: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating notification pattern: $e');
    }
  }

  // Eliminar patrón
  Future<void> deletePattern(int id) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.delete('/notification-patterns/$id', token: token);

      if (response.statusCode != 204) {
        if (response.statusCode == 404) {
          throw Exception('Notification pattern not found');
        } else {
          throw Exception('Failed to delete notification pattern: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error deleting notification pattern: $e');
    }
  }

  // Cambiar estado del patrón
  Future<void> setPatternStatus(int id, NotificationPatternStatus status) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      // Usar PUT ya que no hay método patch
      final response = await ApiService.put('/notification-patterns/$id/status', {'status': status.name}, token: token);

      if (response.statusCode != 204) {
        if (response.statusCode == 404) {
          throw Exception('Notification pattern not found');
        } else {
          throw Exception('Failed to update pattern status: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error updating pattern status: $e');
    }
  }

  // Procesar notificación
  Future<ProcessedNotificationModel> processNotification(
    ProcessNotificationRequest request,
  ) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.post('/notification-patterns/process', request.toJson(), token: token);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProcessedNotificationModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Bank account not found');
      } else {
        throw Exception('Failed to process notification: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error processing notification: $e');
    }
  }

  // Obtener estadísticas de patrones
  Future<PatternStatisticsModel> getPatternStatistics() async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.get('/notification-patterns/statistics', token: token);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PatternStatisticsModel.fromJson(data);
      } else {
        throw Exception('Failed to load pattern statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching pattern statistics: $e');
    }
  }
}
