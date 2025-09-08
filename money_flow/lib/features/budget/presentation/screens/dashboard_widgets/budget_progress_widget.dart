import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
import '../../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../providers/dashboard_provider.dart';

class BudgetProgressWidget extends StatelessWidget {
  const BudgetProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CurrencyProvider, DashboardProvider>(
      builder: (context, currencyProvider, dashboardProvider, child) {
        return GlassmorphismCard(
          style: GlassStyles.medium,
          enableEntryAnimation: true,
          enableHoverEffect: true,
          animationDuration: const Duration(milliseconds: 1200),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Presupuesto Mensual',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  Text(
                    '${currencyProvider.formatAmount(dashboardProvider.budgetSpent)} / ${currencyProvider.formatAmount(dashboardProvider.budgetTotal)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: dashboardProvider.budgetProgressValue.clamp(0.0, 1.0),
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    dashboardProvider.getBudgetStatusIcon(),
                    size: 16,
                    color: dashboardProvider.getBudgetStatusColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dashboardProvider.getBudgetStatusMessage(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: dashboardProvider.getBudgetStatusColor(),
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
}
