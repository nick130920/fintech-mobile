// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_notification_pattern_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankNotificationPatternModel _$BankNotificationPatternModelFromJson(
  Map<String, dynamic> json,
) => BankNotificationPatternModel(
  id: (json['id'] as num).toInt(),
  bankAccountId: (json['bank_account_id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
  status: $enumDecode(_$NotificationPatternStatusEnumMap, json['status']),
  messagePattern: json['message_pattern'] as String,
  exampleMessage: json['example_message'] as String,
  keywordsTrigger: (json['keywords_trigger'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  keywordsExclude: (json['keywords_exclude'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  amountRegex: json['amount_regex'] as String,
  dateRegex: json['date_regex'] as String,
  descriptionRegex: json['description_regex'] as String,
  merchantRegex: json['merchant_regex'] as String,
  requiresValidation: json['requires_validation'] as bool,
  confidenceThreshold: (json['confidence_threshold'] as num).toDouble(),
  autoApprove: json['auto_approve'] as bool,
  matchCount: (json['match_count'] as num).toInt(),
  successCount: (json['success_count'] as num).toInt(),
  successRate: (json['success_rate'] as num).toDouble(),
  lastMatchedAt: json['last_matched_at'] as String?,
  priority: (json['priority'] as num).toInt(),
  isDefault: json['is_default'] as bool,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$BankNotificationPatternModelToJson(
  BankNotificationPatternModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'bank_account_id': instance.bankAccountId,
  'name': instance.name,
  'description': instance.description,
  'channel': _$NotificationChannelEnumMap[instance.channel]!,
  'status': _$NotificationPatternStatusEnumMap[instance.status]!,
  'message_pattern': instance.messagePattern,
  'example_message': instance.exampleMessage,
  'keywords_trigger': instance.keywordsTrigger,
  'keywords_exclude': instance.keywordsExclude,
  'amount_regex': instance.amountRegex,
  'date_regex': instance.dateRegex,
  'description_regex': instance.descriptionRegex,
  'merchant_regex': instance.merchantRegex,
  'requires_validation': instance.requiresValidation,
  'confidence_threshold': instance.confidenceThreshold,
  'auto_approve': instance.autoApprove,
  'match_count': instance.matchCount,
  'success_count': instance.successCount,
  'success_rate': instance.successRate,
  'last_matched_at': instance.lastMatchedAt,
  'priority': instance.priority,
  'is_default': instance.isDefault,
  'tags': instance.tags,
  'metadata': instance.metadata,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

const _$NotificationChannelEnumMap = {
  NotificationChannel.sms: 'sms',
  NotificationChannel.push: 'push',
  NotificationChannel.email: 'email',
  NotificationChannel.app: 'app',
};

const _$NotificationPatternStatusEnumMap = {
  NotificationPatternStatus.active: 'active',
  NotificationPatternStatus.inactive: 'inactive',
  NotificationPatternStatus.learning: 'learning',
};

ProcessedNotificationModel _$ProcessedNotificationModelFromJson(
  Map<String, dynamic> json,
) => ProcessedNotificationModel(
  bankAccountId: (json['bank_account_id'] as num).toInt(),
  channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
  message: json['message'] as String,
  processed: json['processed'] as bool,
  patternId: (json['pattern_id'] as num?)?.toInt(),
  patternName: json['pattern_name'] as String?,
  confidence: (json['confidence'] as num).toDouble(),
  requiresValidation: json['requires_validation'] as bool,
  extractedData: json['extracted_data'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ProcessedNotificationModelToJson(
  ProcessedNotificationModel instance,
) => <String, dynamic>{
  'bank_account_id': instance.bankAccountId,
  'channel': _$NotificationChannelEnumMap[instance.channel]!,
  'message': instance.message,
  'processed': instance.processed,
  'pattern_id': instance.patternId,
  'pattern_name': instance.patternName,
  'confidence': instance.confidence,
  'requires_validation': instance.requiresValidation,
  'extracted_data': instance.extractedData,
};

PatternStatisticsModel _$PatternStatisticsModelFromJson(
  Map<String, dynamic> json,
) => PatternStatisticsModel(
  totalPatterns: (json['total_patterns'] as num).toInt(),
  activePatterns: (json['active_patterns'] as num).toInt(),
  learningPatterns: (json['learning_patterns'] as num).toInt(),
  totalMatches: (json['total_matches'] as num).toInt(),
  totalSuccesses: (json['total_successes'] as num).toInt(),
  overallSuccessRate: (json['overall_success_rate'] as num).toDouble(),
);

Map<String, dynamic> _$PatternStatisticsModelToJson(
  PatternStatisticsModel instance,
) => <String, dynamic>{
  'total_patterns': instance.totalPatterns,
  'active_patterns': instance.activePatterns,
  'learning_patterns': instance.learningPatterns,
  'total_matches': instance.totalMatches,
  'total_successes': instance.totalSuccesses,
  'overall_success_rate': instance.overallSuccessRate,
};

CreateBankNotificationPatternRequest
_$CreateBankNotificationPatternRequestFromJson(Map<String, dynamic> json) =>
    CreateBankNotificationPatternRequest(
      bankAccountId: (json['bank_account_id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
      messagePattern: json['message_pattern'] as String?,
      exampleMessage: json['example_message'] as String?,
      keywordsTrigger:
          (json['keywords_trigger'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      keywordsExclude:
          (json['keywords_exclude'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      amountRegex: json['amount_regex'] as String?,
      dateRegex: json['date_regex'] as String?,
      descriptionRegex: json['description_regex'] as String?,
      merchantRegex: json['merchant_regex'] as String?,
      requiresValidation: json['requires_validation'] as bool? ?? true,
      confidenceThreshold:
          (json['confidence_threshold'] as num?)?.toDouble() ?? 0.8,
      autoApprove: json['auto_approve'] as bool? ?? false,
      priority: (json['priority'] as num?)?.toInt() ?? 100,
      isDefault: json['is_default'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CreateBankNotificationPatternRequestToJson(
  CreateBankNotificationPatternRequest instance,
) => <String, dynamic>{
  'bank_account_id': instance.bankAccountId,
  'name': instance.name,
  'description': instance.description,
  'channel': _$NotificationChannelEnumMap[instance.channel]!,
  'message_pattern': instance.messagePattern,
  'example_message': instance.exampleMessage,
  'keywords_trigger': instance.keywordsTrigger,
  'keywords_exclude': instance.keywordsExclude,
  'amount_regex': instance.amountRegex,
  'date_regex': instance.dateRegex,
  'description_regex': instance.descriptionRegex,
  'merchant_regex': instance.merchantRegex,
  'requires_validation': instance.requiresValidation,
  'confidence_threshold': instance.confidenceThreshold,
  'auto_approve': instance.autoApprove,
  'priority': instance.priority,
  'is_default': instance.isDefault,
  'tags': instance.tags,
  'metadata': instance.metadata,
};

UpdateBankNotificationPatternRequest
_$UpdateBankNotificationPatternRequestFromJson(Map<String, dynamic> json) =>
    UpdateBankNotificationPatternRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      messagePattern: json['message_pattern'] as String?,
      exampleMessage: json['example_message'] as String?,
      keywordsTrigger: (json['keywords_trigger'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      keywordsExclude: (json['keywords_exclude'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      amountRegex: json['amount_regex'] as String?,
      dateRegex: json['date_regex'] as String?,
      descriptionRegex: json['description_regex'] as String?,
      merchantRegex: json['merchant_regex'] as String?,
      requiresValidation: json['requires_validation'] as bool?,
      confidenceThreshold: (json['confidence_threshold'] as num?)?.toDouble(),
      autoApprove: json['auto_approve'] as bool?,
      priority: (json['priority'] as num?)?.toInt(),
      isDefault: json['is_default'] as bool?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UpdateBankNotificationPatternRequestToJson(
  UpdateBankNotificationPatternRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'message_pattern': instance.messagePattern,
  'example_message': instance.exampleMessage,
  'keywords_trigger': instance.keywordsTrigger,
  'keywords_exclude': instance.keywordsExclude,
  'amount_regex': instance.amountRegex,
  'date_regex': instance.dateRegex,
  'description_regex': instance.descriptionRegex,
  'merchant_regex': instance.merchantRegex,
  'requires_validation': instance.requiresValidation,
  'confidence_threshold': instance.confidenceThreshold,
  'auto_approve': instance.autoApprove,
  'priority': instance.priority,
  'is_default': instance.isDefault,
  'tags': instance.tags,
  'metadata': instance.metadata,
};

ProcessNotificationRequest _$ProcessNotificationRequestFromJson(
  Map<String, dynamic> json,
) => ProcessNotificationRequest(
  bankAccountId: (json['bank_account_id'] as num).toInt(),
  channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
  message: json['message'] as String,
);

Map<String, dynamic> _$ProcessNotificationRequestToJson(
  ProcessNotificationRequest instance,
) => <String, dynamic>{
  'bank_account_id': instance.bankAccountId,
  'channel': _$NotificationChannelEnumMap[instance.channel]!,
  'message': instance.message,
};
