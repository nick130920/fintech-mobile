import 'package:flutter/foundation.dart';
import 'package:money_flow/features/bank_accounts/data/models/transaction_model.dart';
import 'package:money_flow/features/bank_accounts/data/repositories/automatic_transactions_repository.dart';

class AutomaticTransactionsProvider with ChangeNotifier {
  // Estado de carga
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  // Transacciones pendientes
  List<TransactionModel> _pendingTransactions = [];
  int _pendingCount = 0;
  bool _hasPendingLoaded = false;

  // Transacciones automáticas
  List<TransactionModel> _automaticTransactions = [];
  bool _hasAutomaticLoaded = false;

  // Estadísticas
  AutomaticTransactionStats? _stats;

  // Filtros y paginación
  int _currentPage = 0;
  static const int _pageSize = 20;
  bool _hasMorePending = true;
  bool _hasMoreAutomatic = true;

  // Getters
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  
  List<TransactionModel> get pendingTransactions => _pendingTransactions;
  int get pendingCount => _pendingCount;
  bool get hasPendingTransactions => _pendingTransactions.isNotEmpty;
  
  List<TransactionModel> get automaticTransactions => _automaticTransactions;
  bool get hasAutomaticTransactions => _automaticTransactions.isNotEmpty;
  
  AutomaticTransactionStats? get stats => _stats;
  
  bool get hasMorePending => _hasMorePending;
  bool get hasMoreAutomatic => _hasMoreAutomatic;

  /// Carga transacciones pendientes de revisión
  Future<void> loadPendingTransactions({bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    
    try {
      _isLoading = true;
      _error = null;
      
      if (refresh) {
        _pendingTransactions.clear();
        _currentPage = 0;
        _hasMorePending = true;
      }
      
      notifyListeners();

      final transactions = await AutomaticTransactionsRepository.getPendingTransactions(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      if (refresh) {
        _pendingTransactions = transactions;
      } else {
        _pendingTransactions.addAll(transactions);
      }

      _hasMorePending = transactions.length == _pageSize;
      _currentPage++;
      _hasPendingLoaded = true;

      // También cargar el conteo
      await _loadPendingCount();

    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading pending transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga más transacciones pendientes (paginación)
  Future<void> loadMorePendingTransactions() async {
    if (!_hasMorePending || _isLoading) return;
    await loadPendingTransactions();
  }

  /// Carga transacciones automáticas
  Future<void> loadAutomaticTransactions({
    bool refresh = false,
    String? fromDate,
    String? toDate,
  }) async {
    if (_isLoading && !refresh) return;
    
    try {
      _isLoading = true;
      _error = null;
      
      if (refresh) {
        _automaticTransactions.clear();
        _currentPage = 0;
        _hasMoreAutomatic = true;
      }
      
      notifyListeners();

      final transactions = await AutomaticTransactionsRepository.getAutomaticTransactions(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
        fromDate: fromDate,
        toDate: toDate,
      );

      if (refresh) {
        _automaticTransactions = transactions;
      } else {
        _automaticTransactions.addAll(transactions);
      }

      _hasMoreAutomatic = transactions.length == _pageSize;
      _currentPage++;
      _hasAutomaticLoaded = true;

    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading automatic transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga más transacciones automáticas (paginación)
  Future<void> loadMoreAutomaticTransactions() async {
    if (!_hasMoreAutomatic || _isLoading) return;
    await loadAutomaticTransactions();
  }

  /// Aprueba una transacción
  Future<bool> approveTransaction(int transactionId) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();

      final updatedTransaction = await AutomaticTransactionsRepository.approveTransaction(transactionId);
      
      // Actualizar la transacción en la lista
      _updateTransactionInList(updatedTransaction);
      
      // Decrementar el conteo de pendientes
      if (_pendingCount > 0) {
        _pendingCount--;
      }

      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error approving transaction: $e');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Rechaza una transacción
  Future<bool> rejectTransaction(int transactionId, {String? reason}) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();

      await AutomaticTransactionsRepository.rejectTransaction(transactionId, reason: reason);
      
      // Remover la transacción de la lista de pendientes
      _pendingTransactions.removeWhere((t) => t.id == transactionId);
      
      // Decrementar el conteo de pendientes
      if (_pendingCount > 0) {
        _pendingCount--;
      }

      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error rejecting transaction: $e');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Edita y aprueba una transacción
  Future<bool> editAndApproveTransaction(
    int transactionId, {
    double? amount,
    String? description,
    int? categoryId,
    String? notes,
  }) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();

      final updatedTransaction = await AutomaticTransactionsRepository.editAndApproveTransaction(
        transactionId,
        amount: amount,
        description: description,
        categoryId: categoryId,
        notes: notes,
      );
      
      // Actualizar la transacción en la lista
      _updateTransactionInList(updatedTransaction);
      
      // Decrementar el conteo de pendientes
      if (_pendingCount > 0) {
        _pendingCount--;
      }

      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error editing and approving transaction: $e');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Procesa múltiples transacciones en lote
  Future<BatchProcessResult?> processBatchTransactions(
    List<int> transactionIds,
    String action,
  ) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();

      final result = await AutomaticTransactionsRepository.processBatchTransactions(
        transactionIds,
        action,
      );

      // Actualizar las listas según la acción
      if (action == 'approve') {
        // Las transacciones aprobadas se mantienen pero cambian de estado
        for (final id in transactionIds) {
          final transaction = _pendingTransactions.firstWhere(
            (t) => t.id == id,
            orElse: () => throw StateError('Transaction not found'),
          );
          final updated = transaction.copyWith(
            validationStatus: ValidationStatus.manualValidated,
          );
          _updateTransactionInList(updated);
        }
      } else if (action == 'reject') {
        // Las transacciones rechazadas se remueven de pendientes
        _pendingTransactions.removeWhere((t) => transactionIds.contains(t.id));
      }

      // Actualizar conteo
      _pendingCount = (_pendingCount - result.successful).clamp(0, double.infinity).toInt();

      return result;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error processing batch transactions: $e');
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Carga estadísticas de transacciones automáticas
  Future<void> loadStats({int days = 30}) async {
    try {
      _stats = await AutomaticTransactionsRepository.getAutomaticTransactionStats(days: days);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  /// Carga el conteo de transacciones pendientes
  Future<void> _loadPendingCount() async {
    try {
      _pendingCount = await AutomaticTransactionsRepository.getPendingTransactionsCount();
    } catch (e) {
      debugPrint('Error loading pending count: $e');
    }
  }

  /// Actualiza una transacción en las listas
  void _updateTransactionInList(TransactionModel updatedTransaction) {
    // Actualizar en pendientes
    final pendingIndex = _pendingTransactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (pendingIndex != -1) {
      if (updatedTransaction.isPendingReview) {
        _pendingTransactions[pendingIndex] = updatedTransaction;
      } else {
        _pendingTransactions.removeAt(pendingIndex);
      }
    }

    // Actualizar en automáticas
    final automaticIndex = _automaticTransactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (automaticIndex != -1) {
      _automaticTransactions[automaticIndex] = updatedTransaction;
    } else if (updatedTransaction.isFromNotification) {
      // Añadir al inicio si es nueva transacción automática
      _automaticTransactions.insert(0, updatedTransaction);
    }
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresca todos los datos
  Future<void> refreshAll() async {
    await Future.wait([
      loadPendingTransactions(refresh: true),
      loadAutomaticTransactions(refresh: true),
      loadStats(),
    ]);
  }

  /// Inicializa los datos si no se han cargado
  Future<void> initializeIfNeeded() async {
    if (!_hasPendingLoaded && !_hasAutomaticLoaded) {
      await Future.wait([
        loadPendingTransactions(),
        loadStats(),
      ]);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

