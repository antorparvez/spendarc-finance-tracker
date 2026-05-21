import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../domain/entities/transaction_type.dart';
import '../bloc/finance/finance_bloc.dart';
import '../bloc/finance/finance_event.dart';

Future<void> showAddTransactionSheet(BuildContext context) {
  final financeBloc = context.read<FinanceBloc>();
  return showAppBottomSheet<void>(
    context: context,
    title: 'finance.add'.tr(),
    maxHeightFactor: 0.75,
    child: BlocProvider.value(
      value: financeBloc,
      child: const AddTransactionSheet(),
    ),
  );
}

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (title.isEmpty || amount <= 0) return;

    setState(() => _submitting = true);
    context.read<FinanceBloc>().add(
          FinanceAddRequested(title: title, amount: amount, type: _type),
        );
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'finance.title_hint'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: 'finance.title_hint'.tr()),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'finance.amount_hint'.tr()),
          ),
          const SizedBox(height: 18),
          SegmentedButton<TransactionType>(
            segments: [
              ButtonSegment(
                value: TransactionType.expense,
                label: Text('finance.expense_type'.tr()),
                icon: const Icon(Icons.arrow_downward_rounded),
              ),
              ButtonSegment(
                value: TransactionType.income,
                label: Text('finance.income_type'.tr()),
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (set) => setState(() => _type = set.first),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text('finance.save'.tr()),
          ),
        ],
      ),
    );
  }
}
