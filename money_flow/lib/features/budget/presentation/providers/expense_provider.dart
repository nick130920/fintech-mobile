import 'package:flutter/foundation.dart';

import '../../data/models/budget_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/expense_repository.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final BudgetRepository _budgetRepository = BudgetRepository();

  // Lista de gastos
  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> get expenses => _expenses;

  // Lista de gastos recientes
  List<ExpenseModel> _recentExpenses = [];
  List<ExpenseModel> get recentExpenses => _recentExpenses;

  // Categorías disponibles
  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  // Presupuesto actual
  BudgetModel? _currentBudget;
  BudgetModel? get currentBudget => _currentBudget;

  // Estado de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Filtros actuales
  ExpenseFilters _currentFilters = const ExpenseFilters();
  ExpenseFilters get currentFilters => _currentFilters;

  // Inicializar provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Cargar categorías, presupuesto y gastos del mes actual en paralelo
      await Future.wait([
        _loadCategories(),
        _loadCurrentBudget(),
        _loadRecentExpenses(),
        _loadMonthlyExpenses(),
      ]);
      _clearError();
    } catch (e) {
      _setError('Error al inicializar: $e');
    }
    _setLoading(false);
  }

  // Crear nuevo gasto
  Future<bool> createExpense({
    required int categoryId,
    required double amount,
    required String description,
    DateTime? date,
    String location = '',
    String merchant = '',
    List<String> tags = const [],
    String notes = '',
  }) async {
    _setSubmitting(true);
    try {
      final expenseDate = date ?? DateTime.now();
      
      final newExpense = CreateExpenseModel(
        categoryId: categoryId,
        amount: amount,
        description: description,
        date: expenseDate.toIso8601String(),
        location: location,
        merchant: merchant,
        tags: tags,
        notes: notes,
        source: 'manual',
      );

      final createdExpense = await _expenseRepository.createExpense(newExpense);
      
      // Agregar al inicio de la lista
      _expenses.insert(0, createdExpense);
      _recentExpenses.insert(0, createdExpense);
      
      // Mantener solo los 10 más recientes
      if (_recentExpenses.length > 10) {
        _recentExpenses = _recentExpenses.take(10).toList();
      }
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al crear gasto: $e');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Cargar gastos con filtros
  Future<void> loadExpenses({ExpenseFilters? filters}) async {
    _setLoading(true);
    try {
      _currentFilters = filters ?? const ExpenseFilters();
      _expenses = await _expenseRepository.getExpenses(filters: _currentFilters);
      _clearError();
    } catch (e) {
      _setError('Error al cargar gastos: $e');
    }
    _setLoading(false);
  }

  // Cargar más gastos (paginación)
  Future<void> loadMoreExpenses() async {
    if (_isLoading) return;

    try {
      final nextFilters = ExpenseFilters(
        categoryId: _currentFilters.categoryId,
        startDate: _currentFilters.startDate,
        endDate: _currentFilters.endDate,
        limit: _currentFilters.limit,
        offset: _currentFilters.offset + _currentFilters.limit,
      );

      final moreExpenses = await _expenseRepository.getExpenses(filters: nextFilters);
      
      if (moreExpenses.isNotEmpty) {
        _expenses.addAll(moreExpenses);
        _currentFilters = nextFilters;
        notifyListeners();
      }
    } catch (e) {
      _setError('Error al cargar más gastos: $e');
    }
  }

  // Actualizar gasto
  Future<bool> updateExpense(int expenseId, Map<String, dynamic> updates) async {
    try {
      final updatedExpense = await _expenseRepository.updateExpense(expenseId, updates);
      
      // Actualizar en las listas
      final expenseIndex = _expenses.indexWhere((e) => e.id == expenseId);
      if (expenseIndex != -1) {
        _expenses[expenseIndex] = updatedExpense;
      }
      
      final recentIndex = _recentExpenses.indexWhere((e) => e.id == expenseId);
      if (recentIndex != -1) {
        _recentExpenses[recentIndex] = updatedExpense;
      }
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al actualizar gasto: $e');
      return false;
    }
  }

  // Eliminar gasto
  Future<bool> deleteExpense(int expenseId) async {
    try {
      await _expenseRepository.deleteExpense(expenseId);
      
      // Remover de las listas
      _expenses.removeWhere((e) => e.id == expenseId);
      _recentExpenses.removeWhere((e) => e.id == expenseId);
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al eliminar gasto: $e');
      return false;
    }
  }

  // Aplicar filtros
  void applyFilters(ExpenseFilters filters) {
    _currentFilters = filters;
    loadExpenses(filters: filters);
  }

  // Limpiar filtros
  void clearFilters() {
    _currentFilters = const ExpenseFilters();
    loadExpenses();
  }

  // Métodos privados
  Future<void> _loadCategories() async {
    _categories = await _budgetRepository.getCategories();
  }

  Future<void> _loadCurrentBudget() async {
    try {
      _currentBudget = await _budgetRepository.getCurrentBudget();
    } catch (e) {
      // Si no hay presupuesto configurado, _currentBudget será null
      _currentBudget = null;
    }
  }

  Future<void> _loadRecentExpenses() async {
    _recentExpenses = await _expenseRepository.getRecentExpenses(limit: 10);
  }

  Future<void> _loadMonthlyExpenses() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
    
    final monthlyFilters = ExpenseFilters(
      startDate: startOfMonth,
      endDate: endOfMonth,
      limit: 200, // Límite más alto para capturar todos los gastos del mes
    );
    
    _expenses = await _expenseRepository.getExpenses(filters: monthlyFilters);
    _currentFilters = monthlyFilters;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helpers
  List<ExpenseModel> getExpensesByCategory(int categoryId) {
    return _expenses.where((expense) => expense.category.id == categoryId).toList();
  }

  double getTotalSpent() {
    return _expenses
        .where((expense) => expense.isConfirmed)
        .map((expense) => expense.amount)
        .fold(0.0, (sum, amount) => sum + amount);
  }

  double getTotalSpentByCategory(int categoryId) {
    return _expenses
        .where((expense) => expense.category.id == categoryId && expense.isConfirmed)
        .map((expense) => expense.amount)
        .fold(0.0, (sum, amount) => sum + amount);
  }

  // Obtener gastos del día actual
  List<ExpenseModel> get todayExpenses {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _expenses.where((expense) {
      final expenseDate = expense.dateTime;
      return expenseDate.isAfter(startOfDay) && expenseDate.isBefore(endOfDay);
    }).toList();
  }

  // Obtener gastos del mes actual
  List<ExpenseModel> get monthlyExpenses {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    
    return _expenses.where((expense) {
      final expenseDate = expense.dateTime;
      return expenseDate.isAfter(startOfMonth) && expenseDate.isBefore(endOfMonth);
    }).toList();
  }

  // Obtener total de gastos del mes
  double get monthlyTotal {
    return monthlyExpenses
        .where((expense) => expense.isConfirmed)
        .map((expense) => expense.amount)
        .fold(0.0, (sum, amount) => sum + amount);
  }

  // Obtener categorías principales por gasto
  List<Map<String, dynamic>> get topCategories {
    final Map<String, double> categoryTotals = {};
    final Map<String, CategoryModel> categoryMap = {};
    
    for (final expense in monthlyExpenses.where((e) => e.isConfirmed)) {
      final categoryName = expense.category.name;
      categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + expense.amount;
      categoryMap[categoryName] = expense.category;
    }
    
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedCategories.map((entry) => {
      'name': entry.key,
      'amount': entry.value,
      'category': categoryMap[entry.key]!,
    }).toList();
  }

  // Obtener gastos por categoría con presupuesto (para barras de progreso)
  List<Map<String, dynamic>> getCategoryBudgetProgress() {
    // Si no hay presupuesto configurado, retornar lista vacía
    if (_currentBudget == null || _currentBudget!.allocations.isEmpty) {
      return [];
    }
    
    // Calcular gastos por categoría del mes actual
    final Map<String, double> categoryTotals = {};
    final Map<String, CategoryModel> categoryMap = {};
    
    for (final expense in monthlyExpenses.where((e) => e.isConfirmed)) {
      final categoryName = expense.category.name;
      categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + expense.amount;
      categoryMap[categoryName] = expense.category;
    }
    
    // Crear lista de progreso basada en las asignaciones reales del presupuesto
    final List<Map<String, dynamic>> progressList = [];
    
    for (final allocation in _currentBudget!.allocations) {
      final categoryName = allocation.category.name;
      final spent = categoryTotals[categoryName] ?? 0.0;
      final budget = allocation.allocatedAmount;
      
      progressList.add({
        'name': categoryName,
        'spent': spent,
        'budget': budget,
        'category': allocation.category,
        'allocation': allocation, // Incluir la asignación completa para más datos
      });
    }
    
    // Ordenar por cantidad gastada (descendente) y tomar los primeros 3
    progressList.sort((a, b) => (b['spent'] as double).compareTo(a['spent'] as double));
    return progressList.take(3).toList();
  }

  // Refrescar datos
  Future<void> refresh() async {
    await Future.wait([
      _loadCurrentBudget(),
      _loadRecentExpenses(),
      _loadMonthlyExpenses(),
    ]);
  }
}
