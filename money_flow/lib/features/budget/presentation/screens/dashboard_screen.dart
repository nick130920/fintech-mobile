import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/currency_provider.dart';
import '../../data/models/expense_model.dart';
import '../providers/dashboard_provider.dart';
import '../providers/expense_provider.dart';

class DashboardScreen extends StatefulWidget {
  final bool useScaffold;
  
  const DashboardScreen({super.key, this.useScaffold = true});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().initialize();
      context.read<DashboardProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily Overview Cards
                  _buildDailyOverview(),
                  
                  const SizedBox(height: 24),
                  
                  // Budget Progress
                  _buildBudgetProgress(),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Transactions
                  _buildRecentTransactions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.useScaffold == false) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: _buildCustomAppBar(),
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildCustomAppBar(),
      body: body,
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'MoneyFlow',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            // Navegación a configuración
          },
          icon: Icon(
            Icons.settings,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyOverview() {
    return Consumer3<ExpenseProvider, CurrencyProvider, DashboardProvider>(
      builder: (context, expenseProvider, currencyProvider, dashboardProvider, child) {
        final todayExpenses = expenseProvider.todayExpenses;
        final dailyTotal = todayExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

        return Column(
          children: [
            _buildMetricCard(
              'Gasto Diario',
              currencyProvider.formatAmount(dailyTotal),
              isNegative: true,
              trendPercentage: dashboardProvider.spendingTrend.abs(),
              isUp: dashboardProvider.spendingTrend > 0,
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              'Balance Disponible',
              currencyProvider.formatAmount(dashboardProvider.availableBalance),
              isNegative: dashboardProvider.availableBalance < 0,
              trendPercentage: dashboardProvider.incomeTrend.abs(),
              isUp: dashboardProvider.incomeTrend > 0,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String amount, {required bool isNegative, double? trendPercentage, bool isUp = true}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    amount,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              if (trendPercentage != null)
                Row(
                  children: [
                    Icon(
                      isUp ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                      color: isUp ? Colors.green : Theme.of(context).colorScheme.error,
                    ),
                                            Text(
                          '${trendPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isUp ? Colors.green : Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetProgress() {
    return Consumer2<CurrencyProvider, DashboardProvider>(
      builder: (context, currencyProvider, dashboardProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
          ),
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
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: dashboardProvider.budgetProgressValue.clamp(0.0, 1.0),
                backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  dashboardProvider.isOverBudget 
                    ? Theme.of(context).colorScheme.error 
                    : dashboardProvider.isNearingLimit 
                      ? Colors.orange 
                      : Theme.of(context).colorScheme.primary
                ),
                minHeight: 10,
              ),
              const SizedBox(height: 8),
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

  Widget _buildRecentTransactions() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
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
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/expense-history'),
                  child:  Text(
                    'Ver Todas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.recentExpenses.isEmpty)
              _buildEmptyTransactions()
            else
              Column(
                children: provider.recentExpenses.take(3).map((expense) {
                  return _buildTransactionCard(expense);
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay transacciones aún',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza a rastrear tus gastos',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(ExpenseModel expense) {
    final categoryColor = expense.category.color;
    final categoryIcon = expense.category.iconData;
    final iconBackgroundColor = categoryColor.withValues(alpha: 0.15);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
              size: 20,
            ),
          ),
          
          SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface, // text-slate-800
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  expense.category.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), // text-slate-500
                  ),
                ),
              ],
            ),
          ),
          
          Consumer<CurrencyProvider>(
            builder: (context, currencyProvider, child) {
              return Text(
                '-${currencyProvider.formatAmount(expense.amount)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              );
            },
          ),
        ],
      ),
    );
  }


}
