import 'package:flutter/material.dart';

/// Paleta alineada con dashboard_money_flow_blue.html:
/// primary #007bff, background-dark #0a0f14, background-light #f6f8fa,
/// glass con primary 5%, glass-card con white 3%.
class AppColors {
  // Primary - del diseño HTML
  static const Color primary = Color(0xFF007BFF);
  static const Color primaryHover = Color(0xFF0066D9);

  // Neutral - slate (texto y superficies)
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

  // Semantic
  static const Color white = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // Gastos / negativos (red-400 del HTML)
  static const Color expenseRed = Color(0xFFF87171);
  // Ingresos / positivos usan primary
  // Gastos de hoy / naranja (orange-500 del HTML)
  static const Color expenseOrange = Color(0xFFF97316);

  static const Color focusBorder = Color(0xFF007BFF);
  static const Color focusRing = Color(0x1A007BFF);

  // Fondos - del HTML
  static const Color backgroundLight = Color(0xFFF6F8FA);
  static const Color backgroundDark = Color(0xFF0A0F14);

  // Dark theme
  static const Color darkBackground = Color(0xFF0A0F14);
  static const Color darkBackgroundGradient = Color(0xFF0D1419);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkOnSurface = Color(0xFFF8FAFC);
  static const Color darkOnSurfaceMedium = Color(0xFFE2E8F0);
  static const Color darkOnSurfaceSoft = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  // Glass - del HTML: glass = primary 5%, border primary 10%; glass-card = white 3%, border white 5%
  static const Color glassBackground = Color(0x0D007BFF); // rgba(0,123,255,0.05)
  static const Color glassBorder = Color(0x1A007BFF); // rgba(0,123,255,0.1)
  static const Color glassCardBackground = Color(0x08FFFFFF); // rgba(255,255,255,0.03)
  static const Color glassCardBorder = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)

  static const Color glassCardBackgroundDark = Color(0x08FFFFFF);
  static const Color glassCardBorderDark = Color(0x0DFFFFFF);

  // Light theme
  static const Color lightBackground = Color(0xFFF6F8FA);
  static const Color lightBackgroundGradient = Color(0xFFF1F5F9);
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightOnSurfaceMedium = Color(0xFF64748B);
  static const Color lightOnSurfaceSoft = Color(0xFF94A3B8);

  static const Color glassLight = Color(0xFFFFFFFF);
  static const Color glassDark = Color(0xFF6B7C96);

  // Trend (mantener consistencia con expense/success)
  static const Color trendUp = Color(0xFFF87171);
  static const Color trendDown = Color(0xFF4ADE80);

  // Progress - barra tipo HTML: fondo slate-800, fill primary
  static const Color progressBackground = Color(0xFF1E293B);
  static const Color progressBackgroundLight = Color(0xFFE2E8F0);
  static const Color progressBar = Color(0xFF007BFF);

  // Status (para getBudgetStatusColor en DashboardProvider)
  static const Color statusGood = Color(0xFF4ADE80);
  static const Color statusWarning = Color(0xFFFBBF24);
  static const Color statusDanger = Color(0xFFF87171);
}
