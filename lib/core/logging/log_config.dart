class LogConfig {
  const LogConfig({
    required this.enabled,
    required this.environment,
    required this.appName,
    this.logNetworkBodies = true,
    this.redactSensitiveFields = false,
    this.maxBodyLength = 0,
  });

  final bool enabled;
  final String environment;
  final String appName;

  /// When false, network logs only the status line (no JSON bodies).
  final bool logNetworkBodies;

  /// Masks tokens/passwords in prod-style builds.
  final bool redactSensitiveFields;

  /// `0` = print full JSON in debug. Set a positive value to cap body size.
  final int maxBodyLength;
}
