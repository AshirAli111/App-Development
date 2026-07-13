import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Typography following Apple's Human Interface Guidelines type scale.
///
/// Apple's system font (SF Pro) can't be bundled on non-Apple platforms, so we
/// use Inter — a neutral, highly legible sans that closely matches SF's metrics
/// and keeps the same look across every screen.
class AppTypography {
  // Kept names (used directly by some screens), mapped to the HIG scale.
  static final h1 = GoogleFonts.inter(
    fontSize: 28, // Title 1
    fontWeight: FontWeight.w700,
    letterSpacing: 0.36,
    color: AppColors.textDark,
  );

  static final h2 = GoogleFonts.inter(
    fontSize: 22, // Title 2
    fontWeight: FontWeight.w700,
    letterSpacing: 0.35,
    color: AppColors.textDark,
  );

  static final h3 = GoogleFonts.inter(
    fontSize: 20, // Title 3
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
    color: AppColors.textDark,
  );

  static final body16 = GoogleFonts.inter(
    fontSize: 16, // Callout
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    color: AppColors.textMedium,
  );

  static final body14 = GoogleFonts.inter(
    fontSize: 15, // Subheadline
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    color: AppColors.textMedium,
  );

  static final body12 = GoogleFonts.inter(
    fontSize: 13, // Footnote
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  /// Builds a full Material [TextTheme] on the HIG scale for the given label
  /// colours, so all Flutter widgets that read the theme stay consistent.
  static TextTheme textTheme({
    required Color label,
    required Color secondary,
    required Color tertiary,
  }) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      // Large Title
      displayLarge: GoogleFonts.inter(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.37,
          color: label),
      // Title 1
      headlineLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.36,
          color: label),
      // Title 2
      headlineMedium: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.35,
          color: label),
      // Title 3
      titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.38,
          color: label),
      // Headline
      titleMedium: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
          color: label),
      // Subheadline (emphasised)
      titleSmall: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.24,
          color: label),
      // Body
      bodyLarge: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
          color: label),
      // Callout
      bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.32,
          color: secondary),
      // Footnote
      bodySmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.08,
          color: tertiary),
      // Button label
      labelLarge: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
          color: label),
      // Caption
      labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: tertiary),
    );
  }
}
