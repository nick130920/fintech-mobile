import 'package:json_annotation/json_annotation.dart';

import 'category_model.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class ExpenseModel {
  final int id;
  final double amount;
  @JsonKey(name: 'formatted_amount')
  final String formattedAmount;
  final String description;
  final String date;
  @JsonKey(name: 'time_ago')
  final String timeAgo;
  final CategoryModel category;
  final String source;
  final String status;
  final String location;
  final String merchant;
  final List<String> tags;
  final String notes;
  final String currency;
  @JsonKey(name: 'can_be_modified')
  final bool canBeModified;
  @JsonKey(name: 'can_be_cancelled')
  final bool canBeCancelled;
  @JsonKey(name: 'triggered_alert')
  final bool triggeredAlert;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const ExpenseModel({
    required this.id,
    required this.amount,
    required this.formattedAmount,
    required this.description,
    required this.date,
    required this.timeAgo,
    required this.category,
    required this.source,
    required this.status,
    required this.location,
    required this.merchant,
    required this.tags,
    required this.notes,
    required this.currency,
    required this.canBeModified,
    required this.canBeCancelled,
    required this.triggeredAlert,
    required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);

  // Helper methods
  DateTime get dateTime => DateTime.parse(date);
  DateTime get createdDateTime => DateTime.parse(createdAt);
  
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  
  bool get isFromManual => source == 'manual';
  bool get isFromSMS => source == 'sms';
  bool get isFromWhatsApp => source == 'whatsapp';
  
  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }
  
  String get sourceDisplayName {
    switch (source) {
      case 'manual':
        return 'Manual';
      case 'sms':
        return 'SMS';
      case 'whatsapp':
        return 'WhatsApp';
      case 'bank_api':
        return 'Banco';
      case 'notification':
        return 'Notificación';
      default:
        return source;
    }
  }
}

// Modelo para crear un gasto
@JsonSerializable()
class CreateExpenseModel {
  @JsonKey(name: 'category_id')
  final int categoryId;
  final double amount;
  final String description;
  final String date;
  final String location;
  final String merchant;
  final List<String> tags;
  final String notes;
  final String source;
  @JsonKey(name: 'receipt_url')
  final String receiptUrl;

  const CreateExpenseModel({
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
    this.location = '',
    this.merchant = '',
    this.tags = const [],
    this.notes = '',
    this.source = 'manual',
    this.receiptUrl = '',
  });

  factory CreateExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$CreateExpenseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateExpenseModelToJson(this);
}

// Modelo para filtros de gastos
class ExpenseFilters {
  final int? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int limit;
  final int offset;

  const ExpenseFilters({
    this.categoryId,
    this.startDate,
    this.endDate,
    this.limit = 50,
    this.offset = 0,
  });

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    
    if (categoryId != null) {
      params['category_id'] = categoryId.toString();
    }
    
    if (startDate != null) {
      params['start_date'] = startDate!.toIso8601String().split('T')[0];
    }
    
    if (endDate != null) {
      params['end_date'] = endDate!.toIso8601String().split('T')[0];
    }
    
    params['limit'] = limit.toString();
    params['offset'] = offset.toString();
    
    return params;
  }
}
