import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../data/models/bank_account_model.dart';
import '../providers/bank_account_provider.dart';

class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen({super.key});

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _accountAliasController = TextEditingController();
  final _accountNumberMaskController = TextEditingController();
  final _notificationPhoneController = TextEditingController();
  final _notificationEmailController = TextEditingController();
  final _minAmountController = TextEditingController(text: '0.0');
  final _notesController = TextEditingController();

  BankAccountType _selectedType = BankAccountType.checking;
  String _selectedColor = '#007bff';
  bool _isNotificationEnabled = true;
  bool _isLoading = false;

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
  void dispose() {
    _bankNameController.dispose();
    _accountAliasController.dispose();
    _accountNumberMaskController.dispose();
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
        title: const Text('Nueva Cuenta Bancaria'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveBankAccount,
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
              _buildAccountTypeSection(),
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
                'Agregar Cuenta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'Configura tu nueva cuenta bancaria',
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
              'Ej: BBVA México',
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
            _buildFormField(
              'Últimos Dígitos',
              'Ej: ****1234',
              _accountNumberMaskController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Los últimos dígitos son requeridos';
                }
                if (value.length < 4) {
                  return 'Debe tener al menos 4 caracteres';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeSection() {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de Cuenta',
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
              children: BankAccountType.values.map((type) {
                final isSelected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Theme.of(context).colorScheme.primary)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getAccountIcon(type),
                          size: 20,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getTypeDisplayName(type),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
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
        onPressed: _isLoading ? null : _saveBankAccount,
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
                'Guardar Cuenta Bancaria',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _saveBankAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final request = CreateBankAccountRequest(
      bankName: _bankNameController.text,
      accountAlias: _accountAliasController.text,
      accountNumberMask: _accountNumberMaskController.text,
      type: _selectedType,
      color: _selectedColor,
      isNotificationEnabled: _isNotificationEnabled,
      notificationPhone: _notificationPhoneController.text.isEmpty
          ? null
          : _notificationPhoneController.text,
      notificationEmail: _notificationEmailController.text.isEmpty
          ? null
          : _notificationEmailController.text,
      minAmountToNotify: _isNotificationEnabled 
          ? (double.tryParse(_minAmountController.text) ?? 0.0)
          : 0.0,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    // Debug: Imprimir request
    debugPrint('🚀 Enviando request: ${request.toJson()}');

    final provider = context.read<BankAccountProvider>();
    final success = await provider.createBankAccount(request);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cuenta bancaria creada exitosamente'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.of(context).pop();
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

  String _getTypeDisplayName(BankAccountType type) {
    switch (type) {
      case BankAccountType.checking:
        return 'Cuenta Corriente';
      case BankAccountType.savings:
        return 'Cuenta de Ahorros';
      case BankAccountType.credit:
        return 'Tarjeta de Crédito';
      case BankAccountType.debit:
        return 'Tarjeta de Débito';
      case BankAccountType.investment:
        return 'Cuenta de Inversión';
    }
  }
}
