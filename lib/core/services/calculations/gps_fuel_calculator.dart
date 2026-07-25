class GpsFuelCalculator {
  /// Calculate Weighted Moving Average mileage.
  ///
  /// Applies a 60% weight to the most recent mileage and 40% to the historical average.
  /// recentMileage = trackedDistance / fuelAdded
  /// averageMileage = (recentMileage * 0.6) + (previousAverage * 0.4)
  static double calculateWmaMileage({
    required double recentMileage,
    required double previousAverage,
  }) {
    if (recentMileage <= 0) return previousAverage;

    if (previousAverage == 0.0) {
      return recentMileage;
    }

    return (recentMileage * 0.6) + (previousAverage * 0.4);
  }

  /// Calculates the live remaining range based on distance traveled since last fill up.
  static double calculateLiveRange({
    required double tankCapacity,
    required double currentFuelLiters,
    required double
    totalDistanceSinceFill, // unloggedGpsDistance + currentRideDistance
    required double averageMileage,
  }) {
    if (averageMileage <= 0 || tankCapacity <= 0) return 0.0;

    final maxPossibleRangeKm = tankCapacity * averageMileage;
    final fuelConsumed = totalDistanceSinceFill / averageMileage;
    final remainingFuel = currentFuelLiters - fuelConsumed;

    if (remainingFuel <= 0) return 0.0;

    final remainingRangeKm = remainingFuel * averageMileage;
    return remainingRangeKm.clamp(0.0, maxPossibleRangeKm);
  }

  /// Calculates the progress ratio for UI elements (e.g. range bar width)
  /// Guaranteed to return between 0.0 and 1.0
  static double calculateProgressRatio({
    required double liveRangeKm,
    required double tankCapacityLiters,
    required double averageMileageKmpl,
  }) {
    final maxRangeKm = tankCapacityLiters * averageMileageKmpl;
    if (maxRangeKm <= 0) return 0.0;
    return (liveRangeKm / maxRangeKm).clamp(0.0, 1.0);
  }
}
