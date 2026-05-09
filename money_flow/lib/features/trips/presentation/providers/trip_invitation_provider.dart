import 'package:flutter/foundation.dart';

import '../../data/models/trip_models.dart';
import '../../data/repositories/trip_member_repository.dart';

/// Provider para manejar la aceptación de invitaciones recibidas por deep link
class TripInvitationProvider extends ChangeNotifier {
  TripInvitationProvider({TripMemberRepository? repository})
      : _repository = repository ?? TripMemberRepository();

  final TripMemberRepository _repository;

  String? _pendingToken;
  bool _isProcessing = false;
  String? _error;
  TripMember? _acceptedMember;

  String? get pendingToken => _pendingToken;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  TripMember? get acceptedMember => _acceptedMember;
  bool get hasPending => _pendingToken != null && _pendingToken!.isNotEmpty;

  void setPendingToken(String token) {
    _pendingToken = token;
    _acceptedMember = null;
    _error = null;
    notifyListeners();
  }

  void clear() {
    _pendingToken = null;
    _acceptedMember = null;
    _error = null;
    notifyListeners();
  }

  Future<TripMember?> accept(String token) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();
    try {
      final member = await _repository.acceptInvitation(token);
      _acceptedMember = member;
      _pendingToken = null;
      return member;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
