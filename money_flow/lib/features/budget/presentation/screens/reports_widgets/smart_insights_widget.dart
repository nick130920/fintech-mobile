import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../providers/expense_provider.dart';

class SmartInsightsWidget extends StatelessWidget {
  const SmartInsightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final insights = _generateSmartInsights(expenseProvider);
        
        return GlassmorphismCard(
          style: GlassStyles.medium,
          enableHoverEffect: true,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Insights Inteligentes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                ...insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight['emoji'] ?? '💡',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          insight['text'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, String>> _generateSmartInsights(ExpenseProvider expenseProvider) {
    final insights = <Map<String, String>>[];
    
    // Insight sobre gastos vs mes anterior (simulado)
    insights.add({
      'emoji': '📊',
      'text': 'Has gastado 15% menos que el mes pasado. ¡Excelente control financiero!',
    });
    
    // Insight sobre categoría principal
    if (expenseProvider.topCategories.isNotEmpty) {
      final topCategory = expenseProvider.topCategories.first;
      insights.add({
        'emoji': '🏆',
        'text': 'Tu mayor gasto este mes es en ${topCategory['name']}. Representa el ${((topCategory['amount'] / expenseProvider.monthlyTotal) * 100).toStringAsFixed(1)}% de tus gastos.',
      });
    }
    
    // Insight sobre ahorros
    insights.add({
      'emoji': '💰',
      'text': 'Tu saldo disponible está 25% por encima del promedio de los últimos 3 meses.',
    });
    
    // Insight sobre tendencia
    insights.add({
      'emoji': '📈',
      'text': 'Tus gastos tienden a aumentar en la segunda quincena del mes.',
    });
    
    return insights;
  }
}
