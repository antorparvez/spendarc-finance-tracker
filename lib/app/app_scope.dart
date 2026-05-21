import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/localization/locale_cubit.dart';
import '../core/theme/theme_cubit.dart';
import '../features/home/presentation/cubit/home_nav_cubit.dart';
import '../features/sample_api/sample_api_di.dart';
import '../shared/di/app_dependencies.dart';

/// Root [MultiBlocProvider] and [RepositoryProvider] for the app.
class AppScope {
  AppScope._();

  static Widget wrap({
    required AppDependencies dependencies,
    required Widget child,
  }) {
    return RepositoryProvider<AppDependencies>.value(
      value: dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ThemeModeCubit(dependencies.localStorage),
          ),
          BlocProvider(
            create: (_) => LocaleCubit(dependencies.localStorage),
          ),
          BlocProvider(create: (_) => HomeNavCubit()),
          BlocProvider(
            create: (_) => SampleApiDi.createCubit(dependencies.apiService),
          ),
        ],
        child: child,
      ),
    );
  }

  /// Minimal scope for widget tests (subset of production blocs).
  static Widget wrapForTest({
    required AppDependencies dependencies,
    required Widget child,
  }) {
    return RepositoryProvider<AppDependencies>.value(
      value: dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => HomeNavCubit()),
          BlocProvider(
            create: (_) => SampleApiDi.createCubit(dependencies.apiService),
          ),
        ],
        child: child,
      ),
    );
  }
}
