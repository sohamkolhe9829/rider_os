import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_os/core/constants/app_colors.dart';
import 'package:rider_os/core/constants/app_spacing.dart';
import 'package:rider_os/core/constants/app_typography.dart';
import 'package:rider_os/core/responsive/responsive_engine.dart';
import 'package:rider_os/features/fuel/presentation/providers/fuel_providers.dart';
import 'package:rider_os/features/ride_console/domain/ride_metrics.dart';
import 'package:rider_os/features/ride_console/presentation/providers/console_providers.dart';
import 'package:rider_os/features/ride_console/presentation/widgets/console_widgets.dart';
import 'package:rider_os/core/services/calculations/gps_fuel_calculator.dart';
import 'package:rider_os/features/ride_console/presentation/widgets/metric_box.dart';
import 'package:rider_os/features/settings/presentation/providers/settings_providers.dart';
import 'package:rider_os/core/providers/system_providers.dart';
import 'package:rider_os/features/ride_session/domain/ride_state.dart';
import 'package:rider_os/features/ride_session/presentation/providers/session_providers.dart';
import 'package:rider_os/features/safety/data/safety_service.dart';
import 'package:rider_os/features/safety/presentation/providers/safety_providers.dart';

class RideConsoleScreen extends ConsumerStatefulWidget {
  const RideConsoleScreen({super.key});

  @override
  ConsumerState<RideConsoleScreen> createState() => _RideConsoleScreenState();
}

class _RideConsoleScreenState extends ConsumerState<RideConsoleScreen>
    with TickerProviderStateMixin {
  Timer? _clockTimer;
  String _currentTime = '';

  // Flashing effect controller
  late AnimationController _flashController;
  late Animation<Color?> _flashAnimation;

  // Crash flash controller
  late AnimationController _crashFlashController;
  late Animation<Color?> _crashFlashAnimation;

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateClock();
    });

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _flashAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: AppColors.emergency.withValues(
            alpha: 0.15,
          ), // Reduced intensity for subtlety
        ).animate(
          CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
        );

    _crashFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _crashFlashAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: AppColors.emergency.withValues(alpha: 0.8),
        ).animate(
          CurvedAnimation(
            parent: _crashFlashController,
            curve: Curves.easeInOut,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rideConsoleRepositoryProvider).start();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _flashController.dispose();
    _crashFlashController.dispose();
    super.dispose();
  }

  void _updateClock() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  void _manageFlash(int speed) {
    if (speed >= 80) {
      if (!_flashController.isAnimating) {
        _flashController.repeat(reverse: true);
      }
    } else {
      if (_flashController.isAnimating) {
        _flashController.stop();
        _flashController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(currentRideMetricsProvider);
    final screen = ScreenInfo.of(context);
    final safetyState =
        ref.watch(safetyStateProvider).valueOrNull ?? SafetyState.monitoring;
    final safetyService = ref.read(safetyServiceProvider);

    _manageFlash(metrics.speedDisplay);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: _flashAnimation,
        builder: (context, child) {
          return Container(color: _flashAnimation.value, child: child);
        },
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screen.scale(AppSpacing.lg),
                  vertical: screen.scale(AppSpacing.sm),
                ),
                child: _buildFullLayout(context, metrics, screen),
              ),
            ),
            if (safetyState == SafetyState.crashDetected ||
                safetyState == SafetyState.sosActive)
              _buildCrashOverlay(context, screen, safetyState, safetyService),
          ],
        ),
      ),
    );
  }

  Widget _buildCrashOverlay(
    BuildContext context,
    ScreenInfo screen,
    SafetyState state,
    SafetyService service,
  ) {
    final isCrash = state == SafetyState.crashDetected;
    final theme = Theme.of(context);

    // Start flashing if it's a crash
    if (isCrash && !_crashFlashController.isAnimating) {
      _crashFlashController.repeat(reverse: true);
    } else if (!isCrash && _crashFlashController.isAnimating) {
      _crashFlashController.stop();
      _crashFlashController.reset();
    }

    return Stack(
      children: [
        // Flashing background
        AnimatedBuilder(
          animation: _crashFlashAnimation,
          builder: (context, child) {
            return Container(
              color: isCrash
                  ? _crashFlashAnimation.value
                  : theme.colorScheme.surface.withValues(alpha: 0.9),
              width: double.infinity,
              height: double.infinity,
            );
          },
        ),
        // Content
        SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isCrash ? 'EMERGENCY' : 'SOS ACTIVE',
                  style: AppTypography.metricLarge.copyWith(
                    fontSize: screen.scaleText(80),
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: screen.scale(AppSpacing.xs)),
                Text(
                  isCrash
                      ? 'POSSIBLE CRASH DETECTED'
                      : 'EMERGENCY PROTOCOL ENGAGED',
                  style: AppTypography.title.copyWith(
                    fontSize: screen.scaleText(24),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    letterSpacing: 4.0,
                  ),
                ),
                SizedBox(height: screen.scale(AppSpacing.xl)),

                if (isCrash) ...[
                  Text(
                    '${service.countdownSeconds}',
                    style: AppTypography.metricLarge.copyWith(
                      fontSize: screen.scaleText(160),
                      color: AppColors.emergency,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'SECONDS TO AUTO-ALERT',
                    style: AppTypography.label.copyWith(
                      fontSize: screen.scaleText(16),
                      color: AppColors.emergency,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(height: screen.scale(AppSpacing.xxl)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        context,
                        'CANCEL',
                        Icons.close,
                        () => service.cancelSos(),
                        screen,
                        color: theme.colorScheme.surface,
                        textColor: theme.colorScheme.onSurface,
                      ),
                      SizedBox(width: screen.scale(AppSpacing.lg)),
                      _buildActionButton(
                        context,
                        'CALL EMERGENCY',
                        Icons.phone,
                        () {},
                        screen,
                        color: AppColors.emergency,
                        textColor: theme.colorScheme.onPrimary,
                      ),
                      SizedBox(width: screen.scale(AppSpacing.lg)),
                      _buildActionButton(
                        context,
                        'SEND LOCATION',
                        Icons.location_on,
                        () {},
                        screen,
                        color: AppColors.active,
                        textColor: theme.colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ] else ...[
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.emergency,
                    size: screen.scaleText(120),
                  ),
                  SizedBox(height: screen.scale(AppSpacing.lg)),
                  Text(
                    'Emergency contacts and medical services have been notified.',
                    style: AppTypography.label.copyWith(
                      fontSize: screen.scaleText(24),
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screen.scale(AppSpacing.xxl)),
                  _buildActionButton(
                    context,
                    'STAND DOWN',
                    Icons.security,
                    () => service.cancelSos(),
                    screen,
                    color: theme.colorScheme.surface,
                    textColor: theme.colorScheme.onSurface,
                  ),
                ],

                SizedBox(height: screen.scale(AppSpacing.xxl)),
                _buildEmergencyPanel(context, screen),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onTap,
    ScreenInfo screen, {
    Color? color,
    Color? textColor,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: color ?? colors.surfaceContainer,
      borderRadius: BorderRadius.circular(screen.scale(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screen.scale(AppSpacing.xxl),
            vertical: screen.scale(AppSpacing.lg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: textColor ?? colors.onSurface,
                size: screen.scaleText(28),
              ),
              SizedBox(width: screen.scale(AppSpacing.sm)),
              Text(
                text,
                style: AppTypography.label.copyWith(
                  fontSize: screen.scaleText(20),
                  fontWeight: FontWeight.bold,
                  color: textColor ?? colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyPanel(BuildContext context, ScreenInfo screen) {
    final contactName = ref.watch(emergencyContactNameProvider);
    final contactNumber = ref.watch(emergencyContactNumberProvider);
    final bloodGroup = ref.watch(bloodGroupProvider);
    final theme = Theme.of(context);

    return Container(
      width: screen.scale(600),
      padding: EdgeInsets.all(screen.scale(AppSpacing.md)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(screen.scale(16)),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screen.scale(12)),
                decoration: BoxDecoration(
                  color: AppColors.emergency.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  color: AppColors.emergency,
                  size: screen.scaleText(24),
                ),
              ),
              SizedBox(width: screen.scale(AppSpacing.md)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contactName,
                      style: AppTypography.body.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: screen.scaleText(20),
                      ),
                    ),
                    SizedBox(height: screen.scale(4)),
                    Text(
                      'EMERGENCY CONTACT • $contactNumber',
                      style: AppTypography.label.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: screen.scaleText(12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screen.scale(AppSpacing.md),
                  vertical: screen.scale(AppSpacing.sm),
                ),
                decoration: BoxDecoration(
                  color: AppColors.emergency,
                  borderRadius: BorderRadius.circular(screen.scale(8)),
                ),
                child: Text(
                  bloodGroup,
                  style: AppTypography.label.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: screen.scaleText(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFullLayout(
    BuildContext context,
    RideMetrics metrics,
    ScreenInfo screen,
  ) {
    return Column(
      children: [
        _buildTopBar(context, metrics, screen),
        SizedBox(height: screen.scale(AppSpacing.sm)),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 22,
                child: _buildLeftPanel(context, metrics, screen),
              ),
              Expanded(
                flex: 56, // Gauge needs a lot of space
                child: Center(child: SpeedDisplay(speed: metrics.speedDisplay)),
              ),
              Expanded(
                flex: 22,
                child: _buildRightPanel(context, metrics, screen),
              ),
            ],
          ),
        ),
        SizedBox(height: screen.scale(AppSpacing.md)),
        _buildBottomNav(context, screen),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildAutoLayout(
    BuildContext context,
    RideMetrics metrics,
    ScreenInfo screen,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Center(child: SpeedDisplay(speed: metrics.speedDisplay)),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MetricBox(
                label: 'Trip',
                value: metrics.tripDistanceFormatted,
                unit: metrics.tripDistanceUnit,
              ),
              SizedBox(height: screen.scale(AppSpacing.lg)),
              MetricBox(label: 'Time', value: metrics.rideTimeFormatted),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    RideMetrics metrics,
    ScreenInfo screen,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard_customize_outlined,
                  color: colors.onSurface,
                  size: screen.scaleText(28),
                ),
                SizedBox(width: screen.scale(AppSpacing.sm)),
                Text(
                  'RIDER OS V2.0',
                  style: AppTypography.label.copyWith(
                    color: colors.onSurface,
                    letterSpacing: 2,
                    fontSize: screen.scaleText(18),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildStatusIndicator(
                  'GPS ON',
                  Icons.location_on,
                  screen,
                  isActive: metrics.isGpsActive,
                  activeColor: colors.primary,
                ),
                SizedBox(width: screen.scale(AppSpacing.lg)),
                Icon(
                  Icons.bluetooth,
                  color: colors.onSurface,
                  size: screen.scaleText(28),
                ),
                SizedBox(width: screen.scale(AppSpacing.lg)),
                Icon(
                  Icons.battery_full,
                  color: colors.onSurface,
                  size: screen.scaleText(28),
                ),
                SizedBox(width: screen.scale(AppSpacing.xs)),
                Text(
                  '${ref.watch(batteryStateProvider).valueOrNull ?? 85}%',
                  style: AppTypography.label.copyWith(
                    color: colors.onSurface,
                    fontSize: screen.scaleText(18),
                  ),
                ),
                SizedBox(width: screen.scale(AppSpacing.lg)),
                Icon(
                  Icons.thermostat,
                  color: colors.onSurface,
                  size: screen.scaleText(28),
                ),
                SizedBox(width: screen.scale(AppSpacing.xs)),
                Text(
                  '22°C',
                  style: AppTypography.label.copyWith(
                    color: colors.onSurface,
                    fontSize: screen.scaleText(18),
                  ),
                ),
                SizedBox(width: screen.scale(AppSpacing.xl)),
                Padding(
                  padding: EdgeInsets.only(right: screen.scale(AppSpacing.sm)),
                  child: Text(
                    ref.watch(clockProvider).valueOrNull ?? _currentTime,
                    style: AppTypography.metricLarge.copyWith(
                      color: colors.onSurface,
                      fontSize: screen.scaleText(36),
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: screen.scale(AppSpacing.sm)),
        Divider(
          height: 1,
          thickness: 1,
          color: colors.outline.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, ScreenInfo screen) {
    final colors = Theme.of(context).colorScheme;
    final rideState = ref.watch(currentRideStateProvider);
    final recorder = ref.read(rideRecorderProvider);
    final repo = ref.read(rideRepositoryProvider);

    return Container(
      height: screen.scale(80),
      padding: EdgeInsets.symmetric(horizontal: screen.scale(AppSpacing.lg)),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(screen.scale(40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(context, Icons.speed, 'DASHBOARD', true, screen),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push('/fuel'),
            child: _buildNavItem(
              context,
              Icons.local_gas_station,
              'FUEL',
              false,
              screen,
            ),
          ),

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (rideState == RideState.inactive) {
                recorder.start();
              } else if (rideState == RideState.recording) {
                recorder.pause();
              } else {
                recorder.resume();
              }
            },
            onLongPress: () {
              if (rideState != RideState.inactive) {
                repo.endAndSaveRide();
              }
            },
            child: Container(
              height: screen.scale(64),
              margin: EdgeInsets.symmetric(
                vertical: screen.scale(AppSpacing.sm),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screen.scale(AppSpacing.xxl),
              ),
              decoration: BoxDecoration(
                color: rideState == RideState.recording
                    ? AppColors.warning
                    : (rideState == RideState.inactive
                          ? AppColors.warning
                          : AppColors.active),
                borderRadius: BorderRadius.circular(screen.scale(16.0)),
              ),
              child: Row(
                children: [
                  Icon(
                    rideState == RideState.recording
                        ? Icons.pause_circle_filled
                        : Icons.radio_button_checked,
                    color: colors.onPrimary,
                    size: screen.scaleText(28),
                  ),
                  SizedBox(width: screen.scale(AppSpacing.md)),
                  Text(
                    rideState == RideState.recording
                        ? 'PAUSE RIDE'
                        : (rideState == RideState.paused
                              ? 'RESUME RIDE'
                              : 'START RIDE'),
                    style: AppTypography.label.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: screen.scaleText(18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push('/safety'),
            child: _buildNavItem(
              context,
              Icons.shield_outlined,
              'SAFETY',
              false,
              screen,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push('/settings'),
            child: _buildNavItem(
              context,
              Icons.settings_outlined,
              'SETTINGS',
              false,
              screen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    ScreenInfo screen,
  ) {
    final colors = Theme.of(context).colorScheme;
    final color = isActive ? AppColors.warning : colors.onSurface;
    return Container(
      constraints: BoxConstraints(minHeight: screen.scale(64)),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: screen.scaleText(28)),
          SizedBox(width: screen.scale(AppSpacing.sm)),
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: color,
              fontSize: screen.scaleText(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(
    String label,
    IconData icon,
    ScreenInfo screen, {
    bool isActive = false,
    Color? activeColor,
  }) {
    final colors = Theme.of(context).colorScheme;
    final color = isActive
        ? (activeColor ?? AppColors.warning)
        : colors.onSurface;
    return Row(
      children: [
        Icon(icon, color: color, size: screen.scaleText(20)),
        SizedBox(width: screen.scale(4)),
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: color,
            fontSize: screen.scaleText(16),
          ),
        ),
      ],
    );
  }

  Widget _buildLeftPanel(
    BuildContext context,
    RideMetrics metrics,
    ScreenInfo screen,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: MetricBox(
            label: 'TRIP A',
            icon: Icons.alt_route_rounded,
            value: metrics.tripDistanceFormatted,
            unit: metrics.tripDistanceUnit,
          ),
        ),
        SizedBox(height: screen.scale(AppSpacing.sm)),
        Expanded(
          child: MetricBox(
            label: 'DURATION',
            icon: Icons.access_time_rounded,
            value: metrics.rideTimeFormatted,
            unit: 'hh:mm',
          ),
        ),
        SizedBox(height: screen.scale(AppSpacing.sm)),
        Expanded(
          child: MetricBox(
            label: 'AVG SPEED',
            icon: Icons.speed,
            value: metrics.avgSpeedDisplay.toString(),
            unit: 'km/h',
          ),
        ),
        SizedBox(height: screen.scale(AppSpacing.sm)),
        Expanded(
          child: MetricBox(
            label: 'TOP SPEED',
            icon: Icons.av_timer,
            value: metrics.maxSpeedDisplay.toString(),
            unit: 'km/h',
            valueColor: AppColors.emergency, // Pure red as requested
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel(
    BuildContext context,
    RideMetrics metrics,
    ScreenInfo screen,
  ) {
    final fuelStats = ref.watch(fuelStatsProvider).valueOrNull;
    final rangeStr = fuelStats?.estimatedRangeKm.toStringAsFixed(0) ?? '145';
    final expectedMileage = ref.watch(expectedMileageProvider);
    final displayMileageStr =
        (fuelStats != null && fuelStats.averageMileageKmpl > 0)
        ? fuelStats.averageMileageKmpl.toStringAsFixed(1)
        : expectedMileage.toStringAsFixed(1);
    final colors = Theme.of(context).colorScheme;

    // Calculate progress bar width
    double progress = 0.0;
    if (fuelStats != null) {
      final tankCapacity = ref.watch(tankCapacityProvider);
      final mileage = fuelStats.averageMileageKmpl > 0
          ? fuelStats.averageMileageKmpl
          : expectedMileage;

      progress = GpsFuelCalculator.calculateProgressRatio(
        liveRangeKm: fuelStats.estimatedRangeKm,
        tankCapacityLiters: tankCapacity,
        averageMileageKmpl: mileage,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: MetricBox(
            label: 'FUEL RANGE',
            icon: Icons.local_gas_station_rounded,
            customContent: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      rangeStr,
                      style: AppTypography.metricLarge.copyWith(
                        fontSize: screen.scaleText(48),
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(width: screen.scale(AppSpacing.xs)),
                    Text(
                      'km',
                      style: AppTypography.unit.copyWith(
                        fontSize: screen.scaleText(14),
                        color: colors.secondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screen.scale(AppSpacing.sm)),
                SizedBox(
                  width: screen.scale(120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          final segmentStart = index / 6.0;
                          final segmentEnd = (index + 1) / 6.0;
                          final isFilled = progress >= segmentEnd;
                          final isPartial =
                              !isFilled && progress > segmentStart;

                          return Expanded(
                            child: Container(
                              height: screen.scale(8),
                              margin: EdgeInsets.only(
                                right: index < 5 ? screen.scale(4) : 0,
                              ),
                              decoration: BoxDecoration(
                                color: isPartial
                                    ? colors.primary.withValues(alpha: 0.5)
                                    : isFilled
                                    ? colors.primary
                                    : colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  screen.scale(2),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: screen.scale(AppSpacing.xs)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'E',
                            style: AppTypography.label.copyWith(
                              color: AppColors.emergency,
                              fontSize: screen.scaleText(12),
                            ),
                          ),
                          Text(
                            'F',
                            style: AppTypography.label.copyWith(
                              color: AppColors.active,
                              fontSize: screen.scaleText(12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: screen.scale(AppSpacing.sm)),
        Expanded(
          child: MetricBox(
            label: 'HEADING',
            icon: Icons.explore_outlined,
            customContent: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${metrics.headingDisplay}°',
                      style: AppTypography.metricLarge.copyWith(
                        fontSize: screen.scaleText(48),
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(width: screen.scale(AppSpacing.sm)),
                    Text(
                      metrics.compassDirection,
                      style: AppTypography.unit.copyWith(
                        color: AppColors.active,
                        fontSize: screen.scaleText(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screen.scale(AppSpacing.md)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildCompassTick('210', colors.secondary, screen),
                    _buildCompassTick('W', colors.secondary, screen),
                    _buildCompassTick('240', colors.secondary, screen),
                    _buildCompassTick(
                      'W',
                      AppColors.active,
                      screen,
                      isMain: true,
                    ),
                    _buildCompassTick('300', colors.secondary, screen),
                    _buildCompassTick('330', colors.secondary, screen),
                    _buildCompassTick('N', AppColors.active, screen),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: screen.scale(AppSpacing.sm)),
        Expanded(
          child: MetricBox(
            label: 'ALTITUDE',
            icon: Icons.terrain,
            customContent: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      metrics.altitudeDisplay.toString(),
                      style: AppTypography.metricLarge.copyWith(
                        fontSize: screen.scaleText(48),
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(width: screen.scale(AppSpacing.xs)),
                    Text(
                      'm',
                      style: AppTypography.unit.copyWith(
                        fontSize: screen.scaleText(14),
                        color: colors.secondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screen.scale(AppSpacing.xs)),
                Text(
                  'MAX ${metrics.highestAltitude.round()}m • MIN ${metrics.lowestAltitude.round()}m',
                  style: AppTypography.label.copyWith(
                    color: colors.secondary,
                    fontSize: screen.scaleText(10),
                  ),
                ),
                SizedBox(height: screen.scale(2)),
                Text(
                  'GAIN ${metrics.elevationGain.round()}m • LOSS ${metrics.elevationLoss.round()}m',
                  style: AppTypography.label.copyWith(
                    color: colors.secondary,
                    fontSize: screen.scaleText(10),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: screen.scale(AppSpacing.sm)),
        Expanded(
          child: MetricBox(
            label: 'CURRENT MILEAGE',
            icon: Icons.local_gas_station_rounded,
            customContent: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      displayMileageStr,
                      style: AppTypography.metricLarge.copyWith(
                        fontSize: screen.scaleText(48),
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(width: screen.scale(AppSpacing.xs)),
                    Text(
                      'km/L',
                      style: AppTypography.unit.copyWith(
                        fontSize: screen.scaleText(14),
                        color: colors.secondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screen.scale(AppSpacing.xs)),
                Text(
                  'WMA CALCULATED',
                  style: AppTypography.label.copyWith(
                    color: colors.secondary,
                    fontSize: screen.scaleText(10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompassTick(
    String label,
    Color color,
    ScreenInfo screen, {
    bool isMain = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: color,
            fontSize: screen.scaleText(10),
          ),
        ),
        SizedBox(height: screen.scale(4)),
        Container(
          width: screen.scale(isMain ? 2 : 1),
          height: screen.scale(isMain ? 12 : 6),
          color: color,
        ),
      ],
    );
  }
}
