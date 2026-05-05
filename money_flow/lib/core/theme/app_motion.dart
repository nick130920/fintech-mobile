import 'package:flutter/animation.dart';

/// Tokens de motion del sistema MoneyFlow.
///
/// Espejo del bloque `motion:` de `money_flow/DESIGN.md`. Incluye duraciones,
/// easings nombrados y constantes auxiliares para los primitives declarados
/// en el design system.
class AppMotion {
  AppMotion._();

  // ---------------------------------------------------------------------------
  // Durations
  // ---------------------------------------------------------------------------
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration pronounced = Duration(milliseconds: 600);
  static const Duration cinematic = Duration(milliseconds: 1200);
  static const Duration pulseCycle = Duration(milliseconds: 2000);

  // ---------------------------------------------------------------------------
  // Easings (cubic-bezier nombrados de DESIGN.md)
  // ---------------------------------------------------------------------------
  static const Curve standard = Cubic(0.4, 0.0, 0.2, 1.0);
  static const Curve easeIn = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Curve easeOut = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve easeInOut = Cubic(0.4, 0.0, 0.2, 1.0);
  static const Curve easeOutCubic = Cubic(0.33, 1.0, 0.68, 1.0);
  static const Curve elastic = Cubic(0.34, 1.56, 0.64, 1.0);

  // ---------------------------------------------------------------------------
  // Primitive constants (DESIGN.md motion.primitives.*)
  // ---------------------------------------------------------------------------
  static const Duration entryCard = slow; // 400ms
  static const Duration entryCardCinematic = cinematic; // 1200ms
  static const Duration listItemSlideIn = slow; // 400ms
  static const Duration listItemStagger = Duration(milliseconds: 50);
  static const Duration hoverLiftCard = base; // 200ms
  static const Duration hoverLiftList = fast; // 150ms
  static const Duration pressScale = base; // 200ms
  static const Duration ripple = pronounced; // 600ms
  static const Duration snackbarEnter = medium; // 300ms

  static const double hoverLiftCardScale = 1.02;
  static const double hoverLiftListScale = 1.01;
  static const double pressScaleAmount = 0.95;
  static const double pulseMaxScale = 1.05;

  static const double cardEntryStartScale = 0.95;
  static const Offset listItemStartOffset = Offset(0.2, 0.0);
}
