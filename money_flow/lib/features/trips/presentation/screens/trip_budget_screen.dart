import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/custom_snackbar.dart';
import '../../data/models/trip_models.dart';
import '../providers/active_trip_provider.dart';

class TripBudgetScreen extends StatelessWidget {
  final int tripId;
  const TripBudgetScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveTripProvider>(
      builder: (context, provider, _) {
        final trip = provider.trip;
        final allocations = provider.allocations;
        if (trip == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final formatter = NumberFormat.currency(
          name: trip.primaryCurrency,
          symbol: '${trip.primaryCurrency} ',
          decimalDigits: 2,
        );

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openEditor(context, trip, allocations),
            icon: const Icon(Icons.tune),
            label: const Text('Editar presupuesto'),
          ),
          body: RefreshIndicator(
            onRefresh: () => context.read<ActiveTripProvider>().load(tripId),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _buildTotalsCard(context, trip, formatter),
                const SizedBox(height: 16),
                if (allocations.isEmpty)
                  _buildEmpty(context)
                else
                  ...allocations.map(
                    (a) => _AllocationCard(
                      allocation: a,
                      formatter: formatter,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart,
            size: 56,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'Aún no defines un presupuesto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Asigna un monto estimado a cada categoría de gasto del viaje.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsCard(
    BuildContext context,
    Trip trip,
    NumberFormat formatter,
  ) {
    final daily = trip.daysRemaining > 0
        ? (trip.remainingAmount / trip.daysRemaining).clamp(0.0, double.infinity)
        : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total estimado',
            style: TextStyle(
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatter.format(trip.estimatedTotal),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Gastado',
                  value: formatter.format(trip.spentTotal),
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: 'Disponible',
                  value: formatter.format(trip.remainingAmount),
                  color: trip.remainingAmount < 0
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MetricTile(
            label: 'Sugerido por día',
            value: formatter.format(daily),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    Trip trip,
    List<TripAllocation> existing,
  ) async {
    final result = await showModalBottomSheet<List<Map<String, dynamic>>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BudgetEditor(trip: trip, allocations: existing),
    );
    if (result == null || !context.mounted) return;
    final provider = context.read<ActiveTripProvider>();
    final ok = await provider.upsertBudget(result);
    if (!context.mounted) return;
    if (ok) {
      CustomSnackBar.showSuccess(context, 'Presupuesto actualizado');
    } else {
      CustomSnackBar.showError(
          context, provider.error ?? 'No se pudo guardar el presupuesto');
    }
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllocationCard extends StatelessWidget {
  final TripAllocation allocation;
  final NumberFormat formatter;

  const _AllocationCard({required this.allocation, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final progress = (allocation.progressPercent / 100).clamp(0.0, 1.5);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    allocation.category?.displayName ??
                        allocation.category?.name ??
                        'Categoría',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  formatter.format(allocation.estimatedAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress > 1.5 ? 1.5 : progress,
                minHeight: 6,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gastado: ${formatter.format(allocation.spentAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  'Sugerido/día: ${formatter.format(allocation.dailySuggested)}',
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
          ],
        ),
      ),
    );
  }
}

class _BudgetEditor extends StatefulWidget {
  final Trip trip;
  final List<TripAllocation> allocations;

  const _BudgetEditor({required this.trip, required this.allocations});

  @override
  State<_BudgetEditor> createState() => _BudgetEditorState();
}

class _BudgetEditorState extends State<_BudgetEditor> {
  final List<_EditableAllocation> _items = [];

  @override
  void initState() {
    super.initState();
    for (final a in widget.allocations) {
      _items.add(_EditableAllocation(
        categoryId: a.category?.id,
        categoryName: a.category?.displayName ??
            a.category?.name ??
            'Categoría sin nombre',
        controller: TextEditingController(text: a.estimatedAmount.toStringAsFixed(2)),
      ));
    }
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.controller.dispose();
    }
    super.dispose();
  }

  void _addCategoryDialog() async {
    final result = await showDialog<_NewCategoryInput>(
      context: context,
      builder: (_) => const _AddCategoryDialog(),
    );
    if (result == null) return;
    setState(() {
      _items.add(_EditableAllocation(
        categoryId: result.categoryId,
        categoryName: result.name,
        controller: TextEditingController(text: result.amount.toStringAsFixed(2)),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Editar presupuesto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _addCategoryDialog,
                    icon: const Icon(Icons.add),
                    tooltip: 'Agregar categoría',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(item.categoryName),
                        ),
                        Expanded(
                          flex: 4,
                          child: TextField(
                            controller: item.controller,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              prefixText: '${widget.trip.primaryCurrency} ',
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              item.controller.dispose();
                              _items.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar presupuesto',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final result = <Map<String, dynamic>>[];
    for (final item in _items) {
      if (item.categoryId == null) continue;
      final amount = double.tryParse(item.controller.text.trim()) ?? 0;
      result.add({
        'category_id': item.categoryId,
        'estimated_amount': amount,
        'currency': widget.trip.primaryCurrency,
      });
    }
    Navigator.of(context).pop(result);
  }
}

class _EditableAllocation {
  final int? categoryId;
  final String categoryName;
  final TextEditingController controller;

  _EditableAllocation({
    required this.categoryId,
    required this.categoryName,
    required this.controller,
  });
}

class _NewCategoryInput {
  final int categoryId;
  final String name;
  final double amount;

  _NewCategoryInput({
    required this.categoryId,
    required this.name,
    required this.amount,
  });
}

class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog();

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar categoría'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _idController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ID de categoría'),
          ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Monto estimado'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final id = int.tryParse(_idController.text.trim());
            final amount = double.tryParse(_amountController.text.trim()) ?? 0;
            if (id == null || _nameController.text.trim().isEmpty) {
              return;
            }
            Navigator.pop(
              context,
              _NewCategoryInput(
                categoryId: id,
                name: _nameController.text.trim(),
                amount: amount,
              ),
            );
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
