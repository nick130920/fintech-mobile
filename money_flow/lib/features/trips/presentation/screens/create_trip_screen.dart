import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/currency_provider.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../providers/trips_provider.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _countryCodeController = TextEditingController();
  final _coverController = TextEditingController();
  final _notesController = TextEditingController();
  late TextEditingController _currencyController;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 5));

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final currency = context.read<CurrencyProvider>().selectedCurrency.code;
    _currencyController = TextEditingController(text: currency.toUpperCase());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _countryCodeController.dispose();
    _coverController.dispose();
    _notesController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Nuevo viaje'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Guardar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
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
              _buildHeader(),
              const SizedBox(height: 32),
              _buildField(
                label: 'Nombre del viaje',
                controller: _nameController,
                hint: 'Vacaciones a Bali',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa un nombre para el viaje'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Destino',
                controller: _destinationController,
                hint: 'Ciudad o región',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Indica el destino'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Código de país (opcional)',
                controller: _countryCodeController,
                hint: 'Ej: ID, MX, CO',
                maxLength: 2,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              _buildDateRange(),
              const SizedBox(height: 16),
              _buildField(
                label: 'Moneda principal',
                controller: _currencyController,
                hint: 'USD, EUR, ARS',
                maxLength: 3,
                textCapitalization: TextCapitalization.characters,
                validator: (v) {
                  if (v == null || v.trim().length != 3) {
                    return 'Ingresa un código ISO 4217';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Foto de portada (opcional)',
                controller: _coverController,
                hint: 'URL de imagen',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Notas (opcional)',
                controller: _notesController,
                hint: 'Detalles, expectativas, recordatorios...',
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
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
                          'Crear viaje',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.flight_takeoff,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Planifica un viaje',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'Define las fechas y la moneda principal para empezar a estimar el presupuesto.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField({
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

  Widget _buildDateRange() {
    final formatter = DateFormat('d MMM y', 'es');
    return Row(
      children: [
        Expanded(
          child: _buildDateButton(
            label: 'Inicio',
            date: _startDate,
            formatter: formatter,
            onTap: () => _selectDate(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateButton(
            label: 'Fin',
            date: _endDate,
            formatter: formatter,
            onTap: () => _selectDate(false),
          ),
        ),
      ],
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime date,
    required DateFormat formatter,
    required VoidCallback onTap,
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
        InkWell(
          onTap: onTap,
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
                  formatter.format(date),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final result = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (result == null) return;
    setState(() {
      if (isStart) {
        _startDate = result;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 1));
        }
      } else {
        if (result.isBefore(_startDate)) {
          CustomSnackBar.showWarning(
            context,
            'La fecha fin debe ser posterior a la de inicio',
          );
          return;
        }
        _endDate = result;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        'name': _nameController.text.trim(),
        'destination': _destinationController.text.trim(),
        'country_code': _countryCodeController.text.trim().toUpperCase(),
        'start_date': _startDate.toUtc().toIso8601String(),
        'end_date': _endDate.toUtc().toIso8601String(),
        'primary_currency': _currencyController.text.trim().toUpperCase(),
        'cover_image_url': _coverController.text.trim(),
        'notes': _notesController.text.trim(),
      }..removeWhere((_, value) => value is String && value.isEmpty);

      final trip = await context.read<TripsProvider>().create(body);
      if (!mounted) return;
      if (trip != null) {
        CustomSnackBar.showSuccess(context, 'Viaje creado');
        Navigator.of(context).pop(true);
      } else {
        final error = context.read<TripsProvider>().error;
        CustomSnackBar.showError(context, error ?? 'No se pudo crear el viaje');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
