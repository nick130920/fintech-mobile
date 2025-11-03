import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
import '../../providers/income_provider.dart';
import 'income_list_item_widget.dart';

class IncomeTabWidget extends StatelessWidget {
  const IncomeTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<IncomeProvider, CurrencyProvider>(
      builder: (context, incomeProvider, currencyProvider, child) {
        if (incomeProvider.isLoading && incomeProvider.incomes.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: incomeProvider.refresh,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPeriodSelector(context),
                const SizedBox(height: 24),
                _buildIncomeSummarySection(context),
                const SizedBox(height: 24),
                if (incomeProvider.incomes.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ingresos Recientes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('/income-history'),
                        child: const Text('Ver Todos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...incomeProvider.incomes.take(5).map((income) {
                    final index = incomeProvider.incomes.indexOf(income);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: IncomeListItemWidget(
                        income: income,
                        provider: incomeProvider,
                        index: index,
                      ),
                    );
                  }),
                ] else
                  _buildIncomesEmptyState(context),
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
          'Ingresos',
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
        color: isSelected ? Theme.of(context).colorScheme.surface : Colors.transparent,
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

  Widget _buildIncomeSummarySection(BuildContext context) {
    return Consumer<IncomeProvider>(
      builder: (context, incomeProvider, child) {
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
                    'Total Ingresos (Mensual)',
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
                incomeProvider.formattedTotalIncome,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Promedio Mensual',
                      incomeProvider.formattedMonthlyAverage,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomesEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay ingresos registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza registrando tu primer ingreso',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/add-income'),
            icon: const Icon(Icons.add),
            label: const Text('Registrar Ingreso'),
          ),
        ],
      ),
    );
  }
}
