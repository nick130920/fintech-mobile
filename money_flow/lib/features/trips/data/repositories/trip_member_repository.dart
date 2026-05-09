import 'package:http/http.dart' as http;

import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/trip_models.dart';

/// Repositorio HTTP para miembros e invitaciones de un viaje
class TripMemberRepository {
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

  Future<List<TripMember>> listMembers(int tripId) async {
    final token = await _token();
    final response = await ApiService.get('/trips/$tripId/members', token: token);
    final list = _decodeList(response);
    return list.whereType<Map<String, dynamic>>().map(TripMember.fromJson).toList();
  }

  Future<TripMember> addGhost(int tripId, Map<String, dynamic> body) async {
    final token = await _token();
    final response = await ApiService.post('/trips/$tripId/members', body, token: token);
    return TripMember.fromJson(_decodeData(response));
  }

  Future<TripMember> updateMember(int tripId, int memberId, Map<String, dynamic> body) async {
    final token = await _token();
    final response = await ApiService.put('/trips/$tripId/members/$memberId', body, token: token);
    return TripMember.fromJson(_decodeData(response));
  }

  Future<void> removeMember(int tripId, int memberId) async {
    final token = await _token();
    final response = await ApiService.delete('/trips/$tripId/members/$memberId', token: token);
    if (response.statusCode >= 400) {
      ApiService.handleResponse(response);
    }
  }

  Future<TripInvitation> createInvitation(int tripId, Map<String, dynamic> body) async {
    final token = await _token();
    final response = await ApiService.post('/trips/$tripId/invitations', body, token: token);
    return TripInvitation.fromJson(_decodeData(response));
  }

  Future<List<TripInvitation>> listInvitations(int tripId) async {
    final token = await _token();
    final response = await ApiService.get('/trips/$tripId/invitations', token: token);
    final list = _decodeList(response);
    return list.whereType<Map<String, dynamic>>().map(TripInvitation.fromJson).toList();
  }

  Future<TripMember> acceptInvitation(String token) async {
    final accessToken = await _token();
    final response = await ApiService.post(
      '/trips/invitations/accept',
      {'token': token},
      token: accessToken,
    );
    return TripMember.fromJson(_decodeData(response));
  }
}
