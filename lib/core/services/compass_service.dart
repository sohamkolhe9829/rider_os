import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';

/// Wrapper around [FlutterCompass] providing a clean stream of
/// compass heading data.
///
/// Provides the device's magnetic heading (0–360°) for the
/// Ride Console compass widget.
class CompassService {
  StreamSubscription<CompassEvent>? _subscription;
  final _headingController = StreamController<CompassData>.broadcast();

  /// Stream of compass heading data.
  Stream<CompassData> get headingStream => _headingController.stream;

  /// Most recent compass data.
  CompassData? _lastHeading;
  CompassData? get lastHeading => _lastHeading;

  /// Whether the compass stream is currently active.
  bool get isTracking => _subscription != null;

  /// Start listening for compass heading updates.
  void startTracking() {
    if (isTracking) return;

    _subscription = FlutterCompass.events?.listen(
      _onCompassEvent,
      onError: (e) => debugPrint('CompassService: Stream error: $e'),
    );
  }

  /// Stop listening for compass heading updates.
  void stopTracking() {
    _subscription?.cancel();
    _subscription = null;
  }

  double? _smoothedHeading;
  static const double _alpha =
      0.2; // Smoothing factor (lower = smoother but more lag)

  void _onCompassEvent(CompassEvent event) {
    final heading = event.heading;
    if (heading == null) return;

    if (_smoothedHeading == null) {
      _smoothedHeading = heading;
    } else {
      // Calculate shortest angular distance
      double diff = (heading - _smoothedHeading! + 540) % 360 - 180;
      _smoothedHeading = (_smoothedHeading! + _alpha * diff) % 360;
      if (_smoothedHeading! < 0) _smoothedHeading = _smoothedHeading! + 360;
    }

    final data = CompassData(
      heading: _smoothedHeading!,
      accuracy: event.accuracy ?? 0.0,
      direction: _headingToDirection(_smoothedHeading!),
    );
    _lastHeading = data;
    _headingController.add(data);
  }

  /// Converts a heading in degrees to a cardinal direction string.
  static String _headingToDirection(double heading) {
    // Normalize to 0–360.
    final normalized = heading % 360;

    if (normalized >= 337.5 || normalized < 22.5) return 'N';
    if (normalized < 67.5) return 'NE';
    if (normalized < 112.5) return 'E';
    if (normalized < 157.5) return 'SE';
    if (normalized < 202.5) return 'S';
    if (normalized < 247.5) return 'SW';
    if (normalized < 292.5) return 'W';
    return 'NW';
  }

  /// Clean up resources.
  void dispose() {
    stopTracking();
    _headingController.close();
  }
}

/// Processed compass data point.
@immutable
class CompassData {
  const CompassData({
    required this.heading,
    required this.accuracy,
    required this.direction,
  });

  /// Magnetic heading in degrees (0–360).
  /// 0 = North, 90 = East, 180 = South, 270 = West.
  final double heading;

  /// Accuracy of the heading reading.
  final double accuracy;

  /// Cardinal direction string (N, NE, E, SE, S, SW, W, NW).
  final String direction;

  /// Static zero-value for initial state.
  static const zero = CompassData(heading: 0.0, accuracy: 0.0, direction: 'N');
}
