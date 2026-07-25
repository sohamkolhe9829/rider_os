import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_os/core/constants/app_colors.dart';
import 'package:rider_os/core/constants/app_spacing.dart';
import 'package:rider_os/core/constants/app_typography.dart';
import 'package:rider_os/core/responsive/responsive_engine.dart';
import 'package:rider_os/core/services/service_providers.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  bool _isLoading = false;

  Future<void> _initializeServices() async {
    setState(() {
      _isLoading = true;
    });

    final permissionService = ref.read(permissionServiceProvider);
    await permissionService.requestRidePermissions();

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final screen = ScreenInfo.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'WELCOME TO RIDER OS',
              style: AppTypography.metricLarge.copyWith(
                color: colors.primary,
                fontSize: screen.scaleText(48),
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: screen.scale(AppSpacing.md)),
            Text(
              'Your motorcycle must be fully initialized before riding.',
              style: AppTypography.label.copyWith(color: colors.secondary),
            ),
            SizedBox(height: screen.scale(AppSpacing.xxl)),
            GestureDetector(
              onTap: _isLoading ? null : _initializeServices,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screen.scale(AppSpacing.xxl),
                  vertical: screen.scale(AppSpacing.lg),
                ),
                decoration: BoxDecoration(
                  color: _isLoading
                      ? colors.surface
                      : AppColors.warning, // Yellow button
                  borderRadius: BorderRadius.circular(screen.scale(8)),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: screen.scale(24),
                        height: screen.scale(24),
                        child: const CircularProgressIndicator(
                          color: AppColors.warning,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'INITIALIZE SYSTEMS',
                        style: AppTypography.label.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: screen.scaleText(16),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
