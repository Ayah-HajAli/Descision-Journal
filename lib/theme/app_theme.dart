import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Flat, saturated palette pulled from the reference "Academy" story cards,
/// broadened with a couple more hues so the app reads as more colorful.
/// Status colors carry meaning: yellow = pending/sealed, green = right,
/// coral = wrong, violet = partially right.
class AppColors {
  AppColors._();

  static const Color violet = Color(0xFFB6B2F2);
  static const Color violetDeep = Color(0xFF6A63D1);
  static const Color mint = Color(0xFFBDEEDC);
  static const Color pink = Color(0xFFF3C7DC);
  static const Color coral = Color(0xFFEF8FA6);
  static const Color yellow = Color(0xFFF3E463);
  static const Color forestGreen = Color(0xFF1F6E4A);
  static const Color forestGreenDeep = Color(0xFF184F36);
  static const Color skyBlue = Color(0xFFA9D8F0);
  static const Color peach = Color(0xFFF7B984);
  static const Color ink = Color(0xFF17181C);
  static const Color cream = Color(0xFFFFFDF8);
  static const Color paper = Color(0xFFF7F5EF);

  static const Color statusPending = yellow;
  static const Color statusRight = forestGreen;
  static const Color statusWrong = coral;
  static const Color statusPartial = violet;

  /// One background color per category, so the home timeline doesn't
  /// read as only-four-colors even before anything is resolved.
  static const List<Color> categoryPalette = [
    violet,
    mint,
    pink,
    skyBlue,
    peach,
  ];

  static Color onStatus(Color status) {
    if (status == forestGreen || status == violetDeep) return cream;
    return ink;
  }
}

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.fredoka(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        height: 1.05,
      ),
      displayMedium: GoogleFonts.fredoka(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        height: 1.1,
      ),
      titleLarge: GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleMedium: GoogleFonts.fredoka(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyLarge: GoogleFonts.nunitoSans(
        fontSize: 16,
        color: AppColors.ink,
        height: 1.4,
      ),
      bodyMedium: GoogleFonts.nunitoSans(
        fontSize: 14,
        color: AppColors.ink,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.nunitoSans(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        color: AppColors.ink,
      ),
      labelSmall: GoogleFonts.nunitoSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: AppColors.ink.withOpacity(0.7),
      ),
    );
  }

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      textTheme: _textTheme(base.textTheme),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.violetDeep,
        secondary: AppColors.forestGreen,
        surface: AppColors.cream,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.cream,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
