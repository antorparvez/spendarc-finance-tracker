class SyncState {
  const SyncState({
    this.isSyncing = false,
    this.completedTick = 0,
  });

  final bool isSyncing;
  final int completedTick;

  SyncState copyWith({
    bool? isSyncing,
    int? completedTick,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      completedTick: completedTick ?? this.completedTick,
    );
  }
}
