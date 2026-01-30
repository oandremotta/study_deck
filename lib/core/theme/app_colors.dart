import 'package:flutter/material.dart';

/// Application color palette.
abstract final class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2563EB);
  static const Color accent = Color(0xFF22C55E);

  // Background colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);

  // Text colors
  static const Color textMain = Color(0xFF0F172A);
  static const Color textSoft = Color(0xFF64748B);

  // Additional colors for dark theme
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textMainDark = Color(0xFFF8FAFC);
  static const Color textSoftDark = Color(0xFF94A3B8);

  // Semantic colors
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}
