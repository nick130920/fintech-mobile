import 'package:flutter/material.dart';
import 'package:money_flow/features/bank_accounts/presentation/widgets/automatic_transactions_stats_widget.dart';

import 'bank_accounts_overview_widget.dart';
import 'budget_progress_widget.dart';
import 'daily_overview_widget.dart';
import 'dashboard_header_widget.dart';
import 'recent_transactions_widget.dart';

class DashboardContentWidget extends StatelessWidget {
  const DashboardContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
                  // Daily Overview Cards
                  const DailyOverviewWidget(),
                  
                  const SizedBox(height: 24),
                  
                  // Budget Progress
                  const BudgetProgressWidget(),
                  
                  const SizedBox(height: 24),
                  
                  // Bank Accounts Overview
                  const BankAccountsOverviewWidget(),
                  
                  const SizedBox(height: 24),
                  
                  // Automatic Transactions Stats
                  const AutomaticTransactionsStatsWidget(),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Transactions
                  const RecentTransactionsWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
