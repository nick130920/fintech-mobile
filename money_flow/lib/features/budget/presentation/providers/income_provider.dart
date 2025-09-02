import 'package:flutter/material.dart';

import '../../data/models/income_model.dart';
import '../../data/repositories/income_repository.dart';

class IncomeProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<IncomeSummaryModel> _incomes = [];
  Map<String, dynamic> _incomeStats = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<IncomeSummaryModel> get incomes => _incomes;
  Map<String, dynamic> get incomeStats => _incomeStats;

  // Computed getters
  double get totalIncome => (_incomeStats['total_income'] as num?)?.toDouble() ?? 0.0;
  double get monthlyAverage => (_incomeStats['monthly_average'] as num?)?.toDouble() ?? 0.0;
  String get formattedTotalIncome => _incomeStats['formatted_total_income'] ?? '\$0.00';
  String get formattedMonthlyAverage => _incomeStats['formatted_monthly_average'] ?? '\$0.00';

  // Recent incomes
  List<IncomeSummaryModel> get recentIncomes => _incomes.take(5).toList();

  // Initialize provider
  Future<void> initialize() async {
    await Future.wait([
      loadIncomes(),
      loadIncomeStats(),
    ]);
  }

  // Load incomes
  Future<void> loadIncomes({
    String? startDate,
    String? endDate,
    String? source,
    int limit = 50,
    int offset = 0,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      _incomes = await IncomeRepository.getIncomes(
        startDate: startDate,
        endDate: endDate,
        source: source,
        limit: limit,
        offset: offset,
      );
      _setError(null);
    } catch (e) {
      _setError('Error al cargar ingresos: $e');
      print('Income loading error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load income statistics
  Future<void> loadIncomeStats({int? year}) async {
    try {
      _incomeStats = await IncomeRepository.getIncomeStats(year: year);
      notifyListeners();
    } catch (e) {
      print('Income stats loading error: $e');
    }
  }

  // Create income
  Future<bool> createIncome({
    required double amount,
    required String description,
    required String source,
    required DateTime date,
    String? notes,
    double? taxDeducted,
    bool isRecurring = false,
    String? frequency,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await IncomeRepository.createIncome(
        amount: amount,
        description: description,
        source: source,
        date: date.toIso8601String(),
        notes: notes,
        taxDeducted: taxDeducted,
        isRecurring: isRecurring,
        frequency: frequency,
        endDate: endDate?.toIso8601String(),
      );

      // Reload data after creation
      await Future.wait([
        loadIncomes(),
        loadIncomeStats(),
      ]);

      _setError(null);
      return true;
    } catch (e) {
      _setError('Error al crear ingreso: $e');
      print('Income creation error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update income
  Future<bool> updateIncome({
    required int id,
    double? amount,
    String? description,
    String? source,
    DateTime? date,
    String? notes,
    double? taxDeducted,
    bool? isRecurring,
    String? frequency,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await IncomeRepository.updateIncome(
        id: id,
        amount: amount,
        description: description,
        source: source,
        date: date?.toIso8601String(),
        notes: notes,
        taxDeducted: taxDeducted,
        isRecurring: isRecurring,
        frequency: frequency,
        endDate: endDate?.toIso8601String(),
      );

      // Reload data after update
      await Future.wait([
        loadIncomes(),
        loadIncomeStats(),
      ]);

      _setError(null);
      return true;
    } catch (e) {
      _setError('Error al actualizar ingreso: $e');
      print('Income update error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete income
  Future<bool> deleteIncome(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      await IncomeRepository.deleteIncome(id);

      // Reload data after deletion
      await Future.wait([
        loadIncomes(),
        loadIncomeStats(),
      ]);

      _setError(null);
      return true;
    } catch (e) {
      _setError('Error al eliminar ingreso: $e');
      print('Income deletion error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await initialize();
  }

  // Process recurring incomes
  Future<bool> processRecurringIncomes() async {
    try {
      await IncomeRepository.processRecurringIncomes();
      
      // Reload data after processing
      await Future.wait([
        loadIncomes(),
        loadIncomeStats(),
      ]);

      return true;
    } catch (e) {
      _setError('Error al procesar ingresos recurrentes: $e');
      print('Recurring incomes processing error: $e');
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Get income by source
  List<IncomeSummaryModel> getIncomesBySource(String source) {
    return _incomes.where((income) => income.source == source).toList();
  }

  // Get income for date range
  List<IncomeSummaryModel> getIncomesForDateRange(DateTime start, DateTime end) {
    return _incomes.where((income) {
      final incomeDate = income.dateTime;
      return incomeDate.isAfter(start.subtract(const Duration(days: 1))) &&
             incomeDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get total income for current month
  double get currentMonthIncome {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return getIncomesForDateRange(startOfMonth, endOfMonth)
        .fold(0.0, (sum, income) => sum + income.amount);
  }
}
