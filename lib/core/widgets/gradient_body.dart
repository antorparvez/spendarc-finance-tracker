import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GradientBody extends StatelessWidget {
  const GradientBody({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.useSafeArea = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? AppColors.gradientDark
        : AppColors.gradientLight;

    Widget content = Padding(padding: padding, child: child);
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: content,
    );
  }
}
