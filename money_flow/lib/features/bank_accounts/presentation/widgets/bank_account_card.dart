import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../data/models/bank_account_model.dart';

class BankAccountCard extends StatelessWidget {
  final BankAccountModel account;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isSelected;

  const BankAccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      style: isSelected ? GlassStyles.heavy : GlassStyles.medium,
      enableHoverEffect: true,
      enableEntryAnimation: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.allBase,
        child: Container(
          padding: AppSpacing.glass,
          decoration: BoxDecoration(
            borderRadius: AppRadius.allBase,
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.step4),
              _buildAccountInfo(context),
              const SizedBox(height: AppSpacing.step4),
              _buildBalance(context),
              if (showActions) ...[
                const SizedBox(height: AppSpacing.step4),
                _buildActions(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(int.parse(account.color.replaceFirst('#', '0xFF'))),
            borderRadius: AppRadius.allBase,
          ),
          child: Icon(
            _getAccountIcon(account.type),
            color: AppColors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.step4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.accountAlias,
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                account.shortBankName,
                style: AppTypography.bodyMd.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        if (!account.isActive)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.step2,
              vertical: AppSpacing.step1,
            ),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: AppRadius.allSm,
            ),
            child: Text(
              'Inactiva',
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onErrorContainer,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAccountInfo(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoItem(
            context,
            'Número',
            account.accountNumberMask,
            Icons.credit_card,
          ),
        ),
        const SizedBox(width: AppSpacing.step4),
        Expanded(
          child: _buildInfoItem(
            context,
            'Tipo',
            account.typeDisplayName,
            _getAccountIcon(account.type),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.step3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: AppRadius.allSm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: scheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: AppSpacing.step2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySm.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.labelLg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalance(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        final isPositive = account.lastBalance >= 0;
        final formattedBalance = currencyProvider.formatAmountWithCode(
          account.lastBalance,
          account.currency,
        );

        final scheme = Theme.of(context).colorScheme;
        final fgColor = isPositive ? scheme.onPrimaryContainer : scheme.onErrorContainer;
        return Container(
          width: double.infinity,
          padding: AppSpacing.card,
          decoration: BoxDecoration(
            color: isPositive ? scheme.primaryContainer : scheme.errorContainer,
            borderRadius: AppRadius.allBase,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    size: 20,
                    color: fgColor,
                  ),
                  const SizedBox(width: AppSpacing.step2),
                  Text(
                    'Balance Actual',
                    style: AppTypography.bodyMd.copyWith(color: fgColor),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.step2),
              Text(
                formattedBalance,
                style: AppTypography.headlineMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: fgColor,
                ),
              ),
              if (account.hasMeaningfulLastBalanceUpdate) ...[
                const SizedBox(height: AppSpacing.step1),
                Text(
                  'Actualizado: ${_formatDate(account.lastBalanceUpdate)}',
                  style: AppTypography.bodySm.copyWith(
                    color: fgColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return Row(
      children: [
        Expanded(
          child: GlassmorphismButton(
            style: GlassButtonStyles.outline,
            onPressed: onEdit,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, size: 16),
                SizedBox(width: AppSpacing.step2),
                Text('Editar'),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.step3),
        Expanded(
          child: GlassmorphismButton(
            style: GlassButtonStyles.outline,
            onPressed: onDelete,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, size: 16, color: error),
                const SizedBox(width: AppSpacing.step2),
                Text('Eliminar', style: TextStyle(color: error)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getAccountIcon(BankAccountType type) {
    switch (type) {
      case BankAccountType.checking:
        return Icons.account_balance;
      case BankAccountType.savings:
        return Icons.savings;
      case BankAccountType.credit:
        return Icons.credit_card;
      case BankAccountType.debit:
        return Icons.payment;
      case BankAccountType.investment:
        return Icons.trending_up;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Hoy';
      } else if (difference.inDays == 1) {
        return 'Ayer';
      } else if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} días';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'N/A';
    }
  }
}
