import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/app/app_wrapper.dart';
import 'core/models/sms_settings.dart';
import 'core/providers/currency_provider.dart';
import 'core/providers/sms_settings_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/api_service.dart';
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
import 'features/bank_accounts/presentation/screens/transactions_flow_screen.dart';
import 'features/budget/data/models/expense_model.dart';
import 'features/budget/presentation/providers/budget_setup_provider.dart';
import 'features/budget/presentation/providers/dashboard_provider.dart';
import 'features/budget/presentation/providers/expense_provider.dart';
import 'features/budget/presentation/providers/income_provider.dart';
import 'features/budget/presentation/screens/add_expense_screen.dart';
import 'features/budget/presentation/screens/add_income_screen.dart';
import 'features/budget/presentation/screens/budget_setup_screen.dart';
import 'features/budget/presentation/screens/reports_screen.dart';
import 'features/settings/presentation/screens/currency_settings_screen.dart';
import 'features/settings/presentation/screens/sms_settings_screen.dart';
import 'shared/screens/main_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final SmsService smsService = SmsService();

void smsSyncHandler(String? message) async {
  if (message == null) return;

  debugPrint("smsSyncHandler procesando mensaje...");
  final context = navigatorKey.currentContext;
  if (context == null) {
    debugPrint("Error: No se pudo obtener el contexto del navegador");
    return;
  }

  // Verificar si hay una sesión activa antes de procesar
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  if (authProvider.status != AuthStatus.authenticated) {
    debugPrint("No hay sesión activa, omitiendo procesamiento de SMS");
    return;
  }

  // Verificar configuración de SMS
  final smsSettingsProvider = Provider.of<SmsSettingsProvider>(context, listen: false);
  
  final bankAccountProvider = Provider.of<BankAccountProvider>(context, listen: false);
  await bankAccountProvider.loadBankAccounts(activeOnly: true);
  
  final smsEnabledAccounts = bankAccountProvider.activeBankAccounts
      .where((acc) => acc.isNotificationEnabled && acc.notificationPhone.isNotEmpty)
      .toList();

  // Verificar si se puede procesar automáticamente
  if (!smsSettingsProvider.canAutoProcess(smsEnabledAccounts.isNotEmpty)) {
    debugPrint("Procesamiento automático deshabilitado o no cumple condiciones");
    return;
  }

  if (smsEnabledAccounts.isEmpty) {
    debugPrint("No hay cuentas con notificaciones SMS activas.");
    return;
  }
  
  debugPrint("Cuentas con SMS activado: ${smsEnabledAccounts.length}");
  debugPrint("Configuración SMS: ${smsSettingsProvider.settings.processMode.displayName}");

  final patternProvider = Provider.of<BankNotificationPatternProvider>(context, listen: false);

  for (var account in smsEnabledAccounts) {
    debugPrint("Procesando SMS para la cuenta: ${account.accountAlias}");
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
        ChangeNotifierProvider(create: (_) => SmsSettingsProvider()..initialize()),
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
              '/add-expense': (context) {
                final expense = ModalRoute.of(context)?.settings.arguments as ExpenseModel?;
                return AddExpenseScreen(expense: expense);
              },
              '/add-income': (context) => const AddIncomeScreen(),
              '/expense-history': (context) => const MainScreen(initialTab: 1),
              '/income-history': (context) => const ReportsScreen(useScaffold: true, initialTabIndex: 1),
              '/category-management': (context) => const MainScreen(initialTab: 2),
              '/currency-settings': (context) => const CurrencySettingsScreen(),
              '/sms-settings': (context) => const SmsSettingsScreen(),
              '/bank-accounts': (context) => const BankAccountsScreen(),
              '/add-bank-account': (context) => const AddBankAccountScreen(),
              '/notification-patterns': (context) => const NotificationPatternsScreen(),
              '/add-notification-pattern': (context) => const AddNotificationPatternScreen(),
              '/process-notification': (context) => const ProcessNotificationScreen(),
              '/pending-transactions': (context) => const PendingTransactionsScreen(),
              '/transactions-flow': (context) => const TransactionsFlowScreen(),
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
