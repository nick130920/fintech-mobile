// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmsSettings _$SmsSettingsFromJson(Map<String, dynamic> json) => SmsSettings(
      autoProcessEnabled: json['autoProcessEnabled'] as bool? ?? true,
      requireActiveBankAccounts:
          json['requireActiveBankAccounts'] as bool? ?? true,
      minProcessDate: json['minProcessDate'] == null
          ? null
          : DateTime.parse(json['minProcessDate'] as String),
      processMode: $enumDecodeNullable(_$SmsProcessModeEnumMap, json['processMode']) ??
          SmsProcessMode.currentMonth,
      lastManualSync: json['lastManualSync'] == null
          ? null
          : DateTime.parse(json['lastManualSync'] as String),
    );

Map<String, dynamic> _$SmsSettingsToJson(SmsSettings instance) =>
    <String, dynamic>{
      'autoProcessEnabled': instance.autoProcessEnabled,
      'requireActiveBankAccounts': instance.requireActiveBankAccounts,
      'minProcessDate': instance.minProcessDate?.toIso8601String(),
      'processMode': _$SmsProcessModeEnumMap[instance.processMode]!,
      'lastManualSync': instance.lastManualSync?.toIso8601String(),
    };

const _$SmsProcessModeEnumMap = {
  SmsProcessMode.currentMonth: 'currentMonth',
  SmsProcessMode.lastThreeMonths: 'lastThreeMonths',
  SmsProcessMode.lastSixMonths: 'lastSixMonths',
  SmsProcessMode.customDate: 'customDate',
  SmsProcessMode.all: 'all',
};

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

