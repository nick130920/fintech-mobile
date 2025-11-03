import 'package:json_annotation/json_annotation.dart';

part 'bank_account_model.g.dart';

enum BankAccountType {
  @JsonValue('checking')
  checking,
  @JsonValue('savings')
  savings,
  @JsonValue('credit')
  credit,
  @JsonValue('debit')
  debit,
  @JsonValue('investment')
  investment,
}

@JsonSerializable()
class BankAccountModel {
  final int id;
  @JsonKey(name: 'bank_name')
  final String bankName;
  @JsonKey(name: 'bank_code')
  final String bankCode;
  @JsonKey(name: 'branch_code')
  final String branchCode;
  @JsonKey(name: 'branch_name')
  final String branchName;
  @JsonKey(name: 'account_number_mask')
  final String accountNumberMask;
  @JsonKey(name: 'account_alias')
  final String accountAlias;
  final BankAccountType type;
  final String color;
  final String icon;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_notification_enabled')
  final bool isNotificationEnabled;
  final String currency;
  @JsonKey(name: 'last_balance')
  final double lastBalance;
  @JsonKey(name: 'last_balance_update')
  final String lastBalanceUpdate;
  @JsonKey(name: 'notification_phone')
  final String notificationPhone;
  @JsonKey(name: 'notification_email')
  final String notificationEmail;
  @JsonKey(name: 'min_amount_to_notify')
  final double minAmountToNotify;
  final String notes;
  @JsonKey(name: 'display_name')
  final String displayName;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  const BankAccountModel({
    required this.id,
    required this.bankName,
    required this.bankCode,
    required this.branchCode,
    required this.branchName,
    required this.accountNumberMask,
    required this.accountAlias,
    required this.type,
    required this.color,
    required this.icon,
    required this.isActive,
    required this.isNotificationEnabled,
    required this.currency,
    required this.lastBalance,
    required this.lastBalanceUpdate,
    required this.notificationPhone,
    required this.notificationEmail,
    required this.minAmountToNotify,
    required this.notes,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) =>
      _$BankAccountModelFromJson(json);

  Map<String, dynamic> toJson() => _$BankAccountModelToJson(this);

  BankAccountModel copyWith({
    int? id,
    String? bankName,
    String? bankCode,
    String? branchCode,
    String? branchName,
    String? accountNumberMask,
    String? accountAlias,
    BankAccountType? type,
    String? color,
    String? icon,
    bool? isActive,
    bool? isNotificationEnabled,
    String? currency,
    double? lastBalance,
    String? lastBalanceUpdate,
    String? notificationPhone,
    String? notificationEmail,
    double? minAmountToNotify,
    String? notes,
    String? displayName,
    String? createdAt,
    String? updatedAt,
  }) {
    return BankAccountModel(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      bankCode: bankCode ?? this.bankCode,
      branchCode: branchCode ?? this.branchCode,
      branchName: branchName ?? this.branchName,
      accountNumberMask: accountNumberMask ?? this.accountNumberMask,
      accountAlias: accountAlias ?? this.accountAlias,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
      currency: currency ?? this.currency,
      lastBalance: lastBalance ?? this.lastBalance,
      lastBalanceUpdate: lastBalanceUpdate ?? this.lastBalanceUpdate,
      notificationPhone: notificationPhone ?? this.notificationPhone,
      notificationEmail: notificationEmail ?? this.notificationEmail,
      minAmountToNotify: minAmountToNotify ?? this.minAmountToNotify,
      notes: notes ?? this.notes,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankAccountModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BankAccountModel{id: $id, displayName: $displayName, bankName: $bankName, accountAlias: $accountAlias}';
  }

  // Métodos de utilidad
  String get shortBankName {
    switch (bankName) {
      case 'Banco Bilbao Vizcaya Argentaria':
        return 'BBVA';
      case 'Banco Nacional de México':
        return 'Banamex';
      case 'Banco Santander México':
        return 'Santander';
      case 'HSBC México':
        return 'HSBC';
      case 'Banco Azteca':
        return 'Azteca';
      default:
        return bankName;
    }
  }

  bool get isCredit => type == BankAccountType.credit;
  bool get isDebit => type == BankAccountType.debit;
  bool get canReceiveNotifications => isActive && isNotificationEnabled;

  String get typeDisplayName {
    switch (type) {
      case BankAccountType.checking:
        return 'Cuenta Corriente';
      case BankAccountType.savings:
        return 'Cuenta de Ahorros';
      case BankAccountType.credit:
        return 'Tarjeta de Crédito';
      case BankAccountType.debit:
        return 'Tarjeta de Débito';
      case BankAccountType.investment:
        return 'Cuenta de Inversión';
    }
  }
}

@JsonSerializable()
class BankAccountSummaryModel {
  final int id;
  @JsonKey(name: 'bank_name')
  final String bankName;
  @JsonKey(name: 'short_bank_name')
  final String shortBankName;
  @JsonKey(name: 'account_alias')
  final String accountAlias;
  @JsonKey(name: 'account_number_mask')
  final String accountNumberMask;
  final BankAccountType type;
  final String color;
  final String icon;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final String currency;
  @JsonKey(name: 'last_balance')
  final double lastBalance;
  @JsonKey(name: 'last_balance_update')
  final String lastBalanceUpdate;
  @JsonKey(name: 'display_name')
  final String displayName;

  const BankAccountSummaryModel({
    required this.id,
    required this.bankName,
    required this.shortBankName,
    required this.accountAlias,
    required this.accountNumberMask,
    required this.type,
    required this.color,
    required this.icon,
    required this.isActive,
    required this.currency,
    required this.lastBalance,
    required this.lastBalanceUpdate,
    required this.displayName,
  });

  factory BankAccountSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$BankAccountSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$BankAccountSummaryModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankAccountSummaryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// DTOs para requests
@JsonSerializable()
class CreateBankAccountRequest {
  @JsonKey(name: 'bank_name')
  final String bankName;
  @JsonKey(name: 'bank_code')
  final String? bankCode;
  @JsonKey(name: 'branch_code')
  final String? branchCode;
  @JsonKey(name: 'branch_name')
  final String? branchName;
  @JsonKey(name: 'account_number')
  final String? accountNumber;
  @JsonKey(name: 'account_number_mask')
  final String accountNumberMask;
  @JsonKey(name: 'account_alias')
  final String accountAlias;
  final BankAccountType type;
  final String? color;
  final String? icon;
  @JsonKey(name: 'is_notification_enabled')
  final bool isNotificationEnabled;
  final String? currency;
  @JsonKey(name: 'notification_phone')
  final String? notificationPhone;
  @JsonKey(name: 'notification_email')
  final String? notificationEmail;
  @JsonKey(name: 'min_amount_to_notify')
  final double minAmountToNotify;
  final String? notes;

  const CreateBankAccountRequest({
    required this.bankName,
    this.bankCode,
    this.branchCode,
    this.branchName,
    this.accountNumber,
    required this.accountNumberMask,
    required this.accountAlias,
    required this.type,
    this.color,
    this.icon,
    this.isNotificationEnabled = true,
    this.currency,
    this.notificationPhone,
    this.notificationEmail,
    this.minAmountToNotify = 0.0,
    this.notes,
  });

  factory CreateBankAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBankAccountRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBankAccountRequestToJson(this);
}

@JsonSerializable()
class UpdateBankAccountRequest {
  @JsonKey(name: 'bank_name')
  final String? bankName;
  @JsonKey(name: 'account_alias')
  final String? accountAlias;
  final String? color;
  final String? icon;
  final String? currency;
  @JsonKey(name: 'is_notification_enabled')
  final bool? isNotificationEnabled;
  @JsonKey(name: 'notification_phone')
  final String? notificationPhone;
  @JsonKey(name: 'notification_email')
  final String? notificationEmail;
  @JsonKey(name: 'min_amount_to_notify')
  final double? minAmountToNotify;
  final String? notes;

  const UpdateBankAccountRequest({
    this.bankName,
    this.accountAlias,
    this.color,
    this.icon,
    this.currency,
    this.isNotificationEnabled,
    this.notificationPhone,
    this.notificationEmail,
    this.minAmountToNotify,
    this.notes,
  });

  factory UpdateBankAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateBankAccountRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateBankAccountRequestToJson(this);
}
