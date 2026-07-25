import 'package:flutter/material.dart';

import 'package:rider_os/core/responsive/breakpoints.dart';

/// Provides screen metrics and scaling utilities.
///
/// All layout should use [ScreenInfo] for responsive values
/// instead of hardcoding dimensions. Call [ScreenInfo.of] or
/// use [ResponsiveBuilder] to access.
class ScreenInfo {
  ScreenInfo._({
    required this.screenWidth,
    required this.screenHeight,
    required this.category,
    required this.scaleFactor,
    required this.textScaleFactor,
    required this.devicePixelRatio,
  });

  /// Creates a [ScreenInfo] from the current [BuildContext].
  factory ScreenInfo.of(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;
    final category = Breakpoints.categoryFor(width);
    final scale = width / Breakpoints.referenceWidth;

    return ScreenInfo._(
      screenWidth: width,
      screenHeight: height,
      category: category,
      scaleFactor: scale.clamp(0.4, 1.2),
      textScaleFactor: scale.clamp(0.6, 1.1),
      devicePixelRatio: media.devicePixelRatio,
    );
  }

  /// Logical screen width.
  final double screenWidth;

  /// Logical screen height.
  final double screenHeight;

  /// Resolved screen category.
  final ScreenCategory category;

  /// General layout scale factor (relative to 2340px reference).
  /// Clamped to 0.4–1.2 to prevent extreme scaling.
  final double scaleFactor;

  /// Text-specific scale factor with tighter clamping
  /// to preserve readability on small screens.
  final double textScaleFactor;

  /// Device pixel ratio.
  final double devicePixelRatio;

  /// Whether this is an Android Auto display.
  bool get isAutoDisplay => category == ScreenCategory.auto;

  /// Whether the screen is compact or smaller.
  bool get isCompact =>
      category == ScreenCategory.auto || category == ScreenCategory.compact;

  /// Scale a dimension relative to the reference width.
  double scale(double value) => value * scaleFactor;

  /// Scale a font size with text-specific clamping.
  double scaleText(double value) => value * textScaleFactor;

  /// Returns [compact] for compact/auto screens, [regular] otherwise.
  T responsive<T>({required T compact, required T regular}) {
    return isCompact ? compact : regular;
  }

  /// Returns a value based on the current [ScreenCategory].
  T byCategory<T>({
    required T auto,
    required T compact,
    required T standard,
    required T expanded,
    required T large,
  }) {
    return switch (category) {
      ScreenCategory.auto => auto,
      ScreenCategory.compact => compact,
      ScreenCategory.standard => standard,
      ScreenCategory.expanded => expanded,
      ScreenCategory.large => large,
    };
  }
}

/// Widget that provides [ScreenInfo] to its builder.
///
/// Use this instead of manually calling [ScreenInfo.of] when the
/// builder needs responsive values.
///
/// ```dart
/// ResponsiveBuilder(
///   builder: (context, screen) {
///     final fontSize = screen.scaleText(48.0);
///     return Text('Speed', style: TextStyle(fontSize: fontSize));
///   },
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, ScreenInfo screen) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, ScreenInfo.of(context));
  }
}

/// Extension on [BuildContext] for quick access to [ScreenInfo].
extension ScreenInfoExtension on BuildContext {
  /// Shorthand for [ScreenInfo.of(this)].
  ScreenInfo get screen => ScreenInfo.of(this);
}
