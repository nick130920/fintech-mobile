import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
import '../../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../providers/expense_provider.dart';

class RecentTransactionsWidget extends StatelessWidget {
  const RecentTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Column(
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
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/expense-history'),
                  child: Text(
                    'Ver Todas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.recentExpenses.isEmpty)
              _buildEmptyTransactions(context)
            else
              Column(
                children: provider.recentExpenses.take(3).map((expense) {
                  final index = provider.recentExpenses.indexOf(expense);
                  return GlassmorphismListItem(
                    key: ValueKey(expense.id),
                    index: index,
                    enableSlideAnimation: true,
                    enableHoverEffect: true,
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: expense.category.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        expense.category.iconData,
                        color: expense.category.color,
                        size: 22,
                      ),
                    ),
                    title: Text(expense.description),
                    subtitle: Text(expense.category.name),
                    trailing: Consumer<CurrencyProvider>(
                      builder: (context, currencyProvider, child) {
                        return Text(
                          '-${currencyProvider.formatAmount(expense.amount)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      _showExpenseDetailsBottomSheet(context, expense);
                    },
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  void _showExpenseDetailsBottomSheet(BuildContext context, expense) {
    final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con categoría
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: expense.category.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(
                          expense.category.iconData,
                          color: expense.category.color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.description,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              expense.category.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Monto
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monto',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          '-${currencyProvider.formatAmount(expense.amount)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Detalles
                  _buildDetailRow(
                    context,
                    Icons.calendar_today,
                    'Fecha',
                    DateFormat('dd/MM/yyyy').format(
                      expense.date is String 
                        ? DateTime.parse(expense.date)
                        : expense.date
                    ),
                  ),
                  
                  if (expense.location != null && expense.location!.isNotEmpty)
                    _buildDetailRow(
                      context,
                      Icons.location_on,
                      'Ubicación',
                      expense.location!,
                    ),
                  
                  if (expense.merchant != null && expense.merchant!.isNotEmpty)
                    _buildDetailRow(
                      context,
                      Icons.store,
                      'Comercio',
                      expense.merchant!,
                    ),
                  
                  if (expense.notes != null && expense.notes!.isNotEmpty)
                    _buildDetailRow(
                      context,
                      Icons.note,
                      'Notas',
                      expense.notes!,
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showDeleteConfirmation(context, expense);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Eliminar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                            side: BorderSide(color: Theme.of(context).colorScheme.error),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushNamed(
                              '/add-expense',
                              arguments: expense,
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Gasto'),
        content: Text('¿Estás seguro de que deseas eliminar "${expense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<ExpenseProvider>(context, listen: false);
              
              try {
                await provider.deleteExpense(expense.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gasto eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
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
