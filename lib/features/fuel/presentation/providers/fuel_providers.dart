import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rider_os/features/fuel/data/fuel_repository.dart';
import 'package:rider_os/features/fuel/data/fuel_service.dart';
import 'package:rider_os/features/fuel/data/fuel_statistics_service.dart';
import 'package:rider_os/features/fuel/data/fuel_storage.dart';
import 'package:rider_os/features/fuel/domain/fuel_log.dart';
import 'package:rider_os/features/fuel/domain/fuel_stats.dart';
import 'package:rider_os/features/settings/presentation/providers/settings_providers.dart';

// ──────────────────────────────────────────────────────────
// Repositories & Services
// ──────────────────────────────────────────────────────────

/// Provides the FuelStorage.
final fuelStorageProvider = Provider<FuelStorage>((ref) {
  return FuelStorage();
});

/// Provides the FuelStatisticsService
final fuelStatisticsServiceProvider = Provider<FuelStatisticsService>((ref) {
  final storage = ref.watch(fuelStorageProvider);
  return FuelStatisticsService(storage);
});

/// Provides the FuelRepository.
final fuelRepositoryProvider = Provider<FuelRepository>((ref) {
  final storage = ref.watch(fuelStorageProvider);
  final statsService = ref.watch(fuelStatisticsServiceProvider);
  return FuelRepository(storage, statsService);
});

/// Provides the FuelService.
final fuelServiceProvider = Provider<FuelService>((ref) {
  final repo = ref.watch(fuelRepositoryProvider);
  final service = FuelService(repo);

  // Refresh stats initially
  service.refreshStats(
    tankCapacity: ref.read(tankCapacityProvider),
    expectedMileage: ref.read(expectedMileageProvider),
  );

  // Re-fetch stats if settings change
  ref.listen<double>(tankCapacityProvider, (_, next) {
    service.refreshStats(
      tankCapacity: next,
      expectedMileage: ref.read(expectedMileageProvider),
    );
  });
  ref.listen<double>(expectedMileageProvider, (_, next) {
    service.refreshStats(
      tankCapacity: ref.read(tankCapacityProvider),
      expectedMileage: next,
    );
  });

  ref.onDispose(service.dispose);
  return service;
});

// ──────────────────────────────────────────────────────────
// State Providers
// ──────────────────────────────────────────────────────────

/// FutureProvider that fetches all fuel logs.
final fuelLogsProvider = FutureProvider<List<FuelLog>>((ref) async {
  final repo = ref.watch(fuelRepositoryProvider);
  return await repo.getLogs();
});

/// StreamProvider that listens to live FuelStats updates.
final fuelStatsProvider = StreamProvider<FuelStats>((ref) {
  final service = ref.watch(fuelServiceProvider);
  return service.statsStream;
});
