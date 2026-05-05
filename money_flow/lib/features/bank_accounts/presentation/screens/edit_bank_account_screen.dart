import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
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

  static const List<String> _availableCurrencies = [
    'MXN',
    'USD',
    'EUR',
    'COP',
    'ARS',
    'CLP',
    'PEN',
    'BRL',
  ];

  static const Map<String, String> _currencyNames = {
    'MXN': 'Peso Mexicano (MXN)',
    'USD': 'Dólar Estadounidense (USD)',
    'EUR': 'Euro (EUR)',
    'COP': 'Peso Colombiano (COP)',
    'ARS': 'Peso Argentino (ARS)',
    'CLP': 'Peso Chileno (CLP)',
    'PEN': 'Sol Peruano (PEN)',
    'BRL': 'Real Brasileño (BRL)',
  };

  /// Paleta fija de colores de marca para diferenciar cuentas en la UI.
  /// Centralizada en `AppColors.bankAccountColorPalette`.
  static const List<Color> _availableColors = AppColors.bankAccountColorPalette;

  @override
  void initState() {
    super.initState();

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
                : Text(
                    'Guardar',
                    style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screen,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildBasicInfoSection(),
              const SizedBox(height: AppSpacing.step5),
              _buildCurrencySection(),
              const SizedBox(height: AppSpacing.step5),
              _buildColorSection(),
              const SizedBox(height: AppSpacing.step5),
              _buildNotificationSection(),
              const SizedBox(height: AppSpacing.step5),
              _buildOptionalSection(),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(int.parse(_selectedColor.replaceFirst('#', '0xFF'))),
            borderRadius: AppRadius.allBase,
          ),
          child: Icon(
            _getAccountIcon(widget.account.type),
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
                'Editar Cuenta',
                style: AppTypography.titleLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                widget.account.accountNumberMask,
                style: AppTypography.bodyMd.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    final scheme = Theme.of(context).colorScheme;
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: AppSpacing.glass,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Básica',
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.step4),
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
            const SizedBox(height: AppSpacing.step4),
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
            const SizedBox(height: AppSpacing.step4),
            _buildReadOnlyField('Tipo de Cuenta', widget.account.typeDisplayName),
            const SizedBox(height: AppSpacing.step4),
            _buildReadOnlyField('Número de Cuenta', widget.account.accountNumberMask),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.titleSm.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.step2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.step4),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: AppRadius.allBase,
            border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
          ),
          child: Text(
            value,
            style: AppTypography.bodyLg.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencySection() {
    final scheme = Theme.of(context).colorScheme;
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: AppSpacing.glass,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Moneda',
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.step4),
            DropdownButtonFormField<String>(
              initialValue: _selectedCurrency,
              decoration: InputDecoration(
                border: const OutlineInputBorder(borderRadius: AppRadius.allBase),
                fillColor: scheme.surfaceContainerHighest,
                filled: true,
                prefixIcon: Icon(Icons.attach_money, color: scheme.primary),
              ),
              items: _availableCurrencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(
                    _currencyNames[currency] ?? currency,
                    style: AppTypography.bodyLg.copyWith(color: scheme.onSurface),
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
    final scheme = Theme.of(context).colorScheme;
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: AppSpacing.glass,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Color de Identificación',
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.step4),
            Wrap(
              spacing: AppSpacing.step3,
              runSpacing: AppSpacing.step3,
              children: _availableColors.map((color) {
                final colorHex = '#${color.toARGB32().toRadixString(16).substring(2)}';
                final isSelected = _selectedColor == colorHex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorHex),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: AppRadius.allBase,
                      border: isSelected
                          ? Border.all(color: scheme.onSurface, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: AppColors.white, size: 24)
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
    final scheme = Theme.of(context).colorScheme;
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: AppSpacing.glass,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Configuración de Notificaciones',
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
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
              const SizedBox(height: AppSpacing.step4),
              _buildFormField(
                'Teléfono para SMS (opcional)',
                'Ej: +52 55 1234 5678',
                _notificationPhoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.step4),
              _buildFormField(
                'Email para Notificaciones (opcional)',
                'Ej: mi@email.com',
                _notificationEmailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.step4),
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
        style: AppTypography.titleSm.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      children: [
        Padding(
          padding: AppSpacing.card,
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
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.titleSm.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.step2),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(borderRadius: AppRadius.allBase),
            fillColor: scheme.surfaceContainerHighest,
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
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text(
                'Guardar Cambios',
                style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w600),
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
      CustomSnackBar.showSuccess(context, 'Cuenta actualizada exitosamente');
      Navigator.of(context).pop(true);
    } else if (provider.error != null && mounted) {
      CustomSnackBar.showError(context, provider.error!);
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
