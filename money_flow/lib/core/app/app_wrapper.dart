import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/auth_wrapper.dart';
import '../../features/budget/presentation/providers/budget_setup_provider.dart';
import '../../features/budget/presentation/screens/budget_setup_choice_screen.dart';
import '../../main.dart';
import '../../shared/screens/main_screen.dart';
import '../providers/currency_provider.dart';
import '../services/notification_listener_service.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    // Inicializar el listener de notificaciones globalmente al arrancar la app
    // Esto configurará el MethodChannel para escuchar eventos desde Android
    NotificationListenerService().initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CurrencyProvider>().initialize();
        // El AuthProvider ya se inicializa en main.dart con ..initialize()
        // No es necesario llamarlo de nuevo aquí
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        Widget child;
        switch (authProvider.status) {
          case AuthStatus.authenticated:
            child = const _AuthenticatedHandler();
            break;
          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            child = AuthWrapper(
              onAuthSuccess: () {
                // El estado de autenticación ya se actualiza automáticamente
                // en el AuthProvider cuando se hace login/register exitoso
              },
            );
            break;
          case AuthStatus.loading:
          case AuthStatus.initial:
            child = const AppLoadingScreen();
            break;
        }
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1).clamp(0.9, 1.3),
            ),
          ),
          child: child,
        );
      },
    );
  }
}

class _AuthenticatedHandler extends StatefulWidget {
  const _AuthenticatedHandler();

  @override
  State<_AuthenticatedHandler> createState() => _AuthenticatedHandlerState();
}

class _AuthenticatedHandlerState extends State<_AuthenticatedHandler> {
  Future<bool>? _needsBudgetSetupFuture;

  @override
  void initState() {
    super.initState();
    _needsBudgetSetupFuture = _checkBudgetSetup();
    _syncCurrencyFromUser();
    _syncSmsInbox();
  }

  void _syncCurrencyFromUser() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      context.read<CurrencyProvider>().syncFromUser(user.currency);
    }
  }

  Future<void> _syncSmsInbox() async {
    // No necesitamos el contexto aquí porque el handler lo obtiene del navigatorKey
    await smsService.syncInbox(
      onInboxBatch: (items) async {
        await smsBatchSyncHandler(items, bulkSilent: items.length != 1);
      },
    );
  }

  Future<bool> _checkBudgetSetup() async {
    // Usar el provider para la lógica de negocio
    return !(await context.read<BudgetSetupProvider>().checkExistingBudget());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _needsBudgetSetupFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingScreen();
        }

        if (snapshot.hasError || snapshot.data == null) {
          return AppErrorScreen(
            message: 'No pudimos verificar tu presupuesto.',
            onRetry: () {
              setState(() {
                _needsBudgetSetupFuture = _checkBudgetSetup();
              });
            },
          );
        }

        final needsSetup = snapshot.data!;
        if (needsSetup) {
          return BudgetSetupChoiceScreen(
            onSetupComplete: () {
              setState(() {
                _needsBudgetSetupFuture = _checkBudgetSetup();
              });
            },
          );
        } else {
          return const MainScreen();
        }
      },
    );
  }
}

class AppErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AppErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Algo salió mal',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
