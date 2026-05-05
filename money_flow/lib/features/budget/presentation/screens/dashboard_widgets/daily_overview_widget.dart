import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/expense_provider.dart';
import '../../../../../core/providers/currency_provider.dart';

class DailyOverviewWidget extends StatelessWidget {
  const DailyOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ExpenseProvider, CurrencyProvider, DashboardProvider>(
      builder: (context, expenseProvider, currencyProvider, dashboardProvider, child) {
        final todayExpenses = expenseProvider.todayExpenses;
        final dailyTotal = todayExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

        return Row(
          children: [
            Expanded(
              child: _OverviewCard(
                title: 'Saldo Disponible',
                amount: currencyProvider.formatAmount(dashboardProvider.availableBalance),
                icon: Icons.account_balance_wallet,
                iconColor: Theme.of(context).colorScheme.primary,
                iconBgColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: _OverviewCard(
                title: 'Gastos de Hoy',
                amount: currencyProvider.formatAmount(dailyTotal),
                icon: Icons.shopping_cart,
                iconColor: AppColors.expenseOrange,
                iconBgColor: AppColors.expenseOrange.withValues(alpha: 0.1),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const _OverviewCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      enableHoverEffect: true,
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: AppRadius.allSm,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.inlineGap),
          Text(
            title,
            style: AppTypography.labelMd.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.step1),
          Text(
            amount,
            style: AppTypography.customAmountCard.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
