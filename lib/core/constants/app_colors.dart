import 'dart:ui';

/// RiderOS color system.
///
/// The UI is strictly monochrome — pure black/white with grey secondary.
/// Color is reserved exclusively for status indication:
/// - Green  → Active / Connected / Good
/// - Orange → Warning
/// - Red    → Emergency / Critical
///
/// Reference: Master Prompt 1, Section "COLOR PHILOSOPHY"
abstract final class AppColors {
  // ──────────────────────────────────────────────
  // Night Mode (18:00 – 05:59)
  // ──────────────────────────────────────────────

  /// Pure black background — OLED optimized.
  static const nightBackground = Color(0xFF000000);

  /// Near-black surface for panels, cards, containers.
  static const nightSurface = Color(0xFF0D0D0D);

  /// White primary text.
  static const nightPrimary = Color(0xFFFFFFFF);

  /// Grey secondary text — labels, units, descriptions.
  static const nightSecondary = Color(0xFF9E9E9E);

  /// Subtle divider / border.
  static const nightDivider = Color(0xFF1C1C1C);

  // ──────────────────────────────────────────────
  // Day Mode (06:00 – 17:59)
  // ──────────────────────────────────────────────

  /// Pure white background.
  static const dayBackground = Color(0xFFFFFFFF);

  /// Very light grey surface.
  static const daySurface = Color(0xFFF5F5F5);

  /// Black primary text.
  static const dayPrimary = Color(0xFF000000);

  /// Grey secondary text.
  static const daySecondary = Color(0xFF757575);

  /// Light divider / border.
  static const dayDivider = Color(0xFFE0E0E0);

  // ──────────────────────────────────────────────
  // Status Colors (Mode-independent)
  // ──────────────────────────────────────────────

  /// Active / Connected / Good.
  static const active = Color(0xFF4CAF50);

  /// Warning / Caution.
  static const warning = Color(0xFFFF9800);

  /// Emergency / Critical / Error.
  static const emergency = Color(0xFFF44336);
}
