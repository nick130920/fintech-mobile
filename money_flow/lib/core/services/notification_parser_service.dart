import 'package:intl/intl.dart';

/// Servicio para parsear notificaciones bancarias y extraer información de transacciones
class NotificationParserService {
  /// Patrones de bancos colombianos
  static final Map<String, BankPattern> _bankPatterns = {
    // Bancolombia
    'co.com.bancolombia.personas.superapp': BankPattern(
      bankName: 'Bancolombia',
      patterns: [
        // Patrón para compras: "Compra en [COMERCIO], $[MONTO], tarjeta final [XXXX]"
        NotificationPattern(
          regex: r'Compra en\s+(.+?),\s+\$([0-9.,]+)',
          type: 'expense',
          amountGroup: 2,
          merchantGroup: 1,
        ),
        // Patrón para retiros
        NotificationPattern(
          regex: r'Retiro.*\$([0-9.,]+)(?:\s+en\s+(.+?))?',
          type: 'expense',
          amountGroup: 1,
          merchantGroup: 2,
        ),
        // Patrón para transferencias
        NotificationPattern(
          regex: r'(?:Transferencia|transferencia).*\$([0-9.,]+)',
          type: 'transfer',
          amountGroup: 1,
          merchantGroup: null,
        ),
        // Patrón genérico de transacción con monto
        NotificationPattern(
          regex: r'Se realizó.*por\s+\$([0-9.,]+)\s+en\s+(.+?)\s',
          type: 'expense',
          amountGroup: 1,
          merchantGroup: 2,
        ),
      ],
    ),
    
    // Nequi
    'com.nequi.MobileApp': BankPattern(
      bankName: 'Nequi',
      patterns: [
        // "has recibido $[MONTO] de [REMITENTE]"
        NotificationPattern(
          regex: r'has recibido\s+\$([0-9.,]+)\s+de\s+(.+?)\.?',
          type: 'income',
          amountGroup: 1,
          merchantGroup: 2,
        ),
        // "enviaste $[MONTO] a [DESTINATARIO]"
        NotificationPattern(
          regex: r'enviaste\s+\$([0-9.,]+)\s+a\s+(.+?)\.?',
          type: 'transfer',
          amountGroup: 1,
          merchantGroup: 2,
        ),
        // Patrón para pagos
        NotificationPattern(
          regex: r'[Pp]ago.*\$([0-9.,]+)',
          type: 'expense',
          amountGroup: 1,
          merchantGroup: null,
        ),
      ],
    ),
    
    // Davivienda
    'com.davivienda.daviviendaapp': BankPattern(
      bankName: 'Davivienda',
      patterns: [
        // "Una transferencia de $[MONTO] ha sido recibida"
        NotificationPattern(
          regex: r'transferencia de\s+\$([0-9.,]+)\s+ha sido recibida',
          type: 'income',
          amountGroup: 1,
          merchantGroup: null,
        ),
        // Compra con tarjeta
        NotificationPattern(
          regex: r'Compra.*\$([0-9.,]+)\s+en\s+(.+?)(?:\s|$)',
          type: 'expense',
          amountGroup: 1,
          merchantGroup: 2,
        ),
        // Retiro
        NotificationPattern(
          regex: r'Retiro de\s+\$([0-9.,]+)',
          type: 'expense',
          amountGroup: 1,
          merchantGroup: null,
        ),
      ],
    ),
    
    // DaviPlata (app separada)
    'com.daviplata.daviplataapp': BankPattern(
      bankName: 'DaviPlata',
      patterns: [
        NotificationPattern(
          regex: r'transferencia de\s+\$([0-9.,]+)\s+ha sido recibida',
          type: 'income',
          amountGroup: 1,
          merchantGroup: null,
        ),
        NotificationPattern(
          regex: r'Has enviado\s+\$([0-9.,]+)',
          type: 'transfer',
          amountGroup: 1,
          merchantGroup: null,
        ),
      ],
    ),
    
    // Banco Popular
    'com.grupoavalpo.bancamovil': BankPattern(
      bankName: 'Banco Popular',
      patterns: [
        // "Se realizó [TIPO] por $[MONTO] en [COMERCIO]"
        NotificationPattern(
          regex: r'Se realizó\s+(?:compra|pago)\s+por\s+\$([0-9.,]+)\s+en\s+(.+?)\s',
          type: 'expense',
          amountGroup: 1,
          merchantGroup: 2,
        ),
        NotificationPattern(
          regex: r'Retiro.*\$([0-9.,]+)',
          type: 'expense',
          amountGroup: 1,
          merchantGroup: null,
        ),
      ],
    ),
    
    // BBVA Colombia
    'co.com.bbva.mb': BankPattern(
      bankName: 'BBVA Colombia',
      patterns: [
        NotificationPattern(
          regex: r'Compra.*\$([0-9.,]+)\s+en\s+(.+?)(?:\s+el\s+|\.|$)',
          type: 'expense',
          amountGroup: 1,
          merchantGroup: 2,
        ),
        NotificationPattern(
          regex: r'Retiro.*\$([0-9.,]+)',
          type: 'expense',
          amountGroup: 1,
          merchantGroup: null,
        ),
        NotificationPattern(
          regex: r'Transferencia.*\$([0-9.,]+)',
          type: 'transfer',
          amountGroup: 1,
          merchantGroup: null,
        ),
      ],
    ),
    
    // AV Villas
    'com.grupoavalav1.bancamovil': BankPattern(
      bankName: 'AV Villas',
      patterns: [
        // "Retiro de $[MONTO] en [OFICINA/CAJERO]"
        NotificationPattern(
          regex: r'Retiro de\s+\$([0-9.,]+)\s+en\s+(.+?)\s+el',
          type: 'expense',
          amountGroup: 1,
          merchantGroup: 2,
        ),
        NotificationPattern(
          regex: r'Compra.*\$([0-9.,]+)\s+en\s+(.+?)(?:\s|$)',
          type: 'expense',
          amountGroup: 1,
          merchantGroup: 2,
        ),
      ],
    ),
    
    // Banco Falabella
    'co.com.bancofallabella.mobile.omc': BankPattern(
      bankName: 'Banco Falabella',
      patterns: [
        // "Compra por $[MONTO] con tarjeta final [XXXX] en [COMERCIO]"
        NotificationPattern(
          regex: r'Compra por\s+\$([0-9.,]+).*en\s+(.+?)\s+el',
          type: 'expense',
          amountGroup: 1,
          merchantGroup: 2,
        ),
      ],
    ),
  };

  /// Patrones genéricos para cuando no se reconoce el banco
  static final List<NotificationPattern> _genericPatterns = [
    // Patrones generales de compra (Colombia usa puntos como separadores de miles)
    NotificationPattern(
      regex: r'(?:Compra|Purchase).*?\$([0-9.,]+)(?:\s+(?:en|at|por)\s+(.+?))?(?:\s+el\s+|\.|$)',
      type: 'expense',
      amountGroup: 1,
      merchantGroup: 2,
    ),
    // Patrones generales de retiro
    NotificationPattern(
      regex: r'(?:Retiro|Withdrawal|Disposi).*?\$([0-9.,]+)(?:\s+(?:en|at|de)\s+(.+?))?(?:\s+el\s+|\.|$)',
      type: 'expense',
      amountGroup: 1,
      merchantGroup: 2,
    ),
    // Patrones generales de depósito/recepción
    NotificationPattern(
      regex: r'(?:Deposito|Abono|Deposit|recibido|recibiste).*?\$([0-9.,]+)(?:\s+(?:de|from)\s+(.+?))?(?:\s+el\s+|\.|$)',
      type: 'income',
      amountGroup: 1,
      merchantGroup: 2,
    ),
    // Patrones generales de transferencia
    NotificationPattern(
      regex: r'(?:Transferencia|Transfer|transferencia).*?\$([0-9.,]+)(?:\s+(?:a|de|to|from)\s+(.+?))?(?:\s+el\s+|\.|$)',
      type: 'transfer',
      amountGroup: 1,
      merchantGroup: 2,
    ),
    // Patrón para "has enviado"
    NotificationPattern(
      regex: r'(?:has enviado|enviaste).*?\$([0-9.,]+)(?:\s+a\s+(.+?))?',
      type: 'transfer',
      amountGroup: 1,
      merchantGroup: 2,
    ),
    // Patrón simple: solo detectar monto con formato colombiano
    NotificationPattern(
      regex: r'\$([0-9.,]+)',
      type: 'expense',
      amountGroup: 1,
      merchantGroup: null,
    ),
  ];

  /// Parsea una notificación y extrae información de transacción
  static Map<String, dynamic>? parseNotification({
    required String title,
    required String body,
    required String packageName,
  }) {
    print('🔍 Parseando notificación:');
    print('   Title: $title');
    print('   Body: $body');
    print('   Package: $packageName');

    // Combinar título y cuerpo para mejor análisis
    final fullText = '$title $body';

    // Intentar con patrones específicos del banco
    final bankPattern = _bankPatterns[packageName];
    if (bankPattern != null) {
      print('🏦 Banco reconocido: ${bankPattern.bankName}');
      final result = _tryPatterns(fullText, bankPattern.patterns, bankPattern.bankName);
      if (result != null) {
        return result;
      }
    }

    // Intentar con patrones genéricos
    print('🔍 Intentando con patrones genéricos...');
    final result = _tryPatterns(fullText, _genericPatterns, 'Desconocido');
    
    if (result == null) {
      print('❌ No se pudo parsear la notificación');
    }
    
    return result;
  }

  /// Intenta aplicar una lista de patrones al texto
  static Map<String, dynamic>? _tryPatterns(
    String text,
    List<NotificationPattern> patterns,
    String bankName,
  ) {
    for (final pattern in patterns) {
      final regex = RegExp(pattern.regex, caseSensitive: false);
      final match = regex.firstMatch(text);

      if (match != null) {
        print('✅ Patrón coincidente: ${pattern.regex}');
        
        // Extraer monto y convertir formato colombiano a formato de punto decimal
        // Formato colombiano: $1.500.000,50 -> 1500000.50
        String amountStr = match.group(pattern.amountGroup) ?? '0';
        // Remover puntos (separadores de miles)
        amountStr = amountStr.replaceAll('.', '');
        // Reemplazar coma (separador decimal) por punto
        amountStr = amountStr.replaceAll(',', '.');
        // Remover cualquier otro carácter no numérico excepto el punto
        amountStr = amountStr.replaceAll(RegExp(r'[^\d.]'), '');
        
        final amount = double.tryParse(amountStr);

        if (amount == null || amount <= 0) {
          print('❌ Monto inválido: $amountStr');
          continue;
        }

        // Extraer comercio/descripción
        String? merchant;
        if (pattern.merchantGroup != null) {
          merchant = match.group(pattern.merchantGroup)?.trim();
          // Limpiar el merchant de caracteres extraños
          merchant = merchant?.replaceAll(RegExp(r'\s+'), ' ');
        }

        // Generar descripción
        final description = merchant ?? 
            _generateDescriptionFromType(pattern.type) ?? 
            'Transacción automática';

        // Calcular confianza de IA basada en qué tan completa está la información
        double aiConfidence = 0.5;
        if (bankName != 'Desconocido') aiConfidence += 0.2;
        if (merchant != null && merchant.isNotEmpty) aiConfidence += 0.2;
        if (pattern.regex.length > 30) aiConfidence += 0.1; // Patrón más específico
        aiConfidence = aiConfidence.clamp(0.0, 1.0);

        return {
          'type': pattern.type,
          'amount': amount,
          'description': description,
          'merchant': merchant,
          'bank_name': bankName,
          'ai_confidence': aiConfidence,
          'transaction_date': DateTime.now().toIso8601String(),
        };
      }
    }

    return null;
  }

  /// Genera una descripción basada en el tipo de transacción
  static String? _generateDescriptionFromType(String type) {
    switch (type) {
      case 'expense':
        return 'Compra con tarjeta';
      case 'income':
        return 'Depósito recibido';
      case 'transfer':
        return 'Transferencia';
      default:
        return null;
    }
  }

  /// Añade un patrón personalizado para un banco
  static void addCustomBankPattern(
    String packageName,
    String bankName,
    List<NotificationPattern> patterns,
  ) {
    _bankPatterns[packageName] = BankPattern(
      bankName: bankName,
      patterns: patterns,
    );
    print('✅ Patrón personalizado añadido para $bankName');
  }

  /// Obtiene la lista de bancos soportados
  static List<String> getSupportedBanks() {
    return _bankPatterns.values.map((p) => p.bankName).toList();
  }
}

/// Modelo para un patrón de banco
class BankPattern {
  final String bankName;
  final List<NotificationPattern> patterns;

  BankPattern({
    required this.bankName,
    required this.patterns,
  });
}

/// Modelo para un patrón de notificación
class NotificationPattern {
  final String regex;
  final String type; // 'expense', 'income', 'transfer'
  final int amountGroup; // Grupo de captura para el monto
  final int? merchantGroup; // Grupo de captura para el comercio (opcional)

  NotificationPattern({
    required this.regex,
    required this.type,
    required this.amountGroup,
    this.merchantGroup,
  });
}


