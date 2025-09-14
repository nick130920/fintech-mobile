import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../data/models/bank_account_model.dart';
import '../../data/models/bank_notification_pattern_model.dart';
import '../providers/bank_account_provider.dart';
import '../providers/bank_notification_pattern_provider.dart';

class AddNotificationPatternScreen extends StatefulWidget {
  const AddNotificationPatternScreen({super.key});

  @override
  State<AddNotificationPatternScreen> createState() => _AddNotificationPatternScreenState();
}

class _AddNotificationPatternScreenState extends State<AddNotificationPatternScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _exampleMessageController = TextEditingController();
  final _amountRegexController = TextEditingController();
  final _confidenceController = TextEditingController(text: '0.8');
  final _priorityController = TextEditingController(text: '100');

  BankAccountModel? _selectedBankAccount;
  NotificationChannel _selectedChannel = NotificationChannel.sms;
  bool _requiresValidation = true;
  bool _autoApprove = false;
  bool _isDefault = false;
  bool _isLoading = false;
  
  List<String> _keywordsTrigger = [];
  List<String> _keywordsExclude = [];
  final _keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BankAccountProvider>().loadBankAccounts(activeOnly: true);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _exampleMessageController.dispose();
    _amountRegexController.dispose();
    _confidenceController.dispose();
    _priorityController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Nuevo Patrón de Notificación'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePattern,
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
              _buildBankAccountSection(),
              const SizedBox(height: 24),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildChannelSection(),
              const SizedBox(height: 24),
              _buildKeywordsSection(),
              const SizedBox(height: 24),
              _buildAdvancedSection(),
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
            Icons.smart_toy,
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
                'Crear Patrón',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'Configura un patrón para procesar notificaciones automáticamente',
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

  Widget _buildBankAccountSection() {
    return Consumer<BankAccountProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final accounts = provider.activeBankAccounts;
        if (accounts.isEmpty) {
          return GlassmorphismCard(
            style: GlassStyles.medium,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.warning,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay cuentas bancarias activas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Necesitas al menos una cuenta bancaria activa para crear patrones',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return GlassmorphismCard(
          style: GlassStyles.medium,
          enableEntryAnimation: true,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cuenta Bancaria',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<BankAccountModel>(
                  value: _selectedBankAccount,
                  decoration: InputDecoration(
                    hintText: 'Selecciona una cuenta bancaria',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                    ),
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    filled: true,
                  ),
                  items: accounts.map((account) {
                    return DropdownMenuItem(
                      value: account,
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(int.parse(account.color.replaceFirst('#', '0xFF'))),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.account_balance,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.accountAlias,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
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
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (account) => setState(() => _selectedBankAccount = account),
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona una cuenta bancaria';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        );
      },
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
              'Nombre del Patrón',
              'Ej: BBVA Gastos SMS',
              _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFormField(
              'Descripción (opcional)',
              'Describe para qué sirve este patrón...',
              _descriptionController,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildFormField(
              'Mensaje de Ejemplo',
              'Pega aquí un ejemplo real de notificación...',
              _exampleMessageController,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Proporciona un mensaje de ejemplo';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelSection() {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Canal de Notificación',
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
              children: NotificationChannel.values.map((channel) {
                final isSelected = _selectedChannel == channel;
                return GestureDetector(
                  onTap: () => setState(() => _selectedChannel = channel),
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
                          _getChannelIcon(channel),
                          size: 20,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getChannelDisplayName(channel),
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

  Widget _buildKeywordsSection() {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Palabras Clave',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildKeywordInput('Palabras de activación', _keywordsTrigger, true),
            const SizedBox(height: 16),
            _buildKeywordInput('Palabras de exclusión', _keywordsExclude, false),
          ],
        ),
      ),
    );
  }

  Widget _buildKeywordInput(String label, List<String> keywords, bool isInclude) {
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
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _keywordController,
                decoration: InputDecoration(
                  hintText: 'Escribe una palabra clave...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  filled: true,
                ),
                onFieldSubmitted: (value) => _addKeyword(value, keywords),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addKeyword(_keywordController.text, keywords),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        if (keywords.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: keywords.map((keyword) {
              return Chip(
                label: Text(keyword),
                backgroundColor: isInclude
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.errorContainer,
                onDeleted: () => setState(() => keywords.remove(keyword)),
                deleteIcon: const Icon(Icons.close, size: 16),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancedSection() {
    return ExpansionTile(
      title: Text(
        'Configuración Avanzada',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      'Umbral de Confianza',
                      '0.8',
                      _confidenceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final confidence = double.tryParse(value);
                        if (confidence == null || confidence < 0 || confidence > 1) {
                          return 'Valor entre 0 y 1';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      'Prioridad',
                      '100',
                      _priorityController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final priority = int.tryParse(value);
                        if (priority == null || priority < 1) {
                          return 'Número mayor a 0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFormField(
                'Regex para Monto (opcional)',
                r'Monto:\s*\$?(\d+\.?\d*)',
                _amountRegexController,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Requiere Validación Manual'),
                subtitle: const Text('Las transacciones necesitarán aprobación'),
                value: _requiresValidation,
                onChanged: (value) => setState(() => _requiresValidation = value),
              ),
              SwitchListTile(
                title: const Text('Auto-aprobar'),
                subtitle: const Text('Aprobar automáticamente si la confianza es alta'),
                value: _autoApprove,
                onChanged: (value) => setState(() => _autoApprove = value),
              ),
              SwitchListTile(
                title: const Text('Patrón por Defecto'),
                subtitle: const Text('Usar este patrón cuando otros no coincidan'),
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
              ),
            ],
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
        onPressed: _isLoading ? null : _savePattern,
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
                'Crear Patrón',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _addKeyword(String keyword, List<String> keywords) {
    final trimmed = keyword.trim().toLowerCase();
    if (trimmed.isNotEmpty && !keywords.contains(trimmed)) {
      setState(() {
        keywords.add(trimmed);
        _keywordController.clear();
      });
    }
  }

  Future<void> _savePattern() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBankAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona una cuenta bancaria'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final request = CreateBankNotificationPatternRequest(
      bankAccountId: _selectedBankAccount!.id,
      name: _nameController.text,
      description: _descriptionController.text,
      channel: _selectedChannel,
      exampleMessage: _exampleMessageController.text,
      keywordsTrigger: _keywordsTrigger,
      keywordsExclude: _keywordsExclude,
      amountRegex: _amountRegexController.text.isEmpty ? null : _amountRegexController.text,
      requiresValidation: _requiresValidation,
      confidenceThreshold: double.tryParse(_confidenceController.text) ?? 0.8,
      autoApprove: _autoApprove,
      priority: int.tryParse(_priorityController.text) ?? 100,
      isDefault: _isDefault,
    );

    final provider = context.read<BankNotificationPatternProvider>();
    final success = await provider.createPattern(request);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Patrón creado exitosamente'),
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

  IconData _getChannelIcon(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.sms:
        return Icons.sms;
      case NotificationChannel.push:
        return Icons.notifications;
      case NotificationChannel.email:
        return Icons.email;
      case NotificationChannel.app:
        return Icons.mobile_friendly;
    }
  }

  String _getChannelDisplayName(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.sms:
        return 'SMS';
      case NotificationChannel.push:
        return 'Push';
      case NotificationChannel.email:
        return 'Email';
      case NotificationChannel.app:
        return 'App';
    }
  }
}
