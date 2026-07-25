import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_os/core/constants/app_spacing.dart';
import 'package:rider_os/core/constants/app_typography.dart';
import 'package:rider_os/core/responsive/responsive_engine.dart';
import 'package:rider_os/features/settings/presentation/providers/settings_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await initializeSettings(ref);
    // Artificial delay for splash screen aesthetic
    await Future.delayed(const Duration(milliseconds: 1500));

    // Navigate to setup screen instead of directly to console
    if (mounted) {
      context.go('/setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final screen = ScreenInfo.of(context);

    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'RIDER OS',
              style: AppTypography.metricLarge.copyWith(
                color: colors.primary,
                fontSize: screen.scaleText(64),
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: screen.scale(AppSpacing.md)),
            Text(
              'V2.0 INITIALIZING...',
              style: AppTypography.label.copyWith(color: colors.secondary),
            ),
            SizedBox(height: screen.scale(AppSpacing.xl)),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
