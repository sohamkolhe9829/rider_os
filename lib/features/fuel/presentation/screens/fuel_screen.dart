import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_os/core/constants/app_spacing.dart';
import 'package:rider_os/core/constants/app_typography.dart';
import 'package:rider_os/core/responsive/responsive_engine.dart';
import 'package:rider_os/core/widgets/numeric_keypad_dialog.dart';
import 'package:rider_os/features/fuel/presentation/providers/fuel_providers.dart';
import 'package:rider_os/features/ride_console/presentation/widgets/metric_box.dart';
import 'package:rider_os/features/settings/presentation/providers/settings_providers.dart';

/// Screen for managing fuel statistics and logs.
class FuelScreen extends ConsumerWidget {
  const FuelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ScreenInfo.of(context);
    final statsAsync = ref.watch(fuelStatsProvider);
    final logsAsync = ref.watch(fuelLogsProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('FUEL MANAGER', style: AppTypography.label),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colors.primary),
            onPressed: () => _showAddLogDialog(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screen.scale(AppSpacing.md)),
          child: Row(
            children: [
              // Left Panel: Stats
              Expanded(
                flex: 2,
                child: statsAsync.when(
                  data: (stats) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MetricCell(
                        label: 'EST. RANGE',
                        value: stats.estimatedRangeKm.toStringAsFixed(0),
                        unit: 'km',
                        alignment: CrossAxisAlignment.start,
                      ),
                      SizedBox(height: screen.scale(AppSpacing.xl)),
                      MetricCell(
                        label: 'AVG MILEAGE',
                        value: stats.averageMileageKmpl.toStringAsFixed(1),
                        unit: 'km/l',
                        alignment: CrossAxisAlignment.start,
                      ),
                      SizedBox(height: screen.scale(AppSpacing.xl)),
                      MetricCell(
                        label: 'COST / KM',
                        value: stats.costPerKm.toStringAsFixed(2),
                        unit: '₹',
                        alignment: CrossAxisAlignment.start,
                      ),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) =>
                      const Center(child: Text('Error loading stats')),
                ),
              ),

              const MetricDivider(),

              // Right Panel: Logs History
              Expanded(
                flex: 3,
                child: logsAsync.when(
                  data: (logs) {
                    if (logs.isEmpty) {
                      return Center(
                        child: Text(
                          'NO FUEL LOGS',
                          style: AppTypography.label.copyWith(
                            color: colors.secondary,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return ListTile(
                          title: Text(
                            '${log.volumeAddedLiters.toStringAsFixed(1)}L @ ₹${log.pricePerLiter.toStringAsFixed(2)}/L',
                            style: AppTypography.metricSmall.copyWith(
                              fontSize: screen.scaleText(20),
                            ),
                          ),
                          subtitle: Text(
                            'Dist: ${log.distanceRiddenKm.toStringAsFixed(0)}km | Cost: ₹${log.totalCost.toStringAsFixed(2)}',
                            style: AppTypography.label.copyWith(
                              color: colors.secondary,
                            ),
                          ),
                          trailing: log.isFullTank
                              ? Icon(
                                  Icons.local_gas_station,
                                  color: colors.primary,
                                )
                              : const SizedBox.shrink(),
                          onLongPress: () {
                            ref.read(fuelRepositoryProvider).deleteLog(log.id);
                            ref.invalidate(fuelLogsProvider);
                            ref.read(fuelServiceProvider).refreshStats();
                          },
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) =>
                      const Center(child: Text('Error loading logs')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddLogDialog(BuildContext context, WidgetRef ref) async {
    String volume = '';
    String price = '';
    String cost = '';
    bool isFullTank = false;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final colors = Theme.of(context).colorScheme;
            final screen = ScreenInfo.of(context);

            // Auto calculate the missing field if 2 are filled
            void autoCalculate() {
              final v = double.tryParse(volume);
              final p = double.tryParse(price);
              final c = double.tryParse(cost);

              if (v != null && p != null && cost.isEmpty) {
                setState(() => cost = (v * p).toStringAsFixed(2));
              } else if (c != null && p != null && p > 0 && volume.isEmpty) {
                setState(() => volume = (c / p).toStringAsFixed(2));
              } else if (c != null && v != null && v > 0 && price.isEmpty) {
                setState(() => price = (c / v).toStringAsFixed(2));
              }
            }

            return AlertDialog(
              backgroundColor: colors.surface,
              title: Text(
                'ADD FUEL LOG',
                style: AppTypography.label.copyWith(color: colors.onSurface),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildKeypadField(
                      context,
                      label: 'Fuel Filled (Liters)',
                      value: volume,
                      onTap: () async {
                        final res = await NumericKeypadDialog.show(
                          context,
                          title: 'Volume',
                          initialValue: volume,
                        );
                        if (res != null) {
                          setState(() => volume = res);
                          autoCalculate();
                        }
                      },
                    ),
                    SizedBox(height: screen.scale(AppSpacing.md)),
                    _buildKeypadField(
                      context,
                      label: 'Fuel Price (per Liter)',
                      value: price,
                      onTap: () async {
                        final res = await NumericKeypadDialog.show(
                          context,
                          title: 'Price (₹)',
                          initialValue: price,
                        );
                        if (res != null) {
                          setState(() => price = res);
                          autoCalculate();
                        }
                      },
                    ),
                    SizedBox(height: screen.scale(AppSpacing.md)),
                    _buildKeypadField(
                      context,
                      label: 'Total Cost (₹)',
                      value: cost,
                      onTap: () async {
                        final res = await NumericKeypadDialog.show(
                          context,
                          title: 'Total Cost',
                          initialValue: cost,
                        );
                        if (res != null) {
                          setState(() => cost = res);
                          autoCalculate();
                        }
                      },
                    ),
                    SizedBox(height: screen.scale(AppSpacing.md)),
                    CheckboxListTile(
                      title: Text(
                        'Full Tank?',
                        style: AppTypography.label.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                      value: isFullTank,
                      onChanged: (val) {
                        setState(() => isFullTank = val ?? false);
                      },
                      activeColor: colors.primary,
                      checkColor: colors.onPrimary,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'CANCEL',
                    style: AppTypography.label.copyWith(
                      color: colors.secondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    // Try to auto-calculate one last time before saving
                    autoCalculate();

                    final vol = double.tryParse(volume) ?? 0;
                    final p = double.tryParse(price) ?? 0;
                    final c = double.tryParse(cost) ?? (vol * p);

                    if (vol > 0 && p > 0 && c > 0) {
                      await ref
                          .read(fuelRepositoryProvider)
                          .addFuelRecord(
                            volumeAddedLiters: vol,
                            pricePerLiter: p,
                            isFullTank: isFullTank,
                            tankCapacity: ref.read(tankCapacityProvider),
                          );

                      ref.invalidate(fuelLogsProvider);
                      ref
                          .read(fuelServiceProvider)
                          .refreshStats(
                            tankCapacity: ref.read(tankCapacityProvider),
                            expectedMileage: ref.read(expectedMileageProvider),
                          );

                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'SAVE',
                    style: AppTypography.label.copyWith(color: colors.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildKeypadField(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    final screen = ScreenInfo.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: screen.scale(AppSpacing.md),
          vertical: screen.scale(AppSpacing.md),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outline),
          borderRadius: BorderRadius.circular(screen.scale(8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: colors.secondary),
            ),
            SizedBox(height: screen.scale(AppSpacing.xs)),
            Text(
              value.isEmpty ? '0.0' : value,
              style: AppTypography.label.copyWith(
                fontSize: screen.scaleText(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
