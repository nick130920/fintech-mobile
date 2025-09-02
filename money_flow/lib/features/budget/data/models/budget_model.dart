import 'package:json_annotation/json_annotation.dart';

import 'category_model.dart';

part 'budget_model.g.dart';

@JsonSerializable()
class BudgetModel {
  final int id;
  final int year;
  final int month;
  @JsonKey(name: 'period_string')
  final String periodString;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  @JsonKey(name: 'spent_amount')
  final double spentAmount;
  @JsonKey(name: 'remaining_amount')
  final double remainingAmount;
  @JsonKey(name: 'progress_percent')
  final double progressPercent;
  @JsonKey(name: 'remaining_days')
  final int remainingDays;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_current_month')
  final bool isCurrentMonth;
  final List<AllocationModel> allocations;

  const BudgetModel({
    required this.id,
    required this.year,
    required this.month,
    required this.periodString,
    required this.totalAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.progressPercent,
    required this.remainingDays,
    required this.isActive,
    required this.isCurrentMonth,
    required this.allocations,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetModelFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetModelToJson(this);

  // Helper methods
  String get formattedTotalAmount => '\$${totalAmount.toStringAsFixed(2)}';
  String get formattedSpentAmount => '\$${spentAmount.toStringAsFixed(2)}';
  String get formattedRemainingAmount => '\$${remainingAmount.toStringAsFixed(2)}';
  
  double get dailyBudget => remainingDays > 0 ? remainingAmount / remainingDays : 0.0;
  String get formattedDailyBudget => '\$${dailyBudget.toStringAsFixed(2)}';

  bool get isOverBudget => spentAmount > totalAmount;
  bool get isNearLimit => progressPercent >= 80.0;
}

@JsonSerializable()
class AllocationModel {
  final int id;
  final CategoryModel category;
  @JsonKey(name: 'allocated_amount')
  final double allocatedAmount;
  @JsonKey(name: 'spent_amount')
  final double spentAmount;
  @JsonKey(name: 'remaining_amount')
  final double remainingAmount;
  @JsonKey(name: 'progress_percent')
  final double progressPercent;
  @JsonKey(name: 'daily_limit')
  final double dailyLimit;
  @JsonKey(name: 'current_daily_limit')
  final double currentDailyLimit;
  @JsonKey(name: 'alert_threshold')
  final double alertThreshold;
  @JsonKey(name: 'is_over_budget')
  final bool isOverBudget;
  @JsonKey(name: 'should_alert')
  final bool shouldAlert;
  @JsonKey(name: 'allocation_percent')
  final double allocationPercent;

  const AllocationModel({
    required this.id,
    required this.category,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.progressPercent,
    required this.dailyLimit,
    required this.currentDailyLimit,
    required this.alertThreshold,
    required this.isOverBudget,
    required this.shouldAlert,
    required this.allocationPercent,
  });

  factory AllocationModel.fromJson(Map<String, dynamic> json) =>
      _$AllocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$AllocationModelToJson(this);

  // Helper methods
  String get formattedAllocatedAmount => '\$${allocatedAmount.toStringAsFixed(2)}';
  String get formattedSpentAmount => '\$${spentAmount.toStringAsFixed(2)}';
  String get formattedRemainingAmount => '\$${remainingAmount.toStringAsFixed(2)}';
  String get formattedDailyLimit => '\$${currentDailyLimit.toStringAsFixed(2)}';
}

// Modelo para crear un presupuesto
@JsonSerializable()
class CreateBudgetModel {
  final int year;
  final int month;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  final List<CreateAllocationModel> allocations;

  const CreateBudgetModel({
    required this.year,
    required this.month,
    required this.totalAmount,
    required this.allocations,
  });

  factory CreateBudgetModel.fromJson(Map<String, dynamic> json) =>
      _$CreateBudgetModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBudgetModelToJson(this);
}

@JsonSerializable()
class CreateAllocationModel {
  @JsonKey(name: 'category_id')
  final int categoryId;
  @JsonKey(name: 'allocated_amount')
  final double allocatedAmount;
  @JsonKey(name: 'alert_threshold')
  final double alertThreshold;

  const CreateAllocationModel({
    required this.categoryId,
    required this.allocatedAmount,
    this.alertThreshold = 0.8, // 80% por defecto
  });

  factory CreateAllocationModel.fromJson(Map<String, dynamic> json) =>
      _$CreateAllocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAllocationModelToJson(this);
}
