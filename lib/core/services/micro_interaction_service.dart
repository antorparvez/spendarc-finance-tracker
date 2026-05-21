import 'package:flutter/material.dart';

class MicroInteractionService {
  const MicroInteractionService();

  Duration tabStaggerDuration(int index) {
    final base = 220;
    final step = 24;
    return Duration(milliseconds: base + (index * step));
  }

  Curve get tabCurve => Curves.easeOutBack;
  Curve get tabScaleCurve => Curves.elasticOut;
  double selectedScale(bool selected) => selected ? 1.08 : 1.0;
}
