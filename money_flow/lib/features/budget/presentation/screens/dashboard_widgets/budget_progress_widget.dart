import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_motion.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../providers/dashboard_provider.dart';
import '../../../../../core/providers/currency_provider.dart';

class BudgetProgressWidget extends StatelessWidget {
  const BudgetProgressWidget({super.key});

  static void _showRolloverInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.event_repeat,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '¿Qué es el rollover diario?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        content: Text(
          'Es el presupuesto que te queda para el mes dividido entre los días que faltan. '
          'Indica cuánto podrías gastar por día de media para no pasarte del presupuesto mensual.\n\n'
          'Por ejemplo: si te quedan \$300 y faltan 10 días, tu rollover diario sería \$30.',
          style: AppTypography.bodyMd.copyWith(
            height: 1.4,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Entendido',
              style: AppTypography.labelLg.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CurrencyProvider, DashboardProvider>(
      builder: (context, currencyProvider, dashboardProvider, child) {
        final progressPercent = (dashboardProvider.budgetProgressValue.clamp(0.0, 1.0) * 100).round();
        return GlassmorphismCard(
          style: GlassStyles.medium,
          enableEntryAnimation: true,
          enableHoverEffect: true,
          animationDuration: AppMotion.entryCardCinematic,
          padding: AppSpacing.cardLg,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.analytics,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRESUPUESTO MENSUAL',
                    style: AppTypography.customEyebrow,
                  ),
                  const SizedBox(height: AppSpacing.step1),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        currencyProvider.formatAmount(dashboardProvider.budgetSpent),
                        style: AppTypography.customAmountHero.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.step2),
                      Text(
                        '/ ${currencyProvider.formatAmount(dashboardProvider.budgetTotal)}',
                        style: AppTypography.bodyMd.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.step4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gastado vs Total',
                        style: AppTypography.labelMd.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        '$progressPercent%',
                        style: AppTypography.labelMd.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.step2),
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.progressBackground,
                      borderRadius: BorderRadius.circular(AppRadius.xs + 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xs + 1),
                      child: LinearProgressIndicator(
                        value: dashboardProvider.budgetProgressValue.clamp(0.0, 1.0),
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.progressBar),
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.step4),
                  GestureDetector(
                    onTap: () => _showRolloverInfo(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.step3,
                        vertical: AppSpacing.step1 + 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: AppRadius.allXl,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_repeat,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.step2),
                          Text(
                            'Rollover diario: ${currencyProvider.formatAmount(dashboardProvider.dailyRollover)}',
                            style: AppTypography.labelMd.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.step1 + 2),
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
