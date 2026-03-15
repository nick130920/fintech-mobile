import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/dashboard_repository.dart';

class DashboardProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isRefreshing = false;
   String? _error;
  bool _hasLoadedOnce = false;

  // Dashboard data
  Map<String, dynamic> _dashboardSummary = {};
  Map<String, dynamic> _incomeStats = {};
  Map<String, dynamic> _budgetProgress = {};
  double _availableBalance = 0.0;

  // Getters
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  bool get hasCachedData => _hasLoadedOnce;
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

  /// Presupuesto restante repartido por los días que quedan en el mes (para chip "Daily Rollover").
  double get dailyRollover {
    if (budgetRemaining <= 0) return 0.0;
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final daysLeft = lastDay.day - now.day + 1;
    if (daysLeft <= 0) return budgetRemaining;
    return budgetRemaining / daysLeft;
  }

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

  // Initialize dashboard data (cache-first: no loading si ya hay datos).
  Future<void> initialize() async {
    await loadDashboardData();
  }

  // Load all dashboard data. Si ya hay datos en caché, refresca en silencio.
  Future<void> loadDashboardData({bool forceShowLoading = false}) async {
    if (_isLoading) return;
    final useCache = _hasLoadedOnce && !forceShowLoading;
    if (!useCache) {
      _setLoading(true);
    } else {
      _isRefreshing = true;
      notifyListeners();
    }
    _setError(null);

    try {
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

      _hasLoadedOnce = true;
      _setError(null);
    } catch (e) {
      _setError('Error al cargar datos del dashboard: $e');
      debugPrint('Dashboard error: $e');
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  // Refresh dashboard data (pull-to-refresh: puede mostrar indicador sutil).
  Future<void> refresh() async {
    await loadDashboardData(forceShowLoading: false);
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

  // Get budget status color (AppColors para consistencia con el tema)
  Color getBudgetStatusColor() {
    if (isOverBudget) {
      return AppColors.statusDanger;
    } else if (isNearingLimit) {
      return AppColors.statusWarning;
    } else {
      return AppColors.statusGood;
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
