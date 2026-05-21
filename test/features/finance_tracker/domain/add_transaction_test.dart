import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/entities/transaction_type.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/add_transaction.dart';

import '../mocks/mock_finance_repository.dart';

void main() {
  test('AddTransaction persists via repository', () async {
    final repo = MockFinanceRepository();
    final useCase = AddTransaction(repo);

    final result = await useCase(
      const AddTransactionParams(
        title: 'Coffee',
        amount: 4.5,
        type: TransactionType.expense,
      ),
    );

    expect(result.isRight, isTrue);
    expect(result.right.title, 'Coffee');
  });
}
