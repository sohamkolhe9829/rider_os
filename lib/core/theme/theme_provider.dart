import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rider_os/core/theme/rider_os_theme.dart';
import 'package:rider_os/features/settings/presentation/providers/settings_providers.dart';

/// Whether the current theme is Night mode.
final isNightModeProvider = Provider<bool>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  return themeState.isNight;
});

/// The active [ThemeData] for the application.
final appThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  return themeState.themeData;
});

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((
  ref,
) {
  final mode = ref.watch(themeModeProvider);
  return ThemeNotifier(mode: mode);
});

@immutable
class ThemeState {
  const ThemeState({required this.isNight, required this.themeData});

  final bool isNight;
  final ThemeData themeData;
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier({required this.mode}) : super(_resolveState(mode)) {
    if (mode == 'Auto') {
      _scheduleNextTransition();
    }
  }

  final String mode;

  Timer? _transitionTimer;

  static const int _dayStartHour = 6;
  static const int _nightStartHour = 18;

  static ThemeState _resolveState(String mode) {
    bool isNight;
    if (mode == 'Light') {
      isNight = false;
    } else if (mode == 'Auto') {
      isNight = _isNightTime(DateTime.now());
    } else {
      isNight = true; // Dark is the default
    }

    return ThemeState(
      isNight: isNight,
      themeData: isNight ? RiderOsTheme.night : RiderOsTheme.day,
    );
  }

  static bool _isNightTime(DateTime time) {
    final hour = time.hour;
    return hour >= _nightStartHour || hour < _dayStartHour;
  }

  void _scheduleNextTransition() {
    _transitionTimer?.cancel();

    final now = DateTime.now();
    final hour = now.hour;

    DateTime nextBoundary;
    if (hour >= _dayStartHour && hour < _nightStartHour) {
      nextBoundary = DateTime(now.year, now.month, now.day, _nightStartHour);
    } else if (hour >= _nightStartHour) {
      nextBoundary = DateTime(now.year, now.month, now.day + 1, _dayStartHour);
    } else {
      nextBoundary = DateTime(now.year, now.month, now.day, _dayStartHour);
    }

    final duration = nextBoundary.difference(now);

    _transitionTimer = Timer(duration, () {
      state = _resolveState('Auto');
      _scheduleNextTransition();
    });
  }

  void refresh() {
    // If not Auto mode, we just re-assert the explicit mode.
    // If Auto mode, we re-evaluate time and schedule the next transition.
    state = _resolveState(mode);
    if (mode == 'Auto') {
      _scheduleNextTransition();
    }
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    super.dispose();
  }
}
