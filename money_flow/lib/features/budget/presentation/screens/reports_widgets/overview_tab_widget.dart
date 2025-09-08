import 'package:flutter/material.dart';

import 'balance_overview_widget.dart';
import 'distribution_widget.dart';
import 'monthly_trends_widget.dart';
import 'savings_progress_widget.dart';
import 'smart_insights_widget.dart';

class OverviewTabWidget extends StatelessWidget {
  const OverviewTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Balance General
          BalanceOverviewWidget(),
          SizedBox(height: 24),
          
          // Distribución Completa (Ingresos y Gastos)
          DistributionWidget(),
          SizedBox(height: 24),
          
          // Progreso de Ahorros
          SavingsProgressWidget(),
          SizedBox(height: 24),
          
          // Tendencias Mensuales
          MonthlyTrendsWidget(),
          SizedBox(height: 24),
          
          // Insights Inteligentes
          SmartInsightsWidget(),
        ],
      ),
    );
  }
}
