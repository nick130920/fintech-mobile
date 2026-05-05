import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
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
            padding: AppSpacing.cardLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESTE MES',
                  style: AppTypography.customEyebrow,
                ),
                const SizedBox(height: AppSpacing.cardGap),
                Text(
                  currencyProvider.formatAmount(netBalance.abs()),
                  style: AppTypography.customAmountHero.copyWith(
                    color: isPositive
                        ? AppColors.success
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
                Text(
                  isPositive ? 'Superávit' : 'Déficit',
                  style: AppTypography.labelLg.copyWith(
                    color: isPositive
                        ? AppColors.success
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.step5),
                Row(
                  children: [
                    Expanded(
                      child: _buildBalanceItem(
                        context,
                        'Ingresos',
                        monthlyIncome,
                        AppColors.success,
                        currencyProvider,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.cardGap),
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
          style: AppTypography.labelLg.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppSpacing.step1),
        Text(
          currencyProvider.formatAmount(amount),
          style: AppTypography.customAmountCard.copyWith(
            fontSize: 20,
            color: color,
          ),
        ),
      ],
    );
  }
}
