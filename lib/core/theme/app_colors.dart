import 'package:flutter/material.dart';

/// SpendArc finance palette (light + dark).
class AppColors {
  AppColors._();

  static const primary = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF818CF8);
  static const secondary = Color(0xFF10B981);
  static const accent = Color(0xFF06B6D4);

  static const lightBackground = Color(0xFFF4F6FB);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFE8ECF4);
  static const onSurfaceLight = Color(0xFF0F172A);
  static const onSurfaceVariantLight = Color(0xFF64748B);

  static const darkBackground = Color(0xFF0B1020);
  static const darkSurface = Color(0xFF151D33);
  static const darkSurfaceVariant = Color(0xFF243049);
  static const onSurfaceDark = Color(0xFFF1F5F9);
  static const onSurfaceVariantDark = Color(0xFF94A3B8);

  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);

  static const gradientLight = <Color>[
    Color(0xFFEEF2FF),
    Color(0xFFF0FDFA),
    Color(0xFFF8FAFC),
  ];

  static const gradientDark = <Color>[
    Color(0xFF0B1020),
    Color(0xFF1E1B4B),
    Color(0xFF0F172A),
  ];

  static const balanceGradientLight = <Color>[
    Color(0xFF4F46E5),
    Color(0xFF6366F1),
    Color(0xFF0D9488),
  ];

  static const balanceGradientDark = <Color>[
    Color(0xFF3730A3),
    Color(0xFF4F46E5),
    Color(0xFF047857),
  ];

  static Color glassSurface(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF1E293B).withValues(alpha: 0.72)
      : Colors.white.withValues(alpha: 0.82);

  static Color glassBorder(Brightness brightness) => brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.white.withValues(alpha: 0.9);
}
