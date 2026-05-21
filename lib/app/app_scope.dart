import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/localization/locale_cubit.dart';
import '../core/theme/theme_cubit.dart';
import '../features/finance_tracker/finance_tracker_di.dart';
import '../features/sample_api/sample_api_di.dart';
import '../shared/di/app_dependencies.dart';
import '../shared/di/service_locator.dart';

class AppScope {
  AppScope._();

  static Widget wrap({
    required AppDependencies dependencies,
    required Widget child,
  }) {
    final bundle = getIt<FinanceBundle>();

    return RepositoryProvider<AppDependencies>.value(
      value: dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeModeCubit(dependencies.localStorage)),
          BlocProvider(create: (_) => LocaleCubit(dependencies.localStorage)),
          BlocProvider(
            create: (_) => SampleApiDi.createCubit(dependencies.apiService),
          ),
          BlocProvider.value(value: bundle.syncBloc),
          BlocProvider.value(value: bundle.financeBloc),
        ],
        child: child,
      ),
    );
  }

  static Widget wrapForTest({
    required AppDependencies dependencies,
    required Widget child,
  }) {
    return RepositoryProvider<AppDependencies>.value(
      value: dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => SampleApiDi.createCubit(dependencies.apiService),
          ),
        ],
        child: child,
      ),
    );
  }
}
