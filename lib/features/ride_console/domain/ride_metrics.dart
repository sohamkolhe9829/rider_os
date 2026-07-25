import 'package:flutter/foundation.dart';

/// Live ride metrics aggregated from all sensor sources.
///
/// This is the primary data model consumed by the Ride Console UI.
/// Updated every GPS tick (typically 1 second) with the latest
/// telemetry values.
///
/// Information priority (per spec):
/// 1. Speed
/// 2. Trip Distance
/// 3. Ride Time
/// 4. Fuel Range
/// 5. Compass
/// 6. Altitude
/// 7. Weather (placeholder)
/// 8. Clock
/// 9. Battery
@immutable
class RideMetrics {
  const RideMetrics({
    required this.speedKmh,
    required this.maxSpeedKmh,
    required this.avgSpeedKmh,
    required this.tripDistanceKm,
    required this.rideTimeSeconds,
    required this.altitude,
    required this.highestAltitude,
    required this.lowestAltitude,
    required this.elevationGain,
    required this.elevationLoss,
    required this.compassHeading,
    required this.compassDirection,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.isGpsActive,
  });

  /// Current speed in km/h.
  final double speedKmh;

  /// Maximum speed reached during the session in km/h.
  final double maxSpeedKmh;

  /// Average speed over the session in km/h.
  final double avgSpeedKmh;

  /// Total trip distance in kilometers.
  final double tripDistanceKm;

  /// Total ride time in seconds.
  final int rideTimeSeconds;

  /// Altitude above sea level in meters.
  final double altitude;

  /// Highest altitude reached in meters.
  final double highestAltitude;

  /// Lowest altitude reached in meters.
  final double lowestAltitude;

  /// Total elevation gained in meters.
  final double elevationGain;

  /// Total elevation lost in meters.
  final double elevationLoss;

  /// Compass heading in degrees (0–360).
  final double compassHeading;

  /// Cardinal direction string (N, NE, E, etc.).
  final String compassDirection;

  /// Current latitude.
  final double latitude;

  /// Current longitude.
  final double longitude;

  /// GPS accuracy in meters.
  final double accuracy;

  /// Whether GPS is currently providing data.
  final bool isGpsActive;

  /// Ride time formatted as HH:MM:SS.
  String get rideTimeFormatted {
    final hours = rideTimeSeconds ~/ 3600;
    final minutes = (rideTimeSeconds % 3600) ~/ 60;
    final seconds = rideTimeSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Trip distance formatted with appropriate precision.
  String get tripDistanceFormatted {
    if (tripDistanceKm < 1.0) {
      // Show meters when under 1 km.
      return '${(tripDistanceKm * 1000).toInt()}';
    }
    if (tripDistanceKm < 100.0) {
      return tripDistanceKm.toStringAsFixed(1);
    }
    return tripDistanceKm.toStringAsFixed(0);
  }

  /// Trip distance unit label.
  String get tripDistanceUnit {
    return tripDistanceKm < 1.0 ? 'm' : 'km';
  }

  /// Speed as an integer for display.
  int get speedDisplay => speedKmh.round();

  /// Max speed as an integer for display.
  int get maxSpeedDisplay => maxSpeedKmh.round();

  /// Average speed as an integer for display.
  int get avgSpeedDisplay => avgSpeedKmh.round();

  /// Altitude as an integer for display.
  int get altitudeDisplay => altitude.round();

  /// Compass heading as an integer for display.
  int get headingDisplay => compassHeading.round();

  /// Initial/zero state.
  static const zero = RideMetrics(
    speedKmh: 0.0,
    maxSpeedKmh: 0.0,
    avgSpeedKmh: 0.0,
    tripDistanceKm: 0.0,
    rideTimeSeconds: 0,
    altitude: 0.0,
    highestAltitude: 0.0,
    lowestAltitude: 0.0,
    elevationGain: 0.0,
    elevationLoss: 0.0,
    compassHeading: 0.0,
    compassDirection: 'N',
    latitude: 0.0,
    longitude: 0.0,
    accuracy: 0.0,
    isGpsActive: false,
  );

  /// Create a copy with updated fields.
  RideMetrics copyWith({
    double? speedKmh,
    double? maxSpeedKmh,
    double? avgSpeedKmh,
    double? tripDistanceKm,
    int? rideTimeSeconds,
    double? altitude,
    double? highestAltitude,
    double? lowestAltitude,
    double? elevationGain,
    double? elevationLoss,
    double? compassHeading,
    String? compassDirection,
    double? latitude,
    double? longitude,
    double? accuracy,
    bool? isGpsActive,
  }) {
    return RideMetrics(
      speedKmh: speedKmh ?? this.speedKmh,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
      tripDistanceKm: tripDistanceKm ?? this.tripDistanceKm,
      rideTimeSeconds: rideTimeSeconds ?? this.rideTimeSeconds,
      altitude: altitude ?? this.altitude,
      highestAltitude: highestAltitude ?? this.highestAltitude,
      lowestAltitude: lowestAltitude ?? this.lowestAltitude,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      compassHeading: compassHeading ?? this.compassHeading,
      compassDirection: compassDirection ?? this.compassDirection,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      isGpsActive: isGpsActive ?? this.isGpsActive,
    );
  }
}
