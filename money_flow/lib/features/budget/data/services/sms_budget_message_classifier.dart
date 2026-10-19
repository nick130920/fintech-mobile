/// Recall-first, local-only eligibility check; not a transaction parser.
///
/// Unknown financial messages stay eligible for backend analysis. Sender identity
/// and bank brands are deliberately not prerequisites.
class SmsBudgetMessageClassifier {
  const SmsBudgetMessageClassifier();

  static final _words = RegExp(r'[a-z0-9]+');
  static final _money = RegExp(
    r'[$€£]\s*\d|\d[\d.,]*\s*(?:cop|usd|eur|pesos|dolares)\b|'
    r'\b(?:cop|usd|eur|pesos|dolares)\s*\d',
  );
  static final _transaction = RegExp(
    r'^(?:compr|retir|pag|transfer|debit|abon|credit|deposit|'
    r'consign|recarg|nomina|movimiento|transacci|purchase|payment|'
    r'paid|withdraw|transaction)',
  );
  static final _nonPostingClause = RegExp(r'\b(?:si|no|nunca)\b[^,.!?;\n]*');
  static final _completed = RegExp(
    r'^(?:compraste|compro|retiraste|pagaste|transferiste|'
    r'transfirio|acredito|consignaste|depositaste|realizaste|efectuaste|hiciste|'
    r'debitaron|acreditaron|abonaron|descontaron|'
    r'paid|purchased|withdrew|credited|debited)$',
  );
  static final _completionStatus = RegExp(
    r'\b(?:compra|retiro|pago|transferencia|debito|abono|credito|deposito|'
    r'consignacion|transaccion|purchase|payment|transfer|withdrawal)\s+'
    r'(?:(?:por|de)\s+(?:(?:cop|usd|eur)\s+)?[$€£]?\s*\d[\d.,]*\s*'
    r'(?:(?:cop|usd|eur|pesos|dolares)\s+)?)?'
    r'(?:(?:fue|ha sido|was|has been)\s+)?'
    r'(?:realizad[oa]s?|efectuad[oa]s?|exitos[oa]s?|aprobad[oa]s?|'
    r'enviad[oa]s?|debitad[oa]s?|acreditad[oa]s?|'
    r'abonad[oa]s?|procesad[oa]s?|applied|completed|successful|approved)\b',
  );
  static final _receivedPosting = RegExp(
    r'\b(?:transferencia|pago|abono|deposito|consignacion)\s+'
    r'(?:\w+\s+){0,3}recibid[oa]s?\b',
  );
  static final _accountPosting = RegExp(
    r'\bse\s+(?:debito|acredito|abono|desconto|retiro)\b',
  );
  static final _receivedFinancial = RegExp(
    r'\b(?:recibiste|recibio|recibimos|received)\s+'
    r'(?:(?:un|una|el|la|a)\s+)?'
    r'(?:transferencia|pago|abono|consignacion|deposito|dinero|transfer|payment|[$€£]|\d)',
  );
  static final _callToAction = RegExp(
    r'\b(?:compra|paga|transfiere|recarga|buy|pay)\s+(?:hoy|ahora|ya|now|today)\b',
  );
  static final _securityReminder = RegExp(
    r'\b(?:no|nunca)\s+compartas\b[^.!?;]*',
  );
  static final _authenticationDetails = RegExp(r'\d|\b(?:autoriz|authoriz)\w*');
  static final _authentication = RegExp(
    r'^(?:otp|codigo|clave|contrasena|password|verificacion|verification|'
    r'autenticacion|authentication|seguridad|security|sesion|login)$',
  );
  static final _promotion = RegExp(
    r'^(?:promoci\w*|oferta\w*|descuento\w*|preaprobad\w*|'
    r'solicit\w*|aprovech\w*|gana|cashback|offer\w*|discount\w*)$',
  );

  bool shouldInclude(String? body) {
    if (body == null || body.trim().isEmpty) return false;
    final text = _normalize(body);
    final tokens = _words.allMatches(text).map((m) => m[0]!).toSet();
    final hasReceivedFinancial = _receivedFinancial.hasMatch(text);
    final hasTransaction =
        tokens.any(_transaction.hasMatch) || hasReceivedFinancial;
    final hasMoney = _money.hasMatch(text);
    final hasFinancialEvidence =
        hasTransaction ||
        hasMoney ||
        tokens.contains('saldo') ||
        tokens.contains('balance');
    if (!hasFinancialEvidence) return false;

    // Negated or conditional clauses cannot establish an actual posting.
    // Keep the original text for recall-first financial and exclusion checks.
    final postingText = text.replaceAll(_nonPostingClause, ' ');
    // A reported transaction takes precedence over an appended promotion.
    final hasCompletedTransaction =
        hasTransaction &&
        (_words
                .allMatches(postingText)
                .any((match) => _completed.hasMatch(match[0]!)) ||
            _completionStatus.hasMatch(postingText) ||
            _receivedFinancial.hasMatch(postingText) ||
            _accountPosting.hasMatch(postingText) ||
            _receivedPosting.hasMatch(postingText));
    if (hasCompletedTransaction) return true;

    // A security reminder alone must not veto ambiguous financial evidence.
    // Keep clauses with credentials or authorization context visible as well.
    final authenticationText = text.replaceAllMapped(_securityReminder, (
      match,
    ) {
      final reminder = match[0]!;
      return _authenticationDetails.hasMatch(reminder) ? reminder : ' ';
    });
    final hasAuthentication = _words
        .allMatches(authenticationText)
        .any((match) => _authentication.hasMatch(match[0]!));
    if (hasAuthentication ||
        tokens.any(_promotion.hasMatch) ||
        _callToAction.hasMatch(text)) {
      return false;
    }
    return true;
  }

  static String _normalize(String text) {
    const accents = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
    };
    var normalized = text.toLowerCase();
    accents.forEach((accent, plain) {
      normalized = normalized.replaceAll(accent, plain);
    });
    return normalized;
  }
}
