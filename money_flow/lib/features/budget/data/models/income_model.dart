import 'package:json_annotation/json_annotation.dart';

part 'income_model.g.dart';

@JsonSerializable()
class IncomeModel {
  final int id;
  final double amount;
  @JsonKey(name: 'formatted_amount')
  final String formattedAmount;
  @JsonKey(name: 'net_amount')
  final double netAmount;
  @JsonKey(name: 'formatted_net_amount')
  final String formattedNetAmount;
  final String description;
  final String source;
  @JsonKey(name: 'source_display_name')
  final String sourceDisplayName;
  final String date;
  final String notes;
  final String currency;
  @JsonKey(name: 'tax_deducted')
  final double taxDeducted;
  @JsonKey(name: 'is_recurring')
  final bool isRecurring;
  final String? frequency;
  @JsonKey(name: 'frequency_display_name')
  final String? frequencyDisplayName;
  @JsonKey(name: 'next_date')
  final String? nextDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  @JsonKey(name: 'can_be_modified')
  final bool canBeModified;
  @JsonKey(name: 'can_be_deleted')
  final bool canBeDeleted;
  @JsonKey(name: 'is_future')
  final bool isFuture;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  IncomeModel({
    required this.id,
    required this.amount,
    required this.formattedAmount,
    required this.netAmount,
    required this.formattedNetAmount,
    required this.description,
    required this.source,
    required this.sourceDisplayName,
    required this.date,
    required this.notes,
    required this.currency,
    required this.taxDeducted,
    required this.isRecurring,
    this.frequency,
    this.frequencyDisplayName,
    this.nextDate,
    this.endDate,
    required this.canBeModified,
    required this.canBeDeleted,
    required this.isFuture,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) => _$IncomeModelFromJson(json);
  Map<String, dynamic> toJson() => _$IncomeModelToJson(this);

  // Helper getters
  DateTime get dateTime => DateTime.parse(date);
  DateTime get createdAtDateTime => DateTime.parse(createdAt);
  DateTime get updatedAtDateTime => DateTime.parse(updatedAt);
  DateTime? get nextDateTime => nextDate != null ? DateTime.parse(nextDate!) : null;
  DateTime? get endDateTime => endDate != null ? DateTime.parse(endDate!) : null;

  // Time ago helper
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} día${difference.inDays == 1 ? '' : 's'} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours == 1 ? '' : 's'} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes == 1 ? '' : 's'} atrás';
    } else {
      return 'Hace un momento';
    }
  }

  // Source icon helper
  String get sourceIcon {
    switch (source) {
      case 'salary':
        return '💼';
      case 'freelance':
        return '💻';
      case 'investment':
        return '📈';
      case 'business':
        return '🏢';
      case 'rental':
        return '🏠';
      case 'bonus':
        return '🎁';
      case 'gift':
        return '🎉';
      case 'other':
      default:
        return '💰';
    }
  }
}

@JsonSerializable()
class IncomeSummaryModel {
  final int id;
  final double amount;
  @JsonKey(name: 'formatted_amount')
  final String formattedAmount;
  final String description;
  final String source;
  @JsonKey(name: 'source_display_name')
  final String sourceDisplayName;
  final String date;
  final String currency;
  @JsonKey(name: 'is_recurring')
  final bool isRecurring;
  @JsonKey(name: 'created_at')
  final String createdAt;

  IncomeSummaryModel({
    required this.id,
    required this.amount,
    required this.formattedAmount,
    required this.description,
    required this.source,
    required this.sourceDisplayName,
    required this.date,
    required this.currency,
    required this.isRecurring,
    required this.createdAt,
  });

  factory IncomeSummaryModel.fromJson(Map<String, dynamic> json) => _$IncomeSummaryModelFromJson(json);
  Map<String, dynamic> toJson() => _$IncomeSummaryModelToJson(this);

  // Helper getters
  DateTime get dateTime => DateTime.parse(date);
  DateTime get createdAtDateTime => DateTime.parse(createdAt);

  // Source icon helper
  String get sourceIcon {
    switch (source) {
      case 'salary':
        return '💼';
      case 'freelance':
        return '💻';
      case 'investment':
        return '📈';
      case 'business':
        return '🏢';
      case 'rental':
        return '🏠';
      case 'bonus':
        return '🎁';
      case 'gift':
        return '🎉';
      case 'other':
      default:
        return '💰';
    }
  }
}
