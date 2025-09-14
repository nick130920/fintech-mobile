import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

enum TransactionType {
  @JsonValue('income')
  income,
  @JsonValue('expense')
  expense,
  @JsonValue('transfer')
  transfer,
}

enum TransactionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

enum TransactionSource {
  @JsonValue('notification')
  notification,
  @JsonValue('manual')
  manual,
  @JsonValue('integration')
  integration,
  @JsonValue('import')
  import,
}

enum ValidationStatus {
  @JsonValue('auto')
  auto,
  @JsonValue('pending_review')
  pendingReview,
  @JsonValue('manual_validated')
  manualValidated,
  @JsonValue('rejected')
  rejected,
}

@JsonSerializable()
class TransactionModel {
  final int id;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final String description;
  @JsonKey(name: 'category_name')
  final String? categoryName;
  @JsonKey(name: 'transaction_date')
  final String transactionDate;
  @JsonKey(name: 'account_name')
  final String? accountName;
  @JsonKey(name: 'to_account_name')
  final String? toAccountName;
  @JsonKey(name: 'bank_account_alias')
  final String? bankAccountAlias;
  final String currency;
  final TransactionSource source;
  @JsonKey(name: 'validation_status')
  final ValidationStatus validationStatus;
  @JsonKey(name: 'ai_confidence')
  final double aiConfidence;
  @JsonKey(name: 'needs_review')
  final bool needsReview;
  @JsonKey(name: 'created_at')
  final String createdAt;

  // Campos adicionales para información completa
  final String? location;
  final String? merchant;
  final List<String> tags;
  final String? notes;
  final String? reference;
  @JsonKey(name: 'raw_notification')
  final String? rawNotification;
  @JsonKey(name: 'pattern_id')
  final int? patternId;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.description,
    this.categoryName,
    required this.transactionDate,
    this.accountName,
    this.toAccountName,
    this.bankAccountAlias,
    required this.currency,
    required this.source,
    required this.validationStatus,
    required this.aiConfidence,
    required this.needsReview,
    required this.createdAt,
    this.location,
    this.merchant,
    this.tags = const [],
    this.notes,
    this.reference,
    this.rawNotification,
    this.patternId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  TransactionModel copyWith({
    int? id,
    TransactionType? type,
    TransactionStatus? status,
    double? amount,
    String? description,
    String? categoryName,
    String? transactionDate,
    String? accountName,
    String? toAccountName,
    String? bankAccountAlias,
    String? currency,
    TransactionSource? source,
    ValidationStatus? validationStatus,
    double? aiConfidence,
    bool? needsReview,
    String? createdAt,
    String? location,
    String? merchant,
    List<String>? tags,
    String? notes,
    String? reference,
    String? rawNotification,
    int? patternId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryName: categoryName ?? this.categoryName,
      transactionDate: transactionDate ?? this.transactionDate,
      accountName: accountName ?? this.accountName,
      toAccountName: toAccountName ?? this.toAccountName,
      bankAccountAlias: bankAccountAlias ?? this.bankAccountAlias,
      currency: currency ?? this.currency,
      source: source ?? this.source,
      validationStatus: validationStatus ?? this.validationStatus,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      needsReview: needsReview ?? this.needsReview,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      merchant: merchant ?? this.merchant,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      reference: reference ?? this.reference,
      rawNotification: rawNotification ?? this.rawNotification,
      patternId: patternId ?? this.patternId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TransactionModel{id: $id, type: $type, amount: $amount, description: $description}';
  }

  // Métodos de utilidad
  DateTime get transactionDateTime => DateTime.parse(transactionDate);
  DateTime get createdDateTime => DateTime.parse(createdAt);

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isTransfer => type == TransactionType.transfer;

  bool get isPending => status == TransactionStatus.pending;
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isCancelled => status == TransactionStatus.cancelled;

  bool get isFromNotification => source == TransactionSource.notification;
  bool get isManual => source == TransactionSource.manual;
  bool get isFromIntegration => source == TransactionSource.integration;

  bool get isAutoValidated => validationStatus == ValidationStatus.auto;
  bool get isPendingReview => validationStatus == ValidationStatus.pendingReview;
  bool get isManuallyValidated => validationStatus == ValidationStatus.manualValidated;
  bool get isRejected => validationStatus == ValidationStatus.rejected;

  bool get hasHighConfidence => aiConfidence >= 0.8;
  bool get hasLowConfidence => aiConfidence < 0.5;

  String get typeDisplayName {
    switch (type) {
      case TransactionType.income:
        return 'Ingreso';
      case TransactionType.expense:
        return 'Gasto';
      case TransactionType.transfer:
        return 'Transferencia';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pendiente';
      case TransactionStatus.completed:
        return 'Completado';
      case TransactionStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get sourceDisplayName {
    switch (source) {
      case TransactionSource.notification:
        return 'Notificación';
      case TransactionSource.manual:
        return 'Manual';
      case TransactionSource.integration:
        return 'Integración';
      case TransactionSource.import:
        return 'Importado';
    }
  }

  String get validationStatusDisplayName {
    switch (validationStatus) {
      case ValidationStatus.auto:
        return 'Auto-validado';
      case ValidationStatus.pendingReview:
        return 'Pendiente revisión';
      case ValidationStatus.manualValidated:
        return 'Validado manualmente';
      case ValidationStatus.rejected:
        return 'Rechazado';
    }
  }

  // Obtener el monto con signo apropiado
  double get signedAmount {
    switch (type) {
      case TransactionType.income:
        return amount;
      case TransactionType.expense:
        return -amount;
      case TransactionType.transfer:
        return -amount; // Por defecto negativo para la cuenta origen
    }
  }

  // Formatear el monto con símbolo de moneda
  String get formattedAmount {
    final symbol = currency == 'MXN' ? '\$' : currency;
    final absAmount = amount.toStringAsFixed(2);
    return '$symbol$absAmount';
  }

  String get formattedSignedAmount {
    final symbol = currency == 'MXN' ? '\$' : currency;
    final signed = signedAmount;
    final prefix = signed >= 0 ? '+' : '';
    return '$prefix$symbol${signed.abs().toStringAsFixed(2)}';
  }
}

// Modelo para crear transacciones
@JsonSerializable()
class CreateTransactionRequest {
  final TransactionType type;
  final double amount;
  final String description;
  @JsonKey(name: 'account_id')
  final int accountId;
  @JsonKey(name: 'bank_account_id')
  final int? bankAccountId;
  @JsonKey(name: 'to_account_id')
  final int? toAccountId;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  @JsonKey(name: 'transaction_date')
  final String transactionDate;
  final String? location;
  final String? merchant;
  final List<String> tags;
  final String? notes;
  final String? reference;
  final TransactionSource source;
  @JsonKey(name: 'raw_notification')
  final String? rawNotification;
  @JsonKey(name: 'ai_confidence')
  final double? aiConfidence;
  @JsonKey(name: 'pattern_id')
  final int? patternId;

  const CreateTransactionRequest({
    required this.type,
    required this.amount,
    required this.description,
    required this.accountId,
    this.bankAccountId,
    this.toAccountId,
    this.categoryId,
    required this.transactionDate,
    this.location,
    this.merchant,
    this.tags = const [],
    this.notes,
    this.reference,
    this.source = TransactionSource.manual,
    this.rawNotification,
    this.aiConfidence,
    this.patternId,
  });

  factory CreateTransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTransactionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTransactionRequestToJson(this);
}

// Modelo para filtros de transacciones
@JsonSerializable()
class TransactionFilter {
  @JsonKey(name: 'account_id')
  final int? accountId;
  @JsonKey(name: 'bank_account_id')
  final int? bankAccountId;
  final TransactionType? type;
  final TransactionStatus? status;
  final TransactionSource? source;
  @JsonKey(name: 'validation_status')
  final ValidationStatus? validationStatus;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  @JsonKey(name: 'from_date')
  final String? fromDate;
  @JsonKey(name: 'to_date')
  final String? toDate;
  @JsonKey(name: 'min_amount')
  final double? minAmount;
  @JsonKey(name: 'max_amount')
  final double? maxAmount;
  @JsonKey(name: 'min_confidence')
  final double? minConfidence;
  @JsonKey(name: 'max_confidence')
  final double? maxConfidence;
  @JsonKey(name: 'needs_review')
  final bool? needsReview;
  final String? search;
  final int limit;
  final int offset;
  @JsonKey(name: 'order_by')
  final String orderBy;
  @JsonKey(name: 'order_dir')
  final String orderDir;

  const TransactionFilter({
    this.accountId,
    this.bankAccountId,
    this.type,
    this.status,
    this.source,
    this.validationStatus,
    this.categoryId,
    this.fromDate,
    this.toDate,
    this.minAmount,
    this.maxAmount,
    this.minConfidence,
    this.maxConfidence,
    this.needsReview,
    this.search,
    this.limit = 50,
    this.offset = 0,
    this.orderBy = 'transaction_date',
    this.orderDir = 'DESC',
  });

  factory TransactionFilter.fromJson(Map<String, dynamic> json) =>
      _$TransactionFilterFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionFilterToJson(this);

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    
    if (accountId != null) params['account_id'] = accountId.toString();
    if (bankAccountId != null) params['bank_account_id'] = bankAccountId.toString();
    if (type != null) params['type'] = type!.name;
    if (status != null) params['status'] = status!.name;
    if (source != null) params['source'] = source!.name;
    if (validationStatus != null) params['validation_status'] = validationStatus!.name;
    if (categoryId != null) params['category_id'] = categoryId.toString();
    if (fromDate != null) params['from_date'] = fromDate!;
    if (toDate != null) params['to_date'] = toDate!;
    if (minAmount != null) params['min_amount'] = minAmount.toString();
    if (maxAmount != null) params['max_amount'] = maxAmount.toString();
    if (minConfidence != null) params['min_confidence'] = minConfidence.toString();
    if (maxConfidence != null) params['max_confidence'] = maxConfidence.toString();
    if (needsReview != null) params['needs_review'] = needsReview.toString();
    if (search != null) params['search'] = search!;
    
    params['limit'] = limit.toString();
    params['offset'] = offset.toString();
    params['order_by'] = orderBy;
    params['order_dir'] = orderDir;
    
    return params;
  }
}
