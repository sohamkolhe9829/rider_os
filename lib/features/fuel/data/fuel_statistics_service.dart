import 'package:rider_os/core/services/calculations/gps_fuel_calculator.dart';
import 'package:rider_os/features/fuel/data/fuel_storage.dart';
import 'package:rider_os/features/fuel/domain/fuel_log.dart';
import 'package:rider_os/features/fuel/domain/fuel_stats.dart';

/// Service that coordinates fuel calculations and manages statistics.
class FuelStatisticsService {
  FuelStatisticsService(this._storage);

  final FuelStorage _storage;

  /// We assume a default tank capacity of 15L if not set in settings yet.
  static const double defaultTankCapacityLiters = 15.0;

  /// Calculate and persist the latest fuel statistics based on all logs.
  Future<FuelStats> calculateAndSaveStats(
    List<FuelLog> logs, {
    double tankCapacity = 15.0,
    double fallbackMileageKmpl = 35.0,
  }) async {
    if (logs.isEmpty) {
      await _storage.setAverageMileage(0.0);
      return const FuelStats(
        averageMileageKmpl: 0.0,
        costPerKm: 0.0,
        monthlyCost: 0.0,
        lifetimeCost: 0.0,
        estimatedRangeKm: 0.0,
      );
    }

    // Sort logs chronologically (oldest first) to calculate moving average
    final sortedLogs = List<FuelLog>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));

    double lifetimeCost = 0;
    double currentMonthCost = 0;
    final now = DateTime.now();

    // We start with 0 average mileage. The WMA formula will just use the first valid recentMileage as the starting point.
    double runningAverageMileage = 0.0;
    int completedFullTanks = 0;

    // To properly calculate mileage in a GPS-distance-ridden system, we just look at each log.
    for (final log in sortedLogs) {
      lifetimeCost += log.totalCost;

      if (log.date.year == now.year && log.date.month == now.month) {
        currentMonthCost += log.totalCost;
      }

      // We only update the average mileage if it was a Full Tank and not a baseline.
      if (!log.isBaseline &&
          log.isFullTank &&
          log.computedMileageKmpl != null) {
        completedFullTanks++;
        runningAverageMileage = GpsFuelCalculator.calculateWmaMileage(
          recentMileage: log.computedMileageKmpl!,
          previousAverage: runningAverageMileage,
        );
      }
    }

    // MileageWmaService Bootstrapping:
    // Until we have at least 2 computed full tanks, use the fallback.
    final effectiveAverageMileage =
        (completedFullTanks < 2 || runningAverageMileage == 0.0)
        ? fallbackMileageKmpl
        : runningAverageMileage;

    // Cost per km calculation
    final eligibleForCost = sortedLogs.where((l) => !l.isBaseline);
    final costForDistance = eligibleForCost.fold(
      0.0,
      (sum, l) => sum + l.totalCost,
    );
    final totalDistanceRidden = eligibleForCost.fold(
      0.0,
      (sum, l) => sum + l.distanceRiddenKm,
    );

    final double costPerKm = (totalDistanceRidden > 0 && costForDistance > 0)
        ? (costForDistance / totalDistanceRidden)
        : 0.0;

    // Calculate live range using unlogged distance
    final unloggedDistance = await _storage.getUnloggedGpsDistance();
    final currentFuelLiters = await _storage.getCurrentFuelLiters();

    // Note: Live range is constantly updated by RideConsoleRepository as well,
    // but this gives the baseline when looking at the fuel screen.
    final estimatedRange = GpsFuelCalculator.calculateLiveRange(
      tankCapacity: tankCapacity,
      currentFuelLiters: currentFuelLiters,
      totalDistanceSinceFill: unloggedDistance,
      averageMileage: effectiveAverageMileage,
    );

    // Persist the calculated average mileage so it can be used globally quickly
    await _storage.setAverageMileage(effectiveAverageMileage);

    return FuelStats(
      averageMileageKmpl: effectiveAverageMileage,
      costPerKm: costPerKm,
      monthlyCost: currentMonthCost,
      lifetimeCost: lifetimeCost,
      estimatedRangeKm: estimatedRange,
    );
  }
}
