import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
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
        if (provider.isLoading) {
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
        padding: const EdgeInsets.all(20),
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
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error al cargar cuentas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Toca para reintentar',
                    style: TextStyle(
                      fontSize: 14,
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_card,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agregar Cuenta Bancaria',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Conecta tus cuentas para un mejor control',
                      style: TextStyle(
                        fontSize: 14,
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
        const SizedBox(height: 16),
        _buildAccountsList(provider),
      ],
    );
  }

  Widget _buildSectionHeader(BankAccountProvider provider) {
    return Row(
      children: [
        Text(
          'Cuentas Bancarias',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/bank-accounts'),
          child: Text(
            'Ver todas (${provider.bankAccountSummary.length})',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountsList(BankAccountProvider provider) {
    final accounts = provider.bankAccountSummary.take(3).toList(); // Mostrar solo las primeras 3

    return Column(
      children: [
        ...accounts.map((account) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAccountCard(account),
        )),
        if (provider.bankAccountSummary.length > 3)
          GlassmorphismCard(
            style: GlassStyles.light,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/bank-accounts'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.more_horiz,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ver ${provider.bankAccountSummary.length - 3} cuentas más',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAccountCard(BankAccountSummaryModel account) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return GlassmorphismCard(
          style: GlassStyles.light,
          enableHoverEffect: true,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/bank-accounts'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(account.color.replaceFirst('#', '0xFF'))),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getAccountIcon(account.type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.accountAlias,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${account.shortBankName} ${account.accountNumberMask}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${currencyProvider.currencySymbol}${account.lastBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: account.lastBalance >= 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                      ),
                      if (!account.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Inactiva',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
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
}
