import 'package:get_it/get_it.dart';

import '../../features/finance_tracker/finance_tracker_di.dart';
import 'app_dependencies.dart';

final getIt = GetIt.instance;

void setupServiceLocator(AppDependencies dependencies) {
  getIt.registerLazySingleton<FinanceBundle>(
    () => FinanceTrackerDi.create(
      localStorage: dependencies.localStorage,
      apiService: dependencies.apiService,
      connectivity: dependencies.connectivity,
    ),
  );
}

Future<void> disposeServiceLocator() async {
  if (getIt.isRegistered<FinanceBundle>()) {
    getIt<FinanceBundle>().dispose();
  }
  await getIt.reset();
}
