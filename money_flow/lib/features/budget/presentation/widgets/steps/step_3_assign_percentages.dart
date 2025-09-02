import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
import '../../../data/models/category_model.dart';
import '../../providers/budget_setup_provider.dart';

class Step3AssignPercentages extends StatelessWidget {
  const Step3AssignPercentages({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSetupProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).viewInsets.bottom - 200,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Encabezado
              Row(
                children: [
                  const Icon(
                    Icons.pie_chart,
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '¿Cómo quieres repartir tu dinero?',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ajusta los porcentajes deslizando. Te sugerimos valores basados en recomendaciones financieras.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Indicador del total
              _buildTotalIndicator(provider),

              const SizedBox(height: 24),

              // Lista de categorías con sliders
              SizedBox(
                height: 300, // Altura fija para la lista
                child: ListView.separated(
                  itemCount: provider.selectedCategories.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final category = provider.selectedCategories[index];
                    final percentage = provider.categoryPercentages[category.id] ?? 0.0;
                    final amount = provider.getCategoryAmount(category.id);
                    
                    return _buildCategorySlider(
                      context,
                      category,
                      percentage,
                      amount,
                      provider,
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Botón para resetear a valores recomendados
              Center(
                child: TextButton.icon(
                  onPressed: () => _resetToRecommended(provider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Usar valores recomendados'),
                ),
              ),

              const SizedBox(height: 24),

              // Botón finalizar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.canProceedFromStep3 
                      ? () => _showConfirmationDialog(context, provider)
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Crear Presupuesto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalIndicator(BudgetSetupProvider provider) {
    final isComplete = provider.totalPercentage == 100.0;
    final isOver = provider.totalPercentage > 100.0;
    
    Color indicatorColor;
    String message;
    
    if (isComplete) {
      indicatorColor = Colors.green;
      message = '¡Perfecto! Suman exactamente 100%';
    } else if (isOver) {
      indicatorColor = Colors.red;
      message = 'Te has pasado del 100%. Ajusta los valores.';
    } else {
      indicatorColor = Colors.orange;
      message = 'Te faltan ${(100 - provider.totalPercentage).toStringAsFixed(1)}% por asignar';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: indicatorColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total asignado',
                style: TextStyle(
                  fontSize: 14,
                  color: indicatorColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${provider.totalPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 20,
                  color: indicatorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: provider.totalPercentage / 100,
            backgroundColor: indicatorColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: indicatorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySlider(
    BuildContext context,
    CategoryModel category,
    double percentage,
    double amount,
    BudgetSetupProvider provider,
  ) {
    final categoryColor = category.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icono y nombre
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    category.iconData,
                    color: categoryColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Consumer<CurrencyProvider>(
                      builder: (context, currencyProvider, child) {
                        final amount = provider.getCategoryAmount(category.id);
                        return Text(
                          currencyProvider.formatAmount(amount),
                          style: TextStyle(
                            fontSize: 14,
                            color: categoryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: categoryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: categoryColor,
              inactiveTrackColor: categoryColor.withValues(alpha: 0.2),
              thumbColor: categoryColor,
              overlayColor: categoryColor.withValues(alpha: 0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: percentage,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (value) {
                provider.setCategoryPercentage(category.id, value);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _resetToRecommended(BudgetSetupProvider provider) {
    // Resetear a valores recomendados basados en las categorías seleccionadas
    for (final category in provider.selectedCategories) {
      final recommendedPercentage = CategoryModel.defaultPercentages[category.id];
      if (recommendedPercentage != null) {
        provider.setCategoryPercentage(category.id, recommendedPercentage);
      }
    }
  }

  void _showConfirmationDialog(BuildContext context, BudgetSetupProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Crear este presupuesto?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<CurrencyProvider>(
              builder: (context, currencyProvider, child) {
                return Text(
                  'Presupuesto total: ${currencyProvider.formatAmount(provider.totalAmount)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'Categorías:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...provider.selectedCategories.map((category) {
              final percentage = provider.categoryPercentages[category.id]!;
              final amount = provider.getCategoryAmount(category.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(category.iconData, size: 16, color: category.color),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                    Consumer<CurrencyProvider>(
                      builder: (context, currencyProvider, child) {
                        return Text(
                          '${percentage.toStringAsFixed(0)}% (${currencyProvider.formatAmount(amount)})',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.completeBudgetSetup();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
