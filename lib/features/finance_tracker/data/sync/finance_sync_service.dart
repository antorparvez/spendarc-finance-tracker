import 'dart:async';
import 'dart:convert';

import '../../../../core/services/connectivity_service.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../datasources/finance_local_datasource.dart';
import '../datasources/finance_remote_datasource.dart';
import '../datasources/finance_write_queue.dart';
import '../../domain/entities/finance_sync_event.dart';
import '../models/pending_sync_action.dart';
import '../models/transaction_model.dart';

/// Background sync with write-queue replay and remote/local diffing.
class FinanceSyncService {
  FinanceSyncService({
    required FinanceLocalDataSource local,
    required FinanceRemoteDataSource remote,
    required FinanceWriteQueue queue,
    required ConnectivityService connectivity,
    required LocalStorageService storage,
  })  : _local = local,
        _remote = remote,
        _queue = queue,
        _connectivity = connectivity,
        _storage = storage;

  final FinanceLocalDataSource _local;
  final FinanceRemoteDataSource _remote;
  final FinanceWriteQueue _queue;
  final ConnectivityService _connectivity;
  final LocalStorageService _storage;

  final _syncEvents = StreamController<FinanceSyncEvent>.broadcast();
  bool _isSyncing = false;

  Stream<FinanceSyncEvent> get events => _syncEvents.stream;

  Set<String> _syncedFingerprints() {
    final raw = _storage.getString(StorageKeys.financeSyncedFingerprints);
    if (raw == null || raw.isEmpty) return {};
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => e.toString()).toSet();
  }

  Future<void> _markFingerprintSynced(String fingerprint) async {
    final set = _syncedFingerprints()..add(fingerprint);
    await _storage.setString(
      StorageKeys.financeSyncedFingerprints,
      jsonEncode(set.toList()),
    );
  }

  Future<void> mergeRemoteDiff() async {
    final remoteDtos = await _remote.fetchSnapshot();
    if (remoteDtos.isEmpty) return;

    final local = await _local.getAll();
    final byId = {for (final t in local) t.id: t};

    for (final dto in remoteDtos) {
      final remoteModel = TransactionModel.fromDto(dto);
      final existing = byId[remoteModel.id];
      if (existing == null ||
          remoteModel.updatedAtMs > existing.updatedAtMs) {
        byId[remoteModel.id] = remoteModel.copyWith(isPending: false);
      }
    }

    await _local.saveAll(byId.values.toList());
  }

  Future<void> syncInBackground() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _syncEvents.add(const FinanceSyncEvent(FinanceSyncStatus.syncing));

    try {
      var online = false;
      try {
        online = await _connectivity.isConnected();
      } catch (_) {
        online = false;
      }
      if (online) {
        await mergeRemoteDiff();
      }

      final synced = _syncedFingerprints();
      final pending = _queue.readAll();

      for (final action in pending) {
        if (synced.contains(action.fingerprint)) {
          await _queue.removeFingerprint(action.fingerprint);
          continue;
        }

        switch (action.action) {
          case PendingSyncActionType.create:
            final model = TransactionModel.fromJson(action.payload);
            if (online) {
              await _remote.pushCreate(model.copyWith(isPending: false));
            }
            await _local.upsert(model.copyWith(isPending: false));
          case PendingSyncActionType.delete:
            if (online) {
              await _remote.pushDelete(action.transactionId);
            }
            await _local.removeById(action.transactionId);
        }

        await _markFingerprintSynced(action.fingerprint);
        await _queue.removeFingerprint(action.fingerprint);
      }

      if (online) {
        await mergeRemoteDiff();
      }

      await _storage.setInt(
        StorageKeys.financeLastSyncAt,
        DateTime.now().millisecondsSinceEpoch,
      );
      _syncEvents.add(const FinanceSyncEvent(FinanceSyncStatus.completed));
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _syncEvents.close();
  }
}
