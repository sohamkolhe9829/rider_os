import 'package:flutter/foundation.dart';

/// Represents a single fuel logging event at the gas station.
@immutable
class FuelLog {
  const FuelLog({
    required this.id,
    required this.date,
    required this.volumeAddedLiters,
    required this.pricePerLiter,
    required this.totalCost,
    required this.distanceRiddenKm,
    required this.isFullTank,
    required this.isBaseline,
    this.computedMileageKmpl,
  });

  final String id;
  final DateTime date;
  final double volumeAddedLiters;
  final double pricePerLiter;
  final double totalCost;
  final double distanceRiddenKm;

  /// Whether the tank was filled completely. Crucial for accurate mileage calculation.
  final bool isFullTank;

  /// True only for the very first log ever, which anchors the counters.
  final bool isBaseline;

  /// The computed WMA mileage at the time this log was created, if computable.
  /// Null if this is a partial fill or the baseline log.
  final double? computedMileageKmpl;
}
