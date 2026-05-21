import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:riverpod_boilerplate/features/finance_tracker/domain/entities/transaction_type.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/presentation/bloc/finance/finance_event.dart';
import 'package:riverpod_boilerplate/features/finance_tracker/presentation/pages/add_transaction_page.dart';

import '../finance_test_helpers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Add transaction sheet wires form fields to FinanceBloc', (tester) async {
    final harness = FinanceTestHarness.create();
    await harness.loadDashboard();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: harness.financeBloc,
          child: const Scaffold(body: AddTransactionSheet()),
        ),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    harness.financeBloc.add(
      FinanceAddRequested(
        title: 'Lunch',
        amount: 12.5,
        type: TransactionType.expense,
      ),
    );
    await tester.pump();

    expect(harness.repository.transactionCount, 1);
  });
}
