import 'dart:convert';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/income_model.dart';

class IncomeRepository {
  // Crear un nuevo ingreso
  static Future<IncomeModel> createIncome({
    required double amount,
    required String description,
    required String source,
    required String date,
    String? notes,
    double? taxDeducted,
    bool isRecurring = false,
    String? frequency,
    String? endDate,
  }) async {
    final token = await StorageService.getAccessToken();
    if (token == null) throw Exception('No token found');

    final body = {
      'amount': amount,
      'description': description,
      'source': source,
      'date': date,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (taxDeducted != null) 'tax_deducted': taxDeducted,
      'is_recurring': isRecurring,
      if (frequency != null) 'frequency': frequency,
      if (endDate != null) 'end_date': endDate,
    };

    final response = await ApiService.post('/incomes/', body, token: token);
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return IncomeModel.fromJson(data['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to create income');
    }
  }

  // Obtener ingresos con filtros
  static Future<List<IncomeSummaryModel>> getIncomes({
    String? startDate,
    String? endDate,
    String? source,
    int limit = 10,
    int offset = 0,
  }) async {
    final token = await StorageService.getAccessToken();
    if (token == null) throw Exception('No token found');

    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (source != null) queryParams['source'] = source;

    final uri = Uri.parse('${ApiService.baseUrl}/incomes/')
        .replace(queryParameters: queryParams);

    final response = await ApiService.getUri(uri, token: token);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> incomes = data['data'] ?? [];
      return incomes.map((json) => IncomeSummaryModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load incomes');
    }
  }

  // Obtener ingreso por ID
  static Future<IncomeModel> getIncomeById(int id) async {
    final token = await StorageService.getAccessToken();
    if (token == null) throw Exception('No token found');

    final response = await ApiService.get('/incomes/$id', token: token);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return IncomeModel.fromJson(data['data']);
    } else {
      throw Exception('Failed to load income');
    }
  }

  // Obtener ingresos recientes
  static Future<List<IncomeSummaryModel>> getRecentIncomes({int limit = 10}) async {
    final token = await StorageService.getAccessToken();
    if (token == null) throw Exception('No token found');

    final response = await ApiService.get('/incomes/recent/?limit=$limit', token: token);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> incomes = data['data'] ?? [];
      return incomes.map((json) => IncomeSummaryModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recent incomes');
    }
  }

  // Obtener estadísticas de ingresos
  static Future<Map<String, dynamic>> getIncomeStats({int? year}) async {
    final token = await StorageService.getAccessToken();
    if (token == null) throw Exception('No token found');

    String endpoint = '/incomes/stats';
    if (year != null) {
      endpoint += '?year=$year';
    }

    final response = await ApiService.get(endpoint, token: token);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to load income stats');
    }
  }

  // Actualizar ingreso
  static Future<IncomeModel> updateIncome({
    required int id,
    double? amount,
    String? description,
    String? source,
    String? date,
    String? notes,
    double? taxDeducted,
    bool? isRecurring,
    String? frequency,
    String? endDate,
  }) async {
    final token = await StorageService.getAccessToken();
    if (token == null) throw Exception('No token found');

    final body = <String, dynamic>{};
    if (amount != null) body['amount'] = amount;
    if (description != null) body['description'] = description;
    if (source != null) body['source'] = source;
    if (date != null) body['date'] = date;
    if (notes != null) body['notes'] = notes;
    if (taxDeducted != null) body['tax_deducted'] = taxDeducted;
    if (isRecurring != null) body['is_recurring'] = isRecurring;
    if (frequency != null) body['frequency'] = frequency;
    if (endDate != null) body['end_date'] = endDate;

    final response = await ApiService.put('/incomes/$id/', body, token: token);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return IncomeModel.fromJson(data['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update income');
    }
  }

  // Eliminar ingreso
  static Future<void> deleteIncome(int id) async {
    final token = await StorageService.getAccessToken();
    if (token == null) throw Exception('No token found');

    final response = await ApiService.delete('/incomes/$id', token: token);
    
    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to delete income');
    }
  }

  // Procesar ingresos recurrentes
  static Future<Map<String, dynamic>> processRecurringIncomes() async {
    final token = await StorageService.getAccessToken();
    if (token == null) throw Exception('No token found');

    final response = await ApiService.post('/incomes/process-recurring/', {}, token: token);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to process recurring incomes');
    }
  }
}
