import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/budget_setup_provider.dart';
import 'steps/step_1_total_amount.dart';
import 'steps/step_2_select_categories.dart';
import 'steps/step_3_assign_percentages.dart';

class BudgetSetupStepper extends StatelessWidget {
  const BudgetSetupStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSetupProvider>(
      builder: (context, provider, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          child: _buildCurrentStep(provider.currentStep, provider),
        );
      },
    );
  }

  Widget _buildCurrentStep(BudgetSetupStep step, BudgetSetupProvider provider) {
    switch (step) {
      case BudgetSetupStep.totalAmount:
        return const Step1TotalAmount(key: ValueKey('step1'));
      case BudgetSetupStep.selectCategories:
        return const Step2SelectCategories(key: ValueKey('step2'));
      case BudgetSetupStep.assignPercentages:
        return const Step3AssignPercentages(key: ValueKey('step3'));
      default:
        return const SizedBox();
    }
  }
}
