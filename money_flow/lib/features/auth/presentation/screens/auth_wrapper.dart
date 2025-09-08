import 'package:flutter/material.dart';

import '../../../../../shared/widgets/money_flow_logo.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthWrapper extends StatelessWidget {
  final VoidCallback onAuthSuccess;
  const AuthWrapper({super.key, required this.onAuthSuccess});

  @override
  Widget build(BuildContext context) {
    return WelcomeScreen(onAuthSuccess: onAuthSuccess);
  }
}

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onAuthSuccess;
  const WelcomeScreen({super.key, required this.onAuthSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo (solo símbolo, sin texto)
              const MoneyFlowLogo.iconOnly(size: 96),
              const SizedBox(height: 32),
              
              // Title
              Text(
                'MoneyFlow',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
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
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 18,
                    ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(flex: 3),
              
              // Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen(
                                    onRegisterSuccess: onAuthSuccess,
                                  )),
                        );
                      },
                      child: const Text('Comenzar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => LoginScreen(
                                    onLoginSuccess: onAuthSuccess,
                                  )),
                        );
                      },
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
