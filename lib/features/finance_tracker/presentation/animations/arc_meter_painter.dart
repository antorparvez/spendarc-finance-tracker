import 'dart:math' as math;

import 'package:flutter/material.dart';

class ArcMeterPainter extends CustomPainter {
  ArcMeterPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = math.pi;
    const sweep = math.pi;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, start, sweep, false, track);
    canvas.drawArc(rect, start, sweep * progress.clamp(0.0, 1.0), false, fill);
  }

  @override
  bool shouldRepaint(covariant ArcMeterPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
