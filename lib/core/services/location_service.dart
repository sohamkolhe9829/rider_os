import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Wrapper around [Geolocator] providing a clean stream-based API
/// for position, speed, and altitude data.
///
/// This service does NOT handle permissions — that responsibility
/// belongs to [PermissionService]. Callers must ensure location
/// permission is granted before starting the stream.
class LocationService {
  LocationService({this.intervalMs = 1000, this.distanceFilter = 0});

  /// GPS update interval in milliseconds.
  final int intervalMs;

  /// Minimum distance (meters) between updates. 0 = every update.
  final int distanceFilter;

  StreamSubscription<Position>? _positionSubscription;
  final _positionController = StreamController<LocationData>.broadcast();

  /// Stream of processed location data.
  Stream<LocationData> get positionStream => _positionController.stream;

  /// Most recent location data, or null if no fix yet.
  LocationData? _lastLocation;
  LocationData? get lastLocation => _lastLocation;

  /// Whether the location stream is currently active.
  bool get isTracking => _positionSubscription != null;

  /// Start listening for GPS position updates.
  ///
  /// Emits [LocationData] on every update, which includes
  /// speed, altitude, heading, and accuracy.
  void startTracking() {
    debugPrint(
      'LocationService: startTracking called. isTracking: $isTracking',
    );
    if (isTracking) return;

    // Attempt to get a fast initial fix to prevent UI from showing 0 for a long time
    Geolocator.getLastKnownPosition()
        .then((position) {
          if (position != null && _lastLocation == null) {
            debugPrint(
              'LocationService: Fast initial fix from last known position',
            );
            final data = LocationData.fromPosition(position);
            _lastLocation = data;
            _positionController.add(data);
          }
        })
        .catchError((e) {
          debugPrint('LocationService: Failed to get last known position: $e');
        });

    Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
          ),
        )
        .then((position) {
          if (_lastLocation == null ||
              (position.timestamp.isAfter(
                _lastLocation!.timestamp ?? DateTime(1970),
              ))) {
            debugPrint(
              'LocationService: Fast initial fix from low accuracy current position',
            );
            final data = LocationData.fromPosition(position);
            _lastLocation = data;
            _positionController.add(data);
          }
        })
        .catchError((_) {});

    late LocationSettings settings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        intervalDuration: const Duration(
          milliseconds: 500,
        ), // Slightly longer to smooth out spikes
        distanceFilter: 2, // Filter out micro-movements < 2m (stationary drift)
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'RiderOS',
          notificationText: 'Tracking your ride',
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.best,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 2, // Filter out micro-movements
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
      );
    } else {
      settings = const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 2,
      );
    }

    debugPrint(
      'LocationService: Requesting position stream with ForegroundNotificationConfig...',
    );
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(_onPosition, onError: _onError);
    debugPrint('LocationService: Position stream requested.');
  }

  /// Stop listening for GPS position updates.
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Get a single position fix.
  Future<LocationData?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final data = LocationData.fromPosition(position);
      _lastLocation = data;
      return data;
    } catch (e) {
      debugPrint('LocationService: getCurrentPosition failed: $e');
      return null;
    }
  }

  void _onPosition(Position position) {
    debugPrint(
      'LocationService: Received position -> Lat: ${position.latitude}, Lng: ${position.longitude}, Speed: ${position.speed} m/s, Altitude: ${position.altitude} m',
    );
    final data = LocationData.fromPosition(position);
    _lastLocation = data;
    _positionController.add(data);
  }

  void _onError(Object error) {
    debugPrint('LocationService: Position stream error: $error');
  }

  /// Clean up resources.
  void dispose() {
    stopTracking();
    _positionController.close();
  }
}

/// Processed location data point.
///
/// Wraps the raw [Position] into a clean, immutable data class
/// with pre-computed values.
@immutable
class LocationData {
  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speedMps,
    required this.speedKmh,
    required this.heading,
    required this.accuracy,
    required this.altitudeAccuracy,
    this.timestamp,
  });

  factory LocationData.fromPosition(Position position) {
    final speedMps = position.speed.clamp(0.0, double.infinity);
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      speedMps: speedMps,
      speedKmh: speedMps * 3.6, // m/s → km/h
      heading: position.heading,
      accuracy: position.accuracy,
      altitudeAccuracy: position.altitudeAccuracy,
      timestamp: position.timestamp,
    );
  }

  /// Latitude in degrees.
  final double latitude;

  /// Longitude in degrees.
  final double longitude;

  /// Altitude above sea level in meters.
  final double altitude;

  /// Speed in meters per second (raw).
  final double speedMps;

  /// Speed in km/h (pre-computed for display).
  final double speedKmh;

  /// Heading / bearing in degrees (0–360).
  final double heading;

  /// Horizontal accuracy in meters.
  final double accuracy;

  /// Vertical accuracy in meters.
  final double altitudeAccuracy;

  /// Timestamp of the fix.
  /// Timestamp of the fix, or null if no fix received.
  final DateTime? timestamp;

  /// Whether this is a reasonably accurate fix.
  bool get isAccurate => accuracy <= 20.0;

  /// Static zero-value for initial state.
  static const zero = LocationData(
    latitude: 0.0,
    longitude: 0.0,
    altitude: 0.0,
    speedMps: 0.0,
    speedKmh: 0.0,
    heading: 0.0,
    accuracy: 0.0,
    altitudeAccuracy: 0.0,
    timestamp: null,
  );
}
