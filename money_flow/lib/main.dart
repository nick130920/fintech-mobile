import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/app/app_wrapper.dart';
import 'core/providers/currency_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/bank_accounts/presentation/providers/bank_account_provider.dart';
import 'features/bank_accounts/presentation/providers/bank_notification_pattern_provider.dart';
import 'features/bank_accounts/presentation/screens/add_bank_account_screen.dart';
import 'features/bank_accounts/presentation/screens/add_notification_pattern_screen.dart';
import 'features/bank_accounts/presentation/screens/bank_accounts_screen.dart';
import 'features/bank_accounts/presentation/screens/notification_patterns_screen.dart';
import 'features/bank_accounts/presentation/screens/process_notification_screen.dart';
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
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => BudgetSetupProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => IncomeProvider()),
        ChangeNotifierProvider(create: (_) => BankAccountProvider()),
        ChangeNotifierProvider(create: (_) => BankNotificationPatternProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'MoneyFlow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AppWrapper(),
            routes: {
              '/budget-setup': (context) => const BudgetSetupScreen(),
              '/dashboard': (context) => const MainScreen(),
              '/add-expense': (context) => const AddExpenseScreen(),
              '/add-income': (context) => const AddIncomeScreen(),
              '/expense-history': (context) => const MainScreen(initialTab: 1),
              '/category-management': (context) => const MainScreen(initialTab: 2),
              '/bank-accounts': (context) => const BankAccountsScreen(),
              '/add-bank-account': (context) => const AddBankAccountScreen(),
              '/notification-patterns': (context) => const NotificationPatternsScreen(),
              '/add-notification-pattern': (context) => const AddNotificationPatternScreen(),
              '/process-notification': (context) => const ProcessNotificationScreen(),
            },
          );
        },
      ),
    );
  }
}
