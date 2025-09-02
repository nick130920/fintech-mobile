import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/auth_wrapper.dart';
import '../../features/budget/data/repositories/budget_repository.dart';
import '../../features/budget/presentation/screens/budget_setup_wrapper.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../shared/screens/main_screen.dart';
import '../../shared/widgets/money_flow_logo.dart';
import '../providers/currency_provider.dart';

enum AppState {
  loading,
  onboarding,
  auth,
  budgetSetup,
  dashboard,
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  AppState _currentState = AppState.loading;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    // Pequeña pausa para mostrar el loading
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Inicializar CurrencyProvider temprano para detección de ubicación
    if (mounted) {
      final currencyProvider = context.read<CurrencyProvider>();
      currencyProvider.initialize(); // No esperamos, se ejecuta en background
    }
    
    // Verificar estado de autenticación y configuración
    if (mounted) {
      final authProvider = context.read<AuthProvider>();
      
      // Verificar estado de autenticación real
      await authProvider.initialize();
      
      if (authProvider.isAuthenticated) {
        // Usuario autenticado - verificar si necesita configurar presupuesto
        final needsBudgetSetup = await _checkBudgetSetup();
        setState(() {
          _currentState = needsBudgetSetup ? AppState.budgetSetup : AppState.dashboard;
        });
      } else {
        // Usuario no autenticado - mostrar onboarding
        setState(() {
          _currentState = AppState.onboarding;
        });
      }
    }
  }

  Future<bool> _checkBudgetSetup() async {
    try {
      final repository = BudgetRepository();
      return !(await repository.hasBudgetConfigured());
    } catch (e) {
      return true; // En caso de error, dirigir a configuración
    }
  }

  void _onOnboardingComplete() {
    setState(() {
      _currentState = AppState.auth;
    });
  }

  void _onAuthComplete() async {
    // Una vez autenticado, verificar si necesita configuración presupuestal
    final needsBudgetSetup = await _checkBudgetSetup();
    setState(() {
      _currentState = needsBudgetSetup ? AppState.budgetSetup : AppState.dashboard;
    });
  }

  void _onBudgetSetupComplete() {
    setState(() {
      _currentState = AppState.dashboard;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentState) {
      case AppState.loading:
        return const AppLoadingScreen();
      
      case AppState.onboarding:
        return OnboardingWrapper(
          onComplete: _onOnboardingComplete,
        );
      
      case AppState.auth:
        return AuthWrapper(onAuthComplete: _onAuthComplete);
        
      case AppState.budgetSetup:
        return BudgetSetupWrapper(onSetupComplete: _onBudgetSetupComplete);
        
      case AppState.dashboard:
        return const MainScreen();
    }
  }
}

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // AppColors.slate50
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(
                    opacity: value,
                    child: Column(
                      children: [
                        // Logo personalizado de MoneyFlow
                        const MoneyFlowLogo(
                          size: 120,
                          showText: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // Loading indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF137FEC)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
