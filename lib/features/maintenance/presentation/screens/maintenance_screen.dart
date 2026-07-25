import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_os/core/constants/app_colors.dart';
import 'package:rider_os/core/constants/app_spacing.dart';
import 'package:rider_os/core/constants/app_typography.dart';
import 'package:rider_os/core/responsive/responsive_engine.dart';
import 'package:rider_os/features/maintenance/domain/maintenance_item.dart';
import 'package:rider_os/features/maintenance/presentation/providers/maintenance_providers.dart';

class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ScreenInfo.of(context);
    final colors = Theme.of(context).colorScheme;
    final itemsAsync = ref.watch(maintenanceItemsProvider);
    final lifetimeDistAsync = ref.watch(lifetimeDistanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('GARAGE & MAINTENANCE', style: AppTypography.label),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: itemsAsync.when(
          data: (items) => lifetimeDistAsync.when(
            data: (lifetimeDist) => ListView.builder(
              padding: EdgeInsets.all(screen.scale(AppSpacing.md)),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildMaintenanceCard(
                  context,
                  item,
                  lifetimeDist,
                  screen,
                  colors,
                  ref,
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('Error: $err', style: AppTypography.body)),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Error: $err', style: AppTypography.body)),
        ),
      ),
    );
  }

  Widget _buildMaintenanceCard(
    BuildContext context,
    MaintenanceItem item,
    double lifetimeDist,
    ScreenInfo screen,
    ColorScheme colors,
    WidgetRef ref,
  ) {
    // Calculate remaining
    double? remKm;
    if (item.nextDueDistance != null) {
      remKm = item.nextDueDistance! - lifetimeDist;
    }

    int? remDays;
    if (item.nextDueDate != null) {
      remDays = item.nextDueDate!.difference(DateTime.now()).inDays;
    }

    // Determine status color
    Color statusColor = colors.surfaceContainerHighest; // default border
    bool isWarning = false;
    bool isEmergency = false;

    if (remKm != null) {
      if (remKm <= 0) {
        isEmergency = true;
      } else if (remKm <= 200) {
        isWarning = true; // 200km warning
      }
    }

    if (remDays != null) {
      if (remDays <= 0) {
        isEmergency = true;
      } else if (remDays <= 7) {
        isWarning = true; // 1 week warning
      }
    }

    if (isEmergency) {
      statusColor = AppColors.emergency;
    } else if (isWarning) {
      statusColor = AppColors.warning;
    } else if (item.lastServiceDate != null) {
      statusColor = AppColors.active;
    }

    return Container(
      margin: EdgeInsets.only(bottom: screen.scale(AppSpacing.sm)),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: statusColor, width: isEmergency ? 2 : 1),
        borderRadius: BorderRadius.circular(screen.scale(16)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(screen.scale(AppSpacing.md)),
        title: Text(
          item.type.displayName,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screen.scale(AppSpacing.xs)),
            if (item.lastServiceDate == null)
              Text(
                'Not Serviced Yet',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.secondary,
                ),
              )
            else ...[
              Text(
                'Last Serviced: ${item.lastServiceDistance.toStringAsFixed(0)} km',
                style: AppTypography.bodySmall,
              ),
              if (remKm != null)
                Text(
                  'Due in: ${remKm > 0 ? remKm.toStringAsFixed(0) : "OVERDUE"} km',
                  style: AppTypography.bodySmall.copyWith(
                    color: isEmergency
                        ? AppColors.emergency
                        : isWarning
                        ? AppColors.warning
                        : colors.onSurface,
                  ),
                ),
              if (remDays != null)
                Text(
                  'Days left: ${remDays > 0 ? remDays : "OVERDUE"} days',
                  style: AppTypography.bodySmall.copyWith(
                    color: isEmergency
                        ? AppColors.emergency
                        : isWarning
                        ? AppColors.warning
                        : colors.onSurface,
                  ),
                ),
            ],
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: statusColor == colors.surfaceContainerHighest
                ? colors.secondary
                : statusColor,
            foregroundColor: statusColor == AppColors.warning
                ? colors.onSurface
                : colors.onPrimary,
          ),
          onPressed: () => _showServiceDialog(context, item, ref),
          child: Text('LOG SERVICE', style: AppTypography.label),
        ),
      ),
    );
  }

  void _showServiceDialog(
    BuildContext context,
    MaintenanceItem item,
    WidgetRef ref,
  ) {
    final notesController = TextEditingController(text: item.notes);

    showDialog(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            'LOG ${item.type.displayName.toUpperCase()}',
            style: AppTypography.label,
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'This will reset the interval for this item based on current distance.',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.secondary,
                    ),
                  ),
                  SizedBox(height: ScreenInfo.of(context).scale(AppSpacing.md)),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes / Cost',
                    ),
                    style: AppTypography.body,
                  ),
                ],
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
                final repo = ref.read(maintenanceRepositoryProvider);
                await repo.recordService(item.id, notesController.text);
                ref.invalidate(maintenanceItemsProvider);
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
}
