import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../shared/widgets/money_flow_logo.dart';

class LogoTestScreen extends StatelessWidget {
  const LogoTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: const Text('MoneyFlow Logo Test'),
        backgroundColor: AppColors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Logo en diferentes tamaños',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Logo grande con texto
            const Text('Logo Grande (150px)', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.slate300.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const MoneyFlowLogo(size: 150, showText: true),
            ),
            
            const SizedBox(height: 30),
            
            // Logo mediano con texto
            const Text('Logo Mediano (100px)', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.slate300.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const MoneyFlowLogo(size: 100, showText: true),
            ),
            
            const SizedBox(height: 30),
            
            // Logo pequeño sin texto
            const Text('Logo Pequeño sin texto (60px)', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.slate300.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const MoneyFlowLogo(size: 60, showText: false),
            ),
            
            const SizedBox(height: 30),
            
            // Logos en fila
            const Text('Logos en fila (diferentes tamaños)', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.slate300.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MoneyFlowLogo(size: 40, showText: false),
                  MoneyFlowLogo(size: 50, showText: false),
                  MoneyFlowLogo(size: 60, showText: false),
                  MoneyFlowLogo(size: 70, showText: false),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Logo con texto en color personalizado
            const Text('Logo con texto personalizado (blanco)', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.slate900,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.slate300.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const MoneyFlowLogo(
                size: 120, 
                showText: true, 
                textColor: AppColors.white,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Información del diseño
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del Logo:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Diseño: Ondas fluidas representando flujo de dinero\n'
                    '• Colores: Degradado de azules (#60A5FA → #1D4ED8)\n'
                    '• Técnica: CustomPainter con paths curvos\n'
                    '• Responsive: Se adapta al tamaño especificado\n'
                    '• Opciones: Con/sin texto, color personalizable',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.slate700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
