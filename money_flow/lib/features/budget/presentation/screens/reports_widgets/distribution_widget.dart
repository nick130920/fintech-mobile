import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
import '../../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';

class DistributionWidget extends StatelessWidget {
  const DistributionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ExpenseProvider, CurrencyProvider, IncomeProvider>(
      builder: (context, expenseProvider, currencyProvider, incomeProvider, child) {
        return Column(
          children: [
            // Distribución de Ingresos
            _buildDistributionCard(
              context,
              'Distribución de Ingresos',
              _getIncomeDistribution(incomeProvider),
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

  List<Map<String, dynamic>> _getIncomeDistribution(IncomeProvider incomeProvider) {
    // Calcular distribución real de ingresos del mes actual
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    final monthIncomes = incomeProvider.getIncomesForDateRange(startOfMonth, endOfMonth);
    
    if (monthIncomes.isEmpty) {
      return [];
    }
    
    // Agrupar por fuente
    final Map<String, double> sourceAmounts = {};
    for (var income in monthIncomes) {
      final source = income.source;
      sourceAmounts[source] = (sourceAmounts[source] ?? 0.0) + income.amount;
    }
    
    // Calcular total para porcentajes
    final totalIncome = sourceAmounts.values.fold(0.0, (sum, amount) => sum + amount);
    
    // Convertir a lista de mapas y ordenar por monto descendente
    final distribution = sourceAmounts.entries.map((entry) {
      return {
        'name': entry.key,
        'amount': entry.value,
        'percentage': totalIncome > 0 ? (entry.value / totalIncome) * 100 : 0.0,
      };
    }).toList()..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
    
    // Tomar solo los top 3
    return distribution.take(3).toList();
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
