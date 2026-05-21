import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/flavor_config.dart';
import '../core/localization/locale_cubit.dart';
import '../core/routing/app_router.dart';
import '../core/system/system_ui_config.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  Brightness? _lastAppliedBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncSystemUi();
    }
  }

  void _syncSystemUi() {
    final mode = context.read<ThemeModeCubit>().state;
    final brightness = switch (mode) {
      ThemeMode.dark => Brightness.dark,
      ThemeMode.light => Brightness.light,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };
    SystemUiConfig.apply(brightness);
  }

  @override
  Widget build(BuildContext context) {
    final config = FlavorConfig.config;

    return BlocListener<LocaleCubit, Locale>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, locale) {
        if (context.locale != locale) {
          context.setLocale(locale);
        }
      },
      child: BlocListener<ThemeModeCubit, ThemeMode>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            SystemUiConfig.apply(Theme.of(context).brightness);
          });
        },
        child: BlocBuilder<ThemeModeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: config.appName,
                  theme: AppTheme.light(),
                  darkTheme: AppTheme.dark(),
                  themeMode: themeMode,
                  routerConfig: appRouter,
                  locale: locale,
                  supportedLocales: context.supportedLocales,
                  localizationsDelegates: context.localizationDelegates,
                  builder: (context, child) {
                    final brightness = Theme.of(context).brightness;
                    if (_lastAppliedBrightness != brightness) {
                      _lastAppliedBrightness = brightness;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        SystemUiConfig.apply(brightness);
                      });
                    }
                    return AnnotatedRegion<SystemUiOverlayStyle>(
                      value: SystemUiConfig.overlayStyleFor(brightness),
                      child: child ?? const SizedBox.shrink(),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
