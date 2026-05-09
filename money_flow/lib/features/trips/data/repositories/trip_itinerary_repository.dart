import 'package:http/http.dart' as http;

import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/trip_models.dart';

/// Repositorio HTTP para los items del itinerario del viaje
class TripItineraryRepository {
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

  Future<List<TripItineraryItem>> list(int tripId) async {
    final token = await _token();
    final response = await ApiService.get('/trips/$tripId/itinerary', token: token);
    final list = _decodeList(response);
    return list.whereType<Map<String, dynamic>>().map(TripItineraryItem.fromJson).toList();
  }

  Future<TripItineraryItem> create(int tripId, Map<String, dynamic> body) async {
    final token = await _token();
    final response = await ApiService.post('/trips/$tripId/itinerary', body, token: token);
    return TripItineraryItem.fromJson(_decodeData(response));
  }

  Future<TripItineraryItem> update(int tripId, int itemId, Map<String, dynamic> body) async {
    final token = await _token();
    final response = await ApiService.put('/trips/$tripId/itinerary/$itemId', body, token: token);
    return TripItineraryItem.fromJson(_decodeData(response));
  }

  Future<void> delete(int tripId, int itemId) async {
    final token = await _token();
    final response = await ApiService.delete('/trips/$tripId/itinerary/$itemId', token: token);
    if (response.statusCode >= 400) {
      ApiService.handleResponse(response);
    }
  }

  Future<TripItineraryItem> linkExpense(int tripId, int itemId, int expenseId) async {
    final token = await _token();
    final response = await ApiService.post(
      '/trips/$tripId/itinerary/$itemId/link-expense',
      {'expense_id': expenseId},
      token: token,
    );
    return TripItineraryItem.fromJson(_decodeData(response));
  }
}
