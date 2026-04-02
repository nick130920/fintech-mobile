import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/dashboard_provider.dart';
import '../../providers/expense_provider.dart';
import '../../../../../shared/widgets/skeleton_widgets.dart';

import 'bank_accounts_overview_widget.dart';
import 'budget_progress_widget.dart';
import 'daily_overview_widget.dart';
import 'dashboard_header_widget.dart';
import 'recent_transactions_widget.dart';

class DashboardContentWidget extends StatelessWidget {
  const DashboardContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardLoading = context.select<DashboardProvider, bool>((p) => p.isLoading);
    final expenseLoading = context.select<ExpenseProvider, bool>((p) => p.isLoading);
    if (dashboardLoading || expenseLoading) {
      return const SafeArea(child: DashboardSkeletonWidget());
    }

    return SafeArea(
      child: Column(
        children: [
          // Header
          const DashboardHeaderWidget(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Presupuesto Mensual (primera sección como en el diseño)
                  const BudgetProgressWidget(),
                  const SizedBox(height: 24),
                  // Saldo disponible + Gastos de hoy en grid
                  const DailyOverviewWidget(),
                  const SizedBox(height: 32),
                  // Cuentas Bancarias
                  const BankAccountsOverviewWidget(),
                  const SizedBox(height: 32),
                  // Transacciones Recientes
                  const RecentTransactionsWidget(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
