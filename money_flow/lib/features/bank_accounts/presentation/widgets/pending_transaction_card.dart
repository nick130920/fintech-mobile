import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_flow/core/theme/app_colors.dart';
import 'package:money_flow/core/theme/app_radius.dart';
import 'package:money_flow/core/theme/app_spacing.dart';
import 'package:money_flow/core/theme/app_typography.dart';
import 'package:money_flow/features/bank_accounts/data/models/transaction_model.dart';
import 'package:money_flow/shared/widgets/glassmorphism_widgets.dart';

class PendingTransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onEdit;

  const PendingTransactionCard({
    super.key,
    required this.transaction,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onTap,
    this.onApprove,
    this.onReject,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.step3),
      child: GlassmorphismCard(
        style: isSelected ? GlassStyles.heavy : GlassStyles.medium,
        enableHoverEffect: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.allLg,
          child: Padding(
            padding: AppSpacing.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.step3),
                _buildTransactionInfo(context),
                const SizedBox(height: AppSpacing.step3),
                _buildConfidenceIndicator(context),
                if (transaction.rawNotification != null) ...[
                  const SizedBox(height: AppSpacing.step3),
                  _buildRawNotification(context),
                ],
                if (!isSelectionMode) ...[
                  const SizedBox(height: AppSpacing.step4),
                  _buildActionButtons(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mutedColor = scheme.onSurface.withValues(alpha: 0.6);
    final mutedStyle = AppTypography.bodySm.copyWith(color: mutedColor);

    return Row(
      children: [
        if (isSelectionMode) ...[
          Checkbox(
            value: isSelected,
            onChanged: (_) => onTap?.call(),
          ),
          const SizedBox(width: AppSpacing.step2),
        ],
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getTransactionColor(context),
            borderRadius: AppRadius.allBase,
          ),
          child: Icon(
            _getTransactionIcon(),
            color: AppColors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.step3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.description,
                style: AppTypography.titleSm.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.step1),
              Row(
                children: [
                  Icon(Icons.smartphone, size: 14, color: mutedColor),
                  const SizedBox(width: AppSpacing.step1),
                  Text(transaction.sourceDisplayName, style: mutedStyle),
                  const SizedBox(width: AppSpacing.step2),
                  Icon(Icons.access_time, size: 14, color: mutedColor),
                  const SizedBox(width: AppSpacing.step1),
                  Text(_formatDate(transaction.createdDateTime), style: mutedStyle),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              transaction.formattedAmount,
              style: AppTypography.customAmountCard.copyWith(
                color: _getAmountColor(context),
              ),
            ),
            const SizedBox(height: AppSpacing.step1),
            if (transaction.bankAccountAlias != null)
              Text(transaction.bankAccountAlias!, style: mutedStyle),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionInfo(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = scheme.onSurface.withValues(alpha: 0.6);
    final textStyle = AppTypography.bodyMd.copyWith(
      color: scheme.onSurface.withValues(alpha: 0.8),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.step3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: AppRadius.allSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: iconColor),
              const SizedBox(width: AppSpacing.step2),
              Text(
                'Fecha de transacción: ${_formatTransactionDate(transaction.transactionDateTime)}',
                style: textStyle,
              ),
            ],
          ),
          if (transaction.categoryName != null) ...[
            const SizedBox(height: AppSpacing.step2),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: iconColor),
                const SizedBox(width: AppSpacing.step2),
                Text('Categoría: ${transaction.categoryName}', style: textStyle),
              ],
            ),
          ],
          if (transaction.merchant != null) ...[
            const SizedBox(height: AppSpacing.step2),
            Row(
              children: [
                Icon(Icons.store, size: 16, color: iconColor),
                const SizedBox(width: AppSpacing.step2),
                Expanded(
                  child: Text('Comercio: ${transaction.merchant}', style: textStyle),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator(BuildContext context) {
    final confidence = transaction.aiConfidence;
    final percentage = (confidence * 100).round();

    final Color confidenceColor;
    final String confidenceText;
    final IconData confidenceIcon;

    if (confidence >= 0.8) {
      confidenceColor = AppColors.success;
      confidenceText = 'Alta confianza';
      confidenceIcon = Icons.check_circle;
    } else if (confidence >= 0.5) {
      confidenceColor = AppColors.warning;
      confidenceText = 'Confianza media';
      confidenceIcon = Icons.warning;
    } else {
      confidenceColor = AppColors.error;
      confidenceText = 'Baja confianza';
      confidenceIcon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.step3,
        vertical: AppSpacing.step2,
      ),
      decoration: BoxDecoration(
        color: confidenceColor.withValues(alpha: 0.1),
        borderRadius: AppRadius.allSm,
        border: Border.all(color: confidenceColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(confidenceIcon, size: 16, color: confidenceColor),
          const SizedBox(width: AppSpacing.step2),
          Text(
            '$confidenceText ($percentage%)',
            style: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.w600,
              color: confidenceColor,
            ),
          ),
          const Spacer(),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: confidenceColor.withValues(alpha: 0.2),
              borderRadius: AppRadius.allXs,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: confidence,
              child: Container(
                decoration: BoxDecoration(
                  color: confidenceColor,
                  borderRadius: AppRadius.allXs,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRawNotification(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExpansionTile(
      title: Text(
        'Notificación original',
        style: AppTypography.labelLg.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.step3),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.step4),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: AppRadius.allSm,
          ),
          child: Text(
            transaction.rawNotification!,
            style: AppTypography.bodySm.copyWith(
              fontFamily: 'monospace',
              color: scheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.step4),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = AppTypography.labelLg.copyWith(fontWeight: FontWeight.w600);

    return Row(
      children: [
        Expanded(
          child: GlassmorphismButton(
            style: GlassButtonStyles.outline,
            onPressed: onReject,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.close, size: 18, color: AppColors.error),
                const SizedBox(width: AppSpacing.step2),
                Text('Rechazar', style: labelStyle.copyWith(color: AppColors.error)),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.step2),
        Expanded(
          child: GlassmorphismButton(
            style: GlassButtonStyles.outline,
            onPressed: onEdit,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, size: 18, color: scheme.primary),
                const SizedBox(width: AppSpacing.step2),
                Text('Editar', style: labelStyle.copyWith(color: scheme.primary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.step2),
        Expanded(
          child: GlassmorphismButton(
            style: GlassButtonStyles.primary,
            onPressed: onApprove,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check, size: 18, color: AppColors.white),
                const SizedBox(width: AppSpacing.step2),
                Text('Aprobar', style: labelStyle.copyWith(color: AppColors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getTransactionColor(BuildContext context) {
    switch (transaction.type) {
      case TransactionType.income:
        return AppColors.success;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.transfer:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getTransactionIcon() {
    switch (transaction.type) {
      case TransactionType.income:
        return Icons.trending_up;
      case TransactionType.expense:
        return Icons.trending_down;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  Color _getAmountColor(BuildContext context) {
    switch (transaction.type) {
      case TransactionType.income:
        return AppColors.success;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.transfer:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return 'Ayer ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días';
    } else {
      return DateFormat('dd/MM/yy').format(date);
    }
  }

  String _formatTransactionDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
