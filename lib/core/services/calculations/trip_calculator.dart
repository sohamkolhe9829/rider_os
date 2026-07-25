import 'dart:math';
import 'package:rider_os/core/services/location_service.dart';

class TripCalculator {
  /// Haversine formula: compute distance between two lat/lng points in km.
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) => degrees * pi / 180.0;

  static const double _maxAcceptableAccuracyMeters = 15.0;
  static const double _minSpeedKmh = 1.0;
  static const double _maxJumpKm = 1.0;

  /// Calculates distance while filtering out GPS drift and impossible jumps.
  /// Returns null if the reading is invalid or pure noise.
  /// Returns 0.0 if the device is stationary (e.g. stopped in traffic).
  static double? filterAndCalculateDistance(
    LocationData prev,
    LocationData current,
  ) {
    if (current.accuracy > _maxAcceptableAccuracyMeters) return null;
    if (prev.timestamp == null || current.timestamp == null) return null;

    final distanceKm = calculateDistanceKm(
      prev.latitude,
      prev.longitude,
      current.latitude,
      current.longitude,
    );

    final elapsedHours =
        current.timestamp!.difference(prev.timestamp!).inMilliseconds /
        3600000.0;
    if (elapsedHours <= 0) return null;

    final speedKmh = distanceKm / elapsedHours;

    if (distanceKm > _maxJumpKm) return null;
    if (speedKmh < _minSpeedKmh) return 0.0;

    return distanceKm;
  }
}
