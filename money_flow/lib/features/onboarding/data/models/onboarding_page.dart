import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_radius.dart';

class OnboardingPageModel {
  final String title;
  final String description;
  final Widget illustration;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const OnboardingPageModel({
    required this.title,
    required this.description,
    required this.illustration,
    required this.buttonText,
    this.onButtonPressed,
  });
}

class OnboardingData {
  static List<OnboardingPageModel> getPages({
    required VoidCallback onComplete,
  }) {
    return [
      OnboardingPageModel(
        title: 'Toma Control de tu Dinero',
        description: 'Configurar un presupuesto es el primer paso hacia la libertad financiera. Vamos a crear uno que funcione para ti.',
        illustration: const BudgetIllustration(),
        buttonText: 'Empecemos',
        onButtonPressed: null,
      ),
      OnboardingPageModel(
        title: 'Rastrea tus Gastos',
        description: 'Registra tus gastos fácilmente y mantén un seguimiento detallado de hacia dónde va tu dinero cada día.',
        illustration: const ExpenseIllustration(),
        buttonText: 'Continuar',
        onButtonPressed: null,
      ),
      OnboardingPageModel(
        title: 'Visualiza tu Progreso',
        description: 'Obtén insights claros sobre tus hábitos de gasto con gráficos intuitivos y reportes detallados.',
        illustration: const ProgressIllustration(),
        buttonText: 'Continuar',
        onButtonPressed: null,
      ),
      OnboardingPageModel(
        title: 'Recibe Alertas Inteligentes',
        description: 'Te notificaremos cuando te acerques a tus límites diarios para ayudarte a mantener el control.',
        illustration: const AlertsIllustration(),
        buttonText: 'Comenzar',
        onButtonPressed: onComplete,
      ),
    ];
  }
}

class BudgetIllustration extends StatelessWidget {
  const BudgetIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        gradient: AppGradients.onboardingBudget,
        borderRadius: AppRadius.allXl,
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(height: 60, color: scheme.primary),
                _buildBar(height: 90, color: scheme.primary.withValues(alpha: 0.7)),
                _buildBar(height: 45, color: AppColors.info),
                _buildBar(height: 75, color: scheme.primary.withValues(alpha: 0.85)),
                _buildBar(height: 55, color: scheme.primary),
              ],
            ),
          ),
          const Positioned(
            top: 30,
            right: 30,
            child: Text('💰', style: TextStyle(fontSize: 32)),
          ),
          const Positioned(
            top: 60,
            left: 50,
            child: Text('📊', style: TextStyle(fontSize: 28)),
          ),
          const Positioned(
            top: 100,
            right: 60,
            child: Text('💡', style: TextStyle(fontSize: 24)),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({required double height, required Color color}) {
    return Container(
      width: 20,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}

class ExpenseIllustration extends StatelessWidget {
  const ExpenseIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        gradient: AppGradients.onboardingExpense,
        borderRadius: AppRadius.allXl,
      ),
      child: const Stack(
        children: [
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(child: Text('📱', style: TextStyle(fontSize: 80))),
          ),
          Positioned(
            bottom: 80,
            left: 30,
            child: Text('🍔', style: TextStyle(fontSize: 32)),
          ),
          Positioned(
            bottom: 100,
            right: 40,
            child: Text('⛽', style: TextStyle(fontSize: 28)),
          ),
          Positioned(
            bottom: 50,
            left: 80,
            child: Text('🛒', style: TextStyle(fontSize: 24)),
          ),
          Positioned(
            bottom: 60,
            right: 90,
            child: Text('🎬', style: TextStyle(fontSize: 26)),
          ),
        ],
      ),
    );
  }
}

class ProgressIllustration extends StatelessWidget {
  const ProgressIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        gradient: AppGradients.onboardingProgress,
        borderRadius: AppRadius.allXl,
      ),
      child: const Stack(
        children: [
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(child: Text('📈', style: TextStyle(fontSize: 100))),
          ),
          Positioned(
            bottom: 60,
            left: 40,
            child: Text('📊', style: TextStyle(fontSize: 32)),
          ),
          Positioned(
            bottom: 80,
            right: 40,
            child: Text('📉', style: TextStyle(fontSize: 28)),
          ),
          Positioned(
            bottom: 40,
            left: 100,
            child: Text('💹', style: TextStyle(fontSize: 24)),
          ),
        ],
      ),
    );
  }
}

class AlertsIllustration extends StatelessWidget {
  const AlertsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        gradient: AppGradients.onboardingAlerts,
        borderRadius: AppRadius.allXl,
      ),
      child: const Stack(
        children: [
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(child: Text('🔔', style: TextStyle(fontSize: 80))),
          ),
          Positioned(
            bottom: 100,
            left: 50,
            child: Text('⚠️', style: TextStyle(fontSize: 32)),
          ),
          Positioned(
            bottom: 60,
            right: 50,
            child: Text('✅', style: TextStyle(fontSize: 28)),
          ),
          Positioned(
            bottom: 80,
            left: 120,
            child: Text('📢', style: TextStyle(fontSize: 24)),
          ),
          Positioned(
            top: 40,
            right: 30,
            child: Text('💡', style: TextStyle(fontSize: 26)),
          ),
        ],
      ),
    );
  }
}
