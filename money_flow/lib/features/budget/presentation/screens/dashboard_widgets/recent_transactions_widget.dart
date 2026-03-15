import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/expense_provider.dart';
import '../reports_widgets/expense_list_item_widget.dart';

class RecentTransactionsWidget extends StatelessWidget {
  const RecentTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transacciones Recientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/expense-history'),
                      child: Text(
                        'Ver todas',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.tune,
                      size: 22,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.isLoading && !provider.hasCachedData)
              const Center(child: CircularProgressIndicator())
            else if (provider.recentExpenses.isEmpty)
              _buildEmptyTransactions(context)
            else
              Column(
                children: provider.recentExpenses.take(3).map((expense) {
                  final index = provider.recentExpenses.indexOf(expense);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ExpenseListItemWidget(
                      key: ValueKey(expense.id),
                      expense: expense,
                      provider: provider,
                      index: index,
                      compact: true,
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyTransactions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay transacciones aún',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza a rastrear tus gastos',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
