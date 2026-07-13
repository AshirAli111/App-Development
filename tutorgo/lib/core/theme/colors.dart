import 'package:flutter/material.dart';

/// App colour palette aligned with Apple's Human Interface Guidelines system
/// colours, so every screen shares the same iOS-style look.
///
/// The flat constants are the light-appearance values (used directly by some
/// screens). Dark-appearance equivalents live in [AppColorsDark] and are wired
/// through the dark [ThemeData].
class AppColors {
  // Primary brand colour — iOS systemBlue.
  static const primary = Color(0xFF007AFF);
  static const primaryDark = Color(0xFF0A84FF); // systemBlue (dark appearance)

  // Labels (text) — HIG label greys (opaque equivalents).
  static const textDark = Color(0xFF1C1C1E); // label
  static const textMedium = Color(0xFF48484A); // secondaryLabel
  static const textLight = Color(0xFF8E8E93); // tertiaryLabel / systemGray

  // Separators & grouped backgrounds.
  static const border = Color(0xFFD1D1D6); // separator
  static const background = Color(0xFFF2F2F7); // systemGroupedBackground
  static const surface = Color(0xFFFFFFFF); // secondarySystemGroupedBackground

  // Status colours — iOS system colours.
  static const success = Color(0xFF34C759); // systemGreen
  static const warning = Color(0xFFFF9500); // systemOrange
  static const error = Color(0xFFFF3B30); // systemRed

  // Accent — iOS systemIndigo (used for secondary highlights).
  static const accent = Color(0xFF5856D6);
}

/// Dark-appearance system colours (HIG).
class AppColorsDark {
  static const primary = Color(0xFF0A84FF); // systemBlue (dark)
  static const background = Color(0xFF000000); // systemGroupedBackground (dark)
  static const surface = Color(0xFF1C1C1E); // secondarySystemGroupedBackground
  static const elevatedSurface = Color(0xFF2C2C2E); // tertiary

  static const textDark = Color(0xFFFFFFFF); // label (dark)
  static const textMedium = Color(0xFFEBEBF5); // secondaryLabel (dark)
  static const textLight = Color(0xFF8E8E93); // systemGray

  static const border = Color(0xFF38383A); // separator (dark)

  static const success = Color(0xFF30D158);
  static const warning = Color(0xFFFF9F0A);
  static const error = Color(0xFFFF453A);
  static const accent = Color(0xFF5E5CE6);
}
