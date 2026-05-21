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

  // Finance tracker (offline-first)
  static const financeTransactions = 'finance_transactions_v1';
  static const financeWriteQueue = 'finance_write_queue_v1';
  static const financeRemoteSnapshot = 'finance_remote_snapshot_v1';
  static const financeSyncedFingerprints = 'finance_synced_fingerprints_v1';
  static const financeLastSyncAt = 'finance_last_sync_at_v1';
}
