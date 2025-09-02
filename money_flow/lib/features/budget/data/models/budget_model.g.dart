// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetModel _$BudgetModelFromJson(Map<String, dynamic> json) => BudgetModel(
  id: (json['id'] as num).toInt(),
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  periodString: json['period_string'] as String,
  totalAmount: (json['total_amount'] as num).toDouble(),
  spentAmount: (json['spent_amount'] as num).toDouble(),
  remainingAmount: (json['remaining_amount'] as num).toDouble(),
  progressPercent: (json['progress_percent'] as num).toDouble(),
  remainingDays: (json['remaining_days'] as num).toInt(),
  isActive: json['is_active'] as bool,
  isCurrentMonth: json['is_current_month'] as bool,
  allocations: (json['allocations'] as List<dynamic>)
      .map((e) => AllocationModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BudgetModelToJson(BudgetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'year': instance.year,
      'month': instance.month,
      'period_string': instance.periodString,
      'total_amount': instance.totalAmount,
      'spent_amount': instance.spentAmount,
      'remaining_amount': instance.remainingAmount,
      'progress_percent': instance.progressPercent,
      'remaining_days': instance.remainingDays,
      'is_active': instance.isActive,
      'is_current_month': instance.isCurrentMonth,
      'allocations': instance.allocations,
    };

AllocationModel _$AllocationModelFromJson(Map<String, dynamic> json) =>
    AllocationModel(
      id: (json['id'] as num).toInt(),
      category: CategoryModel.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      allocatedAmount: (json['allocated_amount'] as num).toDouble(),
      spentAmount: (json['spent_amount'] as num).toDouble(),
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      progressPercent: (json['progress_percent'] as num).toDouble(),
      dailyLimit: (json['daily_limit'] as num).toDouble(),
      currentDailyLimit: (json['current_daily_limit'] as num).toDouble(),
      alertThreshold: (json['alert_threshold'] as num).toDouble(),
      isOverBudget: json['is_over_budget'] as bool,
      shouldAlert: json['should_alert'] as bool,
      allocationPercent: (json['allocation_percent'] as num).toDouble(),
    );

Map<String, dynamic> _$AllocationModelToJson(AllocationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'allocated_amount': instance.allocatedAmount,
      'spent_amount': instance.spentAmount,
      'remaining_amount': instance.remainingAmount,
      'progress_percent': instance.progressPercent,
      'daily_limit': instance.dailyLimit,
      'current_daily_limit': instance.currentDailyLimit,
      'alert_threshold': instance.alertThreshold,
      'is_over_budget': instance.isOverBudget,
      'should_alert': instance.shouldAlert,
      'allocation_percent': instance.allocationPercent,
    };

CreateBudgetModel _$CreateBudgetModelFromJson(Map<String, dynamic> json) =>
    CreateBudgetModel(
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      allocations: (json['allocations'] as List<dynamic>)
          .map((e) => CreateAllocationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreateBudgetModelToJson(CreateBudgetModel instance) =>
    <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'total_amount': instance.totalAmount,
      'allocations': instance.allocations,
    };

CreateAllocationModel _$CreateAllocationModelFromJson(
  Map<String, dynamic> json,
) => CreateAllocationModel(
  categoryId: (json['category_id'] as num).toInt(),
  allocatedAmount: (json['allocated_amount'] as num).toDouble(),
  alertThreshold: (json['alert_threshold'] as num?)?.toDouble() ?? 0.8,
);

Map<String, dynamic> _$CreateAllocationModelToJson(
  CreateAllocationModel instance,
) => <String, dynamic>{
  'category_id': instance.categoryId,
  'allocated_amount': instance.allocatedAmount,
  'alert_threshold': instance.alertThreshold,
};
