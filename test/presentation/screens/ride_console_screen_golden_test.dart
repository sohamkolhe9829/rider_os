import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_os/core/theme/rider_os_theme.dart';
import 'package:rider_os/features/ride_console/presentation/screens/ride_console_screen.dart';
import 'package:rider_os/features/ride_console/domain/ride_metrics.dart';
import 'package:rider_os/features/ride_console/presentation/providers/console_providers.dart';
import 'package:rider_os/features/safety/presentation/providers/safety_providers.dart';
import 'package:rider_os/features/safety/data/safety_service.dart';
import 'package:rider_os/features/ride_session/domain/ride_state.dart';
import 'package:rider_os/features/ride_session/presentation/providers/session_providers.dart';
import 'package:rider_os/core/providers/system_providers.dart';
import 'package:rider_os/features/fuel/presentation/providers/fuel_providers.dart';
import 'package:rider_os/features/fuel/domain/fuel_stats.dart';
import 'package:rider_os/features/ride_session/data/ride_repository.dart';
import 'package:rider_os/features/ride_console/data/ride_console_repository.dart';
import 'package:rider_os/core/services/location_service.dart';
import 'package:rider_os/core/services/sensor_service.dart';
import 'package:rider_os/core/services/compass_service.dart';
import 'package:rider_os/core/services/service_providers.dart';

// Dummy overrides
final _dummyMetrics = RideMetrics.zero.copyWith(speedKmh: 120.0);

class MockSensorService implements SensorService {
  @override
  void dispose() {}
  @override
  Stream<AccelerometerData> get accelerometerStream => const Stream.empty();
  @override
  Stream<GyroscopeData> get gyroscopeStream => const Stream.empty();
  @override
  bool get isTracking => false;
  @override
  AccelerometerData? get lastAccelerometer => null;
  @override
  GyroscopeData? get lastGyroscope => null;
  @override
  void startTracking({Duration? samplingPeriod}) {}
  @override
  void stopTracking() {}
}

class MockLocationService implements LocationService {
  @override
  void dispose() {}
  @override
  Stream<LocationData> get positionStream => const Stream.empty();
  @override
  LocationData? get lastLocation => null;
  @override
  int get distanceFilter => 0;
  @override
  Future<LocationData?> getCurrentPosition() async => null;
  @override
  int get intervalMs => 1000;
  @override
  bool get isTracking => false;
  @override
  void startTracking() {}
  @override
  void stopTracking() {}
}

class MockCompassService implements CompassService {
  @override
  void dispose() {}
  @override
  Stream<CompassData> get headingStream => const Stream.empty();
  @override
  bool get isTracking => false;
  @override
  CompassData? get lastHeading => null;
  @override
  void startTracking() {}
  @override
  void stopTracking() {}
}

class MockRideConsoleRepository implements RideConsoleRepository {
  @override
  void start() {}
  @override
  void stop() {}
  @override
  void dispose() {}
  @override
  Stream<RideMetrics> get metricsStream => const Stream.empty();
  @override
  RideMetrics get currentMetrics => _dummyMetrics;
  @override
  bool get isActive => true;
  @override
  void reset() {}
  @override
  void setRecordingState(bool isRecording) {}
}

class MockSafetyService implements SafetyService {
  @override
  LocationService get locationService => throw UnimplementedError();
  @override
  RideRepository get rideRepository => throw UnimplementedError();
  @override
  Stream<SafetyState> get stateStream => const Stream.empty();
  @override
  void cancelSos() {}
  @override
  void dispose() {}
  // ignore: annotate_overrides
  SafetyState get currentState => SafetyState.monitoring;
  // ignore: annotate_overrides
  int countdownSeconds = 30;
  @override
  void testCrash() {}
  @override
  void triggerManualSos() {}
  // ignore: annotate_overrides
  bool get isTestMode => true;
}

void main() {
  Widget buildGoldenWidget(Size size, ThemeData theme, double textScale) {
    return ProviderScope(
      overrides: [
        currentRideMetricsProvider.overrideWith((ref) => _dummyMetrics),
        safetyStateProvider.overrideWith(
          (ref) => Stream.value(SafetyState.monitoring),
        ),
        rideStateProvider.overrideWith(
          (ref) => Stream.value(RideState.recording),
        ),
        clockProvider.overrideWith((ref) => Stream.value('14:30')),
        batteryStateProvider.overrideWith((ref) => Stream.value(85)),

        // Disable real services
        sensorServiceProvider.overrideWith((ref) => MockSensorService()),
        locationServiceProvider.overrideWith((ref) => MockLocationService()),
        compassServiceProvider.overrideWith((ref) => MockCompassService()),
        rideConsoleRepositoryProvider.overrideWith(
          (ref) => MockRideConsoleRepository(),
        ),
        safetyServiceProvider.overrideWith((ref) => MockSafetyService()),
        fuelStatsProvider.overrideWith(
          (ref) => Stream.value(
            const FuelStats(
              averageMileageKmpl: 35.0,
              costPerKm: 3.5,
              monthlyCost: 1500.0,
              lifetimeCost: 45000.0,
              estimatedRangeKm: 280.0,
            ),
          ),
        ),
      ],
      child: MaterialApp(
        theme: theme,
        debugShowCheckedModeBanner: false,
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale.clamp(0.8, 1.1)),
          ),
          child: const RideConsoleScreen(),
        ),
      ),
    );
  }

  group('RideConsoleScreen Golden Tests', () {
    final devices = {
      'samsung_s24_fe': const Size(2340, 1080),
      'realme_narzo_20a': const Size(1600, 720),
    };

    final themes = {'day': RiderOsTheme.day, 'night': RiderOsTheme.night};

    final textScales = {'100': 1.0, '130': 1.3};

    for (final device in devices.entries) {
      for (final theme in themes.entries) {
        for (final textScale in textScales.entries) {
          testWidgets(
            '${device.key}_${theme.key}_scale_${textScale.key}',
            (tester) async {
              final size = device.value;
              tester.view.physicalSize = size;
              tester.view.devicePixelRatio = 1.0;
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);

              await tester.pumpWidget(
                buildGoldenWidget(size, theme.value, textScale.value),
              );
              // pump twice to allow for animations
              await tester.pump(const Duration(milliseconds: 50));
              await tester.pump(const Duration(milliseconds: 50));

              await expectLater(
                find.byType(RideConsoleScreen),
                matchesGoldenFile(
                  'goldens/console_${device.key}_${theme.key}_scale_${textScale.key}.png',
                ),
              );
            },
            skip: !Platform.isMacOS,
          );
        }
      }
    }
  });
}
