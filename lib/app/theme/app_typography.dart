import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type families. UI text uses IBM Plex Sans Arabic (Arabic + Latin);
/// adhkar use Amiri; Quranic passages use Amiri Quran.
abstract final class AppFonts {
  static const ui = 'IBMPlexSansArabic';
  static const reading = 'Amiri';
  static const quran = 'AmiriQuran';
}

abstract final class AppTypography {
  /// Base reading size before the user's reading scale is applied.
  static const double readingBaseSize = 25;

  static TextTheme textTheme(AppPalette p) {
    TextStyle s(double size, FontWeight weight, double height, Color color) => TextStyle(
      fontFamily: AppFonts.ui,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
    return TextTheme(
      displaySmall: s(32, FontWeight.w600, 1.25, p.textPrimary),
      headlineMedium: s(26, FontWeight.w600, 1.3, p.textPrimary),
      headlineSmall: s(22, FontWeight.w600, 1.35, p.textPrimary),
      titleLarge: s(19, FontWeight.w600, 1.4, p.textPrimary),
      titleMedium: s(16, FontWeight.w600, 1.45, p.textPrimary),
      titleSmall: s(14, FontWeight.w600, 1.45, p.textPrimary),
      bodyLarge: s(16, FontWeight.w400, 1.6, p.textPrimary),
      bodyMedium: s(14, FontWeight.w400, 1.6, p.textSecondary),
      bodySmall: s(12.5, FontWeight.w400, 1.55, p.textMuted),
      labelLarge: s(15, FontWeight.w600, 1.3, p.textPrimary),
      labelMedium: s(13, FontWeight.w500, 1.3, p.textSecondary),
      labelSmall: s(11.5, FontWeight.w500, 1.3, p.textMuted),
    );
  }

  /// Style for adhkar text. [scale] is the user's reading preference.
  static TextStyle reading(AppPalette p, {double scale = 1, double? size}) => TextStyle(
    fontFamily: AppFonts.reading,
    fontSize: (size ?? readingBaseSize) * scale,
    height: 2.0,
    color: p.textPrimary,
  );

  static TextStyle quran(AppPalette p, {double scale = 1, double? size}) => TextStyle(
    fontFamily: AppFonts.quran,
    fontSize: (size ?? readingBaseSize) * scale,
    height: 2.15,
    color: p.quranInk,
  );
}
