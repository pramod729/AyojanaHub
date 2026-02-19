import 'package:flutter/material.dart';

class AppColors {
  // Background gradient
  static const Color gradientStart = Color(0xFF0B1220); // dark navy
  static const Color gradientEnd = Color(0xFF111C34); // deep navy

  // Accents
  static const Color gold = Color(0xFFD4AF37);
  static const Color softYellow = Color(0xFFF5C542);

  // Surfaces
  static const Color card = Color(0xFF16213E);
  static const Color border = Color(0xFF1F2A44);

  // Text
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8C1D1);

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
