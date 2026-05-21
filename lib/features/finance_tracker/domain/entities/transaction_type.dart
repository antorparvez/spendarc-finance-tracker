enum TransactionType {
  income,
  expense;

  bool get isIncome => this == TransactionType.income;
}
