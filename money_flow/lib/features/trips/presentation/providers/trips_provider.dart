import 'package:flutter/foundation.dart';

import '../../data/models/trip_models.dart';
import '../../data/repositories/trip_repository.dart';

/// Provider para la lista de viajes del usuario y la creación de nuevos viajes
class TripsProvider extends ChangeNotifier {
  TripsProvider({TripRepository? repository}) : _repository = repository ?? TripRepository();

  final TripRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<Trip> _trips = const [];
  String _statusFilter = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Trip> get trips => _trips;
  String get statusFilter => _statusFilter;

  List<Trip> filterByStatus(TripStatus? status) {
    if (status == null) return _trips;
    return _trips.where((t) => t.status == status).toList();
  }

  Future<void> load({String status = ''}) async {
    _setLoading(true);
    _statusFilter = status;
    try {
      _trips = await _repository.listTrips(status: status);
      _error = null;
    } catch (e) {
      _error = _humanError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<Trip?> create(Map<String, dynamic> body) async {
    _setLoading(true);
    try {
      final trip = await _repository.createTrip(body);
      _trips = [trip, ..._trips];
      _error = null;
      return trip;
    } catch (e) {
      _error = _humanError(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTrip(int id) async {
    try {
      await _repository.deleteTrip(id);
      _trips = _trips.where((t) => t.id != id).toList();
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanError(e);
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _humanError(Object error) => error.toString().replaceFirst('Exception: ', '');
}
