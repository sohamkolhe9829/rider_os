import 'package:flutter/material.dart';

/// HMI-optimized typography scale for RiderOS.
///
/// Designed for maximum glanceability while riding.
/// Font sizes follow motorcycle instrument cluster principles:
/// - Critical data (speed) is the largest
/// - Supporting metrics decrease in size by importance
/// - Labels and units are small and secondary
///
/// Uses Roboto (system default) for maximum legibility,
/// consistent with real OEM motorcycle HMI systems.
abstract final class AppTypography {
  static const String _fontFamily = 'Roboto';

  // ──────────────────────────────────────────────
  // Speed Display — Largest, most prominent
  // ──────────────────────────────────────────────

  /// Speed readout — the most critical metric.
  static const speedDisplay = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 260.0, // Increased
    fontWeight: FontWeight.w700,
    letterSpacing: -4.0,
    height: 1.0,
  );

  // ──────────────────────────────────────────────
  // Metric Displays — Primary through tertiary
  // ──────────────────────────────────────────────

  /// Primary metric value (trip distance, ride time).
  static const metricLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 84.0, // Increased from 72
    fontWeight: FontWeight.w600,
    letterSpacing: -2.0,
    height: 1.1,
  );

  /// Secondary metric value (average speed, altitude).
  static const metricMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 64.0, // Increased from 48
    fontWeight: FontWeight.w500,
    letterSpacing: -1.0,
    height: 1.2,
  );

  /// Tertiary metric value (compass heading, fuel range).
  static const metricSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 48.0, // Increased from 36
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
    height: 1.2,
  );

  // ──────────────────────────────────────────────
  // Supporting Text
  // ──────────────────────────────────────────────

  /// Unit suffix (km/h, km, °C, L).
  static const unit = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24.0, // Increased from 20
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Label text (SPEED, TRIP, TIME) — uppercase by convention.
  static const label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20.0, // Increased from 16
    fontWeight: FontWeight.w500,
    letterSpacing: 2.0,
    height: 1.4,
  );

  /// Body text — descriptions, notes, lists.
  static const body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.0, // Increased from 14
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.5,
  );

  /// Body text — small variant.
  static const bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.0, // Increased from 12
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.5,
  );

  /// Action / Button text.
  static const action = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18.0, // Increased from 14
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Title text — screen headers, section titles.
  static const title = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24.0, // Increased from 20
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.3,
  );
}
