import 'package:flutter/material.dart';

import 'package:rider_os/core/constants/app_colors.dart';
import 'package:rider_os/core/constants/app_typography.dart';

/// RiderOS ThemeData factory.
///
/// Produces two themes — Night and Day — that follow the OEM HMI
/// design philosophy. Monochrome. High-contrast. No decoration.
///
/// The theme system leverages Material 3 ColorScheme so all
/// standard widgets automatically inherit the correct palette.
abstract final class RiderOsTheme {
  // ──────────────────────────────────────────────
  // Night Mode (18:00 – 05:59)
  // ──────────────────────────────────────────────

  static ThemeData get night => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.nightBackground,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.nightPrimary,
      onPrimary: AppColors.nightBackground,
      secondary: AppColors.nightSecondary,
      onSecondary: AppColors.nightBackground,
      error: AppColors.emergency,
      onError: AppColors.nightPrimary,
      surface: AppColors.nightSurface,
      onSurface: AppColors.nightPrimary,
      outline: AppColors.nightDivider,
    ),
    textTheme: _buildTextTheme(
      primary: AppColors.nightPrimary,
      secondary: AppColors.nightSecondary,
    ),
    dividerColor: AppColors.nightDivider,
    dividerTheme: const DividerThemeData(
      color: AppColors.nightDivider,
      thickness: 1.0,
      space: 0.0,
    ),
    iconTheme: const IconThemeData(color: AppColors.nightPrimary),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.nightBackground,
      foregroundColor: AppColors.nightPrimary,
      elevation: 0.0,
      scrolledUnderElevation: 0.0,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.nightSurface,
      elevation: 0.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        side: BorderSide(color: AppColors.nightDivider),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.nightPrimary,
        foregroundColor: AppColors.nightBackground,
        elevation: 0.0,
        textStyle: AppTypography.action,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.nightPrimary,
        side: const BorderSide(color: AppColors.nightDivider),
        textStyle: AppTypography.action,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.nightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        borderSide: BorderSide(color: AppColors.nightDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        borderSide: BorderSide(color: AppColors.nightDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        borderSide: BorderSide(color: AppColors.nightPrimary),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.nightSurface,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColors.nightDivider),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.nightSurface,
      contentTextStyle: TextStyle(color: AppColors.nightPrimary),
      behavior: SnackBarBehavior.floating,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );

  // ──────────────────────────────────────────────
  // Day Mode (06:00 – 17:59)
  // ──────────────────────────────────────────────

  static ThemeData get day => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.dayBackground,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.dayPrimary,
      onPrimary: AppColors.dayBackground,
      secondary: AppColors.daySecondary,
      onSecondary: AppColors.dayBackground,
      error: AppColors.emergency,
      onError: AppColors.dayBackground,
      surface: AppColors.daySurface,
      onSurface: AppColors.dayPrimary,
      outline: AppColors.dayDivider,
    ),
    textTheme: _buildTextTheme(
      primary: AppColors.dayPrimary,
      secondary: AppColors.daySecondary,
    ),
    dividerColor: AppColors.dayDivider,
    dividerTheme: const DividerThemeData(
      color: AppColors.dayDivider,
      thickness: 1.0,
      space: 0.0,
    ),
    iconTheme: const IconThemeData(color: AppColors.dayPrimary),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.dayBackground,
      foregroundColor: AppColors.dayPrimary,
      elevation: 0.0,
      scrolledUnderElevation: 0.0,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.daySurface,
      elevation: 0.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        side: BorderSide(color: AppColors.dayDivider),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.dayPrimary,
        foregroundColor: AppColors.dayBackground,
        elevation: 0.0,
        textStyle: AppTypography.action,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.dayPrimary,
        side: const BorderSide(color: AppColors.dayDivider),
        textStyle: AppTypography.action,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.daySurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        borderSide: BorderSide(color: AppColors.dayDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        borderSide: BorderSide(color: AppColors.dayDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        borderSide: BorderSide(color: AppColors.dayPrimary),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.daySurface,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColors.dayDivider),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.daySurface,
      contentTextStyle: TextStyle(color: AppColors.dayPrimary),
      behavior: SnackBarBehavior.floating,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );

  // ──────────────────────────────────────────────
  // Shared Text Theme Builder
  // ──────────────────────────────────────────────

  static TextTheme _buildTextTheme({
    required Color primary,
    required Color secondary,
  }) {
    return TextTheme(
      displayLarge: AppTypography.speedDisplay.copyWith(color: primary),
      displayMedium: AppTypography.metricLarge.copyWith(color: primary),
      displaySmall: AppTypography.metricMedium.copyWith(color: primary),
      headlineLarge: AppTypography.metricMedium.copyWith(color: primary),
      headlineMedium: AppTypography.metricSmall.copyWith(color: primary),
      headlineSmall: AppTypography.title.copyWith(color: primary),
      titleLarge: AppTypography.title.copyWith(color: primary),
      titleMedium: AppTypography.action.copyWith(color: primary),
      titleSmall: AppTypography.unit.copyWith(color: primary),
      bodyLarge: AppTypography.body.copyWith(color: primary),
      bodyMedium: AppTypography.body.copyWith(color: secondary),
      bodySmall: AppTypography.bodySmall.copyWith(color: secondary),
      labelLarge: AppTypography.action.copyWith(color: primary),
      labelMedium: AppTypography.label.copyWith(color: secondary),
      labelSmall: AppTypography.label.copyWith(color: secondary),
    );
  }
}
