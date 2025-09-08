import 'package:flutter/material.dart';

class AppColors {
  // Primary colors - basados en el diseño HTML
  static const Color primary = Color(0xFF137FEC);
  static const Color primaryHover = Color(0xFF0E6BC7);
  
  // Neutral colors - slate palette
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
  
  // Semantic colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFEF4444); // red-500
  static const Color success = Color(0xFF10B981); // green-500
  static const Color warning = Color(0xFFF59E0B); // amber-500
  
  // Focus colors
  static const Color focusBorder = Color(0xFF3B82F6);
  static const Color focusRing = Color(0x1A3B82F6);
  
  // Dark Theme Colors - Based on the image design
  static const Color darkBackground = Color(0xFF0D1B2A); // Deep navy blue from image
  static const Color darkBackgroundGradient = Color(0xFF1B263B); // Slightly lighter blue
  static const Color darkSurface = Color(0xFF1F2937); // gray-800
  static const Color darkOnSurface = Color(0xFFFFFFFF); // Pure white for text
  static const Color darkOnSurfaceMedium = Color(0xFFE2E8F0); // Light gray for secondary text
  static const Color darkOnSurfaceSoft = Color(0xFF94A3B8); // slate-400 for tertiary text
  static const Color darkBorder = Color(0xFF374151); // gray-700
  
  // Glass card colors from image
  static const Color glassCardBackground = Color(0xFF1E2A3A); // Dark blue-gray for cards
  static const Color glassCardBorder = Color(0xFF2A3441); // Slightly lighter border
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC); // slate-50
  static const Color lightBackgroundGradient = Color(0xFFF1F5F9); // slate-100
  static const Color lightOnSurface = Color(0xFF1E293B); // slate-800
  static const Color lightOnSurfaceMedium = Color(0xFF64748B); // slate-500
  static const Color lightOnSurfaceSoft = Color(0xFF94A3B8); // slate-400
  
  // Glassmorphism Colors
  static const Color glassLight = Color(0xFFFFFFFF); // white for light mode glass
  static const Color glassDark = Color.fromARGB(255, 111, 124, 150); // dark mode glass
  
  // Trend Colors
  static const Color trendUp = Color(0xFFF87171); // red-400
  static const Color trendDown = Color(0xFF4ADE80); // green-400
  
  // Progress Colors  
  static const Color progressBackground = Color(0xFF1E293B); // slate-800
  static const Color progressBackgroundLight = Color(0xFFE2E8F0); // slate-200
  static const Color progressBar = Color(0xFF3B82F6); // blue-500
  
  // Status Colors
  static const Color statusGood = Color(0xFF4ADE80); // green-400
  static const Color statusWarning = Color(0xFFFBBF24); // amber-400
  static const Color statusDanger = Color(0xFFF87171); // red-400
}
