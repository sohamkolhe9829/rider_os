import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rider_os/features/settings/data/settings_storage.dart';

final settingsStorageProvider = Provider<SettingsStorage>((ref) {
  return SettingsStorage();
});

// Dynamic providers for specific settings.
// These will be used throughout the app to react to settings changes.

// General
final autoStartRideProvider = StateProvider<bool>((ref) => false);
final themeModeProvider = StateProvider<String>((ref) => 'Dark');

// Ride
final useGpsSpeedProvider = StateProvider<bool>((ref) => true);
final autoResetTripProvider = StateProvider<bool>((ref) => false);

// Units
final distanceUnitProvider = StateProvider<String>((ref) => 'Kilometers');

// Bike Profile (Fuel)
final tankCapacityProvider = StateProvider<double>((ref) => 15.0);
final expectedMileageProvider = StateProvider<double>((ref) => 35.0);

// Safety
final autoFallDetectionProvider = StateProvider<bool>((ref) => true);
final crashCountdownProvider = StateProvider<bool>((ref) => true);
final autoSaveCrashProvider = StateProvider<bool>((ref) => true);

// Medical & Emergency Profile
final profileNameProvider = StateProvider<String>((ref) => 'Rider');
final emergencyContactNameProvider = StateProvider<String>((ref) => 'Not Set');
final emergencyContactNumberProvider = StateProvider<String>(
  (ref) => 'Not Set',
);
final bloodGroupProvider = StateProvider<String>((ref) => 'O+');
final hometownProvider = StateProvider<String>((ref) => 'Unknown');

// Initialize settings when app starts
Future<void> initializeSettings(WidgetRef ref) async {
  final storage = ref.read(settingsStorageProvider);
  await storage.init();

  ref.read(autoStartRideProvider.notifier).state = await storage.getBool(
    'autoStartRide',
    defaultValue: false,
  );
  ref.read(themeModeProvider.notifier).state = await storage.getString(
    'themeMode',
    defaultValue: 'Dark',
  );
  ref.read(useGpsSpeedProvider.notifier).state = await storage.getBool(
    'useGpsSpeed',
    defaultValue: true,
  );
  ref.read(autoResetTripProvider.notifier).state = await storage.getBool(
    'autoResetTrip',
    defaultValue: false,
  );
  ref.read(distanceUnitProvider.notifier).state = await storage.getString(
    'distanceUnit',
    defaultValue: 'Kilometers',
  );
  ref.read(tankCapacityProvider.notifier).state = await storage.getDouble(
    'tankCapacity',
    defaultValue: 15.0,
  );
  ref.read(expectedMileageProvider.notifier).state = await storage.getDouble(
    'expectedMileage',
    defaultValue: 35.0,
  );

  ref.read(autoFallDetectionProvider.notifier).state = await storage.getBool(
    'autoFallDetection',
    defaultValue: true,
  );
  ref.read(crashCountdownProvider.notifier).state = await storage.getBool(
    'crashCountdown',
    defaultValue: true,
  );
  ref.read(autoSaveCrashProvider.notifier).state = await storage.getBool(
    'autoSaveCrash',
    defaultValue: true,
  );

  ref.read(profileNameProvider.notifier).state = await storage.getString(
    'profileName',
    defaultValue: 'Rider',
  );
  ref.read(emergencyContactNameProvider.notifier).state = await storage
      .getString('emergencyContactName', defaultValue: 'Not Set');
  ref.read(emergencyContactNumberProvider.notifier).state = await storage
      .getString('emergencyContactNumber', defaultValue: 'Not Set');
  ref.read(bloodGroupProvider.notifier).state = await storage.getString(
    'bloodGroup',
    defaultValue: 'O+',
  );
  ref.read(hometownProvider.notifier).state = await storage.getString(
    'hometown',
    defaultValue: 'Unknown',
  );
}

Future<void> saveSetting<T>(WidgetRef ref, String key, T value) async {
  final storage = ref.read(settingsStorageProvider);
  if (value is bool) {
    await storage.setBool(key, value);
  } else if (value is String) {
    await storage.setString(key, value);
  } else if (value is double) {
    await storage.setDouble(key, value);
  }
}
