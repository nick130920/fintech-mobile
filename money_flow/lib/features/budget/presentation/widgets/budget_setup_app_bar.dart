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
          backgroundColor: Colors.transparent,
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Paso ${provider.stepIndex + 1} de 3',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
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
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
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
