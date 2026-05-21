import '../../../../../core/errors/failures.dart';
import '../../../domain/entities/finance_dashboard.dart';

class FinanceState {
  const FinanceState({
    this.isLoading = false,
    this.isSyncing = false,
    this.dashboard,
    this.failure,
    this.showParticleBurst = false,
    this.rollbackMessage,
  });

  final bool isLoading;
  final bool isSyncing;
  final FinanceDashboard? dashboard;
  final Failure? failure;
  final bool showParticleBurst;
  final String? rollbackMessage;

  FinanceState copyWith({
    bool? isLoading,
    bool? isSyncing,
    FinanceDashboard? dashboard,
    Failure? failure,
    bool clearFailure = false,
    bool? showParticleBurst,
    String? rollbackMessage,
    bool clearRollback = false,
  }) {
    return FinanceState(
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      dashboard: dashboard ?? this.dashboard,
      failure: clearFailure ? null : (failure ?? this.failure),
      showParticleBurst: showParticleBurst ?? this.showParticleBurst,
      rollbackMessage:
          clearRollback ? null : (rollbackMessage ?? this.rollbackMessage),
    );
  }
}
