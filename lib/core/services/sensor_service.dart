import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Wrapper around [SensorsPlus] providing accelerometer and
/// gyroscope data streams.
///
/// Used for:
/// - Crash detection (sudden deceleration in Safety module)
/// - Lean angle estimation (future)
/// - Vibration analysis (future)
class SensorService {
  StreamSubscription<UserAccelerometerEvent>? _accelSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;

  final _accelController = StreamController<AccelerometerData>.broadcast();
  final _gyroController = StreamController<GyroscopeData>.broadcast();

  /// Stream of accelerometer readings.
  Stream<AccelerometerData> get accelerometerStream => _accelController.stream;

  /// Stream of gyroscope readings.
  Stream<GyroscopeData> get gyroscopeStream => _gyroController.stream;

  /// Most recent accelerometer data.
  AccelerometerData? _lastAccel;
  AccelerometerData? get lastAccelerometer => _lastAccel;

  /// Most recent gyroscope data.
  GyroscopeData? _lastGyro;
  GyroscopeData? get lastGyroscope => _lastGyro;

  /// Whether sensor streams are currently active.
  bool get isTracking => _accelSubscription != null;

  /// Start listening to accelerometer and gyroscope sensors.
  ///
  /// [samplingPeriod] controls the sensor polling rate.
  /// Use [SensorInterval.normalInterval] for battery efficiency
  /// or [SensorInterval.gameInterval] for crash detection accuracy.
  void startTracking({
    Duration samplingPeriod = SensorInterval.normalInterval,
  }) {
    if (isTracking) return;

    _accelSubscription =
        userAccelerometerEventStream(samplingPeriod: samplingPeriod).listen(
          _onAccelerometer,
          onError: (e) => debugPrint('SensorService: Accelerometer error: $e'),
        );

    _gyroSubscription = gyroscopeEventStream(samplingPeriod: samplingPeriod)
        .listen(
          _onGyroscope,
          onError: (e) => debugPrint('SensorService: Gyroscope error: $e'),
        );
  }

  /// Stop listening to sensors.
  void stopTracking() {
    _accelSubscription?.cancel();
    _accelSubscription = null;
    _gyroSubscription?.cancel();
    _gyroSubscription = null;
  }

  void _onAccelerometer(UserAccelerometerEvent event) {
    final data = AccelerometerData(
      x: event.x,
      y: event.y,
      z: event.z,
      timestamp: event.timestamp,
    );
    _lastAccel = data;
    _accelController.add(data);
  }

  void _onGyroscope(GyroscopeEvent event) {
    final data = GyroscopeData(
      x: event.x,
      y: event.y,
      z: event.z,
      timestamp: event.timestamp,
    );
    _lastGyro = data;
    _gyroController.add(data);
  }

  /// Clean up resources.
  void dispose() {
    stopTracking();
    _accelController.close();
    _gyroController.close();
  }
}

/// Processed accelerometer reading.
///
/// Uses the user accelerometer (gravity removed) for accurate
/// impact detection.
@immutable
class AccelerometerData {
  const AccelerometerData({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  /// Acceleration along X axis (m/s²).
  final double x;

  /// Acceleration along Y axis (m/s²).
  final double y;

  /// Acceleration along Z axis (m/s²).
  final double z;

  /// Timestamp of the reading.
  final DateTime timestamp;

  /// Total magnitude of acceleration (m/s²).
  /// Useful for crash detection — a sudden spike indicates impact.
  double get magnitude {
    return (x * x + y * y + z * z).abs();
  }

  /// Magnitude in G-force (1G ≈ 9.81 m/s²).
  double get magnitudeG => magnitude / 9.81;
}

/// Processed gyroscope reading.
@immutable
class GyroscopeData {
  const GyroscopeData({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  /// Rate of rotation around X axis (rad/s).
  final double x;

  /// Rate of rotation around Y axis (rad/s).
  final double y;

  /// Rate of rotation around Z axis (rad/s).
  final double z;

  /// Timestamp of the reading.
  final DateTime timestamp;
}
