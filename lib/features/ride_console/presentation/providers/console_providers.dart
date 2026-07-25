import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rider_os/core/services/service_providers.dart';
import 'package:rider_os/features/ride_console/data/ride_console_repository.dart';
import 'package:rider_os/features/ride_console/domain/ride_metrics.dart';

import 'package:rider_os/features/fuel/presentation/providers/fuel_providers.dart';

import 'package:rider_os/features/ride_session/presentation/providers/session_providers.dart';
import 'package:rider_os/features/ride_session/domain/ride_state.dart';

/// Provides the [RideConsoleRepository] singleton.
///
/// Depends on [locationServiceProvider] and [compassServiceProvider]
/// to aggregate their streams into unified [RideMetrics].
final rideConsoleRepositoryProvider = Provider<RideConsoleRepository>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final compassService = ref.watch(compassServiceProvider);
  final fuelStorage = ref.watch(fuelStorageProvider);

  final repository = RideConsoleRepository(
    locationService: locationService,
    compassService: compassService,
    fuelStorage: fuelStorage,
  );

  // Listen to the current RideState to toggle recording.
  ref.listen<AsyncValue<RideState>>(rideStateProvider, (previous, next) {
    final state = next.valueOrNull ?? RideState.inactive;
    repository.setRecordingState(state == RideState.recording);
  });

  ref.onDispose(repository.dispose);
  return repository;
});

/// Stream of live [RideMetrics] for the Ride Console UI.
///
/// Widgets should [ref.watch] this provider to reactively rebuild
/// when new metrics arrive.
final rideMetricsStreamProvider = StreamProvider<RideMetrics>((ref) {
  final repository = ref.watch(rideConsoleRepositoryProvider);
  return repository.metricsStream;
});

/// Current [RideMetrics] snapshot (non-stream).
///
/// Returns the most recent metrics, or [RideMetrics.zero] if
/// no data has been received yet.
final currentRideMetricsProvider = Provider<RideMetrics>((ref) {
  final asyncMetrics = ref.watch(rideMetricsStreamProvider);
  return asyncMetrics.valueOrNull ?? RideMetrics.zero;
});
