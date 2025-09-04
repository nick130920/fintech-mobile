import 'package:flutter/material.dart';

import '../../data/repositories/dashboard_repository.dart';

class DashboardProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  // Dashboard data
  Map<String, dynamic> _dashboardSummary = {};
  Map<String, dynamic> _incomeStats = {};
  Map<String, dynamic> _budgetProgress = {};
  double _availableBalance = 0.0;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get dashboardSummary => _dashboardSummary;
  Map<String, dynamic> get incomeStats => _incomeStats;
  Map<String, dynamic> get budgetProgress => _budgetProgress;
  double get availableBalance => _availableBalance;

  // Computed getters
  double get totalSpent => (_dashboardSummary['total_spent'] as num?)?.toDouble() ?? 0.0;
  double get totalIncome => (_incomeStats['total_income'] as num?)?.toDouble() ?? 0.0;
  double get budgetTotal => (_budgetProgress['total_amount'] as num?)?.toDouble() ?? 0.0;
  double get budgetSpent => (_budgetProgress['spent_amount'] as num?)?.toDouble() ?? 0.0;
  double get budgetRemaining => budgetTotal - budgetSpent;
  double get budgetProgressValue => budgetTotal > 0 ? (budgetSpent / budgetTotal) : 0.0;

  // Trend calculations (comparing with previous period)
  double get spendingTrend {
    final previousSpent = (_dashboardSummary['previous_period_spent'] as num?)?.toDouble() ?? 0.0;
    if (previousSpent == 0) return 0.0;
    return ((totalSpent - previousSpent) / previousSpent) * 100;
  }

  double get incomeTrend {
    final previousIncome = (_incomeStats['previous_period_income'] as num?)?.toDouble() ?? 0.0;
    if (previousIncome == 0) return 0.0;
    return ((totalIncome - previousIncome) / previousIncome) * 100;
  }

  bool get isOverBudget => budgetTotal > 0 && budgetSpent > budgetTotal;
  bool get isNearingLimit => budgetTotal > 0 && budgetProgressValue >= 0.8;

  // Initialize dashboard data
  Future<void> initialize() async {
    await loadDashboardData();
  }

  // Load all dashboard data
  Future<void> loadDashboardData() async {
    _setLoading(true);
    _setError(null);

    try {
      // Load data in parallel for better performance
      final futures = await Future.wait([
        DashboardRepository.getDashboardSummary(),
        DashboardRepository.getIncomeStats(),
        DashboardRepository.getBudgetProgress(),
        DashboardRepository.getAvailableBalance(),
      ]);

      _dashboardSummary = futures[0] as Map<String, dynamic>;
      _incomeStats = futures[1] as Map<String, dynamic>;
      _budgetProgress = futures[2] as Map<String, dynamic>;
      _availableBalance = futures[3] as double;

      _setError(null);
    } catch (e) {
      _setError('Error al cargar datos del dashboard: $e');
      debugPrint('Dashboard error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboardData();
  }

  // Update available balance after income/expense changes
  Future<void> updateAvailableBalance() async {
    try {
      _availableBalance = await DashboardRepository.getAvailableBalance();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating available balance: $e');
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

  // Format helpers
  String getFormattedTotalSpent() {
    return _dashboardSummary['formatted_total_spent'] ?? '\$0.00';
  }

  String getFormattedTotalIncome() {
    return _incomeStats['formatted_total_income'] ?? '\$0.00';
  }

  String getFormattedAvailableBalance() {
    // This will be formatted by CurrencyProvider
    return _availableBalance.toString();
  }

  String getFormattedBudgetTotal() {
    return _budgetProgress['formatted_total_amount'] ?? '\$0.00';
  }

  String getFormattedBudgetSpent() {
    return _budgetProgress['formatted_spent_amount'] ?? '\$0.00';
  }

  // Get budget status message
  String getBudgetStatusMessage() {
    if (isOverBudget) {
      return 'Presupuesto excedido';
    } else if (isNearingLimit) {
      return 'Cerca del límite';
    } else if (budgetProgressValue > 0.5) {
      return 'En buen camino';
    } else {
      return 'Dentro del presupuesto';
    }
  }

  // Get budget status color
  Color getBudgetStatusColor() {
    if (isOverBudget) {
      return Colors.red;
    } else if (isNearingLimit) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  // Get budget status icon
  IconData getBudgetStatusIcon() {
    if (isOverBudget) {
      return Icons.error;
    } else if (isNearingLimit) {
      return Icons.warning;
    } else {
      return Icons.check_circle;
    }
  }
}
