import 'dart:async';
import 'dart:math';

import 'package:rider_os/core/services/location_service.dart';
import 'package:rider_os/core/services/calculations/altitude_calculator.dart';
import 'package:rider_os/features/ride_session/domain/ride_session.dart';
import 'package:rider_os/features/ride_session/domain/ride_state.dart';

/// The core engine responsible for recording a ride session.
///
/// Listens to the [LocationService] when active, calculates
/// real-time statistics (distance, duration, max/avg speed),
/// and supports pause/resume functionality.
class RideRecorder {
  RideRecorder(this._locationService);

  final LocationService _locationService;

  final _stateController = StreamController<RideState>.broadcast();
  final _durationController = StreamController<int>.broadcast();

  StreamSubscription<LocationData>? _locationSub;
  Timer? _rideTimer;

  // State
  RideState _currentState = RideState.inactive;
  DateTime? _startTime;
  int _durationSeconds = 0;

  // Accumulators
  LocationData? _previousLocation;
  double _totalDistanceKm = 0.0;
  double _maxSpeedKmh = 0.0;
  double _speedSum = 0.0;
  int _speedSamples = 0;
  double _startAltitude = 0.0;
  double _endAltitude = 0.0;
  final AltitudeCalculator _altitudeCalculator = AltitudeCalculator();

  /// Stream of the current recording state.
  Stream<RideState> get stateStream => _stateController.stream;

  /// Stream of the current recording duration in seconds.
  Stream<int> get durationStream => _durationController.stream;

  /// Current recording state.
  RideState get currentState => _currentState;

  /// Start a new ride session.
  void start() {
    if (_currentState != RideState.inactive) return;

    _startTime = DateTime.now();
    _totalDistanceKm = 0.0;
    _durationSeconds = 0;
    _maxSpeedKmh = 0.0;
    _speedSum = 0.0;
    _speedSamples = 0;
    _previousLocation = null;
    _altitudeCalculator.reset();

    // Attempt to grab current altitude as start altitude.
    _startAltitude = _locationService.lastLocation?.altitude ?? 0.0;

    _setState(RideState.recording);
    _startRecordingProcesses();
  }

  /// Pause the current ride session.
  void pause() {
    if (_currentState != RideState.recording) return;

    _setState(RideState.paused);
    _stopRecordingProcesses();
  }

  /// Resume a paused ride session.
  void resume() {
    if (_currentState != RideState.paused) return;

    _setState(RideState.recording);
    _startRecordingProcesses();
  }

  /// End the ride session and generate the summary.
  ///
  /// Returns a [RideSession] object representing the completed ride,
  /// or null if the ride was never started.
  RideSession? end() {
    if (_currentState == RideState.inactive || _startTime == null) return null;

    _stopRecordingProcesses();
    _setState(RideState.inactive);

    final avgSpeed = _speedSamples > 0 ? _speedSum / _speedSamples : 0.0;

    final session = RideSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
      startTime: _startTime!,
      endTime: DateTime.now(),
      distanceKm: _totalDistanceKm,
      durationSeconds: _durationSeconds,
      avgSpeedKmh: avgSpeed,
      maxSpeedKmh: _maxSpeedKmh,
      startAltitude: _startAltitude,
      endAltitude: _endAltitude,
      highestAltitude: _altitudeCalculator.highestAltitude,
      lowestAltitude: _altitudeCalculator.lowestAltitude,
      elevationGain: _altitudeCalculator.elevationGain,
      elevationLoss: _altitudeCalculator.elevationLoss,
    );

    return session;
  }

  void _startRecordingProcesses() {
    _locationService.startTracking();
    _locationSub = _locationService.positionStream.listen(_onLocation);

    _rideTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _durationSeconds++;
      _durationController.add(_durationSeconds);
    });
  }

  void _stopRecordingProcesses() {
    _locationSub?.cancel();
    _locationSub = null;
    _rideTimer?.cancel();
    _rideTimer = null;
  }

  void _setState(RideState state) {
    _currentState = state;
    _stateController.add(state);
  }

  void _onLocation(LocationData location) {
    if (_currentState != RideState.recording) return;

    // Haversine distance
    if (_previousLocation != null && location.isAccurate) {
      final distance = _haversineKm(
        _previousLocation!.latitude,
        _previousLocation!.longitude,
        location.latitude,
        location.longitude,
      );

      // Filter GPS jumps (> 1km per tick is unrealistic on a bike)
      if (distance < 1.0) {
        _totalDistanceKm += distance;
      }
    }

    // Speed tracking
    final speed = location.speedKmh;
    if (speed > _maxSpeedKmh) {
      _maxSpeedKmh = speed;
    }
    _speedSum += speed;
    _speedSamples++;

    _altitudeCalculator.addSample(
      location.altitude,
      accuracy: location.altitudeAccuracy,
    );
    _endAltitude = _altitudeCalculator.currentAltitude;
    _previousLocation = location;
  }

  static double _haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) *
            cos(lat2 * pi / 180.0) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  void dispose() {
    _stopRecordingProcesses();
    _stateController.close();
    _durationController.close();
  }
}
