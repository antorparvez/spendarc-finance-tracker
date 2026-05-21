import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class FinanceGlassCard extends StatelessWidget {
  const FinanceGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.glassSurface(brightness),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder(brightness)),
        boxShadow: [
          if (brightness == Brightness.light)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}
