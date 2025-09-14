// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankAccountModel _$BankAccountModelFromJson(Map<String, dynamic> json) =>
    BankAccountModel(
      id: (json['id'] as num).toInt(),
      bankName: json['bank_name'] as String,
      bankCode: json['bank_code'] as String,
      branchCode: json['branch_code'] as String,
      branchName: json['branch_name'] as String,
      accountNumberMask: json['account_number_mask'] as String,
      accountAlias: json['account_alias'] as String,
      type: $enumDecode(_$BankAccountTypeEnumMap, json['type']),
      color: json['color'] as String,
      icon: json['icon'] as String,
      isActive: json['is_active'] as bool,
      isNotificationEnabled: json['is_notification_enabled'] as bool,
      currency: json['currency'] as String,
      lastBalance: (json['last_balance'] as num).toDouble(),
      lastBalanceUpdate: json['last_balance_update'] as String,
      notificationPhone: json['notification_phone'] as String,
      notificationEmail: json['notification_email'] as String,
      minAmountToNotify: (json['min_amount_to_notify'] as num).toDouble(),
      notes: json['notes'] as String,
      displayName: json['display_name'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$BankAccountModelToJson(BankAccountModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bank_name': instance.bankName,
      'bank_code': instance.bankCode,
      'branch_code': instance.branchCode,
      'branch_name': instance.branchName,
      'account_number_mask': instance.accountNumberMask,
      'account_alias': instance.accountAlias,
      'type': _$BankAccountTypeEnumMap[instance.type]!,
      'color': instance.color,
      'icon': instance.icon,
      'is_active': instance.isActive,
      'is_notification_enabled': instance.isNotificationEnabled,
      'currency': instance.currency,
      'last_balance': instance.lastBalance,
      'last_balance_update': instance.lastBalanceUpdate,
      'notification_phone': instance.notificationPhone,
      'notification_email': instance.notificationEmail,
      'min_amount_to_notify': instance.minAmountToNotify,
      'notes': instance.notes,
      'display_name': instance.displayName,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

const _$BankAccountTypeEnumMap = {
  BankAccountType.checking: 'checking',
  BankAccountType.savings: 'savings',
  BankAccountType.credit: 'credit',
  BankAccountType.debit: 'debit',
  BankAccountType.investment: 'investment',
};

BankAccountSummaryModel _$BankAccountSummaryModelFromJson(
  Map<String, dynamic> json,
) => BankAccountSummaryModel(
  id: (json['id'] as num).toInt(),
  bankName: json['bank_name'] as String,
  shortBankName: json['short_bank_name'] as String,
  accountAlias: json['account_alias'] as String,
  accountNumberMask: json['account_number_mask'] as String,
  type: $enumDecode(_$BankAccountTypeEnumMap, json['type']),
  color: json['color'] as String,
  icon: json['icon'] as String,
  isActive: json['is_active'] as bool,
  currency: json['currency'] as String,
  lastBalance: (json['last_balance'] as num).toDouble(),
  lastBalanceUpdate: json['last_balance_update'] as String,
  displayName: json['display_name'] as String,
);

Map<String, dynamic> _$BankAccountSummaryModelToJson(
  BankAccountSummaryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'bank_name': instance.bankName,
  'short_bank_name': instance.shortBankName,
  'account_alias': instance.accountAlias,
  'account_number_mask': instance.accountNumberMask,
  'type': _$BankAccountTypeEnumMap[instance.type]!,
  'color': instance.color,
  'icon': instance.icon,
  'is_active': instance.isActive,
  'currency': instance.currency,
  'last_balance': instance.lastBalance,
  'last_balance_update': instance.lastBalanceUpdate,
  'display_name': instance.displayName,
};

CreateBankAccountRequest _$CreateBankAccountRequestFromJson(
  Map<String, dynamic> json,
) => CreateBankAccountRequest(
  bankName: json['bank_name'] as String,
  bankCode: json['bank_code'] as String?,
  branchCode: json['branch_code'] as String?,
  branchName: json['branch_name'] as String?,
  accountNumber: json['account_number'] as String?,
  accountNumberMask: json['account_number_mask'] as String,
  accountAlias: json['account_alias'] as String,
  type: $enumDecode(_$BankAccountTypeEnumMap, json['type']),
  color: json['color'] as String?,
  icon: json['icon'] as String?,
  isNotificationEnabled: json['is_notification_enabled'] as bool? ?? true,
  currency: json['currency'] as String?,
  notificationPhone: json['notification_phone'] as String?,
  notificationEmail: json['notification_email'] as String?,
  minAmountToNotify: (json['min_amount_to_notify'] as num?)?.toDouble() ?? 0.0,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$CreateBankAccountRequestToJson(
  CreateBankAccountRequest instance,
) => <String, dynamic>{
  'bank_name': instance.bankName,
  'bank_code': instance.bankCode,
  'branch_code': instance.branchCode,
  'branch_name': instance.branchName,
  'account_number': instance.accountNumber,
  'account_number_mask': instance.accountNumberMask,
  'account_alias': instance.accountAlias,
  'type': _$BankAccountTypeEnumMap[instance.type]!,
  'color': instance.color,
  'icon': instance.icon,
  'is_notification_enabled': instance.isNotificationEnabled,
  'currency': instance.currency,
  'notification_phone': instance.notificationPhone,
  'notification_email': instance.notificationEmail,
  'min_amount_to_notify': instance.minAmountToNotify,
  'notes': instance.notes,
};

UpdateBankAccountRequest _$UpdateBankAccountRequestFromJson(
  Map<String, dynamic> json,
) => UpdateBankAccountRequest(
  bankName: json['bank_name'] as String?,
  accountAlias: json['account_alias'] as String?,
  color: json['color'] as String?,
  icon: json['icon'] as String?,
  isNotificationEnabled: json['is_notification_enabled'] as bool?,
  notificationPhone: json['notification_phone'] as String?,
  notificationEmail: json['notification_email'] as String?,
  minAmountToNotify: (json['min_amount_to_notify'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$UpdateBankAccountRequestToJson(
  UpdateBankAccountRequest instance,
) => <String, dynamic>{
  'bank_name': instance.bankName,
  'account_alias': instance.accountAlias,
  'color': instance.color,
  'icon': instance.icon,
  'is_notification_enabled': instance.isNotificationEnabled,
  'notification_phone': instance.notificationPhone,
  'notification_email': instance.notificationEmail,
  'min_amount_to_notify': instance.minAmountToNotify,
  'notes': instance.notes,
};
