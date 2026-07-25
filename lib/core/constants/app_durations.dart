/// Duration tokens for RiderOS.
///
/// Animations are functional only — no decorative motion.
/// Transitions are fast and purposeful.
abstract final class AppDurations {
  /// 100ms — Instant feedback (button press, toggle).
  static const instant = Duration(milliseconds: 100);

  /// 200ms — Fast transition (panel swap, value change).
  static const fast = Duration(milliseconds: 200);

  /// 300ms — Standard transition (screen change).
  static const standard = Duration(milliseconds: 300);

  /// 1000ms — Telemetry update interval (GPS refresh).
  static const telemetryInterval = Duration(seconds: 1);

  /// 60000ms — Theme check interval (time-based switching).
  static const themeCheckInterval = Duration(minutes: 1);
}
