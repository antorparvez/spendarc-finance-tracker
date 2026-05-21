import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_boilerplate/core/localization/locale_cubit.dart';
import 'package:riverpod_boilerplate/core/localization/supported_locales.dart';
import 'package:riverpod_boilerplate/core/theme/theme_cubit.dart';
import 'package:riverpod_boilerplate/core/widgets/app_bottom_sheet.dart';
import 'package:riverpod_boilerplate/shared/di/app_dependencies.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return showAppBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    title: 'app.settings'.tr(),
    maxHeightFactor: 0.5,
    child: const SettingsPanel(),
  );
}

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeModeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final haptic = context.read<AppDependencies>().haptic;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'app.theme'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('app.system'.tr()),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('app.light'.tr()),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('app.dark'.tr()),
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (selection) async {
                  await haptic.selectionClick();
                  if (!context.mounted) return;
                  await context.read<ThemeModeCubit>().setThemeMode(
                    selection.first,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'app.language'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'en', label: Text('app.english'.tr())),
                  ButtonSegment(value: 'bn', label: Text('app.bangla'.tr())),
                ],
                selected: {locale.languageCode},
                onSelectionChanged: (selection) async {
                  final code = selection.first;
                  final selectedLocale = SupportedLocales.values.firstWhere(
                    (item) => item.languageCode == code,
                  );
                  await haptic.selectionClick();
                  if (!context.mounted) return;
                  await context.read<LocaleCubit>().setLocale(selectedLocale);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.hasData
                    ? '${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                    : '...';
                return ListTile(
                  title: Text('app.version'.tr()),
                  subtitle: Text(
                    version,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
