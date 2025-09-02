import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthWrapper extends StatefulWidget {
  final VoidCallback? onAuthComplete;
  
  const AuthWrapper({super.key, this.onAuthComplete});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize auth provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initialize();
    });
  }

  void _onAuthSuccess() {
    // Ejecutar callback si está disponible
    if (widget.onAuthComplete != null) {
      widget.onAuthComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        switch (authProvider.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const LoadingScreen();
          
          case AuthStatus.authenticated:
            // Usuario autenticado - ejecutar callback inmediatamente
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _onAuthSuccess();
              }
            });
            return const LoadingScreen();
          
          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return const WelcomeScreen();
        }
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Text(
              '💸',
              style: TextStyle(fontSize: 64),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando...',
              style: TextStyle(
                color: AppColors.slate600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo
              const Text(
                '💸',
                style: TextStyle(fontSize: 96),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'MoneyFlow',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.slate900,
                      fontWeight: FontWeight.w900,
                      fontSize: 36,
                    ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'Toma control de tus finanzas con presupuestos inteligentes y seguimiento de gastos.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.slate600,
                      fontSize: 18,
                    ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(flex: 3),
              
              // Buttons
              Column(
                children: [
                  // Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Comenzar'),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Ya tengo una cuenta'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: const Text('Panel Principal'),
        actions: [
          IconButton(
            onPressed: () async {
              await authProvider.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Bienvenido ${user?.firstName ?? 'Usuario'}!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Panel principal próximamente...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.slate600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await authProvider.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
