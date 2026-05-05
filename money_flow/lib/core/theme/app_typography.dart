import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tokens tipograficos del sistema MoneyFlow.
///
/// Espejo del bloque `typography:` de `money_flow/DESIGN.md`. Todos los
/// estilos heredan la familia Inter via `google_fonts`.
class AppTypography {
  AppTypography._();

  // ---------------------------------------------------------------------------
  // Display
  // ---------------------------------------------------------------------------
  static TextStyle get displayLg => GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 48 / 40,
        letterSpacing: -0.02 * 40,
      );

  static TextStyle get displayMd => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 44 / 36,
        letterSpacing: -0.02 * 36,
      );

  static TextStyle get displaySm => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
      );

  // ---------------------------------------------------------------------------
  // Headline
  // ---------------------------------------------------------------------------
  static TextStyle get headlineLg => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36 / 28,
        letterSpacing: -0.01 * 28,
      );

  static TextStyle get headlineMd => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
      );

  static TextStyle get headlineSm => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 28 / 20,
      );

  // ---------------------------------------------------------------------------
  // Title
  // ---------------------------------------------------------------------------
  static TextStyle get titleLg => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
      );

  static TextStyle get titleMd => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
      );

  static TextStyle get titleSm => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
      );

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
      );

  // ---------------------------------------------------------------------------
  // Label
  // ---------------------------------------------------------------------------
  static TextStyle get labelLg => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        letterSpacing: 0.01 * 14,
      );

  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.02 * 12,
      );

  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 14 / 10,
        letterSpacing: 0.04 * 10,
      );

  // ---------------------------------------------------------------------------
  // Custom roles (DESIGN.md "custom-amount-hero" / "custom-amount-card" /
  // "custom-eyebrow")
  // ---------------------------------------------------------------------------

  /// Numero hero del dashboard (presupuesto total, balance principal).
  static TextStyle get customAmountHero => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 34 / 28,
        letterSpacing: -0.01 * 28,
      );

  /// Monto en cards y filas de lista de transacciones.
  static TextStyle get customAmountCard => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 24 / 18,
      );

  /// Etiqueta firma del sistema (ALL CAPS, +0.10em, primary blue).
  static TextStyle get customEyebrow => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.10 * 12,
        color: AppColors.primary,
      );

  // ---------------------------------------------------------------------------
  // TextTheme constructor (consumido por AppTheme)
  // ---------------------------------------------------------------------------

  /// Construye un `TextTheme` Material 3 a partir de los tokens. Los colores
  /// los aplica `AppTheme` segun light/dark.
  static TextTheme buildTextTheme({required Color onSurface, required Color onSurfaceVariant}) {
    return TextTheme(
      displayLarge: displayLg.copyWith(color: onSurface),
      displayMedium: displayMd.copyWith(color: onSurface),
      displaySmall: displaySm.copyWith(color: onSurface),
      headlineLarge: headlineLg.copyWith(color: onSurface),
      headlineMedium: headlineMd.copyWith(color: onSurface),
      headlineSmall: headlineSm.copyWith(color: onSurface),
      titleLarge: titleLg.copyWith(color: onSurface),
      titleMedium: titleMd.copyWith(color: onSurfaceVariant),
      titleSmall: titleSm.copyWith(color: onSurface),
      bodyLarge: bodyLg.copyWith(color: onSurface),
      bodyMedium: bodyMd.copyWith(color: onSurfaceVariant),
      bodySmall: bodySm.copyWith(color: onSurfaceVariant),
      labelLarge: labelLg.copyWith(color: onSurfaceVariant),
      labelMedium: labelMd.copyWith(color: onSurfaceVariant),
      labelSmall: labelSm.copyWith(color: onSurfaceVariant),
    );
  }
}
