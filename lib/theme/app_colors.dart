import 'package:flutter/material.dart';

class AppColors {
  // Background gradient - Updated for improved contrast
  static const Color gradientStart = Color(0xFF0F172A); // Lighter dark navy
  static const Color gradientEnd = Color(0xFF0F172A); // Unified background

  // Accents - Improved visibility
  static const Color gold = Color(0xFF3B82F6); // Primary accent - Bright blue
  static const Color softYellow = Color(0xFFF5C542);

  // Surfaces - Lighter cards for better contrast
  static const Color card = Color(0xFF1E293B); // Lighter dark surface
  static const Color border = Color(0xFF334155); // More visible border

  // Text - Pure white for maximum contrast
  static const Color textLight = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondary = Color(0xFFE0E0E0); // Light gray for subtitles

  // Icon colors
  static const Color iconPrimary = Color(0xFF3B82F6); // Bright blue accent
  static const Color iconBackground = Color(0xFF1E3A8A); // Dark blue icon background
  static const Color iconInactive = Color(0xFF94A3B8); // Muted blue-gray

  // Header styling
  static const Color headerText = Color(0xFFF8FAFC); // Very light text for headers

  // Status
  static const Color success = Color(0xFF12B981);
  static const Color error = Color(0xFFD32F2F);

  // Additional semantic tokens (legacy names used across app)
  static const Color info = softYellow;
  static const Color warning = softYellow;
  static const Color accent = gold;
  static const Color surface = card;
  static const Color background = gradientStart;
  static const Color divider = border;

  // Misc
  static const Color transparent = Colors.transparent;

  // Legacy aliases for compatibility
  static const Color primary = gold;
  static const Color surfaceContainer = card;
  static const Color mediumGray = border;
  static const Color textPrimary = textLight;
  static const Color textTertiary = textSecondary;
}
