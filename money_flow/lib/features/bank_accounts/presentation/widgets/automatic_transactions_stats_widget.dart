import 'package:flutter/material.dart';
import 'package:money_flow/core/theme/app_colors.dart';
import 'package:money_flow/core/theme/app_radius.dart';
import 'package:money_flow/core/theme/app_spacing.dart';
import 'package:money_flow/core/theme/app_typography.dart';
import 'package:money_flow/features/bank_accounts/data/repositories/automatic_transactions_repository.dart';
import 'package:money_flow/features/bank_accounts/presentation/providers/automatic_transactions_provider.dart';
import 'package:money_flow/shared/widgets/glassmorphism_widgets.dart';
import 'package:provider/provider.dart';

class AutomaticTransactionsStatsWidget extends StatefulWidget {
  const AutomaticTransactionsStatsWidget({super.key});

  @override
  State<AutomaticTransactionsStatsWidget> createState() =>
      _AutomaticTransactionsStatsWidgetState();
}

class _AutomaticTransactionsStatsWidgetState
    extends State<AutomaticTransactionsStatsWidget> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _loadStats();
        _hasLoaded = true;
      }
    });
  }

  void _loadStats() {
    final provider = Provider.of<AutomaticTransactionsProvider>(context, listen: false);
    provider.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AutomaticTransactionsProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;

        if (stats == null) {
          return _buildLoadingState();
        }

        return GlassmorphismCard(
          style: GlassStyles.medium,
          enableHoverEffect: true,
          enableEntryAnimation: true,
          child: Padding(
            padding: AppSpacing.glass,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, stats),
                const SizedBox(height: AppSpacing.glassPadding),
                _buildStatsGrid(context, stats),
                if (provider.pendingCount > 0) ...[
                  const SizedBox(height: AppSpacing.step4),
                  _buildPendingAlert(context, provider.pendingCount),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const GlassmorphismCard(
      style: GlassStyles.medium,
      child: SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AutomaticTransactionStats stats) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: AppRadius.allBase,
          ),
          child: Icon(
            Icons.auto_awesome,
            color: scheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.step4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transacciones Automáticas',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                'Últimos 30 días',
                style: AppTypography.bodyMd.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _loadStats,
          icon: Icon(
            Icons.refresh,
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, AutomaticTransactionStats stats) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total',
                stats.totalAutomatic.toString(),
                Icons.receipt_long,
                primary,
              ),
            ),
            const SizedBox(width: AppSpacing.step3),
            Expanded(
              child: _buildStatCard(
                context,
                'Aprobadas',
                stats.totalApproved.toString(),
                Icons.check_circle,
                AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.step3),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Pendientes',
                stats.totalPending.toString(),
                Icons.pending,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.step3),
            Expanded(
              child: _buildStatCard(
                context,
                'Confianza',
                '${(stats.averageConfidence * 100).round()}%',
                Icons.psychology,
                _getConfidenceColor(stats.averageConfidence),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.step3),
        _buildApprovalRateCard(context, stats),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: AppRadius.allBase,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const Spacer(),
              Text(
                value,
                style: AppTypography.titleLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.step2),
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalRateCard(BuildContext context, AutomaticTransactionStats stats) {
    final approvalRate = stats.approvalRate;
    final percentage = (approvalRate * 100).round();
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: AppRadius.allBase,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 20,
                color: _getApprovalRateColor(approvalRate),
              ),
              const SizedBox(width: AppSpacing.step2),
              Text(
                'Tasa de Aprobación',
                style: AppTypography.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '$percentage%',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getApprovalRateColor(approvalRate),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.step3),
          LinearProgressIndicator(
            value: approvalRate,
            backgroundColor: scheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getApprovalRateColor(approvalRate),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAlert(BuildContext context, int pendingCount) {
    final scheme = Theme.of(context).colorScheme;
    return GlassmorphismButton(
      style: GlassButtonStyles.outline,
      onPressed: () {
        Navigator.of(context).pushNamed('/pending-transactions');
      },
      child: Container(
        width: double.infinity,
        padding: AppSpacing.card,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: AppRadius.allPill,
              ),
              child: const Icon(
                Icons.notification_important,
                color: AppColors.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.step4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$pendingCount transacciones pendientes',
                    style: AppTypography.titleSm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    'Toca para revisar y aprobar',
                    style: AppTypography.bodySm.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.success;
    if (confidence >= 0.6) return AppColors.warning;
    return AppColors.error;
  }

  Color _getApprovalRateColor(double rate) {
    if (rate >= 0.8) return AppColors.success;
    if (rate >= 0.6) return AppColors.warning;
    return AppColors.error;
  }
}
