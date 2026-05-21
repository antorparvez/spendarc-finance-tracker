import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Flutter-only edge-to-edge helpers (no Android XML).
///
/// On Android 10+, transparent system bars can get a dark scrim unless
/// contrast enforcement is disabled — this mirrors what newer devices handle
/// more gracefully by default.
class SystemUiConfig {
  SystemUiConfig._();

  static SystemUiOverlayStyle overlayStyleFor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );
  }

  static void apply(Brightness brightness) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(overlayStyleFor(brightness));
  }
}
