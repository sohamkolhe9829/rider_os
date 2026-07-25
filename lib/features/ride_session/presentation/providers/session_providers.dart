import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rider_os/core/services/service_providers.dart';
import 'package:rider_os/features/fuel/presentation/providers/fuel_providers.dart';
import 'package:rider_os/features/ride_session/data/ride_recorder.dart';
import 'package:rider_os/features/ride_session/data/ride_repository.dart';
import 'package:rider_os/features/ride_session/data/ride_storage.dart';
import 'package:rider_os/features/ride_session/domain/ride_state.dart';

// ──────────────────────────────────────────────────────────
// Repositories & Services
// ──────────────────────────────────────────────────────────

/// Provides the Hive storage handler.
final rideStorageProvider = Provider<RideStorage>((ref) {
  return RideStorage();
});

/// Provides the active RideRecorder instance.
final rideRecorderProvider = Provider<RideRecorder>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final recorder = RideRecorder(locationService);
  ref.onDispose(recorder.dispose);
  return recorder;
});

/// Provides the RideRepository for coordinating recording and storage.
final rideRepositoryProvider = Provider<RideRepository>((ref) {
  final recorder = ref.watch(rideRecorderProvider);
  final storage = ref.watch(rideStorageProvider);
  final fuelStorage = ref.watch(fuelStorageProvider);
  return RideRepository(recorder, storage, fuelStorage);
});

// ──────────────────────────────────────────────────────────
// Streams
// ──────────────────────────────────────────────────────────

/// Stream of the current ride recording state (inactive/recording/paused).
final rideStateProvider = StreamProvider<RideState>((ref) {
  final recorder = ref.watch(rideRecorderProvider);
  return recorder.stateStream;
});

/// Current ride state as a synchronous value (defaults to inactive).
final currentRideStateProvider = Provider<RideState>((ref) {
  final asyncState = ref.watch(rideStateProvider);
  return asyncState.valueOrNull ?? RideState.inactive;
});

/// Stream of the active ride duration in seconds.
final rideDurationProvider = StreamProvider<int>((ref) {
  final recorder = ref.watch(rideRecorderProvider);
  return recorder.durationStream;
});

/// Current ride duration in seconds.
final currentRideDurationProvider = Provider<int>((ref) {
  final asyncDuration = ref.watch(rideDurationProvider);
  return asyncDuration.valueOrNull ?? 0;
});
