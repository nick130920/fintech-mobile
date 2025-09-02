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
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildCustomAppBar(),
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildCustomAppBar(),
      body: body,
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'MoneyFlow',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B), // text-slate-800
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            // Navegación a configuración
          },
          icon: const Icon(
            Icons.settings,
            color: Color(0xFF64748B), // text-slate-600
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)), // border-slate-200
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B), // text-slate-600
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A), // text-slate-900
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
                      color: isUp ? const Color(0xFF059669) : const Color(0xFFEF4444), // green-600 : red-500
                    ),
                                            Text(
                          '${trendPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isUp ? const Color(0xFF059669) : const Color(0xFFEF4444),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Presupuesto Mensual',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    '${currencyProvider.formatAmount(dashboardProvider.budgetSpent)} / ${currencyProvider.formatAmount(dashboardProvider.budgetTotal)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: dashboardProvider.budgetProgressValue.clamp(0.0, 1.0),
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  dashboardProvider.isOverBudget 
                    ? Colors.red 
                    : dashboardProvider.isNearingLimit 
                      ? Colors.orange 
                      : const Color(0xFF3B82F6)
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
                const Text(
                  'Transacciones Recientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/expense-history'),
                  child: const Text(
                    'Ver Todas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB), // text-blue-600
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay transacciones aún',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comienza a rastrear tus gastos',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B), // text-slate-800
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  expense.category.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B), // text-slate-500
                  ),
                ),
              ],
            ),
          ),
          
          Consumer<CurrencyProvider>(
            builder: (context, currencyProvider, child) {
              return Text(
                '-${currencyProvider.formatAmount(expense.amount)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


}
