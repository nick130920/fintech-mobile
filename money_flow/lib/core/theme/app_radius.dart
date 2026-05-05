import 'package:flutter/widgets.dart';

/// Tokens de radio del sistema MoneyFlow.
///
/// Espejo del bloque `rounded:` de `money_flow/DESIGN.md`.
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double base = 12.0;
  static const double md = 14.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double pill = 9999.0;

  static const Radius radiusXs = Radius.circular(xs);
  static const Radius radiusSm = Radius.circular(sm);
  static const Radius radiusBase = Radius.circular(base);
  static const Radius radiusMd = Radius.circular(md);
  static const Radius radiusLg = Radius.circular(lg);
  static const Radius radiusXl = Radius.circular(xl);
  static const Radius radiusPill = Radius.circular(pill);

  static const BorderRadius allXs = BorderRadius.all(radiusXs);
  static const BorderRadius allSm = BorderRadius.all(radiusSm);
  static const BorderRadius allBase = BorderRadius.all(radiusBase);
  static const BorderRadius allMd = BorderRadius.all(radiusMd);
  static const BorderRadius allLg = BorderRadius.all(radiusLg);
  static const BorderRadius allXl = BorderRadius.all(radiusXl);
  static const BorderRadius allPill = BorderRadius.all(radiusPill);

  /// Top-only `xl` (modal sheets / bottom sheets segun DESIGN.md).
  static const BorderRadius topXl = BorderRadius.vertical(top: radiusXl);
}
