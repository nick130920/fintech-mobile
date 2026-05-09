import 'package:flutter/foundation.dart';

import '../../data/models/trip_models.dart';
import '../../data/repositories/trip_expense_repository.dart';
import '../../data/repositories/trip_itinerary_repository.dart';
import '../../data/repositories/trip_member_repository.dart';
import '../../data/repositories/trip_repository.dart';

/// Provider para el viaje activo: detalle, miembros, presupuesto, gastos e itinerario
class ActiveTripProvider extends ChangeNotifier {
  ActiveTripProvider({
    TripRepository? tripRepository,
    TripMemberRepository? memberRepository,
    TripExpenseRepository? expenseRepository,
    TripItineraryRepository? itineraryRepository,
  })  : _tripRepository = tripRepository ?? TripRepository(),
        _memberRepository = memberRepository ?? TripMemberRepository(),
        _expenseRepository = expenseRepository ?? TripExpenseRepository(),
        _itineraryRepository = itineraryRepository ?? TripItineraryRepository();

  final TripRepository _tripRepository;
  final TripMemberRepository _memberRepository;
  final TripExpenseRepository _expenseRepository;
  final TripItineraryRepository _itineraryRepository;

  Trip? _trip;
  List<TripMember> _members = const [];
  List<TripAllocation> _allocations = const [];
  List<TripExpense> _expenses = const [];
  List<TripItineraryItem> _itinerary = const [];
  List<TripInvitation> _invitations = const [];

  bool _isLoading = false;
  String? _error;

  Trip? get trip => _trip;
  List<TripMember> get members => _members;
  List<TripAllocation> get allocations => _allocations;
  List<TripExpense> get expenses => _expenses;
  List<TripItineraryItem> get itinerary => _itinerary;
  List<TripInvitation> get invitations => _invitations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasTrip => _trip != null;

  Future<void> load(int id) async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _tripRepository.getTrip(id),
        _memberRepository.listMembers(id),
        _tripRepository.getBudget(id),
        _expenseRepository.list(id),
        _itineraryRepository.list(id),
      ]);
      _trip = results[0] as Trip;
      _members = results[1] as List<TripMember>;
      _allocations = results[2] as List<TripAllocation>;
      _expenses = results[3] as List<TripExpense>;
      _itinerary = results[4] as List<TripItineraryItem>;
      _error = null;
    } catch (e) {
      _error = _humanError(e);
    } finally {
      _setLoading(false);
    }
  }

  void clear() {
    _trip = null;
    _members = const [];
    _allocations = const [];
    _expenses = const [];
    _itinerary = const [];
    _invitations = const [];
    _error = null;
    notifyListeners();
  }

  Future<bool> updateTrip(Map<String, dynamic> body) async {
    if (_trip == null) return false;
    try {
      _trip = await _tripRepository.updateTrip(_trip!.id, body);
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeStatus(String action) async {
    if (_trip == null) return false;
    try {
      _trip = await _tripRepository.changeStatus(_trip!.id, action);
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> upsertBudget(List<Map<String, dynamic>> allocations) async {
    if (_trip == null) return false;
    try {
      _allocations = await _tripRepository.upsertBudget(_trip!.id, allocations);
      await refreshTrip();
      return true;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> reloadMembers() async {
    if (_trip == null) return false;
    try {
      _members = await _memberRepository.listMembers(_trip!.id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<TripMember?> addGhostMember(Map<String, dynamic> body) async {
    if (_trip == null) return null;
    try {
      final member = await _memberRepository.addGhost(_trip!.id, body);
      _members = [..._members, member];
      notifyListeners();
      return member;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateMember(int memberId, Map<String, dynamic> body) async {
    if (_trip == null) return false;
    try {
      final updated = await _memberRepository.updateMember(_trip!.id, memberId, body);
      _members = _members.map((m) => m.id == memberId ? updated : m).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeMember(int memberId) async {
    if (_trip == null) return false;
    try {
      await _memberRepository.removeMember(_trip!.id, memberId);
      _members = _members.where((m) => m.id != memberId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<TripInvitation?> createInvitation(Map<String, dynamic> body) async {
    if (_trip == null) return null;
    try {
      final invitation = await _memberRepository.createInvitation(_trip!.id, body);
      _invitations = [..._invitations, invitation];
      notifyListeners();
      return invitation;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> reloadInvitations() async {
    if (_trip == null) return false;
    try {
      _invitations = await _memberRepository.listInvitations(_trip!.id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<TripExpense?> addExpense(Map<String, dynamic> body) async {
    if (_trip == null) return null;
    try {
      final expense = await _expenseRepository.create(_trip!.id, body);
      _expenses = [expense, ..._expenses];
      await refreshTrip();
      return expense;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateExpense(int expenseId, Map<String, dynamic> body) async {
    if (_trip == null) return false;
    try {
      final updated = await _expenseRepository.update(_trip!.id, expenseId, body);
      _expenses = _expenses.map((e) => e.id == expenseId ? updated : e).toList();
      await refreshTrip();
      return true;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeExpense(int expenseId) async {
    if (_trip == null) return false;
    try {
      await _expenseRepository.delete(_trip!.id, expenseId);
      _expenses = _expenses.where((e) => e.id != expenseId).toList();
      await refreshTrip();
      return true;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<TripItineraryItem?> addItineraryItem(Map<String, dynamic> body) async {
    if (_trip == null) return null;
    try {
      final item = await _itineraryRepository.create(_trip!.id, body);
      _itinerary = [..._itinerary, item];
      _itinerary.sort((a, b) => a.day.compareTo(b.day));
      notifyListeners();
      return item;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateItineraryItem(int itemId, Map<String, dynamic> body) async {
    if (_trip == null) return false;
    try {
      final updated = await _itineraryRepository.update(_trip!.id, itemId, body);
      _itinerary = _itinerary.map((i) => i.id == itemId ? updated : i).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeItineraryItem(int itemId) async {
    if (_trip == null) return false;
    try {
      await _itineraryRepository.delete(_trip!.id, itemId);
      _itinerary = _itinerary.where((i) => i.id != itemId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> linkItineraryExpense(int itemId, int expenseId) async {
    if (_trip == null) return false;
    try {
      final updated = await _itineraryRepository.linkExpense(_trip!.id, itemId, expenseId);
      _itinerary = _itinerary.map((i) => i.id == itemId ? updated : i).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshTrip() async {
    if (_trip == null) return;
    try {
      _trip = await _tripRepository.getTrip(_trip!.id);
      notifyListeners();
    } catch (_) {
      // Mantener el trip cacheado si falla la actualización en background
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _humanError(Object error) => error.toString().replaceFirst('Exception: ', '');
}
