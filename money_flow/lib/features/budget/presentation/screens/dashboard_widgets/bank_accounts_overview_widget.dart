import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../../../bank_accounts/data/models/bank_account_model.dart';
import '../../../../bank_accounts/presentation/providers/bank_account_provider.dart';

class BankAccountsOverviewWidget extends StatefulWidget {
  const BankAccountsOverviewWidget({super.key});

  @override
  State<BankAccountsOverviewWidget> createState() => _BankAccountsOverviewWidgetState();
}

class _BankAccountsOverviewWidgetState extends State<BankAccountsOverviewWidget> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _hasLoaded = true;
        context.read<BankAccountProvider>().loadBankAccountSummary();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BankAccountProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && !provider.hasCachedSummary) {
          return _buildLoadingState();
        }

        if (provider.error != null) {
          return _buildErrorState();
        }

        if (provider.bankAccountSummary.isEmpty) {
          return _buildEmptyState();
        }

        return _buildAccountsOverview(provider);
      },
    );
  }

  Widget _buildLoadingState() {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Container(
        height: 120,
        padding: AppSpacing.glass,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: AppSpacing.glass,
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.inlineGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error al cargar cuentas',
                    style: AppTypography.titleSm.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Toca para reintentar',
                    style: AppTypography.bodyMd.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.read<BankAccountProvider>().refresh(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/add-bank-account'),
        borderRadius: AppRadius.allBase,
        child: Padding(
          padding: AppSpacing.glass,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: AppRadius.allBase,
                ),
                child: Icon(
                  Icons.add_card,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.cardGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agregar Cuenta Bancaria',
                      style: AppTypography.titleSm.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Conecta tus cuentas para un mejor control',
                      style: AppTypography.bodyMd.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountsOverview(BankAccountProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(provider),
        const SizedBox(height: AppSpacing.cardGap),
        _buildAccountsList(provider),
      ],
    );
  }

  Widget _buildSectionHeader(BankAccountProvider provider) {
    return Row(
      children: [
        Text(
          'Cuentas Bancarias',
          style: AppTypography.titleMd.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/bank-accounts'),
          child: Text(
            'Ver todas',
            style: AppTypography.labelLg.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountsList(BankAccountProvider provider) {
    final accounts = provider.bankAccountSummary;
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: AppSpacing.step2),
        itemCount: accounts.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.cardGap),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 200,
            child: _buildAccountCard(accounts[index]),
          );
        },
      ),
    );
  }

  Widget _buildAccountCard(BankAccountSummaryModel account) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        final borderColor = _parseColor(account.color);
        return GlassmorphismCard(
          style: GlassStyles.light,
          enableHoverEffect: true,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/bank-accounts'),
            borderRadius: AppRadius.allBase,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.allBase,
                border: Border(
                  left: BorderSide(color: borderColor, width: 4),
                ),
              ),
              padding: AppSpacing.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: AppRadius.allLg,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          account.shortBankName.length >= 2
                              ? account.shortBankName.substring(0, 2).toUpperCase()
                              : '??',
                          style: AppTypography.labelSm.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.inlineGap),
                      Expanded(
                        child: Text(
                          account.accountAlias,
                          style: AppTypography.labelLg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance Actual',
                        style: AppTypography.labelMd.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        currencyProvider.formatAmountWithCode(account.lastBalance, account.currency),
                        style: AppTypography.customAmountCard.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Theme.of(context).colorScheme.primary;
    }
  }
}
