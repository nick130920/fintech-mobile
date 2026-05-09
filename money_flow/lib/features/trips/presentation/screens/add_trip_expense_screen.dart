import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/custom_snackbar.dart';
import '../../data/models/trip_models.dart';
import '../providers/active_trip_provider.dart';

class AddTripExpenseScreen extends StatefulWidget {
  final int tripId;

  const AddTripExpenseScreen({super.key, required this.tripId});

  @override
  State<AddTripExpenseScreen> createState() => _AddTripExpenseScreenState();
}

class _AddTripExpenseScreenState extends State<AddTripExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryIdController = TextEditingController();
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();
  late TextEditingController _currencyController;

  DateTime _date = DateTime.now();
  int? _paidBy;
  ExpenseShareType _shareType = ExpenseShareType.equal;
  final Map<int, TextEditingController> _shareControllers = {};
  final Set<int> _includedMembers = {};

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final trip = context.read<ActiveTripProvider>().trip;
    _currencyController = TextEditingController(
      text: trip?.primaryCurrency ?? 'USD',
    );
    final members = context.read<ActiveTripProvider>().members;
    _includedMembers.addAll(members.map((m) => m.id));
    if (members.isNotEmpty) {
      _paidBy = members.first.id;
    }
    for (final m in members) {
      _shareControllers[m.id] = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryIdController.dispose();
    _merchantController.dispose();
    _notesController.dispose();
    _currencyController.dispose();
    for (final controller in _shareControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveTripProvider>(
      builder: (context, provider, _) {
        final trip = provider.trip;
        final members = provider.members;
        if (trip == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text('Nuevo gasto del viaje'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              TextButton(
                onPressed: _saving ? null : () => _save(trip, members),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field(
                    label: 'Descripción',
                    controller: _descriptionController,
                    hint: 'Ej: Cena en restaurante',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Describe el gasto'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _field(
                    label: 'Monto',
                    controller: _amountController,
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final value = double.tryParse(v ?? '');
                      if (value == null || value <= 0) return 'Ingresa un monto válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _field(
                    label: 'Moneda',
                    controller: _currencyController,
                    hint: trip.primaryCurrency,
                    maxLength: 3,
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) {
                      if (v == null || v.trim().length != 3) {
                        return 'Código ISO de 3 letras';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _field(
                    label: 'ID de categoría',
                    controller: _categoryIdController,
                    hint: 'Ej: 12',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final id = int.tryParse(v ?? '');
                      if (id == null || id <= 0) return 'Ingresa un ID válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _field(
                    label: 'Comercio (opcional)',
                    controller: _merchantController,
                    hint: 'Ej: Cafetería Central',
                  ),
                  const SizedBox(height: 16),
                  _buildDatePicker(),
                  const SizedBox(height: 16),
                  _buildPaidBy(members),
                  const SizedBox(height: 24),
                  _buildShareTypeSelector(),
                  const SizedBox(height: 16),
                  _buildSplitsEditor(members),
                  const SizedBox(height: 24),
                  _field(
                    label: 'Notas (opcional)',
                    controller: _notesController,
                    hint: 'Detalles adicionales...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : () => _save(trip, members),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Registrar gasto',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String hint = '',
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final formatter = DateFormat('d MMM y', 'es');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              setState(() => _date = picked);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6)),
                const SizedBox(width: 8),
                Text(
                  formatter.format(_date),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaidBy(List<TripMember> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Quién pagó?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        if (members.isEmpty)
          Text(
            'Agrega miembros al viaje antes de registrar gastos compartidos.',
            style: TextStyle(
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          )
        else
          DropdownButtonFormField<int>(
            initialValue: _paidBy,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              filled: true,
            ),
            items: members
                .map((m) => DropdownMenuItem(
                      value: m.id,
                      child: Text(m.displayName),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _paidBy = value),
          ),
      ],
    );
  }

  Widget _buildShareTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cómo se divide?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ExpenseShareType.values.map((type) {
            final selected = type == _shareType;
            return ChoiceChip(
              label: Text(type.label),
              selected: selected,
              onSelected: (_) => setState(() => _shareType = type),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSplitsEditor(List<TripMember> members) {
    if (members.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participantes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ...members.map((m) {
          final included = _includedMembers.contains(m.id);
          final controller = _shareControllers.putIfAbsent(
            m.id,
            () => TextEditingController(text: '0'),
          );
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: included,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _includedMembers.add(m.id);
                      } else {
                        _includedMembers.remove(m.id);
                      }
                    });
                  },
                ),
                Expanded(
                  child: Text(m.displayName),
                ),
                if (_shareType != ExpenseShareType.equal)
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        suffixText: _suffixForShareType(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _suffixForShareType() {
    switch (_shareType) {
      case ExpenseShareType.percentage:
        return '%';
      case ExpenseShareType.shares:
        return 'p';
      case ExpenseShareType.exact:
        return '';
      case ExpenseShareType.equal:
        return '';
    }
  }

  Future<void> _save(Trip trip, List<TripMember> members) async {
    if (!_formKey.currentState!.validate()) return;
    if (members.isNotEmpty && _paidBy == null) {
      CustomSnackBar.showWarning(context, 'Selecciona quién pagó');
      return;
    }
    final selectedMembers = members.where((m) => _includedMembers.contains(m.id)).toList();
    final amount = double.parse(_amountController.text.trim());

    final splits = <Map<String, dynamic>>[];
    if (selectedMembers.isNotEmpty) {
      for (final m in selectedMembers) {
        double shareValue = 0;
        switch (_shareType) {
          case ExpenseShareType.equal:
            shareValue = 0;
            break;
          case ExpenseShareType.percentage:
          case ExpenseShareType.exact:
          case ExpenseShareType.shares:
            shareValue = double.tryParse(_shareControllers[m.id]?.text ?? '0') ?? 0;
            break;
        }
        splits.add({
          'member_id': m.id,
          'share_type': _shareType.apiValue,
          'share_value': shareValue,
        });
      }

      final valid = _validateSplits(amount, splits);
      if (valid != null) {
        CustomSnackBar.showWarning(context, valid);
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        'description': _descriptionController.text.trim(),
        'amount': amount,
        'currency': _currencyController.text.trim().toUpperCase(),
        'category_id': int.parse(_categoryIdController.text.trim()),
        'date': _date.toUtc().toIso8601String(),
        if (_paidBy != null) 'paid_by_member_id': _paidBy,
        if (_merchantController.text.trim().isNotEmpty)
          'merchant': _merchantController.text.trim(),
        if (_notesController.text.trim().isNotEmpty)
          'notes': _notesController.text.trim(),
        if (splits.isNotEmpty) 'splits': splits,
      };

      final provider = context.read<ActiveTripProvider>();
      final created = await provider.addExpense(body);
      if (!mounted) return;
      if (created != null) {
        CustomSnackBar.showSuccess(context, 'Gasto registrado');
        Navigator.of(context).pop(true);
      } else {
        CustomSnackBar.showError(
            context, provider.error ?? 'No se pudo registrar el gasto');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _validateSplits(double amount, List<Map<String, dynamic>> splits) {
    switch (_shareType) {
      case ExpenseShareType.equal:
        return null;
      case ExpenseShareType.percentage:
        final total = splits.fold<double>(
          0,
          (sum, s) => sum + ((s['share_value'] as num?)?.toDouble() ?? 0),
        );
        if ((total - 100).abs() > 0.01) {
          return 'Los porcentajes deben sumar 100%';
        }
        return null;
      case ExpenseShareType.exact:
        final total = splits.fold<double>(
          0,
          (sum, s) => sum + ((s['share_value'] as num?)?.toDouble() ?? 0),
        );
        if ((total - amount).abs() > 0.01) {
          return 'Los montos exactos deben sumar el total del gasto';
        }
        return null;
      case ExpenseShareType.shares:
        final total = splits.fold<double>(
          0,
          (sum, s) => sum + ((s['share_value'] as num?)?.toDouble() ?? 0),
        );
        if (total <= 0) {
          return 'Define al menos una parte para repartir';
        }
        return null;
    }
  }
}
