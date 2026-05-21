import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/finance_sync_event.dart';
import '../../../domain/usecases/sync_finance_queue.dart';
import '../../../domain/usecases/watch_sync_events.dart';
import 'sync_event.dart';
import 'sync_state.dart';

/// Emits background sync status for [FinanceBloc] (inter-bloc communication).
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc({
    required WatchSyncEvents watchSyncEvents,
    required SyncFinanceQueue syncFinanceQueue,
  })  : _watchSyncEvents = watchSyncEvents,
        _syncFinanceQueue = syncFinanceQueue,
        super(const SyncState()) {
    on<SyncStarted>(_onStarted);
    on<SyncRepositoryEvent>(_onRepositoryEvent);
  }

  final WatchSyncEvents _watchSyncEvents;
  final SyncFinanceQueue _syncFinanceQueue;
  StreamSubscription<FinanceSyncEvent>? _syncSub;

  Future<void> _onStarted(SyncStarted event, Emitter<SyncState> emit) async {
    await _syncSub?.cancel();
    _syncSub = _watchSyncEvents().listen(
      (repoEvent) => add(SyncRepositoryEvent(repoEvent)),
    );
    await _syncFinanceQueue(const NoParams());
  }

  void _onRepositoryEvent(SyncRepositoryEvent event, Emitter<SyncState> emit) {
    if (event.event.status == FinanceSyncStatus.syncing) {
      emit(state.copyWith(isSyncing: true));
    } else if (event.event.status == FinanceSyncStatus.completed) {
      emit(
        state.copyWith(
          isSyncing: false,
          completedTick: state.completedTick + 1,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _syncSub?.cancel();
    return super.close();
  }
}
