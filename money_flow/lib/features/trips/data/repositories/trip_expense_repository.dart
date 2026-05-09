import 'package:http/http.dart' as http;

import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/trip_models.dart';

/// Repositorio HTTP para los gastos de un viaje
class TripExpenseRepository {
  Future<String?> _token() => StorageService.getAccessToken();

  Map<String, dynamic> _decodeData(http.Response response) {
    final decoded = ApiService.handleResponse(response);
    if (decoded == null) return const {};
    return (decoded['data'] ?? const {}) as Map<String, dynamic>;
  }

  List<dynamic> _decodeList(http.Response response) {
    final decoded = ApiService.handleResponse(response);
    if (decoded == null) return const [];
    final data = decoded['data'];
    if (data is List) return data;
    return const [];
  }

  Future<List<TripExpense>> list(int tripId) async {
    final token = await _token();
    final response = await ApiService.get('/trips/$tripId/expenses', token: token);
    final list = _decodeList(response);
    return list.whereType<Map<String, dynamic>>().map(TripExpense.fromJson).toList();
  }

  Future<TripExpense> create(int tripId, Map<String, dynamic> body) async {
    final token = await _token();
    final response = await ApiService.post('/trips/$tripId/expenses', body, token: token);
    return TripExpense.fromJson(_decodeData(response));
  }

  Future<TripExpense> update(int tripId, int expenseId, Map<String, dynamic> body) async {
    final token = await _token();
    final response = await ApiService.put('/trips/$tripId/expenses/$expenseId', body, token: token);
    return TripExpense.fromJson(_decodeData(response));
  }

  Future<void> delete(int tripId, int expenseId) async {
    final token = await _token();
    final response = await ApiService.delete('/trips/$tripId/expenses/$expenseId', token: token);
    if (response.statusCode >= 400) {
      ApiService.handleResponse(response);
    }
  }
}
