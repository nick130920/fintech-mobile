import 'package:flutter/foundation.dart';

import '../../../../core/services/storage_service.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/budget_repository.dart';

enum BudgetSetupStep {
  totalAmount,
  selectCategories,
  assignPercentages,
  completed,
}

class BudgetSetupProvider with ChangeNotifier {
  final BudgetRepository _repository = BudgetRepository();
  
  // Getter para acceder al repository desde otros lugares
  BudgetRepository get repository => _repository;

  // Estado del stepper
  BudgetSetupStep _currentStep = BudgetSetupStep.totalAmount;
  BudgetSetupStep get currentStep => _currentStep;

  // Paso 1: Monto total
  double _totalAmount = 0.0;
  double get totalAmount => _totalAmount;

  // Paso 2: Categorías seleccionadas
  List<CategoryModel> _availableCategories = [];
  List<CategoryModel> get availableCategories => _availableCategories;

  final List<CategoryModel> _selectedCategories = [];
  List<CategoryModel> get selectedCategories => _selectedCategories;

  // Paso 3: Asignación de porcentajes
  Map<int, double> _categoryPercentages = {};
  Map<int, double> get categoryPercentages => _categoryPercentages;

  // Estado de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Progreso del stepper
  double get progress {
    switch (_currentStep) {
      case BudgetSetupStep.totalAmount:
        return 0.33;
      case BudgetSetupStep.selectCategories:
        return 0.66;
      case BudgetSetupStep.assignPercentages:
        return 1.0;
      case BudgetSetupStep.completed:
        return 1.0;
    }
  }

  int get stepIndex {
    switch (_currentStep) {
      case BudgetSetupStep.totalAmount:
        return 0;
      case BudgetSetupStep.selectCategories:
        return 1;
      case BudgetSetupStep.assignPercentages:
        return 2;
      case BudgetSetupStep.completed:
        return 3;
    }
  }

  // Inicializar provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _availableCategories = await _repository.getCategories();
      _clearError();
    } catch (e) {
      _setError('Error al cargar categorías: $e');
      // Usar categorías por defecto en caso de error
      _availableCategories = CategoryModel.defaultCategories;
    }
    _setLoading(false);
  }

  // PASO 1: Configurar monto total
  void setTotalAmount(double amount) {
    _totalAmount = amount;
    notifyListeners();
  }

  bool get canProceedFromStep1 => _totalAmount > 0;

  void proceedToStep2() {
    if (canProceedFromStep1) {
      _currentStep = BudgetSetupStep.selectCategories;
      notifyListeners();
    }
  }

  // PASO 2: Seleccionar categorías
  void toggleCategorySelection(CategoryModel category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
      _categoryPercentages.remove(category.id);
    } else {
      _selectedCategories.add(category);
      // Asignar porcentaje por defecto si está disponible
      final defaultPercentage = CategoryModel.defaultPercentages[category.id];
      if (defaultPercentage != null) {
        _categoryPercentages[category.id] = defaultPercentage;
      }
    }
    
    _redistributePercentages();
    notifyListeners();
  }

  void useDefaultCategories() {
    _selectedCategories.clear();
    _categoryPercentages.clear();
    
    // Seleccionar las principales categorías predeterminadas
    final mainCategories = _availableCategories
        .where((cat) => [1, 2, 3, 4].contains(cat.id))
        .toList();
    
    _selectedCategories.addAll(mainCategories);
    
    // Asignar porcentajes por defecto
    for (final category in mainCategories) {
      _categoryPercentages[category.id] = 
          CategoryModel.defaultPercentages[category.id] ?? 25.0;
    }
    
    _redistributePercentages();
    notifyListeners();
  }

  bool get canProceedFromStep2 => _selectedCategories.isNotEmpty;

  void proceedToStep3() {
    if (canProceedFromStep2) {
      _currentStep = BudgetSetupStep.assignPercentages;
      // Asegurar que los porcentajes sumen 100%
      _redistributePercentages();
      notifyListeners();
    }
  }

  // PASO 3: Asignar porcentajes
  void setCategoryPercentage(int categoryId, double percentage) {
    _categoryPercentages[categoryId] = percentage;
    notifyListeners();
  }

  void _redistributePercentages() {
    if (_selectedCategories.isEmpty) return;

    final currentTotal = _categoryPercentages.values
        .fold(0.0, (sum, percentage) => sum + percentage);

    if (currentTotal != 100.0) {
      // Redistribuir proporcionalmente para que sumen 100%
      final factor = 100.0 / currentTotal;
      final newPercentages = <int, double>{};
      
      for (final category in _selectedCategories) {
        final currentPercentage = _categoryPercentages[category.id] ?? 0.0;
        newPercentages[category.id] = 
            double.parse((currentPercentage * factor).toStringAsFixed(1));
      }
      
      _categoryPercentages = newPercentages;
    }
  }

  double get totalPercentage => _categoryPercentages.values
      .fold(0.0, (sum, percentage) => sum + percentage);

  bool get canProceedFromStep3 => 
      totalPercentage == 100.0 && _selectedCategories.isNotEmpty;

  // Finalizar configuración
  Future<void> completeBudgetSetup() async {
    if (!canProceedFromStep3) return;

    _setLoading(true);
    try {
      // Verificar autenticación antes de crear presupuesto
      final hasToken = await StorageService.isLoggedIn();
      if (!hasToken) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      }
      final now = DateTime.now();
      final allocations = _selectedCategories.map((category) {
        final percentage = _categoryPercentages[category.id]!;
        final amount = (_totalAmount * percentage / 100);
        
        return CreateAllocationModel(
          categoryId: category.id,
          allocatedAmount: amount,
          alertThreshold: 0.8, // 80% por defecto
        );
      }).toList();

      final budgetRequest = CreateBudgetModel(
        year: now.year,
        month: now.month,
        totalAmount: _totalAmount,
        allocations: allocations,
      );

      await _repository.createBudget(budgetRequest);
      
      _currentStep = BudgetSetupStep.completed;
      _clearError();
    } catch (e) {
      _setError('Error al crear presupuesto: $e');
    }
    _setLoading(false);
  }

  // Navegación del stepper
  void goBack() {
    switch (_currentStep) {
      case BudgetSetupStep.selectCategories:
        _currentStep = BudgetSetupStep.totalAmount;
        break;
      case BudgetSetupStep.assignPercentages:
        _currentStep = BudgetSetupStep.selectCategories;
        break;
      default:
        break;
    }
    notifyListeners();
  }

  void reset() {
    _currentStep = BudgetSetupStep.totalAmount;
    _totalAmount = 0.0;
    _selectedCategories.clear();
    _categoryPercentages.clear();
    _clearError();
    notifyListeners();
  }

  // Helpers de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
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

  // Helpers para UI (el formateo de divisa se hace en el widget con CurrencyProvider)
  double getCategoryAmount(int categoryId) {
    final percentage = _categoryPercentages[categoryId] ?? 0.0;
    return _totalAmount * percentage / 100;
  }
}
