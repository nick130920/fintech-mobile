import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class BudgetSetupReminderCard extends StatelessWidget {
  final bool isVisible;
  final VoidCallback? onSetupBudget;

  const BudgetSetupReminderCard({
    super.key,
    this.onSetupBudget,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: 'Budget setup reminder',
      child: Container(
        width: double.infinity,
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.62),
          borderRadius: AppRadius.allLg,
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.step3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configura tu presupuesto cuando estés listo',
                    style: AppTypography.labelLg.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.step1),
                  Text(
                    'Un presupuesto mensual te ayuda a tener tus gastos a la vista.',
                    style: AppTypography.bodySm.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.step2),
                  TextButton(
                    onPressed:
                        onSetupBudget ??
                        () => Navigator.of(context).pushNamed('/budget-setup'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Configurar presupuesto'),
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
