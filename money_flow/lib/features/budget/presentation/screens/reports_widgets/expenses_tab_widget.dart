import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/expense_provider.dart';
import 'expense_list_item_widget.dart';

class ExpensesTabWidget extends StatelessWidget {
  const ExpensesTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, CurrencyProvider>(
      builder: (context, expenseProvider, currencyProvider, child) {
        if (expenseProvider.isLoading && expenseProvider.expenses.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: expenseProvider.refresh,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Selector de período
                _buildPeriodSelector(context),
                const SizedBox(height: 24),
                
                // Contenido de gastos (movido desde Overview)
                _buildExpensesSpendingSection(context),
                
                const SizedBox(height: 24),
                
                // Lista de gastos recientes
                if (expenseProvider.expenses.isNotEmpty) ...[
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
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('/expense-history'),
                        child: const Text('Ver Todas'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...expenseProvider.expenses.take(5).map((expense) {
                    final index = expenseProvider.expenses.indexOf(expense);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ExpenseListItemWidget(
                        expense: expense,
                        provider: expenseProvider,
                        index: index,
                      ),
                    );
                  }).toList(),
                ] else
                  _buildExpensesEmptyState(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Gastos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              _buildPeriodButton(context, 'Mensual', true),
              _buildPeriodButton(context, 'Anual', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(BuildContext context, String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected 
          ? Theme.of(context).colorScheme.surface
          : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected
          ? [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected 
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildExpensesSpendingSection(BuildContext context) {
    return Consumer2<ExpenseProvider, CurrencyProvider>(
      builder: (context, expenseProvider, currencyProvider, child) {
        final monthlyTotal = expenseProvider.monthlyTotal;
        final topCategories = expenseProvider.topCategories.take(3).toList();
        
        return LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            
            if (isTablet) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildThisMonthCard(context, monthlyTotal, topCategories, currencyProvider),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMonthlyProgressCard(context, currencyProvider),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildThisMonthCard(context, monthlyTotal, topCategories, currencyProvider),
                  const SizedBox(height: 16),
                  _buildMonthlyProgressCard(context, currencyProvider),
                ],
              );
            }
          },
        );
      },
    );
  }

  Widget _buildThisMonthCard(BuildContext context, double monthlyTotal, List<dynamic> topCategories, CurrencyProvider currencyProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Este Mes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Icon(
                Icons.more_horiz,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currencyProvider.formatAmount(monthlyTotal),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 32),
          _buildDonutChart(context, monthlyTotal),
          const SizedBox(height: 32),
          _buildCategoryLegend(context, topCategories, currencyProvider),
        ],
      ),
    );
  }

  Widget _buildDonutChart(BuildContext context, double total) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final topCategories = expenseProvider.topCategories.take(3).toList();
        
        // Si no hay datos, mostrar gráfico vacío
        if (total == 0 || topCategories.isEmpty) {
          return Center(
            child: Container(
              height: 192,
              width: 192,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  width: 12,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sin datos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Center(
          child: SizedBox(
            height: 192,
            width: 192,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Círculo de fondo
                SizedBox(
                  width: 192,
                  height: 192,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                // Generar segmentos dinámicamente
                ...topCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final categoryAmount = category['amount'] as double;
                  final percentage = categoryAmount / total;
                  
                  // Usar color de la categoría guardado en BD
                  final color = category['category']?.color ?? Theme.of(context).colorScheme.primary;
                  
                  // Calcular rotación acumulativa
                  double rotationOffset = 0;
                  for (int i = 0; i < index; i++) {
                    final prevAmount = topCategories[i]['amount'] as double;
                    rotationOffset += (prevAmount / total) * 2 * 3.14159; // 2π
                  }
                  
                  return SizedBox(
                    width: 192,
                    height: 192,
                    child: Transform.rotate(
                      angle: rotationOffset,
                      child: CircularProgressIndicator(
                        value: percentage,
                        strokeWidth: 12,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  );
                }).toList(),
                // Centro del gráfico
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total Gastos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Consumer<CurrencyProvider>(
                      builder: (context, currencyProvider, child) {
                        return Text(
                          currencyProvider.formatAmount(total),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryLegend(BuildContext context, List<dynamic> categories, CurrencyProvider currencyProvider) {
    // Si no hay categorías, mostrar mensaje vacío
    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay gastos este mes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              'Comienza a registrar tus gastos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: categories.map((category) {
        final categoryName = category['name'] as String;
        final amount = category['amount'] as double;
        final categoryModel = category['category'];
        
        // Usar color de la categoría guardado en BD
        final categoryColor = categoryModel?.color ?? Theme.of(context).colorScheme.primary;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: categoryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                currencyProvider.formatAmount(amount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyProgressCard(BuildContext context, CurrencyProvider currencyProvider) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso Mensual',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Icon(
                    Icons.more_horiz,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Mostrar progreso del presupuesto o mensaje si no hay presupuesto
              if (dashboardProvider.budgetTotal > 0) ...[
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: currencyProvider.formatAmount(dashboardProvider.budgetSpent),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${currencyProvider.formatAmount(dashboardProvider.budgetTotal)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Barra de progreso general
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: dashboardProvider.budgetProgressValue.clamp(0.0, 1.0),
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        dashboardProvider.isOverBudget 
                          ? Theme.of(context).colorScheme.error
                          : dashboardProvider.isNearingLimit 
                            ? Colors.orange
                            : Theme.of(context).colorScheme.primary
                      ),
                      minHeight: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Estado del presupuesto
                Row(
                  children: [
                    Icon(
                      dashboardProvider.getBudgetStatusIcon(),
                      size: 16,
                      color: dashboardProvider.getBudgetStatusColor(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dashboardProvider.getBudgetStatusMessage(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: dashboardProvider.getBudgetStatusColor(),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(dashboardProvider.budgetProgressValue * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Mensaje cuando no hay presupuesto configurado
                Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay presupuesto configurado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configura tu presupuesto mensual para ver el progreso',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/budget-setup');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Configurar Presupuesto'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpensesEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay gastos registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza registrando tu primer gasto',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/add-expense'),
            icon: const Icon(Icons.add),
            label: const Text('Registrar Gasto'),
          ),
        ],
      ),
    );
  }
}
