import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rider_os/app/router.dart';
import 'package:rider_os/core/theme/theme_provider.dart';

/// Root application widget for RiderOS.
///
/// Consumes the theme provider and configures the MaterialApp
/// with GoRouter. Landscape only. No debug banner.
///
/// Listens to app lifecycle events to refresh the theme when
/// the app resumes from background (handles the case where the
/// Day↔Night boundary was crossed while backgrounded).
class RiderOsApp extends ConsumerStatefulWidget {
  const RiderOsApp({super.key});

  @override
  ConsumerState<RiderOsApp> createState() => _RiderOsAppState();
}

class _RiderOsAppState extends ConsumerState<RiderOsApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh theme in case Day↔Night boundary crossed while backgrounded.
      ref.read(themeNotifierProvider.notifier).refresh();

      // Re-enforce immersive mode (Android may restore system UI on resume).
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);

    return MaterialApp.router(
      title: 'RiderOS',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: appRouter,
      builder: (context, child) {
        // Globally clamp the OS text scaler to prevent RenderFlex overflows
        // RiderOS has its own text scaling via ResponsiveEngine, but we must
        // also clamp the system setting which can go up to 2.0+ on Android/iOS.
        final mediaQuery = MediaQuery.of(context);
        final currentScaler = mediaQuery.textScaler;
        // TextScaler doesn't have a direct clamp, so we calculate the scale at 14 fontSize
        // and clamp it.
        final scale = currentScaler.scale(14) / 14;
        final clampedScale = scale.clamp(0.8, 1.1);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(clampedScale),
          ),
          child: child!,
        );
      },
    );
  }
}

/// Fallback entry point in case the IDE targets this file directly instead of main.dart.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: RiderOsApp()));
}
