import 'package:flutter/foundation.dart';

import '../../data/models/sms_budget_suggestion.dart';
import '../../data/services/budget_suggestions_service.dart';

/// Provider para sugerencias de presupuesto (SMS últimos 3 meses o extracto bancario).
class BudgetSuggestionsProvider with ChangeNotifier {
  final BudgetSuggestionsService _service = BudgetSuggestionsService();

  bool _isAnalyzing = false;
  bool get isAnalyzing => _isAnalyzing;

  String? _error;
  String? get error => _error;

  SmsBudgetSuggestion? _suggestion;
  SmsBudgetSuggestion? get suggestion => _suggestion;

  /// Analiza SMS de los últimos 3 meses y guarda la sugerencia en [suggestion].
  Future<void> analyzeLast3Months() async {
    if (_isAnalyzing) return;

    _isAnalyzing = true;
    _error = null;
    _suggestion = null;
    notifyListeners();

    try {
      _suggestion = await _service.analyzeLast3Months();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst(RegExp(r'^Exception:?\s*'), '');
      _suggestion = null;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Analiza un archivo de extracto bancario por ruta y guarda la sugerencia en [suggestion].
  Future<void> analyzeStatement(String filePath) async {
    if (_isAnalyzing) return;

    _isAnalyzing = true;
    _error = null;
    _suggestion = null;
    notifyListeners();

    try {
      _suggestion = await _service.analyzeStatement(filePath);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst(RegExp(r'^Exception:?\s*'), '');
      _suggestion = null;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  void clearSuggestion() {
    _suggestion = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
