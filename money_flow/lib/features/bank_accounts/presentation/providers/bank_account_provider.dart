import 'package:flutter/foundation.dart';

import '../../data/models/bank_account_model.dart';
import '../../data/repositories/bank_account_repository.dart';

class BankAccountProvider with ChangeNotifier {
  final BankAccountRepository _repository;

  BankAccountProvider({BankAccountRepository? repository})
      : _repository = repository ?? BankAccountRepository();

  // Estado
  List<BankAccountModel> _bankAccounts = [];
  List<BankAccountSummaryModel> _bankAccountSummary = [];
  BankAccountModel? _selectedBankAccount;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BankAccountModel> get bankAccounts => _bankAccounts;
  List<BankAccountSummaryModel> get bankAccountSummary => _bankAccountSummary;
  BankAccountModel? get selectedBankAccount => _selectedBankAccount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cuentas activas
  List<BankAccountModel> get activeBankAccounts =>
      _bankAccounts.where((account) => account.isActive).toList();

  // Cuentas por tipo
  List<BankAccountModel> getBankAccountsByType(BankAccountType type) =>
      _bankAccounts.where((account) => account.type == type).toList();

  // Cuentas que pueden recibir notificaciones
  List<BankAccountModel> get notificationEnabledAccounts =>
      _bankAccounts.where((account) => account.canReceiveNotifications).toList();

  // Balance total
  double get totalBalance =>
      _bankAccounts.fold(0.0, (sum, account) => sum + account.lastBalance);

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Cargar todas las cuentas bancarias
  Future<void> loadBankAccounts({bool activeOnly = false}) async {
    if (_isLoading) return; // Evitar llamadas múltiples
    
    _setLoading(true);
    _clearError();

    try {
      _bankAccounts = await _repository.getBankAccounts(activeOnly: activeOnly);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Cargar resumen de cuentas bancarias
  Future<void> loadBankAccountSummary() async {
    if (_isLoading) return; // Evitar llamadas múltiples
    
    _setLoading(true);
    _clearError();

    try {
      _bankAccountSummary = await _repository.getBankAccountSummary();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Cargar cuenta bancaria específica
  Future<void> loadBankAccount(int id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedBankAccount = await _repository.getBankAccount(id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Crear nueva cuenta bancaria
  Future<bool> createBankAccount(CreateBankAccountRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final newAccount = await _repository.createBankAccount(request);
      _bankAccounts.add(newAccount);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar cuenta bancaria
  Future<bool> updateBankAccount(int id, UpdateBankAccountRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedAccount = await _repository.updateBankAccount(id, request);
      
      // Actualizar en la lista
      final index = _bankAccounts.indexWhere((account) => account.id == id);
      if (index != -1) {
        _bankAccounts[index] = updatedAccount;
      }
      
      // Actualizar cuenta seleccionada si es la misma
      if (_selectedBankAccount?.id == id) {
        _selectedBankAccount = updatedAccount;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar cuenta bancaria
  Future<bool> deleteBankAccount(int id) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteBankAccount(id);
      
      // Remover de la lista
      _bankAccounts.removeWhere((account) => account.id == id);
      
      // Limpiar cuenta seleccionada si es la misma
      if (_selectedBankAccount?.id == id) {
        _selectedBankAccount = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cambiar estado activo
  Future<bool> setActiveStatus(int id, bool isActive) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.setActiveStatus(id, isActive);
      
      // Actualizar en la lista
      final index = _bankAccounts.indexWhere((account) => account.id == id);
      if (index != -1) {
        _bankAccounts[index] = _bankAccounts[index].copyWith(isActive: isActive);
      }
      
      // Actualizar cuenta seleccionada si es la misma
      if (_selectedBankAccount?.id == id) {
        _selectedBankAccount = _selectedBankAccount!.copyWith(isActive: isActive);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar balance
  Future<bool> updateBalance(int id, double balance) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.updateBalance(id, balance);
      
      // Actualizar en la lista
      final index = _bankAccounts.indexWhere((account) => account.id == id);
      if (index != -1) {
        _bankAccounts[index] = _bankAccounts[index].copyWith(
          lastBalance: balance,
          lastBalanceUpdate: DateTime.now().toIso8601String(),
        );
      }
      
      // Actualizar cuenta seleccionada si es la misma
      if (_selectedBankAccount?.id == id) {
        _selectedBankAccount = _selectedBankAccount!.copyWith(
          lastBalance: balance,
          lastBalanceUpdate: DateTime.now().toIso8601String(),
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cargar cuentas por tipo
  Future<void> loadBankAccountsByType(BankAccountType type) async {
    _setLoading(true);
    _clearError();

    try {
      final accounts = await _repository.getBankAccountsByType(type);
      // Actualizar solo las cuentas del tipo especificado
      _bankAccounts.removeWhere((account) => account.type == type);
      _bankAccounts.addAll(accounts);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Seleccionar cuenta bancaria
  void selectBankAccount(BankAccountModel? account) {
    _selectedBankAccount = account;
    notifyListeners();
  }

  // Limpiar selección
  void clearSelection() {
    _selectedBankAccount = null;
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _clearError();
  }

  // Refrescar datos
  Future<void> refresh() async {
    await loadBankAccounts();
    await loadBankAccountSummary();
  }
}
