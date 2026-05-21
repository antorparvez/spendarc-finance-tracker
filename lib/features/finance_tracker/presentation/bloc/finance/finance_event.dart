import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/transaction_type.dart';

sealed class FinanceEvent {}

class FinanceStarted extends FinanceEvent {}

class FinanceRefreshRequested extends FinanceEvent {
  FinanceRefreshRequested({this.silent = false});

  final bool silent;
}

class FinanceTransactionsUpdated extends FinanceEvent {
  FinanceTransactionsUpdated(this.transactions);

  final List<Transaction> transactions;
}

class FinanceSyncStateChanged extends FinanceEvent {
  FinanceSyncStateChanged({required this.isSyncing, required this.completedTick});

  final bool isSyncing;
  final int completedTick;
}

class FinanceAddRequested extends FinanceEvent {
  FinanceAddRequested({
    required this.title,
    required this.amount,
    required this.type,
    this.category = 'general',
  });

  final String title;
  final double amount;
  final TransactionType type;
  final String category;
}

class FinanceDeleteRequested extends FinanceEvent {
  FinanceDeleteRequested(this.id);

  final String id;
}

class FinanceParticleBurstCleared extends FinanceEvent {}
