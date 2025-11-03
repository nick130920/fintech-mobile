import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
import '../../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';

class BalanceOverviewWidget extends StatelessWidget {
  const BalanceOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer4<ExpenseProvider, CurrencyProvider, DashboardProvider, IncomeProvider>(
      builder: (context, expenseProvider, currencyProvider, dashboardProvider, incomeProvider, child) {
        // Datos reales del mes actual
        final monthlyIncome = incomeProvider.currentMonthIncome;
        final monthlyExpenses = expenseProvider.monthlyTotal;
        final netBalance = monthlyIncome - monthlyExpenses;
        final isPositive = netBalance > 0;
        
        return GlassmorphismCard(
          style: GlassStyles.medium,
          enableHoverEffect: true,
          enableEntryAnimation: true,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Este Mes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Balance Neto Principal
                Text(
                  currencyProvider.formatAmount(netBalance.abs()),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isPositive 
                      ? Colors.green[600] 
                      : Theme.of(context).colorScheme.error,
                  ),
                ),
                Text(
                  isPositive ? 'Superávit' : 'Déficit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isPositive 
                      ? Colors.green[600] 
                      : Theme.of(context).colorScheme.error,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Desglose Ingresos vs Gastos
                Row(
                  children: [
                    Expanded(
                      child: _buildBalanceItem(
                        context,
                        'Ingresos',
                        monthlyIncome,
                        Colors.green[600]!,
                        currencyProvider,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBalanceItem(
                        context,
                        'Gastos',
                        monthlyExpenses,
                        Theme.of(context).colorScheme.error,
                        currencyProvider,
                      ),
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

  Widget _buildBalanceItem(BuildContext context, String title, double amount, Color color, CurrencyProvider currencyProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          currencyProvider.formatAmount(amount),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
