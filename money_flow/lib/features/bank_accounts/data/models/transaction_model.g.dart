// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      categoryName: json['category_name'] as String?,
      transactionDate: json['transaction_date'] as String,
      accountName: json['account_name'] as String?,
      toAccountName: json['to_account_name'] as String?,
      bankAccountAlias: json['bank_account_alias'] as String?,
      currency: json['currency'] as String,
      source: $enumDecode(_$TransactionSourceEnumMap, json['source']),
      validationStatus: $enumDecode(
        _$ValidationStatusEnumMap,
        json['validation_status'],
      ),
      aiConfidence: (json['ai_confidence'] as num).toDouble(),
      needsReview: json['needs_review'] as bool,
      createdAt: json['created_at'] as String,
      location: json['location'] as String?,
      merchant: json['merchant'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      notes: json['notes'] as String?,
      reference: json['reference'] as String?,
      rawNotification: json['raw_notification'] as String?,
      patternId: (json['pattern_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TransactionModelToJson(
  TransactionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'status': _$TransactionStatusEnumMap[instance.status]!,
  'amount': instance.amount,
  'description': instance.description,
  'category_name': instance.categoryName,
  'transaction_date': instance.transactionDate,
  'account_name': instance.accountName,
  'to_account_name': instance.toAccountName,
  'bank_account_alias': instance.bankAccountAlias,
  'currency': instance.currency,
  'source': _$TransactionSourceEnumMap[instance.source]!,
  'validation_status': _$ValidationStatusEnumMap[instance.validationStatus]!,
  'ai_confidence': instance.aiConfidence,
  'needs_review': instance.needsReview,
  'created_at': instance.createdAt,
  'location': instance.location,
  'merchant': instance.merchant,
  'tags': instance.tags,
  'notes': instance.notes,
  'reference': instance.reference,
  'raw_notification': instance.rawNotification,
  'pattern_id': instance.patternId,
};

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
  TransactionType.transfer: 'transfer',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.completed: 'completed',
  TransactionStatus.cancelled: 'cancelled',
};

const _$TransactionSourceEnumMap = {
  TransactionSource.notification: 'notification',
  TransactionSource.manual: 'manual',
  TransactionSource.integration: 'integration',
  TransactionSource.import: 'import',
};

const _$ValidationStatusEnumMap = {
  ValidationStatus.auto: 'auto',
  ValidationStatus.pendingReview: 'pending_review',
  ValidationStatus.manualValidated: 'manual_validated',
  ValidationStatus.rejected: 'rejected',
};

CreateTransactionRequest _$CreateTransactionRequestFromJson(
  Map<String, dynamic> json,
) => CreateTransactionRequest(
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String,
  accountId: (json['account_id'] as num).toInt(),
  bankAccountId: (json['bank_account_id'] as num?)?.toInt(),
  toAccountId: (json['to_account_id'] as num?)?.toInt(),
  categoryId: (json['category_id'] as num?)?.toInt(),
  transactionDate: json['transaction_date'] as String,
  location: json['location'] as String?,
  merchant: json['merchant'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  notes: json['notes'] as String?,
  reference: json['reference'] as String?,
  source:
      $enumDecodeNullable(_$TransactionSourceEnumMap, json['source']) ??
      TransactionSource.manual,
  rawNotification: json['raw_notification'] as String?,
  aiConfidence: (json['ai_confidence'] as num?)?.toDouble(),
  patternId: (json['pattern_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$CreateTransactionRequestToJson(
  CreateTransactionRequest instance,
) => <String, dynamic>{
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'amount': instance.amount,
  'description': instance.description,
  'account_id': instance.accountId,
  'bank_account_id': instance.bankAccountId,
  'to_account_id': instance.toAccountId,
  'category_id': instance.categoryId,
  'transaction_date': instance.transactionDate,
  'location': instance.location,
  'merchant': instance.merchant,
  'tags': instance.tags,
  'notes': instance.notes,
  'reference': instance.reference,
  'source': _$TransactionSourceEnumMap[instance.source]!,
  'raw_notification': instance.rawNotification,
  'ai_confidence': instance.aiConfidence,
  'pattern_id': instance.patternId,
};

TransactionFilter _$TransactionFilterFromJson(Map<String, dynamic> json) =>
    TransactionFilter(
      accountId: (json['account_id'] as num?)?.toInt(),
      bankAccountId: (json['bank_account_id'] as num?)?.toInt(),
      type: $enumDecodeNullable(_$TransactionTypeEnumMap, json['type']),
      status: $enumDecodeNullable(_$TransactionStatusEnumMap, json['status']),
      source: $enumDecodeNullable(_$TransactionSourceEnumMap, json['source']),
      validationStatus: $enumDecodeNullable(
        _$ValidationStatusEnumMap,
        json['validation_status'],
      ),
      categoryId: (json['category_id'] as num?)?.toInt(),
      fromDate: json['from_date'] as String?,
      toDate: json['to_date'] as String?,
      minAmount: (json['min_amount'] as num?)?.toDouble(),
      maxAmount: (json['max_amount'] as num?)?.toDouble(),
      minConfidence: (json['min_confidence'] as num?)?.toDouble(),
      maxConfidence: (json['max_confidence'] as num?)?.toDouble(),
      needsReview: json['needs_review'] as bool?,
      search: json['search'] as String?,
      limit: (json['limit'] as num?)?.toInt() ?? 50,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      orderBy: json['order_by'] as String? ?? 'transaction_date',
      orderDir: json['order_dir'] as String? ?? 'DESC',
    );

Map<String, dynamic> _$TransactionFilterToJson(TransactionFilter instance) =>
    <String, dynamic>{
      'account_id': instance.accountId,
      'bank_account_id': instance.bankAccountId,
      'type': _$TransactionTypeEnumMap[instance.type],
      'status': _$TransactionStatusEnumMap[instance.status],
      'source': _$TransactionSourceEnumMap[instance.source],
      'validation_status': _$ValidationStatusEnumMap[instance.validationStatus],
      'category_id': instance.categoryId,
      'from_date': instance.fromDate,
      'to_date': instance.toDate,
      'min_amount': instance.minAmount,
      'max_amount': instance.maxAmount,
      'min_confidence': instance.minConfidence,
      'max_confidence': instance.maxConfidence,
      'needs_review': instance.needsReview,
      'search': instance.search,
      'limit': instance.limit,
      'offset': instance.offset,
      'order_by': instance.orderBy,
      'order_dir': instance.orderDir,
    };
