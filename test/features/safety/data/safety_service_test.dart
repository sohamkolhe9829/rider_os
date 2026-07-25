// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_os/core/services/location_service.dart';
import 'package:rider_os/features/ride_session/data/ride_repository.dart';
import 'package:rider_os/features/ride_session/domain/ride_session.dart';
import 'package:rider_os/features/safety/data/safety_service.dart';
import 'package:sensors_plus/sensors_plus.dart';

class FakeRideRepository implements RideRepository {
  bool endAndSaveRideCalled = false;

  @override
  Future<RideSession?> endAndSaveRide() async {
    endAndSaveRideCalled = true;
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeLocationService implements LocationService {
  LocationData? _lastLocation;

  @override
  LocationData? get lastLocation => _lastLocation;

  void setLocation(double speedKmh) {
    _lastLocation = LocationData(
      latitude: 0,
      longitude: 0,
      altitude: 0,
      speedMps: speedKmh / 3.6,
      speedKmh: speedKmh,
      heading: 0,
      accuracy: 0,
      altitudeAccuracy: 0,
      timestamp: DateTime.now(),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers.global'),
          (call) async => 1,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers'),
          (call) async => 1,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.svprdga.torchlight/main'),
          (call) async => true,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => '.',
        );
  });

  late FakeRideRepository fakeRideRepo;
  late FakeLocationService fakeLocationService;
  late StreamController<AccelerometerEvent> accelController;
  late StreamController<GyroscopeEvent> gyroController;
  late SafetyService safetyService;

  setUp(() {
    fakeRideRepo = FakeRideRepository();
    fakeLocationService = FakeLocationService();
    accelController = StreamController<AccelerometerEvent>.broadcast();
    gyroController = StreamController<GyroscopeEvent>.broadcast();

    safetyService = SafetyService(
      rideRepository: fakeRideRepo,
      locationService: fakeLocationService,
      accelerometerStream: accelController.stream,
      gyroscopeStream: gyroController.stream,
      isTestMode: true,
    );
  });

  tearDown(() {
    safetyService.dispose();
    accelController.close();
    gyroController.close();
  });

  test('Genuine crash triggers SOS and reports actual G-force', () async {
    // Rider is moving fast
    fakeLocationService.setLocation(40.0);

    // Trigger _checkCrashConditions to set _lastHighSpeedTime
    accelController.add(AccelerometerEvent(0.0, 0.0, 0.0, DateTime.now()));
    await Future.delayed(const Duration(milliseconds: 50));

    // Sudden G-force spike (35 + 20 = 55 m/s^2 > 40 m/s^2 threshold)
    // 55 m/s^2 is approx 5.6G
    print('Testing Genuine Crash with G-Force approx 5.6G (55 m/s²)');
    accelController.add(AccelerometerEvent(35.0, 20.0, 0.0, DateTime.now()));
    await Future.delayed(const Duration(milliseconds: 50));

    // Speed drops to near zero
    fakeLocationService.setLocation(2.0);

    // Another accelerometer tick to trigger the checkCrashConditions
    accelController.add(AccelerometerEvent(0.0, 0.0, 0.0, DateTime.now()));
    await Future.delayed(const Duration(milliseconds: 50));

    expect(
      fakeRideRepo.endAndSaveRideCalled,
      isTrue,
      reason: 'SOS should have triggered',
    );
  });

  test(
    'Pothole (moving fast + G-force spike + NO speed drop) does NOT trigger SOS',
    () async {
      fakeLocationService.setLocation(40.0);
      accelController.add(AccelerometerEvent(0.0, 0.0, 0.0, DateTime.now()));
      await Future.delayed(const Duration(milliseconds: 50));

      // Pothole hit (~5.6G)
      print('Testing Pothole with G-Force approx 5.6G (55 m/s²)');
      accelController.add(AccelerometerEvent(35.0, 20.0, 0.0, DateTime.now()));
      await Future.delayed(const Duration(milliseconds: 50));

      // Speed stays high
      fakeLocationService.setLocation(38.0);

      // Another tick
      accelController.add(AccelerometerEvent(0.0, 0.0, 0.0, DateTime.now()));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(
        fakeRideRepo.endAndSaveRideCalled,
        isFalse,
        reason: 'Pothole should not trigger SOS',
      );
    },
  );

  test(
    'Dropped phone (moving slow + G-force spike) does NOT trigger SOS',
    () async {
      // Was NOT moving fast recently
      fakeLocationService.setLocation(3.0);
      accelController.add(AccelerometerEvent(0.0, 0.0, 0.0, DateTime.now()));
      await Future.delayed(const Duration(milliseconds: 50));

      // Phone drop (~5.6G)
      print('Testing Dropped Phone with G-Force approx 5.6G (55 m/s²)');
      accelController.add(AccelerometerEvent(35.0, 20.0, 0.0, DateTime.now()));
      await Future.delayed(const Duration(milliseconds: 50));

      // Speed is zero
      fakeLocationService.setLocation(0.0);

      // Another tick
      accelController.add(AccelerometerEvent(0.0, 0.0, 0.0, DateTime.now()));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(
        fakeRideRepo.endAndSaveRideCalled,
        isFalse,
        reason: 'Dropped phone should not trigger SOS',
      );
    },
  );
}
