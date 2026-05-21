import '../../core/network/base_api_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/storage/local_storage_service.dart';
import 'data/datasources/finance_local_datasource.dart';
import 'data/datasources/finance_remote_datasource.dart';
import 'data/datasources/finance_write_queue.dart';
import 'data/repositories/finance_repository_impl.dart';
import 'data/sync/finance_sync_service.dart';
import 'domain/repositories/finance_repository.dart';
import 'domain/usecases/add_transaction.dart';
import 'domain/usecases/delete_transaction.dart';
import 'domain/usecases/get_finance_dashboard.dart';
import 'domain/usecases/sync_finance_queue.dart';
import 'domain/usecases/watch_sync_events.dart';
import 'domain/usecases/watch_transactions.dart';
import 'presentation/bloc/finance/finance_bloc.dart';
import 'presentation/bloc/sync/sync_bloc.dart';

class FinanceTrackerDi {
  FinanceTrackerDi._();

  static FinanceBundle create({
    required LocalStorageService localStorage,
    required BaseApiService apiService,
    required ConnectivityService connectivity,
  }) {
    final local = FinanceLocalDataSource(localStorage);
    final remote = FinanceRemoteDataSource(api: apiService, local: localStorage);
    final queue = FinanceWriteQueue(localStorage);
    final sync = FinanceSyncService(
      local: local,
      remote: remote,
      queue: queue,
      connectivity: connectivity,
      storage: localStorage,
    );
    final repository = FinanceRepositoryImpl(
      local: local,
      queue: queue,
      syncService: sync,
    );

    final syncBloc = SyncBloc(
      watchSyncEvents: WatchSyncEvents(repository),
      syncFinanceQueue: SyncFinanceQueue(repository),
    );
    final financeBloc = FinanceBloc(
      getDashboard: GetFinanceDashboard(repository),
      addTransaction: AddTransaction(repository),
      deleteTransaction: DeleteTransaction(repository),
      watchTransactions: WatchTransactions(repository),
      syncBloc: syncBloc,
    );

    return FinanceBundle(
      repository: repository,
      syncService: sync,
      localDataSource: local,
      syncBloc: syncBloc,
      financeBloc: financeBloc,
    );
  }
}

class FinanceBundle {
  const FinanceBundle({
    required this.repository,
    required this.syncService,
    required this.localDataSource,
    required this.syncBloc,
    required this.financeBloc,
  });

  final FinanceRepository repository;
  final FinanceSyncService syncService;
  final FinanceLocalDataSource localDataSource;
  final SyncBloc syncBloc;
  final FinanceBloc financeBloc;

  void dispose() {
    financeBloc.close();
    syncBloc.close();
    syncService.dispose();
    localDataSource.dispose();
  }
}
