import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
import '../../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../providers/expense_provider.dart';

class DistributionWidget extends StatelessWidget {
  const DistributionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, CurrencyProvider>(
      builder: (context, expenseProvider, currencyProvider, child) {
        return Column(
          children: [
            // Distribución de Ingresos
            _buildDistributionCard(
              context,
              'Distribución de Ingresos',
              _getMockIncomeDistribution(),
              currencyProvider,
              Colors.green[600]!,
            ),
            const SizedBox(height: 16),
            
            // Distribución de Gastos
            _buildDistributionCard(
              context,
              'Distribución de Gastos',
              expenseProvider.topCategories.take(3).toList(),
              currencyProvider,
              Theme.of(context).colorScheme.error,
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _getMockIncomeDistribution() {
    // Datos simulados para distribución de ingresos
    return [
      {'name': 'Salario', 'amount': 2500000.0, 'percentage': 83.3},
      {'name': 'Freelance', 'amount': 400000.0, 'percentage': 13.3},
      {'name': 'Inversiones', 'amount': 100000.0, 'percentage': 3.3},
    ];
  }

  Widget _buildDistributionCard(BuildContext context, String title, List<dynamic> data, CurrencyProvider currencyProvider, Color accentColor) {
    return GlassmorphismCard(
      style: GlassStyles.light,
      enableHoverEffect: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            if (data.isEmpty)
              Text(
                'Sin datos',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              )
            else
              ...data.map((item) {
                final name = item['name'] as String;
                final amount = item['amount'] as double;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        currencyProvider.formatAmount(amount),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
