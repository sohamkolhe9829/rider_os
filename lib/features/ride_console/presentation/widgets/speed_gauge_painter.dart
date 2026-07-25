import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A custom painter to draw a 260-degree semi-circular gauge.
///
/// It draws a thick, dark background track and an active white foreground track.
class SpeedGaugePainter extends CustomPainter {
  SpeedGaugePainter({
    required this.speed,
    required this.activeColor,
    required this.maxSpeed,
    required this.backgroundColor,
  });

  final double speed;
  final Color activeColor;
  final double maxSpeed;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);

    // The gauge spans 260 degrees.
    // Start angle is 140 degrees (in radians).
    // Sweep angle is 260 degrees (in radians).
    const startAngle = 140 * (math.pi / 180);
    const sweepAngle = 260 * (math.pi / 180);

    // Draw Background Track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          size.width *
          0.05 // Thicker stroke
      ..strokeCap = StrokeCap.butt; // Flat ends matching image

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Draw Active Track
    // Clamping to ensure we don't overdraw the max gauge
    final progress = (speed / maxSpeed).clamp(0.0, 1.0);
    final activeSweepAngle = sweepAngle * progress;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          size.width *
          0.05 // Thicker stroke
      ..strokeCap = StrokeCap.butt; // Flat ends

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      activeSweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant SpeedGaugePainter oldDelegate) {
    return oldDelegate.speed != speed || oldDelegate.activeColor != activeColor;
  }
}
