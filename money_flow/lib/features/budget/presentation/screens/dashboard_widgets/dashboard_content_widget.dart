import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/services/budget_onboarding_preference_service.dart';
import '../../../../../shared/widgets/skeleton_widgets.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../providers/budget_setup_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/budget_setup_reminder_card.dart';

import 'bank_accounts_overview_widget.dart';
import 'budget_progress_widget.dart';
import 'daily_overview_widget.dart';
import 'dashboard_header_widget.dart';
import 'recent_transactions_widget.dart';

class DashboardContentWidget extends StatelessWidget {
  const DashboardContentWidget({super.key});

  Future<bool> _shouldShowBudgetReminder(BuildContext context) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return false;
    final userId = user.id;
    final budgetSetupProvider = context.read<BudgetSetupProvider>();
    try {
      final hasCurrentBudget = await budgetSetupProvider.checkExistingBudget();
      if (!context.mounted || context.read<AuthProvider>().user?.id != userId) {
        return false;
      }
      return BudgetOnboardingPreferenceService().shouldShowReminder(
        userId: userId,
        hasCurrentBudget: hasCurrentBudget,
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardLoading = context.select<DashboardProvider, bool>((p) => p.isLoading);
    final expenseLoading = context.select<ExpenseProvider, bool>((p) => p.isLoading);
    final activeUserId = context.select<AuthProvider, int?>((p) => p.user?.id);
    if (dashboardLoading || expenseLoading) {
      return const SafeArea(child: DashboardSkeletonWidget());
    }

    return SafeArea(
      child: Column(
        children: [
          const DashboardHeaderWidget(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BudgetSetupReminderSlot(
                    identity: activeUserId,
                    loadVisibility: () => _shouldShowBudgetReminder(context),
                  ),
                  const BudgetProgressWidget(),
                  const SizedBox(height: 24),
                  const DailyOverviewWidget(),
                  const SizedBox(height: 32),
                  const BankAccountsOverviewWidget(),
                  const SizedBox(height: 32),
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

/// Owns reminder visibility while setup is opened and refreshes it on return.
class BudgetSetupReminderSlot extends StatefulWidget {
  final Object? identity;
  final Future<bool> Function() loadVisibility;
  final Future<void> Function(BuildContext context)? openBudgetSetup;

  const BudgetSetupReminderSlot({
    super.key,
    required this.identity,
    required this.loadVisibility,
    this.openBudgetSetup,
  });

  @override
  State<BudgetSetupReminderSlot> createState() => _BudgetSetupReminderSlotState();
}

class _BudgetSetupReminderSlotState extends State<BudgetSetupReminderSlot> {
  Future<bool>? _visibility;

  @override
  void initState() {
    super.initState();
    _visibility = widget.loadVisibility();
  }

  @override
  void didUpdateWidget(covariant BudgetSetupReminderSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identity != widget.identity) _refresh();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _visibility = widget.loadVisibility();
    });
  }

  Future<void> _openBudgetSetup() async {
    try {
      if (widget.openBudgetSetup != null) {
        await widget.openBudgetSetup!(context);
      } else {
        await Navigator.of(context).pushNamed('/budget-setup');
      }
    } finally {
      if (mounted) _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _visibility,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data != true) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: BudgetSetupReminderCard(onSetupBudget: _openBudgetSetup),
        );
      },
    );
  }
}
