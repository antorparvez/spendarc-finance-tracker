import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:riverpod_boilerplate/features/finance_tracker/presentation/widgets/balance_card.dart';

void main() {
  testWidgets('Balance card shows formatted amounts', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BalanceCard(
            balance: 100,
            income: 200,
            expense: 100,
          ),
        ),
      ),
    );

    expect(find.textContaining('\$100.00'), findsWidgets);
    expect(find.textContaining('\$200.00'), findsOneWidget);
  });
}
