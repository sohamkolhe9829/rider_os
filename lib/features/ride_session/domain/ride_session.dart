import 'package:flutter/foundation.dart';

/// A complete summary of a recorded ride session.
///
/// This is the final object that gets persisted to the database
/// when a ride ends.
@immutable
class RideSession {
  const RideSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.distanceKm,
    required this.durationSeconds,
    required this.avgSpeedKmh,
    required this.maxSpeedKmh,
    required this.startAltitude,
    required this.endAltitude,
    required this.highestAltitude,
    required this.lowestAltitude,
    required this.elevationGain,
    required this.elevationLoss,
  });

  /// Unique identifier (typically a UUID).
  final String id;

  /// Timestamp when the ride started.
  final DateTime startTime;

  /// Timestamp when the ride ended.
  final DateTime endTime;

  /// Total distance traveled in kilometers.
  final double distanceKm;

  /// Total duration of the ride (excluding paused time) in seconds.
  final int durationSeconds;

  /// Average speed in km/h.
  final double avgSpeedKmh;

  /// Maximum speed achieved in km/h.
  final double maxSpeedKmh;

  /// Altitude at the start of the ride (meters).
  final double startAltitude;

  /// Altitude at the end of the ride (meters).
  final double endAltitude;

  /// Highest altitude reached during the ride (meters).
  final double highestAltitude;

  /// Lowest altitude reached during the ride (meters).
  final double lowestAltitude;

  /// Total elevation gained during the ride (meters).
  final double elevationGain;

  /// Total elevation lost during the ride (meters).
  final double elevationLoss;

  /// Formatted duration as HH:MM:SS
  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formatted distance as appropriate (m or km)
  String get formattedDistance {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).toInt()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}
