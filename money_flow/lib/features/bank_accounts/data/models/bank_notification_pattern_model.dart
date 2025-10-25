import 'package:json_annotation/json_annotation.dart';

part 'bank_notification_pattern_model.g.dart';

enum NotificationChannel {
  @JsonValue('sms')
  sms,
  @JsonValue('push')
  push,
  @JsonValue('email')
  email,
  @JsonValue('app')
  app,
}

enum NotificationPatternStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('learning')
  learning,
}

@JsonSerializable()
class BankNotificationPatternModel {
  final int id;
  @JsonKey(name: 'bank_account_id')
  final int bankAccountId;
  final String name;
  final String description;
  final NotificationChannel channel;
  final NotificationPatternStatus status;
  @JsonKey(name: 'message_pattern')
  final String messagePattern;
  @JsonKey(name: 'example_message')
  final String exampleMessage;
  @JsonKey(name: 'keywords_trigger')
  final List<String> keywordsTrigger;
  @JsonKey(name: 'keywords_exclude')
  final List<String> keywordsExclude;
  @JsonKey(name: 'amount_regex')
  final String amountRegex;
  @JsonKey(name: 'date_regex')
  final String dateRegex;
  @JsonKey(name: 'description_regex')
  final String descriptionRegex;
  @JsonKey(name: 'merchant_regex')
  final String merchantRegex;
  @JsonKey(name: 'requires_validation')
  final bool requiresValidation;
  @JsonKey(name: 'confidence_threshold')
  final double confidenceThreshold;
  @JsonKey(name: 'auto_approve')
  final bool autoApprove;
  @JsonKey(name: 'match_count')
  final int matchCount;
  @JsonKey(name: 'success_count')
  final int successCount;
  @JsonKey(name: 'success_rate')
  final double successRate;
  @JsonKey(name: 'last_matched_at')
  final String? lastMatchedAt;
  final int priority;
  @JsonKey(name: 'is_default')
  final bool isDefault;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  const BankNotificationPatternModel({
    required this.id,
    required this.bankAccountId,
    required this.name,
    required this.description,
    required this.channel,
    required this.status,
    required this.messagePattern,
    required this.exampleMessage,
    required this.keywordsTrigger,
    required this.keywordsExclude,
    required this.amountRegex,
    required this.dateRegex,
    required this.descriptionRegex,
    required this.merchantRegex,
    required this.requiresValidation,
    required this.confidenceThreshold,
    required this.autoApprove,
    required this.matchCount,
    required this.successCount,
    required this.successRate,
    this.lastMatchedAt,
    required this.priority,
    required this.isDefault,
    required this.tags,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BankNotificationPatternModel.fromJson(Map<String, dynamic> json) =>
      _$BankNotificationPatternModelFromJson(json);

  Map<String, dynamic> toJson() => _$BankNotificationPatternModelToJson(this);

  BankNotificationPatternModel copyWith({
    int? id,
    int? bankAccountId,
    String? name,
    String? description,
    NotificationChannel? channel,
    NotificationPatternStatus? status,
    String? messagePattern,
    String? exampleMessage,
    List<String>? keywordsTrigger,
    List<String>? keywordsExclude,
    String? amountRegex,
    String? dateRegex,
    String? descriptionRegex,
    String? merchantRegex,
    bool? requiresValidation,
    double? confidenceThreshold,
    bool? autoApprove,
    int? matchCount,
    int? successCount,
    double? successRate,
    String? lastMatchedAt,
    int? priority,
    bool? isDefault,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    String? createdAt,
    String? updatedAt,
  }) {
    return BankNotificationPatternModel(
      id: id ?? this.id,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      name: name ?? this.name,
      description: description ?? this.description,
      channel: channel ?? this.channel,
      status: status ?? this.status,
      messagePattern: messagePattern ?? this.messagePattern,
      exampleMessage: exampleMessage ?? this.exampleMessage,
      keywordsTrigger: keywordsTrigger ?? this.keywordsTrigger,
      keywordsExclude: keywordsExclude ?? this.keywordsExclude,
      amountRegex: amountRegex ?? this.amountRegex,
      dateRegex: dateRegex ?? this.dateRegex,
      descriptionRegex: descriptionRegex ?? this.descriptionRegex,
      merchantRegex: merchantRegex ?? this.merchantRegex,
      requiresValidation: requiresValidation ?? this.requiresValidation,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      autoApprove: autoApprove ?? this.autoApprove,
      matchCount: matchCount ?? this.matchCount,
      successCount: successCount ?? this.successCount,
      successRate: successRate ?? this.successRate,
      lastMatchedAt: lastMatchedAt ?? this.lastMatchedAt,
      priority: priority ?? this.priority,
      isDefault: isDefault ?? this.isDefault,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankNotificationPatternModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BankNotificationPatternModel{id: $id, name: $name, channel: $channel, status: $status}';
  }

  // Métodos de utilidad
  bool get isActive => status == NotificationPatternStatus.active;
  bool get isLearning => status == NotificationPatternStatus.learning;
  bool get hasHighSuccessRate => successRate >= 80.0;
  bool get canAutoApprove => autoApprove && confidenceThreshold > 0;

  String get channelDisplayName {
    switch (channel) {
      case NotificationChannel.sms:
        return 'SMS';
      case NotificationChannel.push:
        return 'Push';
      case NotificationChannel.email:
        return 'Email';
      case NotificationChannel.app:
        return 'App';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case NotificationPatternStatus.active:
        return 'Activo';
      case NotificationPatternStatus.inactive:
        return 'Inactivo';
      case NotificationPatternStatus.learning:
        return 'Aprendiendo';
    }
  }
}

@JsonSerializable()
class ProcessedNotificationModel {
  @JsonKey(name: 'bank_account_id')
  final int bankAccountId;
  final NotificationChannel channel;
  final String message;
  final bool processed;
  @JsonKey(name: 'pattern_id')
  final int? patternId;
  @JsonKey(name: 'pattern_name')
  final String? patternName;
  final double? confidence;
  @JsonKey(name: 'requires_validation')
  final bool requiresValidation;
  @JsonKey(name: 'extracted_data')
  final Map<String, dynamic> extractedData;

  const ProcessedNotificationModel({
    required this.bankAccountId,
    required this.channel,
    required this.message,
    required this.processed,
    this.patternId,
    this.patternName,
    this.confidence = 0.0,
    required this.requiresValidation,
    required this.extractedData,
  });

  factory ProcessedNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$ProcessedNotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProcessedNotificationModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessedNotificationModel &&
          runtimeType == other.runtimeType &&
          bankAccountId == other.bankAccountId &&
          message == other.message;

  @override
  int get hashCode => Object.hash(bankAccountId, message);

  // Métodos de utilidad
  bool get hasHighConfidence => (confidence ?? 0.0) >= 0.8;
  bool get needsManualReview => requiresValidation || (confidence ?? 0.0) < 0.7;
  
  String? get extractedAmount => extractedData['amount'] as String?;
  String? get extractedDate => extractedData['date'] as String?;
  String? get extractedDescription => extractedData['description'] as String?;
  String? get extractedMerchant => extractedData['merchant'] as String?;
}

@JsonSerializable()
class PatternStatisticsModel {
  @JsonKey(name: 'total_patterns')
  final int totalPatterns;
  @JsonKey(name: 'active_patterns')
  final int activePatterns;
  @JsonKey(name: 'learning_patterns')
  final int learningPatterns;
  @JsonKey(name: 'total_matches')
  final int totalMatches;
  @JsonKey(name: 'total_successes')
  final int totalSuccesses;
  @JsonKey(name: 'overall_success_rate')
  final double overallSuccessRate;

  const PatternStatisticsModel({
    required this.totalPatterns,
    required this.activePatterns,
    required this.learningPatterns,
    required this.totalMatches,
    required this.totalSuccesses,
    required this.overallSuccessRate,
  });

  factory PatternStatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$PatternStatisticsModelFromJson(json);

  Map<String, dynamic> toJson() => _$PatternStatisticsModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatternStatisticsModel &&
          runtimeType == other.runtimeType &&
          totalPatterns == other.totalPatterns;

  @override
  int get hashCode => totalPatterns.hashCode;
}

// DTOs para requests
@JsonSerializable()
class CreateBankNotificationPatternRequest {
  @JsonKey(name: 'bank_account_id')
  final int bankAccountId;
  final String name;
  final String description;
  final NotificationChannel channel;
  @JsonKey(name: 'message_pattern')
  final String? messagePattern;
  @JsonKey(name: 'example_message')
  final String? exampleMessage;
  @JsonKey(name: 'keywords_trigger')
  final List<String> keywordsTrigger;
  @JsonKey(name: 'keywords_exclude')
  final List<String> keywordsExclude;
  @JsonKey(name: 'amount_regex')
  final String? amountRegex;
  @JsonKey(name: 'date_regex')
  final String? dateRegex;
  @JsonKey(name: 'description_regex')
  final String? descriptionRegex;
  @JsonKey(name: 'merchant_regex')
  final String? merchantRegex;
  @JsonKey(name: 'requires_validation')
  final bool requiresValidation;
  @JsonKey(name: 'confidence_threshold')
  final double confidenceThreshold;
  @JsonKey(name: 'auto_approve')
  final bool autoApprove;
  final int priority;
  @JsonKey(name: 'is_default')
  final bool isDefault;
  final List<String> tags;
  final Map<String, dynamic>? metadata;

  const CreateBankNotificationPatternRequest({
    required this.bankAccountId,
    required this.name,
    required this.description,
    required this.channel,
    this.messagePattern,
    this.exampleMessage,
    this.keywordsTrigger = const [],
    this.keywordsExclude = const [],
    this.amountRegex,
    this.dateRegex,
    this.descriptionRegex,
    this.merchantRegex,
    this.requiresValidation = true,
    this.confidenceThreshold = 0.8,
    this.autoApprove = false,
    this.priority = 100,
    this.isDefault = false,
    this.tags = const [],
    this.metadata,
  });

  factory CreateBankNotificationPatternRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBankNotificationPatternRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBankNotificationPatternRequestToJson(this);
}

@JsonSerializable()
class UpdateBankNotificationPatternRequest {
  final String? name;
  final String? description;
  @JsonKey(name: 'message_pattern')
  final String? messagePattern;
  @JsonKey(name: 'example_message')
  final String? exampleMessage;
  @JsonKey(name: 'keywords_trigger')
  final List<String>? keywordsTrigger;
  @JsonKey(name: 'keywords_exclude')
  final List<String>? keywordsExclude;
  @JsonKey(name: 'amount_regex')
  final String? amountRegex;
  @JsonKey(name: 'date_regex')
  final String? dateRegex;
  @JsonKey(name: 'description_regex')
  final String? descriptionRegex;
  @JsonKey(name: 'merchant_regex')
  final String? merchantRegex;
  @JsonKey(name: 'requires_validation')
  final bool? requiresValidation;
  @JsonKey(name: 'confidence_threshold')
  final double? confidenceThreshold;
  @JsonKey(name: 'auto_approve')
  final bool? autoApprove;
  final int? priority;
  @JsonKey(name: 'is_default')
  final bool? isDefault;
  final List<String>? tags;
  final Map<String, dynamic>? metadata;

  const UpdateBankNotificationPatternRequest({
    this.name,
    this.description,
    this.messagePattern,
    this.exampleMessage,
    this.keywordsTrigger,
    this.keywordsExclude,
    this.amountRegex,
    this.dateRegex,
    this.descriptionRegex,
    this.merchantRegex,
    this.requiresValidation,
    this.confidenceThreshold,
    this.autoApprove,
    this.priority,
    this.isDefault,
    this.tags,
    this.metadata,
  });

  factory UpdateBankNotificationPatternRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateBankNotificationPatternRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateBankNotificationPatternRequestToJson(this);
}

@JsonSerializable()
class ProcessNotificationRequest {
  @JsonKey(name: 'bank_account_id')
  final int bankAccountId;
  final NotificationChannel channel;
  final String message;

  const ProcessNotificationRequest({
    required this.bankAccountId,
    required this.channel,
    required this.message,
  });

  factory ProcessNotificationRequest.fromJson(Map<String, dynamic> json) =>
      _$ProcessNotificationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ProcessNotificationRequestToJson(this);
}
