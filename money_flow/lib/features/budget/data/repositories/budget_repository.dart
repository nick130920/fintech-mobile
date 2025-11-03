import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';

class BudgetRepository {

  // Obtener categorías disponibles
  Future<List<CategoryModel>> getCategories() async {
    try {
      final token = await StorageService.getAccessToken();
      
      final response = await ApiService.get('/categories', token: token);
      final data = ApiService.handleResponse(response)['data'] as Map<String, dynamic>;
      
      // Combinar categorías por defecto y del usuario
      final List<dynamic> defaultCategories = data['default_categories'] ?? [];
      final List<dynamic> userCategories = data['user_categories'] ?? [];
      
      final allCategories = [...defaultCategories, ...userCategories];
      
      return allCategories
          .map((category) => CategoryModel.fromJson(category))
          .toList();
    } catch (e) {
      // En caso de error, devolver categorías por defecto
      return CategoryModel.defaultCategories;
    }
  }

  // Crear presupuesto
  Future<BudgetModel> createBudget(CreateBudgetModel budget) async {
    try {
      final token = await StorageService.getAccessToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Token de autenticación no encontrado. Por favor inicia sesión.');
      }
      
      final response = await ApiService.post('/budgets/', budget.toJson(), token: token);
      
      final responseData = ApiService.handleResponse(response);
      final data = responseData['data'];
      
      if (data == null) {
        throw Exception('El servidor no devolvió datos del presupuesto');
      }
      
      return BudgetModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Obtener presupuesto actual
  Future<BudgetModel?> getCurrentBudget() async {
    try {
      final token = await StorageService.getAccessToken();
      
      final response = await ApiService.get('/budgets/current', token: token);
      
      if (response.statusCode == 404) {
        // No hay presupuesto para el mes actual
        return null;
      }
      
      final data = ApiService.handleResponse(response)['data'];
      return BudgetModel.fromJson(data);
    } catch (e) {
      // Re-lanzar el error para que sea manejado en el UI
      rethrow;
    }
  }

  // Obtener dashboard
  Future<Map<String, dynamic>?> getDashboard() async {
    try {
      final token = await StorageService.getAccessToken();
      
      final response = await ApiService.get('/budgets/dashboard', token: token);
      final data = ApiService.handleResponse(response)['data'];
      
      return data;
    } catch (e) {
      return null;
    }
  }

  // Verificar si el usuario ya tiene un presupuesto configurado
  Future<bool> hasBudgetConfigured() async {
    final budget = await getCurrentBudget();
    return budget != null;
  }

  // Actualizar allocation de una categoría
  Future<AllocationModel> updateAllocation(int allocationId, double newAmount) async {
    try {
      final token = await StorageService.getAccessToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Token de autenticación no encontrado. Por favor inicia sesión.');
      }
      
      final body = {
        'allocated_amount': newAmount,
      };
      
      final response = await ApiService.put('/budgets/allocations/$allocationId', body, token: token);
      
      final responseData = ApiService.handleResponse(response);
      final data = responseData['data'];
      
      if (data == null) {
        throw Exception('El servidor no devolvió datos de la asignación');
      }
      
      return AllocationModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
