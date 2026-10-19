import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/auth_wrapper.dart';
import '../../features/budget/presentation/providers/budget_setup_provider.dart';
import '../../features/budget/presentation/screens/budget_setup_choice_screen.dart';
import '../../main.dart';
import '../../shared/screens/main_screen.dart';
import '../providers/currency_provider.dart';
import '../services/budget_onboarding_preference_service.dart';
import '../services/notification_listener_service.dart';
import '../services/platform_capabilities.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Cuando el usuario vuelve la app al primer plano, refrescamos el perfil
  // en background. Si el access token expiró, ApiService lo renueva solo
  // antes de que el usuario haga cualquier acción.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        authProvider.refreshProfile();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        Widget child;
        switch (authProvider.status) {
          case AuthStatus.authenticated:
            child = _AuthenticatedHandler(key: ValueKey(authProvider.user?.id));
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
  const _AuthenticatedHandler({super.key});

  @override
  State<_AuthenticatedHandler> createState() => _AuthenticatedHandlerState();
}

class _AuthenticatedHandlerState extends State<_AuthenticatedHandler> {
  final _onboardingPreferences = BudgetOnboardingPreferenceService();
  Future<bool>? _needsBudgetSetupFuture;
  int? _authenticatedUserId;
  bool _isSkipping = false;
  String? _skipError;

  @override
  void initState() {
    super.initState();
    _authenticatedUserId = context.read<AuthProvider>().user?.id;
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
    final userId = _authenticatedUserId;
    if (!PlatformCapabilities.supportsSmsInbox) {
      debugPrint('Sincronización SMS omitida: plataforma no soportada.');
      return;
    }

    // No necesitamos el contexto aquí porque el handler lo obtiene del navigatorKey
    await smsService.syncInbox(
      onInboxBatch: (items) async {
        if (userId == null || !_isCurrentAuthenticatedUser(userId)) return;
        await smsBatchSyncHandler(items, bulkSilent: items.length != 1);
      },
    );
  }

  bool _isCurrentAuthenticatedUser(int userId) {
    if (!mounted) return false;
    final auth = context.read<AuthProvider>();
    return auth.status == AuthStatus.authenticated &&
        auth.user?.id == userId &&
        _authenticatedUserId == userId;
  }

  Future<bool> _checkBudgetSetup() async {
    final user = context.read<AuthProvider>().user;
    if (user == null || !_isCurrentAuthenticatedUser(user.id)) return true;
    final userId = user.id;
    final budgetSetupProvider = context.read<BudgetSetupProvider>();
    try {
      final needsSetup = await _onboardingPreferences.shouldShowBudgetSetup(
        userId: userId,
        loadHasCurrentBudget: () async {
          if (!_isCurrentAuthenticatedUser(userId)) return false;
          return budgetSetupProvider.checkExistingBudget();
        },
      );
      if (!_isCurrentAuthenticatedUser(userId)) return true;
      return needsSetup;
    } catch (_) {
      if (!_isCurrentAuthenticatedUser(userId)) return true;
      rethrow;
    }
  }

  Future<bool> _skipBudgetSetup() async {
    final userId = _authenticatedUserId;
    if (userId == null || !_isCurrentAuthenticatedUser(userId)) return false;
    try {
      final persisted = await _onboardingPreferences.skipBudgetSetup(userId);
      if (!_isCurrentAuthenticatedUser(userId)) return false;
      return persisted;
    } catch (_) {
      return false;
    }
  }

  Future<void> _skipFromLookupError() async {
    final userId = _authenticatedUserId;
    if (_isSkipping || userId == null || !_isCurrentAuthenticatedUser(userId)) {
      return;
    }
    setState(() {
      _isSkipping = true;
      _skipError = null;
    });
    final persisted = await _skipBudgetSetup();
    if (!_isCurrentAuthenticatedUser(userId)) return;
    setState(() {
      _isSkipping = false;
      if (persisted) {
        _needsBudgetSetupFuture = Future.value(false);
      } else {
        _skipError = 'No pudimos guardar tu decisión. Inténtalo de nuevo.';
      }
    });
  }

  void _refreshBudgetGate() {
    final userId = _authenticatedUserId;
    if (_isSkipping || userId == null || !_isCurrentAuthenticatedUser(userId)) {
      return;
    }
    setState(() {
      _skipError = null;
      _needsBudgetSetupFuture = _checkBudgetSetup();
      // A retry can fail before the next frame subscribes via FutureBuilder.
      // Observe it now too; FutureBuilder still receives the original error.
      _needsBudgetSetupFuture!.ignore();
    });
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
            onRetry: _refreshBudgetGate,
            onSkip: _skipFromLookupError,
            isSkipping: _isSkipping,
            skipError: _skipError,
          );
        }

        final needsSetup = snapshot.data!;
        if (needsSetup) {
          return BudgetSetupChoiceScreen(
            onSkip: _skipBudgetSetup,
            onSetupComplete: _refreshBudgetGate,
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
  final VoidCallback? onSkip;
  final bool isSkipping;
  final String? skipError;

  const AppErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
    this.onSkip,
    this.isSkipping = false,
    this.skipError,
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: isSkipping ? null : onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
              if (onSkip != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isSkipping ? null : onSkip,
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  child: const Text('Omitir por ahora'),
                ),
                if (isSkipping)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: CircularProgressIndicator(),
                  ),
                if (skipError != null)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      skipError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
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
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
