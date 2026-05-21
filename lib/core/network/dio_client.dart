import 'package:dio/dio.dart';

import '../../config/flavor_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class DioClient {
  DioClient({
    required TokenProvider tokenProvider,
    required ConnectivityChecker connectivityChecker,
    SessionExpiredHandler? onSessionExpired,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: FlavorConfig.config.baseUrl,
           connectTimeout: const Duration(seconds: 30),
           receiveTimeout: const Duration(seconds: 30),
           sendTimeout: const Duration(seconds: 30),
           contentType: 'application/json',
           responseType: ResponseType.json,
         ),
       ) {
    dio.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(
        tokenProvider: tokenProvider,
        onSessionExpired: onSessionExpired,
      ),
      RetryInterceptor(dio: dio),
      ConnectivityInterceptor(isConnected: connectivityChecker),
    ]);
  }

  final Dio dio;
}
