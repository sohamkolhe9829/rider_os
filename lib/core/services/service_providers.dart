import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rider_os/core/utils/stream_utils.dart';

import 'package:rider_os/core/services/compass_service.dart';
import 'package:rider_os/core/services/connectivity_service.dart';
import 'package:rider_os/core/services/location_service.dart';
import 'package:rider_os/core/services/permission_service.dart';
import 'package:rider_os/core/services/sensor_service.dart';

// ──────────────────────────────────────────────────────────
// Service Singletons
// ──────────────────────────────────────────────────────────
// Each service is provided as a singleton instance that persists
// for the application lifetime. Services are created lazily
// and disposed when the provider is disposed.

/// Provides the [PermissionService] singleton.
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

/// Provides the [LocationService] singleton.
///
/// Automatically disposes when the provider scope is destroyed.
final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  ref.onDispose(service.dispose);
  return service;
});

/// Provides the [SensorService] singleton.
final sensorServiceProvider = Provider<SensorService>((ref) {
  final service = SensorService();
  ref.onDispose(service.dispose);
  return service;
});

/// Provides the [CompassService] singleton.
final compassServiceProvider = Provider<CompassService>((ref) {
  final service = CompassService();
  ref.onDispose(service.dispose);
  return service;
});

/// Provides the [ConnectivityService] singleton.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

// ──────────────────────────────────────────────────────────
// Data Stream Providers
// ──────────────────────────────────────────────────────────
// These expose the service data streams as Riverpod StreamProviders,
// enabling widgets to watch live data reactively with automatic
// lifecycle management.

/// Stream of live GPS location data.
///
/// Returns [AsyncValue<LocationData>] enabling loading/error/data
/// states in the UI. The location service must be started before
/// this stream emits data.
final locationStreamProvider = StreamProvider<LocationData>((ref) {
  final service = ref.watch(locationServiceProvider);
  return service.positionStream.throttleTime(const Duration(milliseconds: 66));
});

/// Stream of live accelerometer data.
final accelerometerStreamProvider = StreamProvider<AccelerometerData>((ref) {
  final service = ref.watch(sensorServiceProvider);
  return service.accelerometerStream.throttleTime(
    const Duration(milliseconds: 66),
  );
});

/// Stream of live gyroscope data.
final gyroscopeStreamProvider = StreamProvider<GyroscopeData>((ref) {
  final service = ref.watch(sensorServiceProvider);
  return service.gyroscopeStream.throttleTime(const Duration(milliseconds: 66));
});

/// Stream of live compass heading data.
final compassStreamProvider = StreamProvider<CompassData>((ref) {
  final service = ref.watch(compassServiceProvider);
  return service.headingStream.throttleTime(const Duration(milliseconds: 66));
});

/// Stream of connectivity status changes.
final connectivityStreamProvider = StreamProvider<ConnectionStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

// ──────────────────────────────────────────────────────────
// Permission State
// ──────────────────────────────────────────────────────────

/// Provider for requesting and tracking ride permissions.
///
/// Returns a [Future<PermissionReport>] that resolves after the
/// user responds to the permission dialogs.
final ridePermissionsProvider = FutureProvider<PermissionReport>((ref) async {
  final service = ref.watch(permissionServiceProvider);
  return service.requestRidePermissions();
});

/// Whether location services are currently enabled on the device.
final locationServiceEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(permissionServiceProvider);
  return service.isLocationServiceEnabled();
});
