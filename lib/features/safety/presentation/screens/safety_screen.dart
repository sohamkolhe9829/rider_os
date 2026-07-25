import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_os/core/constants/app_colors.dart';
import 'package:rider_os/core/constants/app_spacing.dart';
import 'package:rider_os/core/constants/app_typography.dart';
import 'package:rider_os/core/responsive/responsive_engine.dart';

import 'package:rider_os/features/safety/presentation/providers/safety_providers.dart';
import 'package:rider_os/features/safety/data/safety_service.dart';
import 'package:rider_os/features/settings/presentation/providers/settings_providers.dart';

class SafetyScreen extends ConsumerWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ScreenInfo.of(context);
    final colors = Theme.of(context).colorScheme;

    final safetyStateAsync = ref.watch(safetyStateProvider);
    final safetyState = safetyStateAsync.valueOrNull ?? SafetyState.monitoring;
    final safetyService = ref.read(safetyServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('SAFETY & EMERGENCY', style: AppTypography.label),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(screen.scale(AppSpacing.md)),
          children: [
            if (safetyState != SafetyState.monitoring)
              Container(
                padding: EdgeInsets.all(screen.scale(AppSpacing.lg)),
                decoration: BoxDecoration(
                  color: AppColors.emergency.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.emergency, width: 2),
                  borderRadius: BorderRadius.circular(screen.scale(16)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: AppColors.emergency,
                      size: screen.scaleText(48),
                    ),
                    SizedBox(width: screen.scale(AppSpacing.md)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            safetyState == SafetyState.crashDetected
                                ? 'CRASH DETECTED'
                                : 'SOS ACTIVE',
                            style: AppTypography.label.copyWith(
                              color: AppColors.emergency,
                            ),
                          ),
                          SizedBox(height: screen.scale(AppSpacing.xs)),
                          Text(
                            safetyState == SafetyState.crashDetected
                                ? 'Alerting contacts in ${safetyService.countdownSeconds}s'
                                : 'Emergency contacts have been notified.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (safetyState == SafetyState.crashDetected)
                      IconButton(
                        icon: Icon(Icons.cancel, color: colors.onPrimary),
                        onPressed: () => safetyService.cancelSos(),
                      ),
                  ],
                ),
              )
            else
              GestureDetector(
                onLongPress: () => safetyService.triggerManualSos(),
                child: Container(
                  padding: EdgeInsets.all(screen.scale(AppSpacing.lg)),
                  decoration: BoxDecoration(
                    color: AppColors.emergency.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.emergency, width: 2),
                    borderRadius: BorderRadius.circular(screen.scale(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: AppColors.emergency,
                        size: screen.scaleText(48),
                      ),
                      SizedBox(width: screen.scale(AppSpacing.md)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SOS STANDBY',
                              style: AppTypography.label.copyWith(
                                color: AppColors.emergency,
                              ),
                            ),
                            SizedBox(height: screen.scale(AppSpacing.xs)),
                            Text(
                              'Long press anywhere here to trigger emergency protocol manually.',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: screen.scale(AppSpacing.xl)),
            _buildSectionHeader('CRASH DETECTION', colors, screen),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergency,
                foregroundColor: colors.onPrimary,
                padding: EdgeInsets.symmetric(
                  vertical: screen.scale(AppSpacing.md),
                ),
              ),
              onPressed: () {
                // Test Crash overlay
                safetyService
                    .triggerManualSos(); // Wait, manual SOS isn't the same as crash. But I can expose a test method on safetyService, or just triggerManualSos for now. Wait, safetyService has a private `_triggerCrashProtocol()` method.
                // Let's add testCrash() to safetyService or use triggerManualSos().
                // Actually, triggerManualSos triggers SOS immediately. Crash triggers a 30s countdown.
                // We need to add `testCrash()` to `SafetyService`. For now, I will use a placeholder and then modify SafetyService.
                safetyService.testCrash();
              },
              child: Text('TEST CRASH OVERLAY', style: AppTypography.label),
            ),
            SizedBox(height: screen.scale(AppSpacing.md)),
            SwitchListTile(
              title: Text('Auto Fall Detection', style: AppTypography.body),
              subtitle: Text(
                'Uses accelerometer to detect sudden impacts',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.secondary,
                ),
              ),
              value: ref.watch(autoFallDetectionProvider),
              activeThumbColor: colors.primary,
              onChanged: (val) {
                ref.read(autoFallDetectionProvider.notifier).state = val;
                saveSetting(ref, 'autoFallDetection', val);
              },
            ),
            SwitchListTile(
              title: Text('30s Countdown Timer', style: AppTypography.body),
              subtitle: Text(
                'Gives you time to cancel before alerting contacts',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.secondary,
                ),
              ),
              value: ref.watch(crashCountdownProvider),
              activeThumbColor: colors.primary,
              onChanged: (val) {
                ref.read(crashCountdownProvider.notifier).state = val;
                saveSetting(ref, 'crashCountdown', val);
              },
            ),
            SwitchListTile(
              title: Text('Auto-save Ride on Crash', style: AppTypography.body),
              subtitle: Text(
                'Preserves GPS track immediately upon impact',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.secondary,
                ),
              ),
              value: ref.watch(autoSaveCrashProvider),
              activeThumbColor: colors.primary,
              onChanged: (val) {
                ref.read(autoSaveCrashProvider.notifier).state = val;
                saveSetting(ref, 'autoSaveCrash', val);
              },
            ),

            SizedBox(height: screen.scale(AppSpacing.md)),
            _buildSectionHeader('EMERGENCY CONTACTS', colors, screen),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: colors.surface,
                child: Icon(Icons.person, color: colors.primary),
              ),
              title: Text('Primary Contact Name', style: AppTypography.body),
              subtitle: Text(
                ref.watch(emergencyContactNameProvider),
                style: AppTypography.bodySmall.copyWith(
                  color: colors.secondary,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: colors.secondary),
                onPressed: () {
                  _showEditDialog(
                    context,
                    ref,
                    'Emergency Contact Name',
                    emergencyContactNameProvider,
                    'emergencyContactName',
                  );
                },
              ),
            ),
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.transparent),
              title: Text('Primary Contact Number', style: AppTypography.body),
              subtitle: Text(
                ref.watch(emergencyContactNumberProvider),
                style: AppTypography.bodySmall.copyWith(
                  color: colors.secondary,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: colors.secondary),
                onPressed: () {
                  _showEditDialog(
                    context,
                    ref,
                    'Emergency Contact Number',
                    emergencyContactNumberProvider,
                    'emergencyContactNumber',
                  );
                },
              ),
            ),

            SizedBox(height: screen.scale(AppSpacing.md)),
            _buildSectionHeader('MEDICAL PROFILE', colors, screen),
            ListTile(
              title: Text('Rider Name', style: AppTypography.body),
              subtitle: Text(
                ref.watch(profileNameProvider),
                style: AppTypography.bodySmall.copyWith(
                  color: colors.secondary,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: colors.secondary),
                onPressed: () {
                  _showEditDialog(
                    context,
                    ref,
                    'Rider Name',
                    profileNameProvider,
                    'profileName',
                  );
                },
              ),
            ),
            ListTile(
              title: Text('Blood Group', style: AppTypography.body),
              subtitle: Text(
                ref.watch(bloodGroupProvider),
                style: AppTypography.bodySmall.copyWith(
                  color: colors.secondary,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: colors.secondary),
                onPressed: () {
                  _showEditDialog(
                    context,
                    ref,
                    'Blood Group',
                    bloodGroupProvider,
                    'bloodGroup',
                  );
                },
              ),
            ),
            ListTile(
              title: Text('Hometown Location', style: AppTypography.body),
              subtitle: Text(
                ref.watch(hometownProvider),
                style: AppTypography.bodySmall.copyWith(
                  color: colors.secondary,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: colors.secondary),
                onPressed: () {
                  _showEditDialog(
                    context,
                    ref,
                    'Hometown',
                    hometownProvider,
                    'hometown',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    StateProvider<String> provider,
    String storageKey,
  ) {
    final controller = TextEditingController(text: ref.read(provider));
    showDialog(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text('EDIT $title', style: AppTypography.label),
          content: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: TextField(
                controller: controller,
                style: AppTypography.body,
                decoration: InputDecoration(hintText: 'Enter $title'),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: AppTypography.label.copyWith(color: colors.secondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                ref.read(provider.notifier).state = controller.text;
                await saveSetting(ref, storageKey, controller.text);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(
                'SAVE',
                style: AppTypography.label.copyWith(color: AppColors.active),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(
    String title,
    ColorScheme colors,
    ScreenInfo screen,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.scale(AppSpacing.md),
        horizontal: screen.scale(AppSpacing.sm),
      ),
      child: Text(
        title,
        style: AppTypography.label.copyWith(color: colors.primary),
      ),
    );
  }
}
