/// Screen size categories for RiderOS responsive layout.
///
/// Categories are defined by landscape width and cover all
/// target displays from the specification:
/// - Android Auto head units
/// - 1280×720 phones
/// - 1600×720 phones
/// - 1920×1080 phones/tablets
/// - 2340×1080 phones (preferred reference)
/// - 7" / 8" TFT landscape tablets
enum ScreenCategory {
  /// < 800px width — Android Auto head units, very small displays.
  auto,

  /// 800–1279px width — Small landscape phones, compact tablets.
  compact,

  /// 1280–1599px width — Standard landscape phones (1280×720).
  standard,

  /// 1600–1919px width — Wide landscape phones (1600×720).
  expanded,

  /// ≥ 1920px width — Full HD+ (1920×1080, 2340×1080).
  large,
}

/// Breakpoint thresholds (landscape width in logical pixels).
abstract final class Breakpoints {
  /// Android Auto upper bound.
  static const double auto = 800.0;

  /// Compact upper bound.
  static const double compact = 1280.0;

  /// Standard upper bound.
  static const double standard = 1600.0;

  /// Expanded upper bound.
  static const double expanded = 1920.0;

  /// Reference design width (2340×1080 at 19.5:9).
  static const double referenceWidth = 2340.0;

  /// Reference design height.
  static const double referenceHeight = 1080.0;

  /// Resolves the [ScreenCategory] for a given [width].
  static ScreenCategory categoryFor(double width) {
    if (width < auto) return ScreenCategory.auto;
    if (width < compact) return ScreenCategory.compact;
    if (width < standard) return ScreenCategory.standard;
    if (width < expanded) return ScreenCategory.expanded;
    return ScreenCategory.large;
  }
}
