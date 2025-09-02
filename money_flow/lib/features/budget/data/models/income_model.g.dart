// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncomeModel _$IncomeModelFromJson(Map<String, dynamic> json) => IncomeModel(
  id: (json['id'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
  formattedAmount: json['formatted_amount'] as String,
  netAmount: (json['net_amount'] as num).toDouble(),
  formattedNetAmount: json['formatted_net_amount'] as String,
  description: json['description'] as String,
  source: json['source'] as String,
  sourceDisplayName: json['source_display_name'] as String,
  date: json['date'] as String,
  notes: json['notes'] as String,
  currency: json['currency'] as String,
  taxDeducted: (json['tax_deducted'] as num).toDouble(),
  isRecurring: json['is_recurring'] as bool,
  frequency: json['frequency'] as String?,
  frequencyDisplayName: json['frequency_display_name'] as String?,
  nextDate: json['next_date'] as String?,
  endDate: json['end_date'] as String?,
  canBeModified: json['can_be_modified'] as bool,
  canBeDeleted: json['can_be_deleted'] as bool,
  isFuture: json['is_future'] as bool,
  isActive: json['is_active'] as bool,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$IncomeModelToJson(IncomeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'formatted_amount': instance.formattedAmount,
      'net_amount': instance.netAmount,
      'formatted_net_amount': instance.formattedNetAmount,
      'description': instance.description,
      'source': instance.source,
      'source_display_name': instance.sourceDisplayName,
      'date': instance.date,
      'notes': instance.notes,
      'currency': instance.currency,
      'tax_deducted': instance.taxDeducted,
      'is_recurring': instance.isRecurring,
      'frequency': instance.frequency,
      'frequency_display_name': instance.frequencyDisplayName,
      'next_date': instance.nextDate,
      'end_date': instance.endDate,
      'can_be_modified': instance.canBeModified,
      'can_be_deleted': instance.canBeDeleted,
      'is_future': instance.isFuture,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

IncomeSummaryModel _$IncomeSummaryModelFromJson(Map<String, dynamic> json) =>
    IncomeSummaryModel(
      id: (json['id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      formattedAmount: json['formatted_amount'] as String,
      description: json['description'] as String,
      source: json['source'] as String,
      sourceDisplayName: json['source_display_name'] as String,
      date: json['date'] as String,
      currency: json['currency'] as String,
      isRecurring: json['is_recurring'] as bool,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$IncomeSummaryModelToJson(IncomeSummaryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'formatted_amount': instance.formattedAmount,
      'description': instance.description,
      'source': instance.source,
      'source_display_name': instance.sourceDisplayName,
      'date': instance.date,
      'currency': instance.currency,
      'is_recurring': instance.isRecurring,
      'created_at': instance.createdAt,
    };
