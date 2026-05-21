import 'transaction.dart';

class FinanceDashboard {
  const FinanceDashboard({
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    required this.spendingProgress,
    required this.weeklyTrend,
    required this.transactions,
    required this.monthlyBudget,
  });

  final double balance;
  final double totalIncome;
  final double totalExpense;
  /// 0.0 – 1.0 for arc meter (expense vs budget).
  final double spendingProgress;
  final List<double> weeklyTrend;
  final List<Transaction> transactions;
  final double monthlyBudget;

  FinanceDashboard copyWith({
    double? balance,
    double? totalIncome,
    double? totalExpense,
    double? spendingProgress,
    List<double>? weeklyTrend,
    List<Transaction>? transactions,
    double? monthlyBudget,
  }) {
    return FinanceDashboard(
      balance: balance ?? this.balance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      spendingProgress: spendingProgress ?? this.spendingProgress,
      weeklyTrend: weeklyTrend ?? this.weeklyTrend,
      transactions: transactions ?? this.transactions,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
    );
  }
}
