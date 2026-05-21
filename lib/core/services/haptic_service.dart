import 'package:flutter/services.dart';

class HapticService {
  Future<void> lightImpact() => HapticFeedback.lightImpact();

  Future<void> mediumImpact() => HapticFeedback.mediumImpact();

  Future<void> heavyImpact() => HapticFeedback.heavyImpact();

  Future<void> selectionClick() => HapticFeedback.selectionClick();
}
