import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/app/app_wrapper.dart';
import 'core/providers/currency_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/budget/presentation/providers/budget_setup_provider.dart';
import 'features/budget/presentation/providers/dashboard_provider.dart';
import 'features/budget/presentation/providers/expense_provider.dart';
import 'features/budget/presentation/providers/income_provider.dart';
import 'features/budget/presentation/screens/add_expense_screen.dart';
import 'features/budget/presentation/screens/add_income_screen.dart';
import 'features/budget/presentation/screens/budget_setup_screen.dart';
import 'shared/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar datos de localización para español
  await initializeDateFormatting('es', null);
  
  runApp(const MoneyFlowApp());
}

class MoneyFlowApp extends StatelessWidget {
  const MoneyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => BudgetSetupProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => IncomeProvider()),
      ],
      child: MaterialApp(
        title: 'MoneyFlow',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AppWrapper(),
        routes: {
          '/budget-setup': (context) => const BudgetSetupScreen(),
          '/dashboard': (context) => const MainScreen(),
          '/add-expense': (context) => const AddExpenseScreen(),
          '/add-income': (context) => const AddIncomeScreen(),
          '/expense-history': (context) => const MainScreen(initialTab: 1),
          '/category-management': (context) => const MainScreen(initialTab: 2),
        },
      ),
    );
  }

}
