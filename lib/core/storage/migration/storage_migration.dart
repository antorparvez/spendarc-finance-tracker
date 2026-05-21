import '../storage_keys.dart';
import '../../logging/app_log.dart';
import '../local_storage_service.dart';
import '../secure_storage_service.dart';

/// Shared access to non-DB storage during migrations (no DB in this project).
class StorageMigrationContext {
  const StorageMigrationContext({
    required this.local,
    required this.secure,
  });

  final LocalStorageService local;
  final SecureStorageService secure;
}

/// Runs when upgrading stored data from version [index] to [index + 1].
///
/// Register functions in [kStorageMigrations] in order: the first entry
/// migrates `0 → 1`, the second `1 → 2`, etc. Length of the list is the target
/// schema version.
typedef StorageMigrationFn = Future<void> Function(StorageMigrationContext ctx);

/// Applies sequential migrations stored in SharedPreferences under
/// [StorageKeys.storageSchemaVersion].
///
/// - Missing or null version is treated as `0`.
/// - After each migration step, the version is incremented so a failed run can
///   resume safely on next launch.
/// - If stored version is **greater** than [migrations.length] (downgrade /
///   mismatched build), the version is clamped to the target and migrations are
///   skipped.
class StorageMigrationRunner {
  StorageMigrationRunner({
    required LocalStorageService local,
    required SecureStorageService secure,
    required List<StorageMigrationFn> migrations,
  })  : _local = local,
        _secure = secure,
        _migrations = migrations;

  final LocalStorageService _local;
  final SecureStorageService _secure;
  final List<StorageMigrationFn> _migrations;

  int get _targetVersion => _migrations.length;

  Future<void> run() async {
    final key = StorageKeys.storageSchemaVersion;
    var current = _local.getInt(key) ?? 0;
    final target = _targetVersion;

    AppLog.storage('schema version $current → $target');

    if (current > target) {
      AppLog.storage('downgrade detected, clamping to $target');
      await _local.setInt(key, target);
      return;
    }

    final ctx = StorageMigrationContext(local: _local, secure: _secure);

    while (current < target) {
      AppLog.storage('running migration ${current + 1}/$target');
      await _migrations[current](ctx);
      current += 1;
      await _local.setInt(key, current);
    }

    if (target > 0) {
      AppLog.storage('migrations complete at v$target');
    }
  }
}
