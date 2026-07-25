import 'package:flutter/material.dart';
import 'package:rider_os/core/constants/app_spacing.dart';
import 'package:rider_os/core/constants/app_typography.dart';
import 'package:rider_os/core/responsive/responsive_engine.dart';

/// A rounded, bordered box for displaying metrics, strictly matching the OEM HMI style.
class MetricBox extends StatelessWidget {
  const MetricBox({
    super.key,
    required this.label,
    this.icon,
    this.value,
    this.unit,
    this.valueColor,
    this.customContent,
  });

  final String label;
  final IconData? icon;
  final String? value;
  final String? unit;
  final Color? valueColor;
  final Widget? customContent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final screen = ScreenInfo.of(context);

    // Use theme colors to support both Light and Dark mode correctly.
    final surfaceColor = colors.surfaceContainer;
    final borderColor = colors.outline.withValues(alpha: 0.5);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screen.scale(AppSpacing.md),
        vertical: screen.scale(AppSpacing.sm),
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(screen.scale(8.0)),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (Icon + Label)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: screen.scaleText(14.0),
                      color: valueColor ?? colors.secondary,
                    ),
                    SizedBox(width: screen.scale(AppSpacing.xs)),
                  ],
                  Text(
                    label.toUpperCase(),
                    style: AppTypography.label.copyWith(
                      color: colors.secondary,
                      fontSize: screen.scaleText(11.0),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screen.scale(AppSpacing.sm)),

            // Content
            if (customContent != null)
              customContent!
            else if (value != null)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value!,
                      style: AppTypography.metricLarge.copyWith(
                        color: valueColor ?? colors.onSurface,
                        fontSize: screen.scaleText(
                          48.0,
                        ), // Massive font for metric value
                        height: 1.0,
                        letterSpacing: -1.0,
                      ),
                    ),
                    if (unit != null) ...[
                      SizedBox(width: screen.scale(AppSpacing.xs)),
                      Text(
                        unit!,
                        style: AppTypography.unit.copyWith(
                          color: valueColor ?? colors.secondary,
                          fontSize: screen.scaleText(14.0), // Small unit
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MetricCell extends StatelessWidget {
  const MetricCell({
    super.key,
    required this.label,
    required this.value,
    this.unit = '',
    this.alignment = CrossAxisAlignment.center,
  });

  final String label;
  final String value;
  final String unit;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final screen = ScreenInfo.of(context);

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: colors.secondary,
            fontSize: screen.scaleText(12),
          ),
        ),
        SizedBox(height: screen.scale(AppSpacing.xs)),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTypography.metricMedium.copyWith(
                color: colors.onSurface,
                fontSize: screen.scaleText(32),
              ),
            ),
            if (unit.isNotEmpty) ...[
              SizedBox(width: screen.scale(AppSpacing.xs)),
              Text(
                unit,
                style: AppTypography.unit.copyWith(
                  color: colors.secondary,
                  fontSize: screen.scaleText(16),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class MetricDivider extends StatelessWidget {
  const MetricDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 1,
      height: double.infinity,
      color: colors.outline.withValues(alpha: 0.1),
      margin: EdgeInsets.symmetric(
        horizontal: ScreenInfo.of(context).scale(AppSpacing.lg),
      ),
    );
  }
}
