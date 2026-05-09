import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/custom_snackbar.dart';
import '../../data/models/trip_models.dart';
import '../providers/active_trip_provider.dart';

class TripItineraryScreen extends StatelessWidget {
  final int tripId;
  const TripItineraryScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveTripProvider>(
      builder: (context, provider, _) {
        final trip = provider.trip;
        if (trip == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final itinerary = provider.itinerary;
        final grouped = _groupByDay(itinerary);
        final dateFormat = DateFormat('EEEE d MMM', 'es');
        final amountFormat = NumberFormat.currency(
          name: trip.primaryCurrency,
          symbol: '${trip.primaryCurrency} ',
          decimalDigits: 2,
        );

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addItem(context),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo item'),
          ),
          body: itinerary.isEmpty
              ? _buildEmpty(context)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            dateFormat.format(entry.key),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        ...entry.value.map(
                          (item) => _ItineraryTile(
                            item: item,
                            amountFormat: amountFormat,
                            onTap: () => _editItem(context, item),
                            onDelete: () => _confirmDelete(context, item),
                            onLink: () => _linkExpense(context, item),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.event_note,
          size: 64,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Sin items en el itinerario',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () => _addItem(context),
            icon: const Icon(Icons.add),
            label: const Text('Agregar primer item'),
          ),
        ),
      ],
    );
  }

  Map<DateTime, List<TripItineraryItem>> _groupByDay(
    List<TripItineraryItem> items,
  ) {
    final map = <DateTime, List<TripItineraryItem>>{};
    for (final item in items) {
      final key = DateTime(item.day.year, item.day.month, item.day.day);
      map.putIfAbsent(key, () => []).add(item);
    }
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    for (final entry in sorted.entries) {
      entry.value.sort((a, b) => a.time.compareTo(b.time));
    }
    return sorted;
  }

  Future<void> _addItem(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ItineraryEditor(),
    );
    if (result == null || !context.mounted) return;
    final provider = context.read<ActiveTripProvider>();
    final created = await provider.addItineraryItem(result);
    if (!context.mounted) return;
    if (created != null) {
      CustomSnackBar.showSuccess(context, 'Item agregado');
    } else {
      CustomSnackBar.showError(
          context, provider.error ?? 'No se pudo agregar el item');
    }
  }

  Future<void> _editItem(BuildContext context, TripItineraryItem item) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItineraryEditor(initial: item),
    );
    if (result == null || !context.mounted) return;
    final provider = context.read<ActiveTripProvider>();
    final ok = await provider.updateItineraryItem(item.id, result);
    if (!context.mounted) return;
    if (ok) {
      CustomSnackBar.showSuccess(context, 'Item actualizado');
    } else {
      CustomSnackBar.showError(
          context, provider.error ?? 'No se pudo actualizar el item');
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TripItineraryItem item,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar item'),
        content: Text('¿Eliminar "${item.title}" del itinerario?'),
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
    if (confirm != true || !context.mounted) return;
    final provider = context.read<ActiveTripProvider>();
    final ok = await provider.removeItineraryItem(item.id);
    if (!context.mounted) return;
    if (ok) {
      CustomSnackBar.showSuccess(context, 'Item eliminado');
    } else {
      CustomSnackBar.showError(
          context, provider.error ?? 'No se pudo eliminar el item');
    }
  }

  Future<void> _linkExpense(
    BuildContext context,
    TripItineraryItem item,
  ) async {
    final expenses = context.read<ActiveTripProvider>().expenses;
    if (expenses.isEmpty) {
      CustomSnackBar.showWarning(context, 'Aún no hay gastos para vincular');
      return;
    }
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExpensePickerSheet(expenses: expenses),
    );
    if (selected == null || !context.mounted) return;
    final provider = context.read<ActiveTripProvider>();
    final ok = await provider.linkItineraryExpense(item.id, selected);
    if (!context.mounted) return;
    if (ok) {
      CustomSnackBar.showSuccess(context, 'Gasto vinculado');
    } else {
      CustomSnackBar.showError(
          context, provider.error ?? 'No se pudo vincular el gasto');
    }
  }
}

class _ItineraryTile extends StatelessWidget {
  final TripItineraryItem item;
  final NumberFormat amountFormat;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onLink;

  const _ItineraryTile({
    required this.item,
    required this.amountFormat,
    required this.onTap,
    required this.onDelete,
    required this.onLink,
  });

  @override
  Widget build(BuildContext context) {
    final hasExpense = item.expenseId != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            _iconFor(item.type),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.type.label}${item.time.isEmpty ? '' : ' · ${item.time}'}',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            Text(
              'Estimado: ${amountFormat.format(item.estimatedCost)}',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            if (hasExpense)
              Text(
                'Real: ${amountFormat.format(item.actualAmount)} '
                '(${item.variance >= 0 ? '+' : ''}${item.variance.toStringAsFixed(2)})',
                style: TextStyle(
                  color: item.variance > 0
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onTap();
                break;
              case 'link':
                onLink();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'link', child: Text('Vincular gasto')),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _iconFor(TripItineraryType type) {
    switch (type) {
      case TripItineraryType.flight:
        return Icons.flight;
      case TripItineraryType.hotel:
        return Icons.hotel;
      case TripItineraryType.transport:
        return Icons.directions_bus;
      case TripItineraryType.activity:
        return Icons.local_activity;
      case TripItineraryType.food:
        return Icons.restaurant;
      case TripItineraryType.other:
        return Icons.event;
    }
  }
}

class _ItineraryEditor extends StatefulWidget {
  final TripItineraryItem? initial;
  const _ItineraryEditor({this.initial});

  @override
  State<_ItineraryEditor> createState() => _ItineraryEditorState();
}

class _ItineraryEditorState extends State<_ItineraryEditor> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _amountController = TextEditingController();
  final _timeController = TextEditingController();
  late TextEditingController _currencyController;

  DateTime _day = DateTime.now();
  TripItineraryType _type = TripItineraryType.activity;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _titleController.text = initial.title;
      _descriptionController.text = initial.description;
      _locationController.text = initial.location;
      _amountController.text = initial.estimatedCost.toStringAsFixed(2);
      _timeController.text = initial.time;
      _day = initial.day;
      _type = initial.type;
    }
    _currencyController =
        TextEditingController(text: initial?.currency ?? 'USD');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _amountController.dispose();
    _timeController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('d MMM y', 'es');
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                widget.initial == null ? 'Nuevo item' : 'Editar item',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TripItineraryType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: TripItineraryType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                    .toList(),
                onChanged: (value) => setState(() => _type = value ?? _type),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Día'),
                subtitle: Text(formatter.format(_day)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _day,
                    firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) setState(() => _day = picked);
                },
              ),
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Hora (opcional)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Lugar (opcional)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Costo estimado'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: _currencyController,
                      maxLength: 3,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Moneda',
                        counterText: '',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.pop<Map<String, dynamic>>(context, {
                    'day': _day.toUtc().toIso8601String(),
                    'time': _timeController.text.trim(),
                    'type': _type.apiValue,
                    'title': _titleController.text.trim(),
                    'description': _descriptionController.text.trim(),
                    'location': _locationController.text.trim(),
                    'estimated_cost':
                        double.tryParse(_amountController.text.trim()) ?? 0,
                    'currency': _currencyController.text.trim().toUpperCase(),
                  });
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExpensePickerSheet extends StatelessWidget {
  final List<TripExpense> expenses;
  const _ExpensePickerSheet({required this.expenses});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
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
            Text(
              'Vincular un gasto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return ListTile(
                    title: Text(expense.description),
                    subtitle: Text(
                      '${expense.amount.toStringAsFixed(2)} ${expense.currency}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pop(context, expense.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
