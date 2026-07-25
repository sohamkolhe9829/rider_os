import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:rider_os/app/rider_os_app.dart';

/// RiderOS application entry point.
///
/// Initialization sequence:
/// 1. Ensure Flutter bindings are ready.
/// 2. Lock orientation to landscape (both directions).
/// 3. Enable immersive sticky mode (hide system bars).
/// 4. Set system UI overlay style for status bar.
/// 5. Initialize Hive for local storage.
/// 6. Launch the app inside ProviderScope.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Orientation Lock ─────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // ── Immersive Mode ───────────────────────────
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // ── System UI Style ──────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── Local Storage ────────────────────────────
  await Hive.initFlutter();

  // ── Launch ───────────────────────────────────
  runApp(const ProviderScope(child: RiderOsApp()));
}
