import 'package:flutter/material.dart';

import 'line_chart_painter.dart';

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({
    super.key,
    required this.values,
    this.height = 120,
  });

  final List<double> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: LineChartPainter(
          values: values,
          lineColor: scheme.primary,
          fillColor: scheme.primary.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
