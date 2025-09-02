// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) => ExpenseModel(
  id: (json['id'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
  formattedAmount: json['formatted_amount'] as String,
  description: json['description'] as String,
  date: json['date'] as String,
  timeAgo: json['time_ago'] as String,
  category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
  source: json['source'] as String,
  status: json['status'] as String,
  location: json['location'] as String,
  merchant: json['merchant'] as String,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  notes: json['notes'] as String,
  currency: json['currency'] as String,
  canBeModified: json['can_be_modified'] as bool,
  canBeCancelled: json['can_be_cancelled'] as bool,
  triggeredAlert: json['triggered_alert'] as bool,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ExpenseModelToJson(ExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'formatted_amount': instance.formattedAmount,
      'description': instance.description,
      'date': instance.date,
      'time_ago': instance.timeAgo,
      'category': instance.category,
      'source': instance.source,
      'status': instance.status,
      'location': instance.location,
      'merchant': instance.merchant,
      'tags': instance.tags,
      'notes': instance.notes,
      'currency': instance.currency,
      'can_be_modified': instance.canBeModified,
      'can_be_cancelled': instance.canBeCancelled,
      'triggered_alert': instance.triggeredAlert,
      'created_at': instance.createdAt,
    };

CreateExpenseModel _$CreateExpenseModelFromJson(Map<String, dynamic> json) =>
    CreateExpenseModel(
      categoryId: (json['category_id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: json['date'] as String,
      location: json['location'] as String? ?? '',
      merchant: json['merchant'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      notes: json['notes'] as String? ?? '',
      source: json['source'] as String? ?? 'manual',
      receiptUrl: json['receipt_url'] as String? ?? '',
    );

Map<String, dynamic> _$CreateExpenseModelToJson(CreateExpenseModel instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'amount': instance.amount,
      'description': instance.description,
      'date': instance.date,
      'location': instance.location,
      'merchant': instance.merchant,
      'tags': instance.tags,
      'notes': instance.notes,
      'source': instance.source,
      'receipt_url': instance.receiptUrl,
    };
