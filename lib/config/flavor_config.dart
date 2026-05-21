import 'app_config.dart';
import 'environment.dart';
import '../core/constants/flavor_constants.dart';

class FlavorConfig {
  FlavorConfig._();

  static late AppConfig _config;

  static AppConfig get config => _config;

  static void initialize(Environment environment) {
    final defaultAppName = FlavorConstants.appNames[environment]!;
    final defaultBaseUrl = FlavorConstants.baseUrls[environment]!;
    final dynamicBaseUrl = String.fromEnvironment(
      'BASE_URL',
      defaultValue: defaultBaseUrl,
    );

    _config = AppConfig(
      environment: environment.name,
      appName: defaultAppName,
      baseUrl: dynamicBaseUrl,
    );
  }
}
