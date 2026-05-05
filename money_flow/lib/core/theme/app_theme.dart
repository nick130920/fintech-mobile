import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Tema MoneyFlow.
///
/// Construye `ThemeData` light y dark consumiendo los tokens del design system
/// (`AppColors`, `AppTypography`, `AppRadius`, `AppSpacing`). Mapea
/// explicitamente todos los slots del `ColorScheme` que `DESIGN.md` pide y
/// aplica Inter al `TextTheme` via `google_fonts`.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Light
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.lightOnPrimaryContainer,
      secondary: AppColors.lightOnSurfaceMedium,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.lightSecondaryContainer,
      onSecondaryContainer: AppColors.lightOnSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.lightTertiaryContainer,
      onTertiaryContainer: AppColors.lightOnTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.lightErrorContainer,
      onErrorContainer: AppColors.lightOnErrorContainer,
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightOnSurface,
      surfaceContainerLowest: AppColors.lightSurfaceContainerLowest,
      surfaceContainerLow: AppColors.lightSurfaceContainerLow,
      surfaceContainer: AppColors.lightSurfaceContainer,
      surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
      surfaceDim: AppColors.lightSurfaceDim,
      surfaceBright: AppColors.lightSurfaceBright,
      surfaceTint: AppColors.primary,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,
      outline: AppColors.lightOutline,
      outlineVariant: AppColors.lightOutlineVariant,
      inverseSurface: AppColors.lightInverseSurface,
      onInverseSurface: AppColors.lightInverseOnSurface,
      inversePrimary: AppColors.lightInversePrimary,
      scrim: AppColors.scrim,
      shadow: AppColors.shadow,
    );

    return _build(
      colorScheme: colorScheme,
      onSurface: AppColors.lightOnSurface,
      onSurfaceVariant: AppColors.lightOnSurfaceMedium,
      surface: AppColors.lightBackground,
      surfaceContainer: AppColors.lightSurfaceContainer,
      onSurfaceMedium: AppColors.lightOnSurfaceMedium,
      onSurfaceSoft: AppColors.lightOnSurfaceSoft,
      outline: AppColors.lightOutlineVariant,
    );
  }

  // ---------------------------------------------------------------------------
  // Dark
  // ---------------------------------------------------------------------------
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkOnSurface,
      surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
      surfaceContainerLow: AppColors.darkSurfaceContainerLow,
      surfaceContainer: AppColors.darkSurfaceContainer,
      surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
      surfaceDim: AppColors.darkSurfaceDim,
      surfaceBright: AppColors.darkSurfaceBright,
      surfaceTint: AppColors.primary,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.slate700,
      inverseSurface: AppColors.darkOnSurface,
      onInverseSurface: AppColors.lightOnSurface,
      inversePrimary: AppColors.inversePrimary,
      scrim: AppColors.scrim,
      shadow: AppColors.shadow,
    );

    return _build(
      colorScheme: colorScheme,
      onSurface: AppColors.darkOnSurface,
      onSurfaceVariant: AppColors.darkOnSurfaceMedium,
      surface: AppColors.darkBackground,
      surfaceContainer: AppColors.darkSurface,
      onSurfaceMedium: AppColors.darkOnSurfaceMedium,
      onSurfaceSoft: AppColors.darkOnSurfaceSoft,
      outline: AppColors.darkBorder,
    );
  }

  // ---------------------------------------------------------------------------
  // Builder comun
  // ---------------------------------------------------------------------------
  static ThemeData _build({
    required ColorScheme colorScheme,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color surface,
    required Color surfaceContainer,
    required Color onSurfaceMedium,
    required Color onSurfaceSoft,
    required Color outline,
  }) {
    final textTheme = AppTypography.buildTextTheme(
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceMedium,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.interTextTheme(textTheme),
      primaryTextTheme: GoogleFonts.interTextTheme(textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: onSurfaceMedium),
        titleTextStyle: AppTypography.titleMd.copyWith(color: onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.step4,
          vertical: AppSpacing.step3 + 2,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.allBase,
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.allBase,
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.allBase,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.allBase,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.allBase,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTypography.labelLg.copyWith(color: onSurfaceMedium),
        hintStyle: AppTypography.bodyMd.copyWith(color: onSurfaceSoft),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.allBase),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.step5,
            vertical: AppSpacing.step4,
          ),
          textStyle: AppTypography.titleSm,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: surfaceContainer,
          foregroundColor: onSurfaceMedium,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.allPill),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.topXl),
        showDragHandle: true,
        dragHandleColor: onSurfaceMedium.withValues(alpha: 0.3),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
