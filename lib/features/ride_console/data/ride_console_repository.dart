// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rider_os/core/services/compass_service.dart';
import 'package:rider_os/core/services/location_service.dart';
import 'package:rider_os/core/services/calculations/trip_calculator.dart';
import 'package:rider_os/core/services/calculations/speed_calculator.dart';
import 'package:rider_os/core/services/calculations/altitude_calculator.dart';
import 'package:rider_os/core/services/calculations/compass_calculator.dart';
import 'package:rider_os/features/ride_console/domain/ride_metrics.dart';
import 'package:rider_os/features/fuel/data/fuel_storage.dart';

/// Aggregates GPS and compass data into a unified [RideMetrics] stream.
///
/// Responsibilities:
/// - Combines location + compass into a single metrics model.
/// - Calculates trip distance.
/// - Tracks max speed and average speed.
/// - Counts ride time.
///
/// This repository does NOT persist data — persistence is the
/// concern of the Ride Session module.
class RideConsoleRepository {
  RideConsoleRepository({
    required LocationService locationService,
    required CompassService compassService,
    required FuelStorage fuelStorage,
  }) : _locationService = locationService,
       _compassService = compassService,
       _fuelStorage = fuelStorage {
    start();
  }

  final LocationService _locationService;
  final CompassService _compassService;
  final FuelStorage _fuelStorage;

  final _metricsController = StreamController<RideMetrics>.broadcast();

  /// Stream of aggregated ride metrics.
  Stream<RideMetrics> get metricsStream => _metricsController.stream;

  RideMetrics _current = RideMetrics.zero;
  RideMetrics get currentMetrics => _current;

  LocationData? _previousLocation;
  double _totalDistanceKm = 0.0;

  // RAM buffer for unlogged distance to reduce Hive disk I/O
  double _sessionDistanceKm = 0.0;
  Timer? _flushTimer;

  int _rideTimeSeconds = 0;
  double? _emaSpeedKmh; // Exponential Moving Average for speed

  final SpeedCalculator _speedCalculator = SpeedCalculator();
  final AltitudeCalculator _altitudeCalculator = AltitudeCalculator();

  Timer? _rideTimer;
  StreamSubscription<LocationData>? _locationSub;
  StreamSubscription<CompassData>? _compassSub;

  CompassData _lastCompass = CompassData.zero;

  bool _isActive = false;
  bool get isActive => _isActive;

  bool _isRecording = false;

  /// Update the recording state from the external RideSession.
  void setRecordingState(bool isRecording) {
    _isRecording = isRecording;
  }

  /// Start aggregating metrics from location and compass streams.
  void start() {
    if (_isActive) return;
    _isActive = true;

    // Listen to compass updates.
    _compassSub = _compassService.headingStream.listen((compass) {
      _lastCompass = compass;
    });

    // Listen to GPS updates and recompute metrics.
    _locationSub = _locationService.positionStream.listen(_onLocation);

    // Ride timer — ticks every second.
    _rideTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRecording) {
        _rideTimeSeconds++;
      }

      // If we haven't received a location update in 3 seconds, assume stationary or signal lost
      if (_previousLocation != null && _previousLocation!.timestamp != null) {
        final age = DateTime.now().difference(_previousLocation!.timestamp!);
        if (age.inSeconds > 3 && _current.speedKmh > 0) {
          _emaSpeedKmh = 0.0;
          _emitMetrics(
            speedKmh: 0.0,
            isGpsActive: false, // Mark GPS as inactive/stale
          );
          return;
        }
      }

      _emitMetrics(isGpsActive: _current.isGpsActive);
    });

    // Ensure location service is tracking.
    debugPrint(
      'RideConsoleRepository: Starting location and compass tracking...',
    );
    _locationService.startTracking();
    _compassService.startTracking();

    // Start RAM buffer flush timer
    _flushTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _flushDistanceToDisk(),
    );
  }

  /// Stop aggregating metrics.
  void stop() {
    _isActive = false;
    _rideTimer?.cancel();
    _rideTimer = null;
    _flushTimer?.cancel();
    _flushTimer = null;
    _flushDistanceToDisk();
    _locationSub?.cancel();
    _locationSub = null;
    _compassSub?.cancel();
    _compassSub = null;
  }

  /// Reset all accumulated values.
  void reset() {
    _previousLocation = null;
    _totalDistanceKm = 0.0;
    _sessionDistanceKm = 0.0;
    _rideTimeSeconds = 0;
    _emaSpeedKmh = null;
    _speedCalculator.reset();
    _altitudeCalculator.reset();
    _current = RideMetrics.zero;
  }

  void _onLocation(LocationData location) {
    debugPrint(
      'RideConsoleRepository: Received LocationUpdate -> Speed: ${location.speedKmh} km/h, Altitude: ${location.altitude} m, isRecording: $_isRecording',
    );

    if (_previousLocation != null && location.isAccurate && _isRecording) {
      final distance = TripCalculator.filterAndCalculateDistance(
        _previousLocation!,
        location,
      );

      if (distance != null && distance > 0.0) {
        _totalDistanceKm += distance;

        // Add to RAM buffer instead of writing directly to disk
        _sessionDistanceKm += distance;
      }
    }

    // Update stats via calculators

    // Filter ghost speeds when accuracy is low (e.g., indoors or IMU tilt noise)
    double rawSpeed = location.speedKmh;
    if (!location.isAccurate && rawSpeed < 10.0) {
      rawSpeed = 0.0;
    }

    // Apply Exponential Moving Average (EMA) filter to speed for smoothness
    if (_emaSpeedKmh == null) {
      _emaSpeedKmh = rawSpeed;
    } else {
      // Very fast EMA to prevent lag while providing minimal smoothing
      const double alpha = 0.95;
      _emaSpeedKmh = (alpha * rawSpeed) + ((1.0 - alpha) * _emaSpeedKmh!);

      // Stationary deadband: If raw speed is below 3.5 km/h, snap to 0 immediately
      // to avoid ghost speeds from GPS drift or sensor fusion anomalies.
      if (rawSpeed < 3.5 && _emaSpeedKmh! < 5.0) {
        _emaSpeedKmh = 0.0;
      }
    }

    if (_isRecording) {
      _speedCalculator.addSample(_emaSpeedKmh!);
    }
    _altitudeCalculator.addSample(
      location.altitude,
      accuracy: location.altitudeAccuracy,
    );

    _previousLocation = location;

    _emitMetrics(
      speedKmh: _emaSpeedKmh!,
      altitude: _altitudeCalculator.currentAltitude > 0
          ? _altitudeCalculator.currentAltitude
          : location.altitude,
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy,
      isGpsActive: true,
    );

    debugPrint(
      'RideConsoleRepository: Emitted Metrics -> Speed: $_emaSpeedKmh, Altitude: ${location.altitude}',
    );
  }

  void _emitMetrics({
    double? speedKmh,
    double? altitude,
    double? latitude,
    double? longitude,
    double? accuracy,
    required bool isGpsActive,
  }) {
    _current = RideMetrics(
      speedKmh: speedKmh ?? _current.speedKmh,
      maxSpeedKmh: _speedCalculator.maxSpeed,
      avgSpeedKmh: _speedCalculator.averageSpeed,
      tripDistanceKm: _totalDistanceKm,
      rideTimeSeconds: _rideTimeSeconds,
      altitude: altitude ?? _altitudeCalculator.currentAltitude,
      highestAltitude: _altitudeCalculator.highestAltitude,
      lowestAltitude: _altitudeCalculator.lowestAltitude,
      elevationGain: _altitudeCalculator.elevationGain,
      elevationLoss: _altitudeCalculator.elevationLoss,
      compassHeading: _lastCompass.heading,
      compassDirection: CompassCalculator.getDirection(_lastCompass.heading),
      latitude: latitude ?? _current.latitude,
      longitude: longitude ?? _current.longitude,
      accuracy: accuracy ?? _current.accuracy,
      isGpsActive: isGpsActive,
    );

    _metricsController.add(_current);
  }

  /// Clean up resources.
  void dispose() {
    stop();
    _metricsController.close();
  }

  void _flushDistanceToDisk() {
    if (_sessionDistanceKm == 0.0) return;
    _fuelStorage.addUnloggedGpsDistance(_sessionDistanceKm);
    _fuelStorage.addDistanceSinceFullTank(_sessionDistanceKm);
    _sessionDistanceKm = 0.0;
  }
}
