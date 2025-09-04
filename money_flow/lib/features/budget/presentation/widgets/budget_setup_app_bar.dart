import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/budget_setup_provider.dart';

class BudgetSetupAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BudgetSetupAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSetupProvider>(
      builder: (context, provider, child) {
        return AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          leading: provider.currentStep != BudgetSetupStep.totalAmount 
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: provider.goBack,
                )
              : null,
          title: Column(
            children: [
              Text(
                _getStepTitle(provider.currentStep),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Paso ${provider.stepIndex + 1} de 3',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(8),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: provider.progress,
                backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getStepTitle(BudgetSetupStep step) {
    switch (step) {
      case BudgetSetupStep.totalAmount:
        return 'Tu Presupuesto';
      case BudgetSetupStep.selectCategories:
        return 'Categorías';
      case BudgetSetupStep.assignPercentages:
        return 'Asignación';
      case BudgetSetupStep.completed:
        return '¡Listo!';
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
