import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/custom_snackbar.dart';
import '../../data/models/trip_models.dart';
import '../providers/active_trip_provider.dart';
import 'add_trip_expense_screen.dart';

class TripExpensesScreen extends StatelessWidget {
  final int tripId;
  const TripExpensesScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveTripProvider>(
      builder: (context, provider, _) {
        final trip = provider.trip;
        final expenses = provider.expenses;
        if (trip == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final dateFormat = DateFormat('d MMM y', 'es');
        final amountFormat = NumberFormat.currency(
          name: trip.primaryCurrency,
          symbol: '${trip.primaryCurrency} ',
          decimalDigits: 2,
        );

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addExpense(context, trip),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo gasto'),
          ),
          body: RefreshIndicator(
            onRefresh: () => context.read<ActiveTripProvider>().load(tripId),
            child: expenses.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Aún no hay gastos en este viaje',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _addExpense(context, trip),
                          icon: const Icon(Icons.add),
                          label: const Text('Registrar primer gasto'),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: expenses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return _ExpenseCard(
                        expense: expense,
                        amountFormat: amountFormat,
                        dateFormat: dateFormat,
                        onDelete: () => _confirmDelete(context, expense),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Future<void> _addExpense(BuildContext context, Trip trip) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddTripExpenseScreen(tripId: trip.id),
      ),
    );
    if (saved == true && context.mounted) {
      await context.read<ActiveTripProvider>().load(trip.id);
    }
  }

  Future<void> _confirmDelete(BuildContext context, TripExpense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: Text('¿Eliminar "${expense.description}" del viaje?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final provider = context.read<ActiveTripProvider>();
    final ok = await provider.removeExpense(expense.id);
    if (!context.mounted) return;
    if (ok) {
      CustomSnackBar.showSuccess(context, 'Gasto eliminado');
    } else {
      CustomSnackBar.showError(
          context, provider.error ?? 'No se pudo eliminar el gasto');
    }
  }
}

class _ExpenseCard extends StatelessWidget {
  final TripExpense expense;
  final NumberFormat amountFormat;
  final DateFormat dateFormat;
  final VoidCallback onDelete;

  const _ExpenseCard({
    required this.expense,
    required this.amountFormat,
    required this.dateFormat,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormat.format(expense.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountFormat.format(expense.amountPrimary),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (expense.currency != amountFormat.currencyName)
                    Text(
                      '${expense.amount.toStringAsFixed(2)} ${expense.currency}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ),
          if (expense.paidByName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6)),
                const SizedBox(width: 4),
                Text(
                  'Pagó: ${expense.paidByName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
          if (expense.splits.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: expense.splits.map((split) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${split.memberName.isEmpty ? 'Miembro' : split.memberName}: '
                    '${split.shareAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
