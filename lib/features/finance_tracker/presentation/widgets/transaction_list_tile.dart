import 'package:flutter/material.dart';
import 'package:riverpod_boilerplate/core/theme/app_colors.dart';

import '../../domain/entities/transaction.dart';
import '../animations/swipe_delete_transaction.dart';
import 'finance_glass_card.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  final Transaction transaction;
  final VoidCallback onDelete;

  IconData _categoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'food' => Icons.restaurant_rounded,
      'travel' => Icons.directions_car_rounded,
      'work' => Icons.work_rounded,
      _ => Icons.receipt_long_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = !transaction.isExpense;
    final amountColor = isIncome ? AppColors.success : AppColors.error;
    final theme = Theme.of(context);

    final tile = FinanceGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: amountColor.withValues(alpha: 0.12),
          child: Icon(
            _categoryIcon(transaction.category),
            color: amountColor,
            size: 22,
          ),
        ),
        title: Text(
          transaction.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          transaction.category,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (transaction.isPending)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Pending',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.warning,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SwipeDeleteTransaction(
        onDelete: onDelete,
        child: tile,
      ),
    );
  }
}
