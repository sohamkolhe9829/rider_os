/// Spacing tokens for consistent layout across all RiderOS screens.
///
/// All spacing is defined in logical pixels and scales
/// proportionally through the responsive engine.
abstract final class AppSpacing {
  /// 4.0 — Micro spacing (icon-to-text, tight grouping).
  static const double xs = 4.0;

  /// 8.0 — Small spacing (between related elements).
  static const double sm = 8.0;

  /// 12.0 — Compact spacing (form elements, list items).
  static const double compact = 12.0;

  /// 16.0 — Standard spacing (section padding, card content).
  static const double md = 16.0;

  /// 24.0 — Large spacing (between sections).
  static const double lg = 24.0;

  /// 32.0 — Extra large spacing (major layout gaps).
  static const double xl = 32.0;

  /// 48.0 — Screen-level spacing (edge padding on large displays).
  static const double xxl = 48.0;

  /// 1.0 — Standard border width.
  static const double borderWidth = 1.0;

  /// 4.0 — Standard border radius for HMI panels.
  static const double borderRadius = 4.0;

  /// 8.0 — Larger border radius for containers.
  static const double borderRadiusLg = 8.0;
}
