import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_boilerplate/core/usecases/usecase.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/domain/usecases/get_finance_dashboard.dart';

import '../mocks/mock_finance_repository.dart';

void main() {
  test('GetFinanceDashboard returns dashboard from repository', () async {
    final repo = MockFinanceRepository();
    final useCase = GetFinanceDashboard(repo);

    final result = await useCase(const NoParams());

    expect(result.isRight, isTrue);
    expect(result.right.balance, 100);
    expect(result.right.transactions, isEmpty);
  });
}
