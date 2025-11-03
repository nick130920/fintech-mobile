import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
import '../../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../../data/models/expense_model.dart';
import '../../providers/expense_provider.dart';

class ExpenseListItemWidget extends StatelessWidget {
  final ExpenseModel expense;
  final ExpenseProvider provider;
  final int index;

  const ExpenseListItemWidget({
    super.key,
    required this.expense,
    required this.provider,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return GlassmorphismListItem(
          enableSlideAnimation: true,
          enableHoverEffect: true,
          index: index,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              expense.category.iconData,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          title: Text(
            expense.description,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    expense.category.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  if (expense.location.isNotEmpty) ...[
                    Text(
                      ' • ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        expense.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                expense.timeAgo,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currencyProvider.formatAmount(expense.amount),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 4),
              if (!expense.isConfirmed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    expense.statusDisplayName,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () => _showExpenseDetails(context, expense, provider),
        );
      },
    );
  }

  void _showExpenseDetails(BuildContext context, ExpenseModel expense, ExpenseProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: expense.category.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              expense.category.iconData,
                              color: expense.category.color,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense.description,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                expense.category.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Consumer<CurrencyProvider>(
                          builder: (context, currencyProvider, child) {
                            return Text(
                              currencyProvider.formatAmount(expense.amount),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Detalles
                    _buildExpenseDetailRow(context, 'Fecha', DateFormat('dd/MM/yyyy HH:mm').format(expense.dateTime)),
                    if (expense.location.isNotEmpty)
                      _buildExpenseDetailRow(context, 'Lugar', expense.location),
                    if (expense.merchant.isNotEmpty)
                      _buildExpenseDetailRow(context, 'Comercio', expense.merchant),
                    _buildExpenseDetailRow(context, 'Fuente', expense.sourceDisplayName),
                    _buildExpenseDetailRow(context, 'Estado', expense.statusDisplayName),
                    if (expense.notes.isNotEmpty)
                      _buildExpenseDetailRow(context, 'Notas', expense.notes),
                    
                    const Spacer(),
                    
                    // Acciones
                    if (expense.canBeModified || expense.canBeCancelled)
                      Row(
                        children: [
                          if (expense.canBeModified)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushNamed(
                                    '/add-expense',
                                    arguments: expense,
                                  );
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Editar'),
                              ),
                            ),
                          if (expense.canBeModified && expense.canBeCancelled)
                            const SizedBox(width: 16),
                          if (expense.canBeCancelled)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _deleteExpense(context, expense.id, provider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                icon: const Icon(Icons.delete),
                                label: const Text('Eliminar'),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExpense(BuildContext context, int expenseId, ExpenseProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Gasto'),
        content: const Text('¿Estás seguro de que quieres eliminar este gasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      Navigator.of(context).pop(); // Cerrar detalles
      
      final success = await provider.deleteExpense(expenseId);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gasto eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
