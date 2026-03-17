/// DTO para sugerencias de presupuesto (SMS o extracto bancario).
class SmsBudgetSuggestion {
  final double totalSuggested;
  final List<SmsBudgetSuggestionCategory> byCategory;

  const SmsBudgetSuggestion({
    required this.totalSuggested,
    required this.byCategory,
  });
}

class SmsBudgetSuggestionCategory {
  final int categoryId;
  final String categoryName;
  final double total;
  final double percentage;

  const SmsBudgetSuggestionCategory({
    required this.categoryId,
    required this.categoryName,
    required this.total,
    required this.percentage,
  });
}
