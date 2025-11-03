import 'package:json_annotation/json_annotation.dart';

part 'sms_settings.g.dart';

@JsonSerializable()
class SmsSettings {
  // Control de procesamiento automático
  final bool autoProcessEnabled;
  
  // Solo procesar si hay cuentas bancarias activas
  final bool requireActiveBankAccounts;
  
  // Fecha mínima desde la cual procesar SMS (null = sin límite)
  final DateTime? minProcessDate;
  
  // Modo de procesamiento
  final SmsProcessMode processMode;
  
  // Última vez que se sincronizó manualmente
  final DateTime? lastManualSync;

  SmsSettings({
    this.autoProcessEnabled = true,
    this.requireActiveBankAccounts = true,
    this.minProcessDate,
    this.processMode = SmsProcessMode.currentMonth,
    this.lastManualSync,
  });

  factory SmsSettings.fromJson(Map<String, dynamic> json) => _$SmsSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$SmsSettingsToJson(this);

  SmsSettings copyWith({
    bool? autoProcessEnabled,
    bool? requireActiveBankAccounts,
    DateTime? minProcessDate,
    SmsProcessMode? processMode,
    DateTime? lastManualSync,
  }) {
    return SmsSettings(
      autoProcessEnabled: autoProcessEnabled ?? this.autoProcessEnabled,
      requireActiveBankAccounts: requireActiveBankAccounts ?? this.requireActiveBankAccounts,
      minProcessDate: minProcessDate ?? this.minProcessDate,
      processMode: processMode ?? this.processMode,
      lastManualSync: lastManualSync ?? this.lastManualSync,
    );
  }

  // Verificar si un mensaje con fecha específica debe ser procesado
  bool shouldProcessMessage(DateTime messageDate) {
    if (minProcessDate == null) return true;
    return messageDate.isAfter(minProcessDate!) || messageDate.isAtSameMomentAs(minProcessDate!);
  }

  // Obtener la fecha mínima según el modo
  DateTime? getEffectiveMinDate() {
    switch (processMode) {
      case SmsProcessMode.currentMonth:
        final now = DateTime.now();
        return DateTime(now.year, now.month, 1);
      case SmsProcessMode.lastThreeMonths:
        final now = DateTime.now();
        return DateTime(now.year, now.month - 3, 1);
      case SmsProcessMode.lastSixMonths:
        final now = DateTime.now();
        return DateTime(now.year, now.month - 6, 1);
      case SmsProcessMode.customDate:
        return minProcessDate;
      case SmsProcessMode.all:
        return null;
    }
  }
}

enum SmsProcessMode {
  currentMonth,      // Solo mensajes del mes actual
  lastThreeMonths,   // Últimos 3 meses
  lastSixMonths,     // Últimos 6 meses
  customDate,        // Desde fecha personalizada
  all,               // Todos los mensajes
}

extension SmsProcessModeExtension on SmsProcessMode {
  String get displayName {
    switch (this) {
      case SmsProcessMode.currentMonth:
        return 'Solo mes actual';
      case SmsProcessMode.lastThreeMonths:
        return 'Últimos 3 meses';
      case SmsProcessMode.lastSixMonths:
        return 'Últimos 6 meses';
      case SmsProcessMode.customDate:
        return 'Desde fecha personalizada';
      case SmsProcessMode.all:
        return 'Todos los mensajes';
    }
  }

  String get description {
    switch (this) {
      case SmsProcessMode.currentMonth:
        return 'Procesar solo SMS del mes en curso';
      case SmsProcessMode.lastThreeMonths:
        return 'Procesar SMS de los últimos 3 meses';
      case SmsProcessMode.lastSixMonths:
        return 'Procesar SMS de los últimos 6 meses';
      case SmsProcessMode.customDate:
        return 'Procesar SMS desde una fecha específica';
      case SmsProcessMode.all:
        return 'Procesar todos los SMS sin restricción';
    }
  }
}

