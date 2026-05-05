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

  /// Paleta fija de colores de marca para diferenciar cuentas en la UI.
  /// Centralizada en `AppColors.bankAccountColorPalette`.
  static const List<Color> _availableColors = AppColors.bankAccountColorPalette;

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
              _buildAccountTypeSection(),
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
            color: scheme.primaryContainer,
            borderRadius: AppRadius.allBase,
          ),
          child: Icon(
            Icons.add_card,
            color: scheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.step4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agregar Cuenta',
                style: AppTypography.titleLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                'Configura tu nueva cuenta bancaria',
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
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.step4),
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
              'Tipo de Cuenta',
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.step4),
            Wrap(
              spacing: AppSpacing.step3,
              runSpacing: AppSpacing.step3,
              children: BankAccountType.values.map((type) {
                final isSelected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.step4,
                      vertical: AppSpacing.step3,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? scheme.primaryContainer
                          : scheme.surfaceContainerHighest,
                      borderRadius: AppRadius.allBase,
                      border: isSelected
                          ? Border.all(color: scheme.primary)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getAccountIcon(type),
                          size: 20,
                          color: isSelected
                              ? scheme.onPrimaryContainer
                              : scheme.onSurface,
                        ),
                        const SizedBox(width: AppSpacing.step2),
                        Text(
                          _getTypeDisplayName(type),
                          style: AppTypography.labelLg.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? scheme.onPrimaryContainer
                                : scheme.onSurface,
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
            border: const OutlineInputBorder(
              borderRadius: AppRadius.allBase,
            ),
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
        onPressed: _isLoading ? null : _saveBankAccount,
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
                'Guardar Cuenta Bancaria',
                style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w600),
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
      CustomSnackBar.showSuccess(context, 'Cuenta bancaria creada exitosamente');
      Navigator.of(context).pop();
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
