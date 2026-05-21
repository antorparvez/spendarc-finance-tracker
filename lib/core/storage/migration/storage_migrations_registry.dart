import 'storage_migration.dart';

/// All storage migrations, in order.
///
/// Add a new function at the **end** when you need to transform existing
/// SharedPreferences or secure storage keys/values. Each new entry bumps the
/// schema by one.
///
/// Example (rename a preference key):
/// ```dart
/// Future<void> _migrate0To1(StorageMigrationContext ctx) async {
///   final legacy = ctx.local.getString('legacy_theme');
///   if (legacy != null &&
///       ctx.local.getString(StorageKeys.currentTheme) == null) {
///     await ctx.local.setString(StorageKeys.currentTheme, legacy);
///     await ctx.local.remove('legacy_theme');
///   }
/// }
/// ```
///
/// Then append `_migrate0To1` to the list below.
final List<StorageMigrationFn> kStorageMigrations = [
  // No migrations yet — version stays 0 until you add one.
];
