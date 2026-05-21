import '../../config/environment.dart';

class FlavorConstants {
  FlavorConstants._();

  static const appNames = <Environment, String>{
    Environment.dev: 'BLoC Boilerplate Dev',
    Environment.staging: 'BLoC Boilerplate Staging',
    Environment.prod: 'BLoC Boilerplate',
  };

  static const baseUrls = <Environment, String>{
    Environment.dev: 'https://dev-api.example.com',
    Environment.staging: 'https://staging-api.example.com',
    Environment.prod: 'https://api.example.com',
  };
}
