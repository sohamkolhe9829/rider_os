import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:rider_os/core/constants/app_colors.dart';
import 'package:rider_os/core/constants/app_spacing.dart';
import 'package:rider_os/core/constants/app_typography.dart';
import 'package:rider_os/core/responsive/responsive_engine.dart';
import 'package:rider_os/features/ride_console/presentation/widgets/speed_gauge_painter.dart';

class SpeedDisplay extends StatelessWidget {
  const SpeedDisplay({super.key, required this.speed, this.unit = 'km/h'});

  final int speed;
  final String unit;

  Color _getSpeedColor(BuildContext context, int currentSpeed) {
    if (currentSpeed <= 20) return Theme.of(context).colorScheme.onSurface;
    if (currentSpeed <= 40) return Colors.lightGreenAccent;
    if (currentSpeed <= 60) return Colors.greenAccent;
    if (currentSpeed <= 80) return Colors.orangeAccent;
    return AppColors.emergency;
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenInfo.of(context);
    final double gaugeSize = screen.scale(420.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: speed.toDouble()),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCirc,
      builder: (context, animatedSpeed, child) {
        final currentSpeed = animatedSpeed.round();
        final currentColor = _getSpeedColor(context, currentSpeed);

        return SizedBox(
          width: gaugeSize,
          height: gaugeSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: gaugeSize,
                height: gaugeSize,
                child: CustomPaint(
                  painter: SpeedGaugePainter(
                    speed: animatedSpeed,
                    activeColor: currentColor,
                    maxSpeed: 160.0,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              // Center Text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width:
                        gaugeSize *
                        0.75, // Restrict width so it stays inside the arc
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AnimatedFlipCounter(
                        value: currentSpeed,

                        duration: const Duration(milliseconds: 250),
                        textStyle: AppTypography.speedDisplay.copyWith(
                          color: currentColor,
                          fontSize: screen.scaleText(200.0),
                          height: 1.0,
                          letterSpacing: -4.0,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    unit,
                    style: AppTypography.unit.copyWith(
                      color: currentColor.withValues(alpha: 0.8),
                      fontSize: screen.scaleText(32.0),
                    ),
                  ),
                  SizedBox(height: screen.scale(AppSpacing.xl) - 1),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screen.scale(AppSpacing.md),
                      vertical: screen.scale(AppSpacing.xs),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: currentColor, width: 1.0),
                      borderRadius: BorderRadius.circular(screen.scale(20.0)),
                      color: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          color: currentColor,
                          size: screen.scaleText(10),
                        ),
                        SizedBox(width: screen.scale(AppSpacing.xs)),
                        Text(
                          'RIDE MODE',
                          style: AppTypography.label.copyWith(
                            color: currentColor,
                            fontSize: screen.scaleText(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
