import 'package:http/http.dart' as http;

import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/trip_models.dart';

/// Repositorio HTTP para balance y settlements del viaje
class TripBalanceRepository {
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

  Future<TripBalance> getBalance(int tripId) async {
    final token = await _token();
    final response = await ApiService.get('/trips/$tripId/balance', token: token);
    return TripBalance.fromJson(_decodeData(response));
  }

  Future<List<Settlement>> listSettlements(int tripId) async {
    final token = await _token();
    final response = await ApiService.get('/trips/$tripId/settlements', token: token);
    final list = _decodeList(response);
    return list.whereType<Map<String, dynamic>>().map(Settlement.fromJson).toList();
  }

  Future<Settlement> createSettlement(int tripId, Map<String, dynamic> body) async {
    final token = await _token();
    final response = await ApiService.post('/trips/$tripId/settlements', body, token: token);
    return Settlement.fromJson(_decodeData(response));
  }

  Future<void> deleteSettlement(int tripId, int settlementId) async {
    final token = await _token();
    final response = await ApiService.delete(
      '/trips/$tripId/settlements/$settlementId',
      token: token,
    );
    if (response.statusCode >= 400) {
      ApiService.handleResponse(response);
    }
  }
}
