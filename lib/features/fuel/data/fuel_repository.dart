import 'package:rider_os/features/fuel/data/fuel_storage.dart';
import 'package:rider_os/features/fuel/data/fuel_statistics_service.dart';
import 'package:rider_os/features/fuel/domain/fuel_log.dart';
import 'package:rider_os/features/fuel/domain/fuel_stats.dart';

/// Repository that manages fuel logs and calculates ongoing statistics.
class FuelRepository {
  FuelRepository(this._storage, this._statsService);

  final FuelStorage _storage;
  final FuelStatisticsService _statsService;

  /// Add a new fuel log, automatically handling accumulators.
  Future<void> addFuelRecord({
    required double volumeAddedLiters,
    required double pricePerLiter,
    required bool isFullTank,
    required double tankCapacity,
  }) async {
    final existingLogs = await _storage.getAllLogs();
    final isFirstLogEver = existingLogs.isEmpty;

    final unloggedDistance = await _storage.getUnloggedGpsDistance();
    final distanceSinceFullTank = await _storage.getDistanceSinceFullTank();
    final fuelSinceFullTank = await _storage.getFuelSinceFullTank();

    // Accumulate total distance and fuel since the last full tank
    final newDistanceAccumulated = distanceSinceFullTank + unloggedDistance;
    final newFuelAccumulated = fuelSinceFullTank + volumeAddedLiters;

    double? computedMileage;

    if (!isFirstLogEver && isFullTank) {
      if (newFuelAccumulated > 0) {
        computedMileage = newDistanceAccumulated / newFuelAccumulated;
      }
      // Reset accumulators only on a full tank
      await _storage.setDistanceSinceFullTank(0.0);
      await _storage.setFuelSinceFullTank(0.0);
    } else {
      // Keep accumulating on partial fill or baseline
      await _storage.setDistanceSinceFullTank(newDistanceAccumulated);
      await _storage.setFuelSinceFullTank(newFuelAccumulated);
    }

    final log = FuelLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      volumeAddedLiters: volumeAddedLiters,
      pricePerLiter: pricePerLiter,
      totalCost: volumeAddedLiters * pricePerLiter,
      distanceRiddenKm: unloggedDistance,
      isFullTank: isFullTank,
      isBaseline: isFirstLogEver,
      computedMileageKmpl: computedMileage,
    );

    await _storage.saveLog(log);

    // Update virtual fuel gauge
    final currentFuelLiters = await _storage.getCurrentFuelLiters();
    if (isFirstLogEver) {
      if (isFullTank) {
        await _storage.setCurrentFuelLiters(tankCapacity);
      } else {
        await _storage.setCurrentFuelLiters(volumeAddedLiters);
      }
    } else {
      if (isFullTank) {
        await _storage.setCurrentFuelLiters(tankCapacity);
      } else {
        final newFuel = currentFuelLiters + volumeAddedLiters;
        await _storage.setCurrentFuelLiters(newFuel.clamp(0.0, tankCapacity));
      }
    }

    // Always reset the unlogged display meter
    await _storage.setUnloggedGpsDistance(0.0);
  }

  /// Delete a log by its ID.
  Future<void> deleteLog(String id) async {
    await _storage.deleteLog(id);
  }

  /// Get all logs.
  Future<List<FuelLog>> getLogs() async {
    return await _storage.getAllLogs();
  }

  /// Calculate the current fuel statistics based on the stored logs.
  Future<FuelStats> getStats({
    double tankCapacity = 15.0,
    double expectedMileage = 35.0,
  }) async {
    final logs = await _storage.getAllLogs();
    return await _statsService.calculateAndSaveStats(
      logs,
      tankCapacity: tankCapacity,
      fallbackMileageKmpl: expectedMileage,
    );
  }
}
