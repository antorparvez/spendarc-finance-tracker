import 'package:flutter/material.dart';

import 'arc_meter_painter.dart';

class ArcMeterWidget extends StatefulWidget {
  const ArcMeterWidget({
    super.key,
    required this.progress,
    required this.label,
    this.size = 160,
  });

  final double progress;
  final String label;
  final double size;

  @override
  State<ArcMeterWidget> createState() => _ArcMeterWidgetState();
}

class _ArcMeterWidgetState extends State<ArcMeterWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _runProgressAnimation();
  }

  @override
  void didUpdateWidget(covariant ArcMeterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _runProgressAnimation();
    }
  }

  void _runProgressAnimation() {
    final animationsEnabled = TickerMode.of(context) ?? true;
    if (animationsEnabled) {
      _controller.forward(from: 0);
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: widget.size,
      height: widget.size * 0.62,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: ArcMeterPainter(
              progress: widget.progress * _animation.value,
              trackColor: theme.colorScheme.surfaceContainerHighest,
              progressColor: theme.colorScheme.secondary,
              strokeWidth: 10,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.label,
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
