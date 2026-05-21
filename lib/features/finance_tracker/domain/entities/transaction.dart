import 'transaction_type.dart';

class Transaction {
  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.syncVersion,
    this.isPending = false,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final int createdAtMs;
  final int updatedAtMs;
  final int syncVersion;
  final bool isPending;

  bool get isExpense => type == TransactionType.expense;

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    int? createdAtMs,
    int? updatedAtMs,
    int? syncVersion,
    bool? isPending,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      syncVersion: syncVersion ?? this.syncVersion,
      isPending: isPending ?? this.isPending,
    );
  }
}
