import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riverpod_boilerplate/config/app_config.dart';
import 'package:riverpod_boilerplate/core/theme/app_colors.dart';
import 'package:riverpod_boilerplate/core/widgets/app_error_widget.dart';
import 'package:riverpod_boilerplate/core/widgets/app_loader.dart';
import 'package:riverpod_boilerplate/core/widgets/glass_background.dart';
import 'package:riverpod_boilerplate/core/widgets/gradient_body.dart';
import 'package:riverpod_boilerplate/features/home/presentation/cubit/home_nav_cubit.dart';
import 'package:riverpod_boilerplate/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:riverpod_boilerplate/features/sample_api/presentation/cubit/sample_api_cubit.dart';
import 'package:riverpod_boilerplate/features/settings/presentation/screens/settings_screen.dart';

import '../../../../config/flavor_config.dart';
import '../../../sample_api/presentation/providers/sample_api_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.enableAutoLoad = true});

  final bool enableAutoLoad;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryAutoLoad());
  }

  /// Loads sample data once when Home tab is shown and state is still empty.
  void _tryAutoLoad() {
    if (!widget.enableAutoLoad) return;
    if (context.read<HomeNavCubit>().state.currentIndex != 0) return;

    final state = context.read<SampleApiCubit>().state;
    if (state.isLoading || state.item != null || state.failure != null) return;

    context.read<SampleApiCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final config = FlavorConfig.config;

    return BlocListener<HomeNavCubit, HomeNavState>(
      listenWhen: (previous, current) =>
          previous.currentIndex != current.currentIndex,
      listener: (context, state) {
        if (state.currentIndex == 0) {
          _tryAutoLoad();
        }
      },
      child: BlocBuilder<HomeNavCubit, HomeNavState>(
        builder: (context, navState) {
          final selectedIndex = navState.currentIndex;

          return PopScope(
            canPop: !navState.canGoBack,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              context.read<HomeNavCubit>().goBack();
            },
            child: Scaffold(
              body: Stack(
                children: [
                  GradientBody(
                    useSafeArea: false,
                    child: _buildContent(context, config, selectedIndex),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: HomeBottomNav(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppConfig config,
    int selectedIndex,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    if (selectedIndex == 4) {
      return const SettingsPanel(showTitle: true);
    }

    if (selectedIndex == 0) {
      return BlocBuilder<SampleApiCubit, SampleApiState>(
        builder: (context, sampleState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              Text(
                config.appName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              GlassBackground(
                color: AppColors.surface.withValues(alpha: 0.32),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _buildSampleSection(
                    context: context,
                    glassTextColor: glassTextColor,
                    config: config,
                    state: sampleState,
                    onRetry: () => context.read<SampleApiCubit>().load(),
                  ),
                ),
              ),
              const Spacer(),
            ],
          );
        },
      );
    }

    return Center(
      child: GlassBackground(
        color: AppColors.surface.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            HomeBottomNav.tabs[selectedIndex].labelKey.tr(),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: glassTextColor),
          ),
        ),
      ),
    );
  }

  Widget _buildSampleSection({
    required BuildContext context,
    required Color glassTextColor,
    required AppConfig config,
    required SampleApiState state,
    required VoidCallback onRetry,
  }) {
    if (state.isLoading == true) {
      return const Center(child: AppLoader());
    }

    if (state.failure != null) {
      return AppErrorView(
        message: 'app.failed_load_sample'.tr(),
        onRetry: onRetry,
      );
    }

    final item = state.item;
    if (item == null) {
      return Text(
        'app.no_data'.tr(),
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: glassTextColor),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'app.environment'.tr()}: ${config.environment}\n'
          '${'app.base_url'.tr()}: ${config.baseUrl}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: glassTextColor),
        ),
        const SizedBox(height: 12),
        Text(
          'app.sample_api'.tr(),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: glassTextColor),
        ),
        const SizedBox(height: 6),
        Text(
          '${item.title} - \$${item.price.toStringAsFixed(2)}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: glassTextColor),
        ),
        const SizedBox(height: 4),
        Text(
          item.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: glassTextColor.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}
