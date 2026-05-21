class StorageKeys {
  StorageKeys._();

  /// Monotonic schema version for [StorageMigrationRunner] (SharedPreferences int).
  static const storageSchemaVersion = 'storage_schema_version';

  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const sessionId = 'session_id';
  static const currentTheme = 'current_theme';
  static const currentLocale = 'current_locale';
  static const defaultLocale = 'en';
}
