import 'dart:async' show unawaited;

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/finance_dashboard.dart';
import '../../domain/entities/finance_sync_event.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_local_datasource.dart';
import '../datasources/finance_write_queue.dart';
import '../models/pending_sync_action.dart';
import '../models/transaction_model.dart';
import '../sync/finance_sync_service.dart';
import 'finance_dashboard_mapper.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  FinanceRepositoryImpl({
    required FinanceLocalDataSource local,
    required FinanceWriteQueue queue,
    required FinanceSyncService syncService,
  })  : _local = local,
        _queue = queue,
        _sync = syncService;

  final FinanceLocalDataSource _local;
  final FinanceWriteQueue _queue;
  final FinanceSyncService _sync;

  @override
  Stream<List<Transaction>> watchTransactions() {
    return _local.watchAll().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Stream<FinanceSyncEvent> watchSyncEvents() => _sync.events;

  @override
  Future<Either<Failure, FinanceDashboard>> getDashboard() async {
    try {
      final models = await _local.getAll();
      return Right(FinanceDashboardMapper.fromModels(models));
    } catch (error) {
      return Left(ErrorHandler.mapToFailure(error));
    }
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = 'tx-$now-${title.hashCode}';
      final model = TransactionModel(
        id: id,
        title: title.trim(),
        amount: amount.abs(),
        type: type,
        category: category,
        createdAtMs: now,
        updatedAtMs: now,
        syncVersion: 1,
        isPending: true,
      );

      await _local.upsert(model);
      await _queue.enqueue(
        PendingSyncAction(
          fingerprint: 'create:$id:$now',
          action: PendingSyncActionType.create,
          transactionId: id,
          payload: model.toJson(),
          createdAtMs: now,
        ),
      );
      unawaited(_sync.syncInBackground());

      return Right(model.toEntity());
    } catch (error) {
      return Left(ErrorHandler.mapToFailure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async {
    try {
      await _local.removeById(id);
      final now = DateTime.now().millisecondsSinceEpoch;
      await _queue.enqueue(
        PendingSyncAction(
          fingerprint: 'delete:$id:$now',
          action: PendingSyncActionType.delete,
          transactionId: id,
          payload: {},
          createdAtMs: now,
        ),
      );
      unawaited(_sync.syncInBackground());
      return const Right(Unit());
    } catch (error) {
      return Left(ErrorHandler.mapToFailure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncPending() async {
    try {
      await _sync.syncInBackground();
      return const Right(Unit());
    } catch (error) {
      return Left(ErrorHandler.mapToFailure(error));
    }
  }
}
