import '../../domain/entities/finance_dashboard.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../datasources/finance_local_datasource.dart';
import '../models/transaction_model.dart';

class FinanceDashboardMapper {
  const FinanceDashboardMapper._();

  static FinanceDashboard fromModels(List<TransactionModel> models) {
    final entities = models.map((m) => m.toEntity()).toList();
    double income = 0;
    double expense = 0;
    for (final t in entities) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    final budget = FinanceLocalDataSource.defaultMonthlyBudget;
    final progress = budget <= 0 ? 0.0 : (expense / budget).clamp(0.0, 1.0);

    return FinanceDashboard(
      balance: income - expense,
      totalIncome: income,
      totalExpense: expense,
      spendingProgress: progress,
      weeklyTrend: _weeklyTrend(entities),
      transactions: entities,
      monthlyBudget: budget,
    );
  }

  static List<double> _weeklyTrend(List<Transaction> items) {
    final now = DateTime.now();
    final buckets = List<double>.filled(7, 0);
    for (final t in items) {
      if (!t.isExpense) continue;
      final date = DateTime.fromMillisecondsSinceEpoch(t.createdAtMs);
      final diff = now.difference(date).inDays;
      if (diff < 0 || diff > 6) continue;
      buckets[6 - diff] += t.amount;
    }
    return buckets;
  }
}
