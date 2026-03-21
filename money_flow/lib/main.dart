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
import 'core/services/notification_listener_service.dart';
import 'features/bank_accounts/data/repositories/automatic_transactions_repository.dart';
import 'features/bank_accounts/data/models/transaction_model.dart';
import 'features/bank_accounts/presentation/providers/automatic_transactions_provider.dart';
import 'features/bank_accounts/presentation/providers/bank_account_provider.dart';
import 'features/bank_accounts/presentation/screens/add_bank_account_screen.dart';
import 'features/bank_accounts/presentation/screens/automatic_transactions_settings_screen.dart';
import 'features/bank_accounts/presentation/screens/bank_accounts_screen.dart';
import 'features/bank_accounts/presentation/screens/edit_pending_transaction_screen.dart';
import 'features/bank_accounts/presentation/screens/pending_transactions_screen.dart';
import 'features/bank_accounts/presentation/screens/transactions_flow_screen.dart';
import 'features/budget/data/models/expense_model.dart';
import 'features/budget/presentation/providers/budget_setup_provider.dart';
import 'features/budget/presentation/providers/budget_suggestions_provider.dart';
import 'features/budget/presentation/providers/dashboard_provider.dart';
import 'features/budget/presentation/providers/expense_provider.dart';
import 'features/budget/presentation/providers/income_provider.dart';
import 'features/budget/presentation/screens/add_expense_screen.dart';
import 'features/budget/presentation/screens/add_income_screen.dart';
import 'features/budget/presentation/screens/ai_transactions_screen.dart';
import 'features/budget/presentation/screens/budget_setup_screen.dart';
import 'features/budget/presentation/screens/reports_screen.dart';
import 'features/settings/presentation/screens/currency_settings_screen.dart';
import 'features/settings/presentation/screens/email_connection_screen.dart';
import 'features/settings/presentation/screens/sms_settings_screen.dart';
import 'shared/screens/main_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final SmsService smsService = SmsService();

/// Procesa varios SMS en una sola petición al backend (chunks de IA en servidor).
/// Devuelve `null` si no aplica (sin sesión, sin cuentas SMS, etc.).
Future<ProcessSMSBatchWithAIResult?> smsBatchSyncHandler(
  List<SmsInboxItem> items, {
  bool bulkSilent = true,
}) async {
  final messages = items
      .where((e) => e.body != null && e.body!.trim().isNotEmpty)
      .map(
        (e) => <String, dynamic>{
          'body': e.body!.trim(),
          'date': e.date?.toIso8601String() ?? '',
        },
      )
      .toList();

  if (messages.isEmpty) {
    return ProcessSMSBatchWithAIResult(
      totalReceived: 0,
      filteredOut: 0,
      smsAfterFilter: 0,
      chunksProcessed: 0,
      transactionsCreated: 0,
      lowConfidenceOrSkipped: 0,
      notBankSms: 0,
      processingErrors: 0,
    );
  }

  debugPrint('smsBatchSyncHandler: ${messages.length} SMS para lote...');
  final context = navigatorKey.currentContext;
  if (context == null) {
    debugPrint('Error: No se pudo obtener el contexto del navegador');
    return null;
  }

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  if (authProvider.status != AuthStatus.authenticated) {
    debugPrint('No hay sesión activa, omitiendo procesamiento de SMS');
    return null;
  }

  final smsSettingsProvider = Provider.of<SmsSettingsProvider>(context, listen: false);
  final bankAccountProvider = Provider.of<BankAccountProvider>(context, listen: false);
  await bankAccountProvider.loadBankAccounts(activeOnly: true);

  final smsEnabledAccounts = bankAccountProvider.activeBankAccounts
      .where((acc) => acc.isNotificationEnabled && acc.notificationPhone.isNotEmpty)
      .toList();

  if (!smsSettingsProvider.canAutoProcess(smsEnabledAccounts.isNotEmpty)) {
    debugPrint('Procesamiento automático deshabilitado o no cumple condiciones');
    return null;
  }

  if (smsEnabledAccounts.isEmpty) {
    debugPrint('No hay cuentas con notificaciones SMS activas.');
    return null;
  }

  debugPrint('Cuentas con SMS activado: ${smsEnabledAccounts.length}');
  debugPrint('Configuración SMS: ${smsSettingsProvider.settings.processMode.displayName}');

  final result = await AutomaticTransactionsRepository.processSMSBatchWithAI(messages);

  if (bulkSilent) {
    debugPrint(
      'Lote SMS: creadas=${result.transactionsCreated}, '
      'recibidos=${result.totalReceived}, filtrados=${result.filteredOut}, '
      'chunks=${result.chunksProcessed}, errores=${result.processingErrors}',
    );
  } else if (result.transactionsCreated > 0) {
    await NotificationListenerService().showBatchSummaryNotification(
      created: result.transactionsCreated,
      totalAnalyzed: result.smsAfterFilter,
    );
  }

  return result;
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
        ChangeNotifierProvider(create: (_) => BudgetSuggestionsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => IncomeProvider()),
        ChangeNotifierProvider(create: (_) => BankAccountProvider()),
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
              '/income-history': (context) => const ReportsScreen(useScaffold: true),
              '/category-management': (context) => const MainScreen(initialTab: 2),
              '/currency-settings': (context) => const CurrencySettingsScreen(),
              '/sms-settings': (context) => const SmsSettingsScreen(),
              '/email-connection': (context) => const EmailConnectionScreen(),
              '/bank-accounts': (context) => const BankAccountsScreen(),
              '/add-bank-account': (context) => const AddBankAccountScreen(),
              '/pending-transactions': (context) => const PendingTransactionsScreen(),
              '/transactions-flow': (context) => const TransactionsFlowScreen(),
              '/edit-pending-transaction': (context) {
                final transaction = ModalRoute.of(context)!.settings.arguments as TransactionModel;
                return EditPendingTransactionScreen(transaction: transaction);
              },
              '/automatic-transactions-settings': (context) => const AutomaticTransactionsSettingsScreen(),
              '/ai-transactions': (context) => const AITransactionsScreen(),
            },
          );
        },
      ),
    );
  }
}
