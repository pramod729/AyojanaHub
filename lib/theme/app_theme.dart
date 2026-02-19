import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData darkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.gradientStart,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.gradientStart,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
        ),
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textLight,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border, width: 0.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: BorderSide(color: AppColors.gold, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        hintStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gold, width: 2),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textLight),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.black,
      ),
      dividerColor: AppColors.border,
    );
  }
}

class AppDimensions {
  // spacing tokens
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;

  // legacy names (mapped)
  static const double paddingXS = s8;
  static const double paddingS = s8;
  static const double paddingM = s16;
  static const double paddingL = s24;
  static const double paddingXL = 32;
  static const double paddingXXL = 48;

  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 24;

  static const double iconS = 20;
  static const double iconM = 24;
  static const double iconL = 32;
}

