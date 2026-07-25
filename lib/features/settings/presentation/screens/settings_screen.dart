import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_os/core/constants/app_spacing.dart';
import 'package:rider_os/core/constants/app_typography.dart';
import 'package:rider_os/core/responsive/responsive_engine.dart';
import 'package:rider_os/core/services/service_providers.dart';
import 'package:rider_os/core/widgets/numeric_keypad_dialog.dart';
import 'package:rider_os/features/settings/presentation/providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ScreenInfo.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('SETTINGS', style: AppTypography.label),
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
            _buildSectionHeader('GENERAL', colors, screen),
            _buildSwitchTile(
              context,
              ref,
              title: 'Auto Start Ride',
              subtitle: 'Start recording when moving > 10km/h',
              provider: autoStartRideProvider,
              storageKey: 'autoStartRide',
            ),
            _buildDropdownTile(
              context,
              ref,
              title: 'Theme Mode',
              options: ['Dark', 'Light', 'Auto'],
              provider: themeModeProvider,
              storageKey: 'themeMode',
            ),

            _buildSectionHeader('RIDE & TRIP', colors, screen),
            _buildSwitchTile(
              context,
              ref,
              title: 'Use GPS Speed',
              subtitle: 'Calculate speed using high-accuracy GPS',
              provider: useGpsSpeedProvider,
              storageKey: 'useGpsSpeed',
            ),
            _buildSwitchTile(
              context,
              ref,
              title: 'Auto Reset Trip',
              subtitle: 'Reset Trip A automatically on full tank',
              provider: autoResetTripProvider,
              storageKey: 'autoResetTrip',
            ),

            _buildSectionHeader('UNITS', colors, screen),
            _buildDropdownTile(
              context,
              ref,
              title: 'Distance Unit',
              options: ['Kilometers', 'Miles'],
              provider: distanceUnitProvider,
              storageKey: 'distanceUnit',
            ),

            _buildSectionHeader('BIKE PROFILE (FUEL)', colors, screen),
            _buildNumericDialogTile(
              context,
              ref,
              title: 'Fuel Tank Capacity (Liters)',
              subtitle: 'Total volume of your fuel tank',
              provider: tankCapacityProvider,
              storageKey: 'tankCapacity',
            ),
            _buildNumericDialogTile(
              context,
              ref,
              title: 'Expected Mileage (km/L)',
              subtitle: 'Fallback baseline mileage for cold starts',
              provider: expectedMileageProvider,
              storageKey: 'expectedMileage',
            ),

            _buildSectionHeader('GARAGE & MAINTENANCE', colors, screen),
            ListTile(
              title: Text('Service Logs & Parts', style: AppTypography.body),
              subtitle: Text(
                'Track engine oil, brake pads, chain lube',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.secondary,
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: colors.secondary),
              onTap: () {
                context.push('/maintenance');
              },
            ),

            _buildSectionHeader('EMERGENCY & SAFETY', colors, screen),
            ListTile(
              title: Text('Crash Detection', style: AppTypography.body),
              subtitle: Text(
                'Configure SOS and Medical Info',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.secondary,
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: colors.secondary),
              onTap: () {
                context.push('/safety');
              },
            ),

            SizedBox(height: screen.scale(AppSpacing.xl)),
            _buildSectionHeader('TROUBLESHOOTING', colors, screen),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screen.scale(AppSpacing.sm),
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Restart the hardware streams
                  final locationService = ref.read(locationServiceProvider);
                  final compassService = ref.read(compassServiceProvider);

                  locationService.stopTracking();
                  compassService.stopTracking();

                  await Future.delayed(const Duration(milliseconds: 500));

                  locationService.startTracking();
                  compassService.startTracking();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sensors Recalibrated!',
                          style: AppTypography.body.copyWith(
                            color: colors.onPrimary,
                          ),
                        ),
                        backgroundColor: colors.primary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('RELOAD CALIBRATION (GPS/COMPASS)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.surfaceContainerHighest,
                  foregroundColor: colors.onSurface,
                  padding: EdgeInsets.symmetric(
                    vertical: screen.scale(AppSpacing.md),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screen.scale(8)),
                  ),
                ),
              ),
            ),

            SizedBox(height: screen.scale(AppSpacing.xxl)),
            Center(
              child: Text(
                'RiderOS v1.0.0\nBuilt for India 🇮🇳',
                textAlign: TextAlign.center,
                style: AppTypography.label.copyWith(color: colors.secondary),
              ),
            ),
            SizedBox(height: screen.scale(AppSpacing.xxl)),
          ],
        ),
      ),
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

  Widget _buildSwitchTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required StateProvider<bool> provider,
    required String storageKey,
  }) {
    final value = ref.watch(provider);
    final colors = Theme.of(context).colorScheme;

    return SwitchListTile(
      title: Text(title, style: AppTypography.body),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(color: colors.secondary),
      ),
      value: value,
      activeThumbColor: colors.primary,
      onChanged: (newValue) async {
        ref.read(provider.notifier).state = newValue;
        await saveSetting(ref, storageKey, newValue);
      },
    );
  }

  Widget _buildDropdownTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required List<String> options,
    required StateProvider<String> provider,
    required String storageKey,
  }) {
    final value = ref.watch(provider);
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      title: Text(title, style: AppTypography.body),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: colors.surface,
        underline: const SizedBox(),
        style: AppTypography.body.copyWith(color: colors.primary),
        items: options.map((String option) {
          return DropdownMenuItem<String>(value: option, child: Text(option));
        }).toList(),
        onChanged: (newValue) async {
          if (newValue != null) {
            ref.read(provider.notifier).state = newValue;
            await saveSetting(ref, storageKey, newValue);
          }
        },
      ),
    );
  }

  Widget _buildNumericDialogTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required StateProvider<double> provider,
    required String storageKey,
  }) {
    final value = ref.watch(provider);
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      title: Text(title, style: AppTypography.body),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(color: colors.secondary),
      ),
      trailing: Text(
        value.toStringAsFixed(1),
        style: AppTypography.body.copyWith(color: colors.primary),
      ),
      onTap: () async {
        final res = await NumericKeypadDialog.show(
          context,
          title: title,
          initialValue: value.toString(),
        );
        if (res != null) {
          final newValue = double.tryParse(res);
          if (newValue != null && newValue > 0) {
            ref.read(provider.notifier).state = newValue;
            await saveSetting(ref, storageKey, newValue);
          }
        }
      },
    );
  }
}
