import '../entities/finance_sync_event.dart';
import '../repositories/finance_repository.dart';

class WatchSyncEvents {
  const WatchSyncEvents(this._repository);

  final FinanceRepository _repository;

  Stream<FinanceSyncEvent> call() => _repository.watchSyncEvents();
}
