import 'dart:convert';

import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../models/pending_sync_action.dart';

/// Persists offline mutations until [FinanceSyncService] applies them.
class FinanceWriteQueue {
  FinanceWriteQueue(this._local);

  final LocalStorageService _local;

  List<PendingSyncAction> readAll() {
    final raw = _local.getString(StorageKeys.financeWriteQueue);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => PendingSyncAction.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> enqueue(PendingSyncAction action) async {
    final items = readAll();
    if (items.any((e) => e.fingerprint == action.fingerprint)) return;
    items.add(action);
    await _persist(items);
  }

  Future<void> removeFingerprint(String fingerprint) async {
    final items = readAll()..removeWhere((e) => e.fingerprint == fingerprint);
    await _persist(items);
  }

  Future<void> clear() => _persist([]);

  Future<void> _persist(List<PendingSyncAction> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _local.setString(StorageKeys.financeWriteQueue, encoded);
  }
}
