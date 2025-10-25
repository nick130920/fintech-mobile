import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../data/models/bank_account_model.dart';
import '../../data/models/bank_notification_pattern_model.dart';
import '../providers/bank_account_provider.dart';
import '../providers/bank_notification_pattern_provider.dart';

class ProcessNotificationScreen extends StatefulWidget {
  const ProcessNotificationScreen({super.key});

  @override
  State<ProcessNotificationScreen> createState() => _ProcessNotificationScreenState();
}

class _ProcessNotificationScreenState extends State<ProcessNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  BankAccountModel? _selectedBankAccount;
  NotificationChannel _selectedChannel = NotificationChannel.sms;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BankAccountProvider>().loadBankAccounts(activeOnly: true);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Procesar Notificación'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<BankNotificationPatternProvider>(
        builder: (context, patternProvider, child) {
          return SingleChildScrollView(
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
                  _buildChannelSection(),
                  const SizedBox(height: 24),
                  _buildMessageSection(),
                  const SizedBox(height: 32),
                  _buildProcessButton(),
                  if (patternProvider.lastProcessedNotification != null) ...[
                    const SizedBox(height: 32),
                    _buildResultSection(patternProvider.lastProcessedNotification!),
                  ],
                ],
              ),
            ),
          );
        },
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
            Icons.psychology,
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
                'Procesar Notificación',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'Prueba cómo se procesaría una notificación bancaria',
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
                            child: const Icon(
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

  Widget _buildMessageSection() {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mensaje de Notificación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Pega aquí el mensaje de notificación bancaria que quieres procesar...\n\nEjemplo:\nBBVA: Compra por \$1500.00 en OXXO el 15/01/2024 a las 14:30. Saldo: \$2350.00',
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el mensaje de notificación';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessButton() {
    return SizedBox(
      width: double.infinity,
      child: GlassmorphismButton(
        style: GlassButtonStyles.primary,
        enablePulseEffect: true,
        onPressed: _isProcessing ? null : _processNotification,
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Procesar con IA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildResultSection(ProcessedNotificationModel result) {
    return GlassmorphismCard(
      style: GlassStyles.heavy,
      enableEntryAnimation: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: result.processed
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    result.processed ? Icons.check_circle : Icons.error,
                    color: result.processed
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onErrorContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.processed ? 'Procesado Exitosamente' : 'No se Pudo Procesar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (result.patternName != null)
                        Text(
                          'Patrón: ${result.patternName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildResultStats(result),
            if (result.extractedData.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildExtractedData(result.extractedData),
            ],
            const SizedBox(height: 16),
            _buildResultActions(result),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStats(ProcessedNotificationModel result) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard( 


            
            'Confianza',
            '${((result.confidence ?? 0.0) * 100).toStringAsFixed(1)}%',
            Icons.psychology,
            result.hasHighConfidence
                ? Theme.of(context).colorScheme.primary
                : Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Validación',
            result.requiresValidation ? 'Requerida' : 'Automática',
            result.requiresValidation ? Icons.pending_actions : Icons.check_circle,
            result.requiresValidation
                ? Colors.orange
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedData(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datos Extraídos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...data.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  _getDataIcon(entry.key),
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_getDataLabel(entry.key)}:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildResultActions(ProcessedNotificationModel result) {
    return Row(
      children: [
        Expanded(
          child: GlassmorphismButton(
            style: GlassButtonStyles.outline,
            onPressed: _clearResult,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.clear, size: 16),
                SizedBox(width: 8),
                Text('Limpiar'),
              ],
            ),
          ),
        ),
        if (result.processed) ...[
          const SizedBox(width: 12),
          Expanded(
            child: GlassmorphismButton(
              style: GlassButtonStyles.primary,
              onPressed: () => _createTransaction(result),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 8),
                  Text('Crear Transacción'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _processNotification() async {
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

    setState(() => _isProcessing = true);

    final request = ProcessNotificationRequest(
      bankAccountId: _selectedBankAccount!.id,
      channel: _selectedChannel,
      message: _messageController.text.trim(),
    );

    final provider = context.read<BankNotificationPatternProvider>();
    final success = await provider.processNotification(request);

    setState(() => _isProcessing = false);

    if (!success && provider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _clearResult() {
    context.read<BankNotificationPatternProvider>().clearLastProcessedNotification();
  }

  void _createTransaction(ProcessedNotificationModel result) {
    // TODO: Implementar navegación a pantalla de crear transacción con datos pre-llenados
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Funcionalidad de crear transacción próximamente'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
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

  IconData _getDataIcon(String key) {
    switch (key.toLowerCase()) {
      case 'amount':
        return Icons.attach_money;
      case 'date':
        return Icons.calendar_today;
      case 'description':
        return Icons.description;
      case 'merchant':
        return Icons.store;
      default:
        return Icons.info;
    }
  }

  String _getDataLabel(String key) {
    switch (key.toLowerCase()) {
      case 'amount':
        return 'Monto';
      case 'date':
        return 'Fecha';
      case 'description':
        return 'Descripción';
      case 'merchant':
        return 'Comercio';
      default:
        return key;
    }
  }
}
