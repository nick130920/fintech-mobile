import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/custom_snackbar.dart';
import '../../data/models/trip_models.dart';
import '../providers/active_trip_provider.dart';
import '../providers/trip_balance_provider.dart';

class TripBalanceScreen extends StatefulWidget {
  final int tripId;
  const TripBalanceScreen({super.key, required this.tripId});

  @override
  State<TripBalanceScreen> createState() => _TripBalanceScreenState();
}

class _TripBalanceScreenState extends State<TripBalanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripBalanceProvider>().load(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripBalanceProvider>(
      builder: (context, balanceProvider, _) {
        if (balanceProvider.isLoading && balanceProvider.balance == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final balance = balanceProvider.balance;
        if (balance == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    balanceProvider.error ?? 'Sin datos de balance',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        context.read<TripBalanceProvider>().load(widget.tripId),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }
        final formatter = NumberFormat.currency(
          name: balance.currency,
          symbol: '${balance.currency} ',
          decimalDigits: 2,
        );

        return RefreshIndicator(
          onRefresh: () => context.read<TripBalanceProvider>().load(widget.tripId),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              Text(
                'Balance neto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...balance.netByMember.map((m) => _NetMemberTile(
                    member: m,
                    formatter: formatter,
                  )),
              const SizedBox(height: 24),
              Text(
                'Transferencias sugeridas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (balance.transfers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    '¡Todo saldado! No hay deudas pendientes.',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                )
              else
                ...balance.transfers.map(
                  (t) => _TransferTile(
                    transfer: t,
                    currency: balance.currency,
                    formatter: formatter,
                    onSettle: () => _registerSettlement(t, balance.currency),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Pagos registrados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (balanceProvider.settlements.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Aún no se han registrado pagos.',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                )
              else
                ...balanceProvider.settlements.map(
                  (s) => _SettlementTile(
                    settlement: s,
                    formatter: formatter,
                    onDelete: () => _confirmDeleteSettlement(s),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _registerSettlement(
    TripBalanceTransfer transfer,
    String currency,
  ) async {
    final controller = TextEditingController(text: transfer.amount.toStringAsFixed(2));
    final notesController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Registrar pago de ${transfer.fromName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Para: ${transfer.toName}'),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Monto',
                prefixText: '$currency ',
              ),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notas (opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
    if (saved != true || !mounted) return;

    final amount = double.tryParse(controller.text.trim()) ?? 0;
    if (amount <= 0) return;

    final body = <String, dynamic>{
      'from_member_id': transfer.fromMemberId,
      'to_member_id': transfer.toMemberId,
      'amount': amount,
      'currency': currency,
      'paid_at': DateTime.now().toUtc().toIso8601String(),
      if (notesController.text.trim().isNotEmpty)
        'notes': notesController.text.trim(),
    };

    final balanceProvider = context.read<TripBalanceProvider>();
    final result = await balanceProvider.createSettlement(widget.tripId, body);
    if (!mounted) return;
    if (result != null) {
      CustomSnackBar.showSuccess(context, 'Pago registrado');
      await context.read<ActiveTripProvider>().refreshTrip();
    } else {
      CustomSnackBar.showError(
          context, balanceProvider.error ?? 'No se pudo registrar el pago');
    }
  }

  Future<void> _confirmDeleteSettlement(Settlement settlement) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar pago'),
        content:
            Text('¿Eliminar el pago de ${settlement.fromName} a ${settlement.toName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final provider = context.read<TripBalanceProvider>();
    final ok = await provider.deleteSettlement(widget.tripId, settlement.id);
    if (!mounted) return;
    if (ok) {
      CustomSnackBar.showSuccess(context, 'Pago eliminado');
    } else {
      CustomSnackBar.showError(
          context, provider.error ?? 'No se pudo eliminar el pago');
    }
  }
}

class _NetMemberTile extends StatelessWidget {
  final TripBalanceMember member;
  final NumberFormat formatter;
  const _NetMemberTile({required this.member, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final isCreditor = member.netAmount > 0;
    final isDebtor = member.netAmount < 0;
    final color = isCreditor
        ? Theme.of(context).colorScheme.primary
        : isDebtor
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.onSurface;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              member.memberName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            (member.netAmount >= 0 ? '+' : '') + formatter.format(member.netAmount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferTile extends StatelessWidget {
  final TripBalanceTransfer transfer;
  final String currency;
  final NumberFormat formatter;
  final VoidCallback onSettle;

  const _TransferTile({
    required this.transfer,
    required this.currency,
    required this.formatter,
    required this.onSettle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.swap_horiz,
              color: Theme.of(context).colorScheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${transfer.fromName} debe ${formatter.format(transfer.amount)} a ${transfer.toName}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: onSettle,
            child: const Text('Marcar pagado'),
          ),
        ],
      ),
    );
  }
}

class _SettlementTile extends StatelessWidget {
  final Settlement settlement;
  final NumberFormat formatter;
  final VoidCallback onDelete;

  const _SettlementTile({
    required this.settlement,
    required this.formatter,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM y', 'es');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.payments_outlined,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${settlement.fromName} → ${settlement.toName}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${formatter.format(settlement.amount)} · ${dateFormat.format(settlement.paidAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Eliminar pago',
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
