import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/gradient_body.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../animations/arc_meter_widget.dart';
import '../animations/line_chart_widget.dart';
import '../animations/particle_burst.dart';
import '../bloc/finance/finance_bloc.dart';
import '../bloc/finance/finance_event.dart';
import '../bloc/finance/finance_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/finance_glass_card.dart';
import '../widgets/transaction_list_tile.dart';
import 'add_transaction_page.dart';

class FinanceDashboardPage extends StatefulWidget {
  const FinanceDashboardPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<FinanceDashboardPage> createState() => _FinanceDashboardPageState();
}

class _FinanceDashboardPageState extends State<FinanceDashboardPage> {
  final _burstOrigin = const Offset(200, 120);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FinanceBloc>().add(FinanceStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FinanceBloc, FinanceState>(
      listenWhen: (p, c) =>
          p.showParticleBurst != c.showParticleBurst ||
          p.rollbackMessage != c.rollbackMessage,
      listener: (context, state) {
        if (state.rollbackMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('finance.rollback'.tr()),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (!state.showParticleBurst) return;
        Future.delayed(const Duration(milliseconds: 750), () {
          if (context.mounted) {
            context.read<FinanceBloc>().add(FinanceParticleBurstCleared());
          }
        });
      },
      builder: (context, state) {
        final content = ParticleBurstOverlay(
          active: state.showParticleBurst,
          origin: _burstOrigin,
          child: _buildBody(context, state),
        );

        if (widget.embedded) {
          return GradientBody(
            padding: EdgeInsets.zero,
            useSafeArea: false,
            child: Column(
              children: [
                _EmbeddedHeader(
                  isSyncing: state.isSyncing,
                  onAdd: () => showAddTransactionSheet(context),
                  onSettings: () => showSettingsSheet(context),
                ),
                Expanded(child: content),
              ],
            ),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('finance.title'.tr()),
            actions: [
              if (state.isSyncing) const _SyncBadge(),
              IconButton(
                onPressed: () => showSettingsSheet(context),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddTransactionSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: Text('finance.add'.tr()),
          ),
          body: GradientBody(
            padding: EdgeInsets.zero,
            useSafeArea: false,
            child: content,
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FinanceState state) {
    if (state.isLoading && state.dashboard == null) {
      return const Center(child: AppLoader());
    }
    if (state.failure != null && state.dashboard == null) {
      return AppErrorView(
        message: state.failure!.message,
        onRetry: () =>
            context.read<FinanceBloc>().add(FinanceRefreshRequested()),
      );
    }

    final dashboard = state.dashboard;
    if (dashboard == null) {
      return Center(child: Text('finance.empty'.tr()));
    }

    final topPad = widget.embedded
        ? 8.0
        : MediaQuery.paddingOf(context).top + kToolbarHeight + 8;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FinanceBloc>().add(FinanceRefreshRequested());
        await context.read<FinanceBloc>().stream.firstWhere(
              (s) => !s.isLoading,
            );
      },
      edgeOffset: topPad,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, topPad, 16, widget.embedded ? 24 : 96),
        children: [
          BalanceCard(
            balance: dashboard.balance,
            income: dashboard.totalIncome,
            expense: dashboard.totalExpense,
          ),
          const SizedBox(height: 16),
          FinanceGlassCard(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Center(
              child: ArcMeterWidget(
                progress: dashboard.spendingProgress,
                label:
                    '${(dashboard.spendingProgress * 100).toStringAsFixed(0)}% ${'finance.spending'.tr()}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          FinanceGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.show_chart_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'finance.weekly_trend'.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LineChartWidget(values: dashboard.weeklyTrend),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'finance.transactions'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 10),
          if (dashboard.transactions.isEmpty)
            FinanceGlassCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text('finance.empty'.tr()),
                ),
              ),
            )
          else
            ...dashboard.transactions.map(
              (tx) => TransactionListTile(
                transaction: tx,
                onDelete: () => context
                    .read<FinanceBloc>()
                    .add(FinanceDeleteRequested(tx.id)),
              ),
            ),
        ],
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text('finance.syncing'.tr()),
        visualDensity: VisualDensity.compact,
        backgroundColor: AppColors.glassSurface(Theme.of(context).brightness),
      ),
    );
  }
}

class _EmbeddedHeader extends StatelessWidget {
  const _EmbeddedHeader({
    required this.isSyncing,
    required this.onAdd,
    required this.onSettings,
  });

  final bool isSyncing;
  final VoidCallback onAdd;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 8,
        left: 16,
        right: 8,
        bottom: 4,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.glassSurface(Theme.of(context).brightness),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.glassBorder(Theme.of(context).brightness),
              ),
            ),
            child: Icon(
              Icons.savings_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'finance.title'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (isSyncing)
                  Text(
                    'finance.syncing'.tr(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton.filled(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
