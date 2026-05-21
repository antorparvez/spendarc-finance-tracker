import 'dart:math' as math;

import 'package:flutter/material.dart';

class ParticleBurstOverlay extends StatefulWidget {
  const ParticleBurstOverlay({
    super.key,
    required this.active,
    required this.origin,
    required this.child,
  });

  final bool active;
  final Offset origin;
  final Widget child;

  @override
  State<ParticleBurstOverlay> createState() => _ParticleBurstOverlayState();
}

class _ParticleBurstOverlayState extends State<ParticleBurstOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.active) _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant ParticleBurstOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.active)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ParticlePainter(
                      progress: _controller.value,
                      origin: widget.origin,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.progress,
    required this.origin,
    required this.color,
  });

  final double progress;
  final Offset origin;
  final Color color;

  static const _count = 18;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < _count; i++) {
      final angle = (i / _count) * math.pi * 2;
      final distance = 40 * progress * (0.6 + (i % 3) * 0.2);
      final offset = Offset(
        origin.dx + math.cos(angle) * distance,
        origin.dy + math.sin(angle) * distance,
      );
      paint.color = color.withValues(alpha: 1 - progress);
      canvas.drawCircle(offset, 3 * (1 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
