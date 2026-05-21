enum FinanceSyncStatus { idle, syncing, completed }

class FinanceSyncEvent {
  const FinanceSyncEvent(this.status);

  final FinanceSyncStatus status;
}
