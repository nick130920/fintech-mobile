import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../data/models/bank_account_model.dart';
import '../providers/bank_account_provider.dart';

class EditBankAccountScreen extends StatefulWidget {
  final BankAccountModel account;

  const EditBankAccountScreen({
    super.key,
    required this.account,
  });

  @override
  State<EditBankAccountScreen> createState() => _EditBankAccountScreenState();
}

class _EditBankAccountScreenState extends State<EditBankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bankNameController;
  late final TextEditingController _accountAliasController;
  late final TextEditingController _notificationPhoneController;
  late final TextEditingController _notificationEmailController;
  late final TextEditingController _minAmountController;
  late final TextEditingController _notesController;

  late String _selectedColor;
  late String _selectedCurrency;
  late bool _isNotificationEnabled;
  bool _isLoading = false;

  final List<String> _availableCurrencies = [
    'MXN',
    'USD',
    'EUR',
    'COP',
    'ARS',
    'CLP',
    'PEN',
    'BRL',
  ];

  final Map<String, String> _currencyNames = {
    'MXN': 'Peso Mexicano (MXN)',
    'USD': 'Dólar Estadounidense (USD)',
    'EUR': 'Euro (EUR)',
    'COP': 'Peso Colombiano (COP)',
    'ARS': 'Peso Argentino (ARS)',
    'CLP': 'Peso Chileno (CLP)',
    'PEN': 'Sol Peruano (PEN)',
    'BRL': 'Real Brasileño (BRL)',
  };

  final List<Color> _availableColors = [
    const Color(0xFF007bff), // Azul
    const Color(0xFF28a745), // Verde
    const Color(0xFFdc3545), // Rojo
    const Color(0xFFffc107), // Amarillo
    const Color(0xFF6f42c1), // Púrpura
    const Color(0xFF20c997), // Turquesa
    const Color(0xFFfd7e14), // Naranja
    const Color(0xFFe83e8c), // Rosa
  ];

  @override
  void initState() {
    super.initState();
    
    // Inicializar controllers con los valores actuales de la cuenta
    _bankNameController = TextEditingController(text: widget.account.bankName);
    _accountAliasController = TextEditingController(text: widget.account.accountAlias);
    _notificationPhoneController = TextEditingController(text: widget.account.notificationPhone);
    _notificationEmailController = TextEditingController(text: widget.account.notificationEmail);
    _minAmountController = TextEditingController(text: widget.account.minAmountToNotify.toString());
    _notesController = TextEditingController(text: widget.account.notes);
    
    _selectedColor = widget.account.color;
    _selectedCurrency = widget.account.currency;
    _isNotificationEnabled = widget.account.isNotificationEnabled;
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountAliasController.dispose();
    _notificationPhoneController.dispose();
    _notificationEmailController.dispose();
    _minAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Editar Cuenta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateBankAccount,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Guardar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
               _buildBasicInfoSection(),
               const SizedBox(height: 24),
               _buildCurrencySection(),
               const SizedBox(height: 24),
               _buildColorSection(),
               const SizedBox(height: 24),
               _buildNotificationSection(),
              const SizedBox(height: 24),
              _buildOptionalSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
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
            color: Color(int.parse(_selectedColor.replaceFirst('#', '0xFF'))),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getAccountIcon(widget.account.type),
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar Cuenta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                widget.account.accountNumberMask,
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

  Widget _buildBasicInfoSection() {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Básica',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildFormField(
              'Nombre del Banco',
              'Ej: BBVA',
              _bankNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre del banco es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFormField(
              'Alias de la Cuenta',
              'Ej: Mi Cuenta Principal',
              _accountAliasController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El alias es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Campo de solo lectura para el tipo de cuenta
            _buildReadOnlyField('Tipo de Cuenta', widget.account.typeDisplayName),
            const SizedBox(height: 16),
            _buildReadOnlyField('Número de Cuenta', widget.account.accountNumberMask),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencySection() {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Moneda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: InputDecoration(
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
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                filled: true,
                prefixIcon: Icon(
                  Icons.attach_money,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              items: _availableCurrencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(
                    _currencyNames[currency] ?? currency,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCurrency = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection() {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Color de Identificación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final colorHex = '#${color.value.toRadixString(16).substring(2)}';
                final isSelected = _selectedColor == colorHex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorHex),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Configuración de Notificaciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Switch(
                  value: _isNotificationEnabled,
                  onChanged: (value) => setState(() => _isNotificationEnabled = value),
                ),
              ],
            ),
            if (_isNotificationEnabled) ...[
              const SizedBox(height: 16),
              _buildFormField(
                'Teléfono para SMS (opcional)',
                'Ej: +52 55 1234 5678',
                _notificationPhoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                'Email para Notificaciones (opcional)',
                'Ej: mi@email.com',
                _notificationEmailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                'Monto Mínimo para Notificar',
                'Ej: 100.00',
                _minAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El monto mínimo es requerido';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Ingresa un monto válido';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalSection() {
    return ExpansionTile(
      title: Text(
        'Información adicional (opcional)',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildFormField(
            'Notas',
            'Información adicional sobre la cuenta...',
            _notesController,
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(
    String label,
    String hint,
    TextEditingController controller, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
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
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
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
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: GlassmorphismButton(
        style: GlassButtonStyles.primary,
        enablePulseEffect: true,
        onPressed: _isLoading ? null : _updateBankAccount,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Guardar Cambios',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _updateBankAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final request = UpdateBankAccountRequest(
      bankName: _bankNameController.text != widget.account.bankName 
          ? _bankNameController.text 
          : null,
      accountAlias: _accountAliasController.text != widget.account.accountAlias
          ? _accountAliasController.text
          : null,
      color: _selectedColor != widget.account.color ? _selectedColor : null,
      currency: _selectedCurrency != widget.account.currency ? _selectedCurrency : null,
      isNotificationEnabled: _isNotificationEnabled != widget.account.isNotificationEnabled
          ? _isNotificationEnabled
          : null,
      notificationPhone: _notificationPhoneController.text != widget.account.notificationPhone
          ? (_notificationPhoneController.text.isEmpty ? null : _notificationPhoneController.text)
          : null,
      notificationEmail: _notificationEmailController.text != widget.account.notificationEmail
          ? (_notificationEmailController.text.isEmpty ? null : _notificationEmailController.text)
          : null,
      minAmountToNotify: _isNotificationEnabled
          ? (double.tryParse(_minAmountController.text) != widget.account.minAmountToNotify
              ? double.tryParse(_minAmountController.text)
              : null)
          : 0.0,
      notes: _notesController.text != widget.account.notes
          ? (_notesController.text.isEmpty ? null : _notesController.text)
          : null,
    );

    final provider = context.read<BankAccountProvider>();
    final success = await provider.updateBankAccount(widget.account.id, request);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cuenta actualizada exitosamente'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.of(context).pop(true); // Retornar true para indicar que se actualizó
    } else if (provider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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

