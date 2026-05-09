import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/trip_models.dart';

/// Repositorio para operaciones HTTP relacionadas con viajes
class TripRepository {
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

  Future<List<Trip>> listTrips({String? status}) async {
    final token = await _token();
    final endpoint = status != null && status.isNotEmpty
        ? '/trips?status=$status'
        : '/trips';
    final response = await ApiService.get(endpoint, token: token);
    final list = _decodeList(response);
    return list.whereType<Map<String, dynamic>>().map(Trip.fromJson).toList();
  }

  Future<Trip> createTrip(Map<String, dynamic> body) async {
    final token = await _token();
    final response = await ApiService.post('/trips', body, token: token);
    return Trip.fromJson(_decodeData(response));
  }

  Future<Trip> getTrip(int id) async {
    final token = await _token();
    final response = await ApiService.get('/trips/$id', token: token);
    return Trip.fromJson(_decodeData(response));
  }

  Future<Trip> updateTrip(int id, Map<String, dynamic> body) async {
    final token = await _token();
    final response = await ApiService.put('/trips/$id', body, token: token);
    return Trip.fromJson(_decodeData(response));
  }

  Future<void> deleteTrip(int id) async {
    final token = await _token();
    final response = await ApiService.delete('/trips/$id', token: token);
    if (response.statusCode >= 400) {
      ApiService.handleResponse(response);
    }
  }

  Future<Trip> changeStatus(int id, String action) async {
    final token = await _token();
    final response = await ApiService.post('/trips/$id/$action', const {}, token: token);
    return Trip.fromJson(_decodeData(response));
  }

  Future<List<TripAllocation>> getBudget(int id) async {
    final token = await _token();
    final response = await ApiService.get('/trips/$id/budget', token: token);
    final list = _decodeList(response);
    return list.whereType<Map<String, dynamic>>().map(TripAllocation.fromJson).toList();
  }

  Future<List<TripAllocation>> upsertBudget(int id, List<Map<String, dynamic>> allocations) async {
    final token = await _token();
    final response = await ApiService.put(
      '/trips/$id/budget',
      {'allocations': allocations},
      token: token,
    );
    final list = _decodeList(response);
    return list.whereType<Map<String, dynamic>>().map(TripAllocation.fromJson).toList();
  }

  /// Descarga el reporte exportado (CSV o PDF) como bytes
  Future<List<int>> downloadReport(int id, String format) async {
    final token = await _token();
    final uri = Uri.parse('${ApiService.baseUrl}/trips/$id/report/export?format=$format');
    final response = await ApiService.getUri(uri, token: token);
    if (response.statusCode >= 400) {
      ApiService.handleResponse(response);
    }
    return response.bodyBytes;
  }

  Future<TripReport> getReport(int id) async {
    final token = await _token();
    final response = await ApiService.get('/trips/$id/report', token: token);
    return TripReport.fromJson(_decodeData(response));
  }

  Future<List<TripImportSuggestion>> suggestImport(int id) async {
    final token = await _token();
    final response = await ApiService.get('/trips/$id/import-suggestions', token: token);
    final list = _decodeList(response);
    return list.whereType<Map<String, dynamic>>().map(TripImportSuggestion.fromJson).toList();
  }

  Future<int> assignImport(int id, List<int> expenseIds) async {
    final token = await _token();
    final response = await ApiService.post(
      '/trips/$id/import-suggestions',
      {'expense_ids': expenseIds},
      token: token,
    );
    final data = _decodeData(response);
    return (data['assigned'] is num) ? (data['assigned'] as num).toInt() : 0;
  }

  /// Helper para imprimir el body en logs/depuración
  static String prettyJson(Map<String, dynamic> body) => jsonEncode(body);
}
