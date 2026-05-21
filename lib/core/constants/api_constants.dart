/// HTTP paths and full URLs used by [BaseApiService] / Dio.
///
/// Relative paths (e.g. `/auth/login`) are resolved against
/// [FlavorConfig.config.baseUrl]. Absolute URLs skip the flavor base URL.
class ApiConstants {
  ApiConstants._();

  // --- Sample / external (demo) ---

  static const dummyJsonBase = 'https://dummyjson.com';

  static const sampleProductDetail = '$dummyJsonBase/products/1';

}
