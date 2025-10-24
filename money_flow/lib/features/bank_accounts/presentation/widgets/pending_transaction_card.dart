import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphismCard(
        style: isSelected ? GlassStyles.heavy : GlassStyles.medium,
        enableHoverEffect: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                _buildTransactionInfo(context),
                const SizedBox(height: 12),
                _buildConfidenceIndicator(context),
                if (transaction.rawNotification != null) ...[
                  const SizedBox(height: 12),
                  _buildRawNotification(context),
                ],
                if (!isSelectionMode) ...[
                  const SizedBox(height: 16),
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
    return Row(
      children: [
        if (isSelectionMode) ...[
          Checkbox(
            value: isSelected,
            onChanged: (_) => onTap?.call(),
          ),
          const SizedBox(width: 8),
        ],
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getTransactionColor(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTransactionIcon(),
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.description,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.smartphone,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    transaction.sourceDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(transaction.createdDateTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getAmountColor(context),
              ),
            ),
            const SizedBox(height: 4),
            if (transaction.bankAccountAlias != null)
              Text(
                transaction.bankAccountAlias!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'Fecha de transacción: ${_formatTransactionDate(transaction.transactionDateTime)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          if (transaction.categoryName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.category,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Categoría: ${transaction.categoryName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
          if (transaction.merchant != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.store,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Comercio: ${transaction.merchant}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
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
    
    Color confidenceColor;
    String confidenceText;
    IconData confidenceIcon;
    
    if (confidence >= 0.8) {
      confidenceColor = Colors.green;
      confidenceText = 'Alta confianza';
      confidenceIcon = Icons.check_circle;
    } else if (confidence >= 0.5) {
      confidenceColor = Colors.orange;
      confidenceText = 'Confianza media';
      confidenceIcon = Icons.warning;
    } else {
      confidenceColor = Colors.red;
      confidenceText = 'Baja confianza';
      confidenceIcon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: confidenceColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: confidenceColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            confidenceIcon,
            size: 16,
            color: confidenceColor,
          ),
          const SizedBox(width: 8),
          Text(
            '$confidenceText ($percentage%)',
            style: TextStyle(
              fontSize: 12,
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
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: confidence,
              child: Container(
                decoration: BoxDecoration(
                  color: confidenceColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRawNotification(BuildContext context) {
    return ExpansionTile(
      title: Text(
        'Notificación original',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            transaction.rawNotification!,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassmorphismButton(
            style: GlassButtonStyles.outline,
            onPressed: onReject,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.close, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Rechazar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GlassmorphismButton(
            style: GlassButtonStyles.outline,
            onPressed: onEdit,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Editar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GlassmorphismButton(
            style: GlassButtonStyles.primary,
            onPressed: onApprove,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Aprobar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
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
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
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
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
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
