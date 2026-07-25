import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rider_os/features/safety/data/safety_service.dart';

import 'package:rider_os/features/ride_session/presentation/providers/session_providers.dart';

import 'package:rider_os/core/services/service_providers.dart';

/// Provides the active SafetyService instance.
final safetyServiceProvider = Provider<SafetyService>((ref) {
  final rideRepo = ref.watch(rideRepositoryProvider);
  final locationService = ref.watch(locationServiceProvider);
  final service = SafetyService(
    rideRepository: rideRepo,
    locationService: locationService,
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Stream of the current safety state.
final safetyStateProvider = StreamProvider<SafetyState>((ref) {
  final service = ref.watch(safetyServiceProvider);
  return service.stateStream;
});
