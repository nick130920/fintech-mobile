import 'package:flutter/material.dart';

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
        onButtonPressed: null, // Se manejará en el PageView
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

// Ilustraciones personalizadas
class BudgetIllustration extends StatelessWidget {
  const BudgetIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF137FEC).withValues(alpha: 0.1),
            const Color(0xFF60A5FA).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Gráfico de barras
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(height: 60, color: const Color(0xFF137FEC)),
                _buildBar(height: 90, color: const Color(0xFF60A5FA)),
                _buildBar(height: 45, color: const Color(0xFF3B82F6)),
                _buildBar(height: 75, color: const Color(0xFF1D4ED8)),
                _buildBar(height: 55, color: const Color(0xFF137FEC)),
              ],
            ),
          ),
          // Monedas flotantes
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981).withValues(alpha: 0.1),
            const Color(0xFF34D399).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Stack(
        children: [
          // Teléfono
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text('📱', style: TextStyle(fontSize: 80)),
            ),
          ),
          // Iconos de gastos
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            const Color(0xFFA78BFA).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Stack(
        children: [
          // Gráfico circular
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text('📈', style: TextStyle(fontSize: 100)),
            ),
          ),
          // Estadísticas
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: 0.1),
            const Color(0xFFFBBF24).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Stack(
        children: [
          // Campana de notificación
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text('🔔', style: TextStyle(fontSize: 80)),
            ),
          ),
          // Alertas
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
