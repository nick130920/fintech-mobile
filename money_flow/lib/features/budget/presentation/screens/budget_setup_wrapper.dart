import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/budget_setup_provider.dart';
import 'budget_setup_screen.dart';

class BudgetSetupWrapper extends StatefulWidget {
  final VoidCallback onSetupComplete;

  const BudgetSetupWrapper({
    super.key,
    required this.onSetupComplete,
  });

  @override
  State<BudgetSetupWrapper> createState() => _BudgetSetupWrapperState();
}

class _BudgetSetupWrapperState extends State<BudgetSetupWrapper> {
  @override
  void initState() {
    super.initState();
    _listenToSetupCompletion();
  }

  void _listenToSetupCompletion() {
    final provider = context.read<BudgetSetupProvider>();
    
    // Escuchar cuando se complete la configuración
    provider.addListener(() {
      if (provider.currentStep == BudgetSetupStep.completed) {
        // Pequeño delay para mostrar la pantalla de éxito
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            widget.onSetupComplete();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const BudgetSetupScreen();
  }
}
