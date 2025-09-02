import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  // Crear gasto
  Future<ExpenseModel> createExpense(CreateExpenseModel expense) async {
    final token = await StorageService.getAccessToken();
    
    if (token == null || token.isEmpty) {
      throw Exception('Token de autenticación no encontrado. Por favor inicia sesión.');
    }
    
    final response = await ApiService.post('/expenses/', expense.toJson(), token: token);
    final responseData = ApiService.handleResponse(response);
    final data = responseData['data'];
    
    if (data == null) {
      throw Exception('El servidor no devolvió datos del gasto');
    }
    
    return ExpenseModel.fromJson(data);
  }

  // Obtener gastos con filtros
  Future<List<ExpenseModel>> getExpenses({ExpenseFilters? filters}) async {
    try {
      final token = await StorageService.getAccessToken();
      
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      // Construir URL con parámetros de query
      String endpoint = '/expenses/';
      if (filters != null) {
        final params = filters.toQueryParams();
        if (params.isNotEmpty) {
          final queryString = params.entries
              .map((e) => '${e.key}=${e.value}')
              .join('&');
          endpoint += '?$queryString';
        }
      }

      final response = await ApiService.get(endpoint, token: token);
      final responseData = ApiService.handleResponse(response);
      final data = responseData['data'] as List<dynamic>;
      
      return data.map((expense) => ExpenseModel.fromJson(expense)).toList();
    } catch (e) {
      return [];
    }
  }

  // Obtener gastos recientes
  Future<List<ExpenseModel>> getRecentExpenses({int limit = 10}) async {
    try {
      final token = await StorageService.getAccessToken();
      
      if (token == null) {
        return [];
      }

      final response = await ApiService.get('/expenses/recent?limit=$limit', token: token);
      final responseData = ApiService.handleResponse(response);
      final data = responseData['data'] as List<dynamic>;
      
      return data.map((expense) => ExpenseModel.fromJson(expense)).toList();
    } catch (e) {
      return [];
    }
  }

  // Obtener gastos por categoría  
  Future<Map<String, dynamic>?> getExpensesByCategory() async {
    try {
      final token = await StorageService.getAccessToken();
      
      if (token == null) {
        return null;
      }

      final response = await ApiService.get('/expenses/by-category', token: token);
      final responseData = ApiService.handleResponse(response);
      
      return responseData['data'];
    } catch (e) {
      return null;
    }
  }

  // Actualizar gasto
  Future<ExpenseModel> updateExpense(int expenseId, Map<String, dynamic> updates) async {
    final token = await StorageService.getAccessToken();
    
    if (token == null || token.isEmpty) {
      throw Exception('Token de autenticación no encontrado');
    }
    
    final response = await ApiService.put('/expenses/$expenseId', updates, token: token);
    final responseData = ApiService.handleResponse(response);
    final data = responseData['data'];
    
    return ExpenseModel.fromJson(data);
  }

  // Eliminar gasto
  Future<void> deleteExpense(int expenseId) async {
    final token = await StorageService.getAccessToken();
    
    if (token == null || token.isEmpty) {
      throw Exception('Token de autenticación no encontrado');
    }
    
    await ApiService.delete('/expenses/$expenseId', token: token);
  }
}
