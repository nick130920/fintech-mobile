import 'package:flutter/foundation.dart';

import '../../data/models/trip_models.dart';
import '../../data/repositories/trip_balance_repository.dart';

/// Provider que expone el balance del viaje y los settlements registrados
class TripBalanceProvider extends ChangeNotifier {
  TripBalanceProvider({TripBalanceRepository? repository})
      : _repository = repository ?? TripBalanceRepository();

  final TripBalanceRepository _repository;

  TripBalance? _balance;
  List<Settlement> _settlements = const [];
  bool _isLoading = false;
  String? _error;

  TripBalance? get balance => _balance;
  List<Settlement> get settlements => _settlements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load(int tripId) async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _repository.getBalance(tripId),
        _repository.listSettlements(tripId),
      ]);
      _balance = results[0] as TripBalance;
      _settlements = results[1] as List<Settlement>;
      _error = null;
    } catch (e) {
      _error = _humanError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<Settlement?> createSettlement(int tripId, Map<String, dynamic> body) async {
    try {
      final settlement = await _repository.createSettlement(tripId, body);
      _settlements = [settlement, ..._settlements];
      _balance = await _repository.getBalance(tripId);
      _error = null;
      notifyListeners();
      return settlement;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteSettlement(int tripId, int settlementId) async {
    try {
      await _repository.deleteSettlement(tripId, settlementId);
      _settlements = _settlements.where((s) => s.id != settlementId).toList();
      _balance = await _repository.getBalance(tripId);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _balance = null;
    _settlements = const [];
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _humanError(Object error) => error.toString().replaceFirst('Exception: ', '');
}
