import 'package:flutter/material.dart';

/// Tokens de color del sistema MoneyFlow.
///
/// Fuente unica de la paleta. Todo color en la UI debe venir de aqui o de
/// `Theme.of(context).colorScheme.*`. Espejo del bloque `colors:` y
/// `overlays:` de `money_flow/DESIGN.md`.
class AppColors {
  // ---------------------------------------------------------------------------
  // Brand / primary
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFF007BFF);
  static const Color primaryHover = Color(0xFF0066D9);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Tonal containers M3 (DESIGN.md)
  static const Color primaryContainer = Color(0xFF003F80);
  static const Color onPrimaryContainer = Color(0xFFCFE5FF);
  static const Color inversePrimary = Color(0xFF003F80);
  static const Color primaryFixed = Color(0xFFCFE5FF);
  static const Color primaryFixedDim = Color(0xFF9DCBFF);
  static const Color onPrimaryFixed = Color(0xFF001D36);
  static const Color onPrimaryFixedVariant = Color(0xFF003F80);

  // ---------------------------------------------------------------------------
  // Slate spine
  // ---------------------------------------------------------------------------
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // ---------------------------------------------------------------------------
  // Secondary / tertiary semanticos
  // ---------------------------------------------------------------------------
  static const Color secondary = Color(0xFF94A3B8);
  static const Color onSecondary = Color(0xFF0F172A);
  static const Color secondaryContainer = Color(0xFF1E293B);
  static const Color onSecondaryContainer = Color(0xFFE2E8F0);

  /// `tertiary` representa el rol de gastos en MoneyFlow.
  static const Color tertiary = Color(0xFFF87171);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF7F1D1D);
  static const Color onTertiaryContainer = Color(0xFFFECACA);

  // ---------------------------------------------------------------------------
  // Semantic feedback
  // ---------------------------------------------------------------------------
  static const Color white = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFF7F1D1D);
  static const Color onErrorContainer = Color(0xFFFCA5A5);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ---------------------------------------------------------------------------
  // Income / expense / status (DESIGN.md "colors:" section)
  // ---------------------------------------------------------------------------
  static const Color income = primary;
  static const Color expense = Color(0xFFF87171);
  static const Color expenseToday = Color(0xFFF97316);
  static const Color expenseRed = expense;
  static const Color expenseOrange = expenseToday;
  static const Color statusGood = Color(0xFF4ADE80);
  static const Color statusWarning = Color(0xFFFBBF24);
  static const Color statusDanger = Color(0xFFF87171);

  // Backwards-compat para indicadores de tendencia
  static const Color trendUp = expense;
  static const Color trendDown = statusGood;

  // ---------------------------------------------------------------------------
  // Backgrounds y superficies
  // ---------------------------------------------------------------------------
  static const Color backgroundLight = Color(0xFFF6F8FA);
  static const Color backgroundDark = Color(0xFF0A0F14);

  // Dark surfaces (DESIGN.md)
  static const Color darkBackground = Color(0xFF0A0F14);
  static const Color darkBackgroundGradient = Color(0xFF0D1419);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkOnSurface = Color(0xFFF8FAFC);
  static const Color darkOnSurfaceMedium = Color(0xFFE2E8F0);
  static const Color darkOnSurfaceSoft = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  static const Color darkSurfaceContainerLowest = Color(0xFF06090C);
  static const Color darkSurfaceContainerLow = Color(0xFF0F172A);
  static const Color darkSurfaceContainer = Color(0xFF1E293B);
  static const Color darkSurfaceContainerHigh = Color(0xFF293548);
  static const Color darkSurfaceContainerHighest = Color(0xFF334155);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkOnSurfaceVariant = Color(0xFFCBD5E1);
  static const Color darkSurfaceBright = Color(0xFF1E293B);
  static const Color darkSurfaceDim = Color(0xFF0A0F14);

  // Light surfaces (DESIGN.md theme.light overrides)
  static const Color lightBackground = Color(0xFFF6F8FA);
  static const Color lightBackgroundGradient = Color(0xFFF1F5F9);
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightOnSurfaceMedium = Color(0xFF64748B);
  static const Color lightOnSurfaceSoft = Color(0xFF94A3B8);

  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF8FAFC);
  static const Color lightSurfaceContainer = Color(0xFFF1F5F9);
  static const Color lightSurfaceContainerHigh = Color(0xFFE9EFF5);
  static const Color lightSurfaceContainerHighest = Color(0xFFE2E8F0);
  static const Color lightSurfaceVariant = Color(0xFFE2E8F0);
  static const Color lightOnSurfaceVariant = Color(0xFF334155);
  static const Color lightSurfaceBright = Color(0xFFFFFFFF);
  static const Color lightSurfaceDim = Color(0xFFD9DEE6);
  static const Color lightOutline = Color(0xFF64748B);
  static const Color lightOutlineVariant = Color(0xFFCBD5E1);

  static const Color lightPrimaryContainer = Color(0xFFCFE5FF);
  static const Color lightOnPrimaryContainer = Color(0xFF003F80);
  static const Color lightSecondaryContainer = Color(0xFFE2E8F0);
  static const Color lightOnSecondaryContainer = Color(0xFF0F172A);
  static const Color lightTertiaryContainer = Color(0xFFFECACA);
  static const Color lightOnTertiaryContainer = Color(0xFF7F1D1D);
  static const Color lightErrorContainer = Color(0xFFFECACA);
  static const Color lightOnErrorContainer = Color(0xFF7F1D1D);
  static const Color lightInverseSurface = Color(0xFF0F172A);
  static const Color lightInverseOnSurface = Color(0xFFF1F5F9);
  static const Color lightInversePrimary = Color(0xFF9DCBFF);

  // Compat con codigo previo
  static const Color glassLight = Color(0xFFFFFFFF);
  static const Color glassDark = Color(0xFF6B7C96);

  // ---------------------------------------------------------------------------
  // Focus / borders
  // ---------------------------------------------------------------------------
  static const Color focusBorder = primary;
  static const Color focusRing = Color(0x1A007BFF);

  // ---------------------------------------------------------------------------
  // Overlays (DESIGN.md "overlays:" block)
  // ---------------------------------------------------------------------------
  static const Color scrim = Color(0x66000000); // rgba(0,0,0,0.40)
  static const Color shadow = Color(0xFF000000);

  static const Color glassTintSoft = Color(0x0D007BFF); // primary @ 5%
  static const Color glassTintMedium = Color(0x1A007BFF); // primary @ 10%
  static const Color glassTintStrong = Color(0x26007BFF); // primary @ 15%

  static const Color glassCardBase = Color(0x08FFFFFF); // white @ 3%
  static const Color glassCardBorder = Color(0x0DFFFFFF); // white @ 5%
  static const Color glassShine = Color(0x4DFFFFFF); // white @ 30%
  static const Color glassShineStrong = Color(0x66FFFFFF); // white @ 40%

  // Backwards-compat tokens viejos
  static const Color glassBackground = glassTintSoft;
  static const Color glassBorder = glassTintMedium;
  static const Color glassCardBackground = glassCardBase;
  static const Color glassCardBackgroundDark = glassCardBase;
  static const Color glassCardBorderDark = glassCardBorder;

  static const Color textDisabled = Color(0x66F8FAFC); // on-surface @ 40%
  static const Color textWatermark = Color(0x1AF8FAFC); // on-surface @ 10%
  static const Color divider = Color(0x1A007BFF); // primary @ 10%
  static const Color ctaGlow = Color(0x4D007BFF); // primary @ 30%

  static const Color successSoft = Color(0x2610B981); // success @ 15%
  static const Color warningSoft = Color(0x26F59E0B); // warning @ 15%
  static const Color errorSoft = Color(0x26EF4444); // error @ 15%
  static const Color infoSoft = Color(0x263B82F6); // info @ 15%

  // ---------------------------------------------------------------------------
  // Brand gradient stops (consumidos por AppGradients y MoneyFlowLogo)
  // ---------------------------------------------------------------------------
  static const Color brandGradientStart = Color(0xFF00D4FF);
  static const Color brandGradientMid = Color(0xFF007BFF);
  static const Color brandGradientEnd = Color(0xFF001D6C);

  // ---------------------------------------------------------------------------
  // Progress
  // ---------------------------------------------------------------------------
  static const Color progressBackground = Color(0xFF1E293B);
  static const Color progressBackgroundLight = Color(0xFFE2E8F0);
  static const Color progressBar = primary;

  // ---------------------------------------------------------------------------
  // Bank account color seeds (paleta seleccionable de etiqueta de cuenta).
  // Vive en `AppColors` por ser dato de presentacion compartido por add/edit
  // bank account screens.
  // ---------------------------------------------------------------------------
  static const Color bankAccountBlue = primary;
  static const Color bankAccountGreen = Color(0xFF28A745);
  static const Color bankAccountRed = Color(0xFFDC3545);
  static const Color bankAccountYellow = Color(0xFFFFC107);
  static const Color bankAccountPurple = Color(0xFF6F42C1);
  static const Color bankAccountTeal = Color(0xFF20C997);
  static const Color bankAccountOrange = Color(0xFFFD7E14);
  static const Color bankAccountPink = Color(0xFFE83E8C);

  static const List<Color> bankAccountColorPalette = [
    bankAccountBlue,
    bankAccountGreen,
    bankAccountRed,
    bankAccountYellow,
    bankAccountPurple,
    bankAccountTeal,
    bankAccountOrange,
    bankAccountPink,
  ];
}
