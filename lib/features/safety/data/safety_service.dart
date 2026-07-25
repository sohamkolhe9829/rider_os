import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:rider_os/features/ride_session/data/ride_repository.dart';
import 'package:rider_os/core/services/location_service.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:torch_light/torch_light.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// The state of the Safety system.
enum SafetyState { monitoring, crashDetected, sosActive }

class SafetyService {
  SafetyService({
    required this.rideRepository,
    required this.locationService,
    Stream<AccelerometerEvent>? accelerometerStream,
    Stream<GyroscopeEvent>? gyroscopeStream,
    this.isTestMode = false,
  }) : _accelerometerStream = accelerometerStream ?? accelerometerEventStream(),
       _gyroscopeStream = gyroscopeStream ?? gyroscopeEventStream() {
    _startMonitoring();
    if (!isTestMode) _initAudio();
  }

  final RideRepository rideRepository;
  final LocationService locationService;
  final Stream<AccelerometerEvent> _accelerometerStream;
  final Stream<GyroscopeEvent> _gyroscopeStream;
  final bool isTestMode;
  final _stateController = StreamController<SafetyState>.broadcast();
  Stream<SafetyState> get stateStream => _stateController.stream;

  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _gyroscopeSubscription;
  Timer? _countdownTimer;
  Timer? _flashTimer;
  int countdownSeconds = 30;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isTorchOn = false;

  // Thresholds for multi-sensor crash detection
  static const double crashGForceThreshold = 40.0;
  static const double crashGyroThreshold = 10.0;
  static const double minSpeedKmh = 15.0;

  DateTime? _lastGForceSpike;
  DateTime? _lastGyroSpike;

  Future<void> _initAudio() async {
    // Configure to bypass media volume if possible using AudioContext.
    // Use the alarm audio stream so the siren plays reliably and loud.
    await _audioPlayer.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          usageType: AndroidUsageType.alarm,
          contentType: AndroidContentType.sonification,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
  }

  void _startMonitoring() {
    _stateController.add(SafetyState.monitoring);

    _accelerometerSubscription = _accelerometerStream.listen((event) {
      final force = event.x.abs() + event.y.abs() + event.z.abs();
      if (force > crashGForceThreshold) {
        _lastGForceSpike = DateTime.now();
      }
      _checkCrashConditions();
    });

    _gyroscopeSubscription = _gyroscopeStream.listen((event) {
      final rotation = event.x.abs() + event.y.abs() + event.z.abs();
      if (rotation > crashGyroThreshold) {
        _lastGyroSpike = DateTime.now();
      }
      _checkCrashConditions();
    });
  }

  DateTime? _lastHighSpeedTime;

  void _checkCrashConditions() {
    final now = DateTime.now();
    final lastLocation = locationService.lastLocation;
    final speed = lastLocation?.speedKmh ?? 0.0;

    if (speed > 15.0) {
      _lastHighSpeedTime = now;
    }

    if (_lastGForceSpike != null) {
      final accelAge = now.difference(_lastGForceSpike!).inMilliseconds;
      if (accelAge > 3000) return; // Wait up to 3 seconds for speed to drop

      bool wasMovingFastRecently = false;
      if (_lastHighSpeedTime != null) {
        wasMovingFastRecently =
            now.difference(_lastHighSpeedTime!).inSeconds < 10;
      }

      bool hasSpeedDropped = wasMovingFastRecently && speed < 5.0;

      bool hasGyroSpike = false;
      if (_lastGyroSpike != null) {
        final gyroAge = now.difference(_lastGyroSpike!).inMilliseconds;
        if (gyroAge < 3000) {
          hasGyroSpike = true;
        }
      }

      // Crash = Moving fast -> speed dropped AND (GForce or Gyro spike)
      if (wasMovingFastRecently && (hasSpeedDropped || hasGyroSpike)) {
        _triggerCrashProtocol();
        _lastGForceSpike = null;
        _lastGyroSpike = null;
      }
    }
  }

  void _triggerCrashProtocol() {
    if (countdownSeconds > 0 && countdownSeconds < 30) return;
    if (_countdownTimer != null && _countdownTimer!.isActive) {
      return; // Debounce multiple sensors
    }

    countdownSeconds = 30;
    _stateController.add(SafetyState.crashDetected);

    if (!isTestMode) {
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      _audioPlayer.play(AssetSource('sounds/alarm.wav'));
    }

    // Start strobing the flashlight
    _startFlashlightStrobe();

    rideRepository.endAndSaveRide();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds > 0) {
        countdownSeconds--;
        _stateController.add(SafetyState.crashDetected);
      } else {
        timer.cancel();
        _activateSos();
      }
    });
  }

  void _startFlashlightStrobe() {
    _flashTimer?.cancel();
    _isTorchOn = false;
    _flashTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) async {
      try {
        if (_isTorchOn) {
          await TorchLight.disableTorch();
          _isTorchOn = false;
        } else {
          await TorchLight.enableTorch();
          _isTorchOn = true;
        }
      } catch (_) {
        // Torch might not be available
      }
    });
  }

  void _activateSos() {
    _stateController.add(SafetyState.sosActive);

    // Auto call 108
    launchUrlString("tel:108");
  }

  void testCrash() {
    _triggerCrashProtocol();
  }

  void cancelSos() async {
    _countdownTimer?.cancel();
    _countdownTimer = null;

    _flashTimer?.cancel();
    _flashTimer = null;

    try {
      await TorchLight.disableTorch();
    } catch (_) {}
    _isTorchOn = false;

    countdownSeconds = 30;
    _audioPlayer.stop();
    _stateController.add(SafetyState.monitoring);
  }

  void triggerManualSos() {
    _activateSos();
  }

  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _countdownTimer?.cancel();
    _flashTimer?.cancel();
    try {
      TorchLight.disableTorch();
    } catch (_) {}
    _audioPlayer.dispose();
    _stateController.close();
  }
}
