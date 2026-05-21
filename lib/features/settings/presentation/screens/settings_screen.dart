import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_boilerplate/core/localization/locale_cubit.dart';
import 'package:riverpod_boilerplate/core/localization/supported_locales.dart';
import 'package:riverpod_boilerplate/core/theme/app_colors.dart';
import 'package:riverpod_boilerplate/core/theme/theme_cubit.dart';
import 'package:riverpod_boilerplate/core/widgets/glass_background.dart';
import 'package:riverpod_boilerplate/core/widgets/gradient_body.dart';
import 'package:riverpod_boilerplate/shared/di/app_dependencies.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key, this.showTitle = true});

  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeModeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final haptic = context.read<AppDependencies>().haptic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassPrimaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final glassSecondaryText = isDark
        ? Colors.white70
        : AppColors.textSecondary;
    final segmentStyle = ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(glassPrimaryText),
      textStyle: WidgetStatePropertyAll(
        Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );

    return ListView(
      padding: EdgeInsets.zero,
      children: [
         SizedBox(height: MediaQuery.of(context).padding.top),
        if (showTitle) ...[
          Text(
            'app.settings'.tr(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
        ],
        Text(
          'app.theme'.tr(),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: glassPrimaryText),
        ),
        const SizedBox(height: 8),
        GlassBackground(
          color: AppColors.surface.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SegmentedButton<ThemeMode>(
              style: segmentStyle,
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
                final themeCubit = context.read<ThemeModeCubit>();
                await haptic.selectionClick();
                await themeCubit.setThemeMode(selection.first);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'app.language'.tr(),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: glassPrimaryText),
        ),
        const SizedBox(height: 8),
        GlassBackground(
          color: AppColors.surface.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SegmentedButton<String>(
              style: segmentStyle,
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
                final localeCubit = context.read<LocaleCubit>();
                await haptic.selectionClick();
                await localeCubit.setLocale(selectedLocale);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        GlassBackground(
          color: AppColors.surface.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          child: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.hasData
                  ? '${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                  : '...';
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                title: Text(
                  'app.version'.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: glassPrimaryText),
                ),
                subtitle: Text(
                  version,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: glassSecondaryText),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('app.settings'.tr())),
      body: GradientBody(child: const SettingsPanel()),
    );
  }
}
