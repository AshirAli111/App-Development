import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

/// App theme built on Apple's Human Interface Guidelines: system colours, the
/// HIG type scale, inset grouped surfaces, hairline separators and filled,
/// rounded controls. Everything is driven from here so every screen that reads
/// `Theme.of(context)` shares one consistent iOS-style look.
class AppTheme {
  // HIG uses continuous ~10-14pt corner radii.
  static const double _radius = 12;
  static const double _fieldRadius = 10;

  static ThemeData lightTheme = _build(
    brightness: Brightness.light,
    primary: AppColors.primary,
    scaffold: AppColors.background,
    surface: AppColors.surface,
    label: AppColors.textDark,
    secondaryLabel: AppColors.textMedium,
    tertiaryLabel: AppColors.textLight,
    separator: AppColors.border,
    error: AppColors.error,
    fieldFill: const Color(0xFFEFEFF4), // tertiarySystemGroupedBackground
  );

  static ThemeData darkTheme = _build(
    brightness: Brightness.dark,
    primary: AppColorsDark.primary,
    scaffold: AppColorsDark.background,
    surface: AppColorsDark.surface,
    label: AppColorsDark.textDark,
    secondaryLabel: AppColorsDark.textMedium,
    tertiaryLabel: AppColorsDark.textLight,
    separator: AppColorsDark.border,
    error: AppColorsDark.error,
    fieldFill: AppColorsDark.elevatedSurface,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color scaffold,
    required Color surface,
    required Color label,
    required Color secondaryLabel,
    required Color tertiaryLabel,
    required Color separator,
    required Color error,
    required Color fieldFill,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: isDark ? AppColorsDark.accent : AppColors.accent,
      onSecondary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: label,
    );

    final textTheme = AppTypography.textTheme(
      label: label,
      secondary: secondaryLabel,
      tertiary: tertiaryLabel,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: colorScheme,
      canvasColor: surface,
      cardColor: surface,
      dividerColor: separator,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
      splashFactory: InkRipple.splashFactory,
      textTheme: textTheme,

      // Navigation bar — HIG: centred title, flat, hairline underline.
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: label,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium,
        iconTheme: IconThemeData(color: primary),
      ),

      // Inset grouped cards.
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(color: separator, width: 0.5),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: separator,
        thickness: 0.5,
        space: 0.5,
      ),

      // Filled, rounded text fields.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: textTheme.bodyLarge?.copyWith(color: tertiaryLabel),
        labelStyle: textTheme.bodyMedium?.copyWith(color: secondaryLabel),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide(color: error, width: 1),
        ),
      ),

      // Primary filled button — full-width, 50pt tall, rounded.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.bodyLarge?.copyWith(color: primary),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(color: separator),
          textStyle: textTheme.labelLarge?.copyWith(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),

      listTileTheme: ListTileThemeData(
        tileColor: surface,
        iconColor: primary,
        textColor: label,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodySmall,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? (isDark ? AppColorsDark.success : AppColors.success)
              : (isDark ? const Color(0xFF39393D) : const Color(0xFFE9E9EA)),
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: fieldFill,
        selectedColor: primary.withValues(alpha: 0.15),
        checkmarkColor: primary,
        labelStyle: textTheme.bodySmall?.copyWith(color: label),
        side: BorderSide(color: separator, width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColorsDark.elevatedSurface : surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColorsDark.elevatedSurface : label,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? label : surface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: tertiaryLabel,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      iconTheme: IconThemeData(color: secondaryLabel),
    );
  }
}
