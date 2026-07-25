import 'package:flutter/foundation.dart';

/// Aggregated statistics derived from fuel logs.
@immutable
class FuelStats {
  const FuelStats({
    required this.averageMileageKmpl,
    required this.costPerKm,
    required this.monthlyCost,
    required this.lifetimeCost,
    required this.estimatedRangeKm,
  });

  /// Average fuel efficiency in kilometers per liter (km/l).
  final double averageMileageKmpl;

  /// Average cost per kilometer traveled.
  final double costPerKm;

  /// Fuel cost for the current month.
  final double monthlyCost;

  /// Total fuel cost across all logs.
  final double lifetimeCost;

  /// Estimated distance remaining based on a full tank capacity.
  final double estimatedRangeKm;
}
