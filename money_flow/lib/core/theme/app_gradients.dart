import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Tokens de gradiente del sistema MoneyFlow.
///
/// Espejo del bloque `gradients:` de `money_flow/DESIGN.md`. El brand wave es
/// la firma visual del producto y se aplica al logo y a CTAs principales.
class AppGradients {
  AppGradients._();

  /// Brand wave (cyan -> mid-blue -> deep-navy, 90deg).
  /// Usada en `MoneyFlowLogo` y en CTAs principales.
  static const LinearGradient brandWave = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.0, 0.5, 1.0],
    colors: [
      AppColors.brandGradientStart,
      AppColors.brandGradientMid,
      AppColors.brandGradientEnd,
    ],
  );

  /// Glass card medium (135deg). Capa por defecto para cards en dark.
  static const LinearGradient glassCardDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x26007BFF), // primary @ 15%
      Color(0x14007BFF), // primary @ 8%
    ],
  );

  /// Glass card heavy (135deg). Reservada para focal cards (budget hero).
  static const LinearGradient glassCardHeavyDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40007BFF), // primary @ 25%
      Color(0x2E007BFF), // primary @ 18%
    ],
  );

  /// Glass button primary (135deg).
  static const LinearGradient buttonGlassPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xCC007BFF), // primary @ 80%
      Color(0x99007BFF), // primary @ 60%
    ],
  );

  /// Glass button floating (135deg). Para FABs y home-row CTAs.
  static const LinearGradient buttonGlassFloating = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF2007BFF), // primary @ 95%
      Color(0xCC007BFF), // primary @ 80%
    ],
  );

  // ---------------------------------------------------------------------------
  // Onboarding illustration backgrounds (translucentes a 10% para no robar foco)
  // ---------------------------------------------------------------------------
  static const LinearGradient onboardingBudget = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1A007BFF), // primary @ 10%
      Color(0x1A60A5FA), // primary-light @ 10%
    ],
  );

  static const LinearGradient onboardingExpense = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1A10B981), // success @ 10%
      Color(0x1A34D399), // success-light @ 10%
    ],
  );

  static const LinearGradient onboardingProgress = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1A8B5CF6), // tertiary purple @ 10%
      Color(0x1AA78BFA), // tertiary purple-light @ 10%
    ],
  );

  static const LinearGradient onboardingAlerts = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AF59E0B), // warning @ 10%
      Color(0x1AFBBF24), // warning-light @ 10%
    ],
  );
}
