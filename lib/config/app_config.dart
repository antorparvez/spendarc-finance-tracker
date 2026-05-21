class AppConfig {
  const AppConfig({
    required this.environment,
    required this.appName,
    required this.baseUrl,
  });

  final String environment;
  final String appName;
  final String baseUrl;
}
