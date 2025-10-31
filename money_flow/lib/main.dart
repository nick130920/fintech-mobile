import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/app/app_wrapper.dart';
import 'core/providers/currency_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/sms_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/bank_accounts/data/models/bank_notification_pattern_model.dart';
import 'features/bank_accounts/data/models/transaction_model.dart';
import 'features/bank_accounts/presentation/providers/automatic_transactions_provider.dart';
import 'features/bank_accounts/presentation/providers/bank_account_provider.dart';
import 'features/bank_accounts/presentation/providers/bank_notification_pattern_provider.dart';
import 'features/bank_accounts/presentation/screens/add_bank_account_screen.dart';
import 'features/bank_accounts/presentation/screens/add_notification_pattern_screen.dart';
import 'features/bank_accounts/presentation/screens/bank_accounts_screen.dart';
import 'features/bank_accounts/presentation/screens/edit_pending_transaction_screen.dart';
import 'features/bank_accounts/presentation/screens/notification_patterns_screen.dart';
import 'features/bank_accounts/presentation/screens/pending_transactions_screen.dart';
import 'features/bank_accounts/presentation/screens/process_notification_screen.dart';
import 'features/budget/presentation/providers/budget_setup_provider.dart';
import 'features/budget/presentation/providers/dashboard_provider.dart';
import 'features/budget/presentation/providers/expense_provider.dart';
import 'features/budget/presentation/providers/income_provider.dart';
import 'features/budget/presentation/screens/add_expense_screen.dart';
import 'features/budget/presentation/screens/add_income_screen.dart';
import 'features/budget/presentation/screens/budget_setup_screen.dart';
import 'shared/screens/main_screen.dart';
import 'core/services/api_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final SmsService smsService = SmsService();

void smsSyncHandler(String? message) async {
  if (message == null) return;

  print("smsSyncHandler procesando mensaje...");
  final context = navigatorKey.currentContext;
  if (context == null) {
    print("Error: No se pudo obtener el contexto del navegador");
    return;
  }

  final bankAccountProvider = Provider.of<BankAccountProvider>(context, listen: false);
  final patternProvider = Provider.of<BankNotificationPatternProvider>(context, listen: false);

  // Asegurarse de que las cuentas estén cargadas
  await bankAccountProvider.loadBankAccounts(activeOnly: true);
  
  final smsEnabledAccounts = bankAccountProvider.activeBankAccounts
      .where((acc) => acc.isNotificationEnabled && acc.notificationPhone.isNotEmpty)
      .toList();

  if (smsEnabledAccounts.isEmpty) {
    print("No hay cuentas con notificaciones SMS activas.");
    return;
  }
  
  print("Cuentas con SMS activado: ${smsEnabledAccounts.length}");

  for (var account in smsEnabledAccounts) {
    print("Procesando SMS para la cuenta: ${account.accountAlias}");
    final request = ProcessNotificationRequest(
      bankAccountId: account.id,
      channel: NotificationChannel.sms,
      message: message,
    );
    await patternProvider.processNotification(request);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  ApiService.initialize(navigatorKey);
  
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
        ChangeNotifierProvider(create: (_) => AutomaticTransactionsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
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
              '/pending-transactions': (context) => const PendingTransactionsScreen(),
              '/edit-pending-transaction': (context) {
                final transaction = ModalRoute.of(context)!.settings.arguments as TransactionModel;
                return EditPendingTransactionScreen(transaction: transaction);
              },
            },
          );
        },
      ),
    );
  }
}
