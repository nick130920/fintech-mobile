import 'dart:convert';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';

class DashboardRepository {
  // Obtener resumen del dashboard
  static Future<Map<String, dynamic>> getDashboardSummary() async {
    final token = await StorageService.getAccessToken();
    if (token == null) throw Exception('No token found');

    final response = await ApiService.get('/budgets/dashboard/', token: token);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to load dashboard summary');
    }
  }

  // Obtener estadísticas de ingresos
  static Future<Map<String, dynamic>> getIncomeStats() async {
    final token = await StorageService.getAccessToken();
    if (token == null) throw Exception('No token found');

    final response = await ApiService.get('/incomes/stats/', token: token);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to load income stats');
    }
  }

  // Obtener balance disponible (ingresos - gastos)
  static Future<double> getAvailableBalance() async {
    try {
      // Obtener datos en paralelo
      final futures = await Future.wait([
        getDashboardSummary(),
        getIncomeStats(),
      ]);
      
      final dashboardData = futures[0];
      final incomeData = futures[1];
      
      // Calcular balance disponible
      final totalIncome = (incomeData['total_income'] as num?)?.toDouble() ?? 0.0;
      final totalSpent = (dashboardData['total_spent'] as num?)?.toDouble() ?? 0.0;
      
      return totalIncome - totalSpent;
    } catch (e) {
      print('Error calculating available balance: $e');
      return 0.0;
    }
  }

  // Obtener progreso del presupuesto
  static Future<Map<String, dynamic>> getBudgetProgress() async {
    final token = await StorageService.getAccessToken();
    if (token == null) throw Exception('No token found');

    final response = await ApiService.get('/budgets/current/', token: token);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to load budget progress');
    }
  }
}
