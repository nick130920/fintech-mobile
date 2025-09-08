import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/expense_provider.dart';

class DailyOverviewWidget extends StatelessWidget {
  const DailyOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ExpenseProvider, CurrencyProvider, DashboardProvider>(
      builder: (context, expenseProvider, currencyProvider, dashboardProvider, child) {
        final todayExpenses = expenseProvider.todayExpenses;
        final dailyTotal = todayExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

        return Column(
          children: [
            GlassmorphismCard(
              style: GlassStyles.dynamic,
              enableEntryAnimation: true,
              enableHoverEffect: true,
              child: _buildCardContent(
                context,
                'Gastos de hoy',
                currencyProvider.formatAmount(dailyTotal),
                isNegative: true,
                trendPercentage: dashboardProvider.spendingTrend.abs(),
                isUp: dashboardProvider.spendingTrend > 0,
              ),
            ),
            const SizedBox(height: 16),
            GlassmorphismCard(
              style: GlassStyles.dynamic,
              enableEntryAnimation: true,
              enableHoverEffect: true,
              animationDuration: const Duration(milliseconds: 1000),
              child: _buildCardContent(
                context,
                'Saldo disponible',
                currencyProvider.formatAmount(dashboardProvider.availableBalance),
                isNegative: dashboardProvider.availableBalance < 0,
                trendPercentage: dashboardProvider.incomeTrend.abs(),
                isUp: dashboardProvider.incomeTrend > 0,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardContent(BuildContext context, String title, String amount, {required bool isNegative, double? trendPercentage, bool isUp = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                amount,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (trendPercentage != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isUp ? AppColors.trendUp : AppColors.trendDown).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUp ? Icons.arrow_downward : Icons.arrow_upward,
                      size: 14,
                      color: isUp ? AppColors.trendUp : AppColors.trendDown,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trendPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isUp ? AppColors.trendUp : AppColors.trendDown,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
