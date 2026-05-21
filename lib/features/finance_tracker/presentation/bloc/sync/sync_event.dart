import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/finance_sync_event.dart';

sealed class SyncEvent {}

class SyncStarted extends SyncEvent {}

class SyncRepositoryEvent extends SyncEvent {
  SyncRepositoryEvent(this.event);

  final FinanceSyncEvent event;
}
