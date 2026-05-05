import 'package:flutter/widgets.dart';

/// Tokens de espaciado del sistema MoneyFlow.
///
/// Todos los valores son multiplos de 8 (con un step de 4 como excepcion).
/// Espejo del bloque `spacing:` de `money_flow/DESIGN.md`.
class AppSpacing {
  AppSpacing._();

  static const double base = 8.0;

  static const double step1 = 4.0;
  static const double step2 = 8.0;
  static const double step3 = 12.0;
  static const double step4 = 16.0;
  static const double step5 = 24.0;
  static const double step6 = 32.0;
  static const double step7 = 40.0;
  static const double step8 = 48.0;
  static const double stepXxl = 64.0;

  // Aliases semanticos (DESIGN.md)
  static const double screenPadding = 24.0;
  static const double cardPadding = 16.0;
  static const double cardPaddingLg = 24.0;
  static const double glassPadding = 20.0;
  static const double sectionGap = 32.0;
  static const double cardGap = 16.0;
  static const double fieldGap = 8.0;
  static const double inlineGap = 12.0;

  // Helpers `EdgeInsets` precomputados
  static const EdgeInsets allXs = EdgeInsets.all(step1);
  static const EdgeInsets allSm = EdgeInsets.all(step2);
  static const EdgeInsets allMd = EdgeInsets.all(step3);
  static const EdgeInsets allLg = EdgeInsets.all(step4);
  static const EdgeInsets allXl = EdgeInsets.all(step5);

  static const EdgeInsets screen = EdgeInsets.all(screenPadding);
  static const EdgeInsets card = EdgeInsets.all(cardPadding);
  static const EdgeInsets cardLg = EdgeInsets.all(cardPaddingLg);
  static const EdgeInsets glass = EdgeInsets.all(glassPadding);

  static const EdgeInsets horizontalScreen = EdgeInsets.symmetric(horizontal: screenPadding);
  static const EdgeInsets verticalSection = EdgeInsets.symmetric(vertical: sectionGap);
}
