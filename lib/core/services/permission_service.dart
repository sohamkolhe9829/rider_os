import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Centralized permission management for RiderOS.
///
/// Handles requesting and checking all permissions required by
/// the application in a single place. Prevents scattered permission
/// logic across feature modules.
class PermissionService {
  /// Check and request all permissions required for ride tracking.
  ///
  /// Returns a [PermissionReport] indicating which permissions
  /// were granted and which were denied.
  Future<PermissionReport> requestRidePermissions() async {
    final results = <PermissionType, bool>{};

    // Location (required for GPS speed, position, altitude).
    results[PermissionType.location] = await _requestPermission(
      Permission.locationWhenInUse,
    );

    // Location Always (required for background tracking / foreground service).
    if (results[PermissionType.location] == true) {
      results[PermissionType.locationAlways] = await _requestPermission(
        Permission.locationAlways,
      );
    }

    // Activity Recognition (optional — improves auto-pause detection).
    results[PermissionType.activityRecognition] = await _requestPermission(
      Permission.activityRecognition,
    );

    // Notifications (required on Android 13+ for Foreground Services).
    results[PermissionType.notification] = await _requestPermission(
      Permission.notification,
    );

    return PermissionReport(results);
  }

  /// Check if location permission is currently granted.
  Future<bool> isLocationGranted() async {
    return await Permission.locationWhenInUse.isGranted;
  }

  /// Check if background location permission is currently granted.
  Future<bool> isLocationAlwaysGranted() async {
    return await Permission.locationAlways.isGranted;
  }

  /// Check if the device GPS is enabled.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open the app settings page (for users who permanently denied
  /// a permission).
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Request a single permission and return whether it was granted.
  Future<bool> _requestPermission(Permission permission) async {
    try {
      final status = await permission.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('PermissionService: Failed to request $permission: $e');
      return false;
    }
  }
}

/// The type of permission being tracked.
enum PermissionType {
  location,
  locationAlways,
  activityRecognition,
  notification,
}

/// Report of permission request results.
@immutable
class PermissionReport {
  const PermissionReport(this.results);

  final Map<PermissionType, bool> results;

  /// Whether location (when in use) was granted.
  bool get hasLocation => results[PermissionType.location] ?? false;

  /// Whether background location was granted.
  bool get hasLocationAlways => results[PermissionType.locationAlways] ?? false;

  /// Whether activity recognition was granted.
  bool get hasActivityRecognition =>
      results[PermissionType.activityRecognition] ?? false;

  /// Whether notification permission was granted.
  bool get hasNotification => results[PermissionType.notification] ?? false;

  /// Whether all critical permissions (location, notifications) are granted.
  bool get hasCriticalPermissions => hasLocation && hasNotification;

  /// Whether all permissions are granted.
  bool get hasAllPermissions =>
      hasLocation &&
      hasLocationAlways &&
      hasActivityRecognition &&
      hasNotification;
}
