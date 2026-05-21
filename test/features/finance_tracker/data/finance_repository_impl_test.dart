import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_boilerplate/config/environment.dart';
import 'package:riverpod_boilerplate/config/flavor_config.dart';
import 'package:riverpod_boilerplate/core/storage/local_storage_service.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/data/datasources/finance_local_datasource.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/data/datasources/finance_remote_datasource.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/data/datasources/finance_write_queue.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/data/repositories/finance_repository_impl.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/data/sync/finance_sync_service.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/entities/transaction_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_boilerplate/core/network/base_api_service.dart';
import 'package:riverpod_boilerplate/core/network/dio_client.dart';
import 'package:riverpod_boilerplate/core/services/connectivity_service.dart';

void main() {
  late LocalStorageService storage;
  late FinanceRepositoryImpl repository;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    FlavorConfig.initialize(Environment.dev);
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.create();
    final local = FinanceLocalDataSource(storage);
    final remote = FinanceRemoteDataSource(
      api: BaseApiService(
        DioClient(
          tokenProvider: () async => null,
          connectivityChecker: () async => true,
        ),
      ),
      local: storage,
    );
    final queue = FinanceWriteQueue(storage);
    final sync = FinanceSyncService(
      local: local,
      remote: remote,
      queue: queue,
      connectivity: ConnectivityService(),
      storage: storage,
    );
    repository = FinanceRepositoryImpl(
      local: local,
      queue: queue,
      syncService: sync,
    );
  });

  test('getDashboard loads seeded local cache', () async {
    final result = await repository.getDashboard();
    expect(result.isRight, isTrue);
    expect(result.right.transactions.length, greaterThanOrEqualTo(3));
  });

  test('addTransaction writes to local cache', () async {
    final before = await repository.getDashboard();
    final count = before.right.transactions.length;

    final added = await repository.addTransaction(
      title: 'Test',
      amount: 10,
      type: TransactionType.income,
      category: 'test',
    );

    expect(added.isRight, isTrue);
    final after = await repository.getDashboard();
    expect(after.right.transactions.length, count + 1);
  });
}
