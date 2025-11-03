import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/sms_settings.dart';
import '../../../../core/providers/sms_settings_provider.dart';
import '../../../../main.dart';
import '../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../../bank_accounts/presentation/providers/bank_account_provider.dart';

class SmsSettingsScreen extends StatefulWidget {
  const SmsSettingsScreen({super.key});

  @override
  State<SmsSettingsScreen> createState() => _SmsSettingsScreenState();
}

class _SmsSettingsScreenState extends State<SmsSettingsScreen> {
  bool _isProcessing = false;
  int _processedCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Configuración de SMS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer2<SmsSettingsProvider, BankAccountProvider>(
        builder: (context, smsProvider, bankProvider, child) {
          if (!smsProvider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final hasActiveBankAccounts = bankProvider.activeBankAccounts
              .where((acc) => acc.isNotificationEnabled && acc.notificationPhone.isNotEmpty)
              .isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, hasActiveBankAccounts),
                const SizedBox(height: 24),
                
                _buildAutoProcessSection(context, smsProvider),
                const SizedBox(height: 16),
                
                _buildProcessModeSection(context, smsProvider),
                const SizedBox(height: 16),
                
                if (smsProvider.processMode == SmsProcessMode.customDate)
                  _buildCustomDateSection(context, smsProvider),
                
                const SizedBox(height: 24),
                _buildConfigSummary(context, smsProvider),
                const SizedBox(height: 24),
                
                _buildManualProcessSection(context, hasActiveBankAccounts),
                
                const SizedBox(height: 16),
                _buildResetButton(context, smsProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool hasActiveBankAccounts) {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasActiveBankAccounts
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.sms,
                color: hasActiveBankAccounts
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
                    'Gestión de SMS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasActiveBankAccounts
                        ? 'Cuentas bancarias activas encontradas'
                        : 'No hay cuentas bancarias con SMS activo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoProcessSection(BuildContext context, SmsSettingsProvider provider) {
    return GlassmorphismCard(
      style: GlassStyles.light,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.autorenew,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Procesamiento Automático',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            SwitchListTile(
              value: provider.autoProcessEnabled,
              onChanged: (value) => provider.setAutoProcessEnabled(value),
              title: Text(
                'Activar procesamiento automático',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Los SMS se procesarán automáticamente al llegar',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 8),
            
            SwitchListTile(
              value: provider.requireActiveBankAccounts,
              onChanged: (value) => provider.setRequireActiveBankAccounts(value),
              title: Text(
                'Requerir cuentas bancarias activas',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Solo procesar si hay al menos una cuenta con SMS activado',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessModeSection(BuildContext context, SmsSettingsProvider provider) {
    return GlassmorphismCard(
      style: GlassStyles.light,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.date_range,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Modo de Procesamiento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ...SmsProcessMode.values.map((mode) {
              return RadioListTile<SmsProcessMode>(
                value: mode,
                groupValue: provider.processMode,
                onChanged: (value) {
                  if (value != null) {
                    provider.setProcessMode(value);
                  }
                },
                title: Text(
                  mode.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  mode.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDateSection(BuildContext context, SmsSettingsProvider provider) {
    final currentDate = provider.minProcessDate ?? DateTime.now();
    
    return GlassmorphismCard(
      style: GlassStyles.light,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha Personalizada',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            
            InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: currentDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                
                if (pickedDate != null) {
                  await provider.setMinProcessDate(pickedDate);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd/MM/yyyy').format(currentDate),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSummary(BuildContext context, SmsSettingsProvider provider) {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableHoverEffect: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resumen de Configuración',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              provider.getConfigSummary(),
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            
            if (provider.lastManualSync != null) ...[
              const SizedBox(height: 12),
              Text(
                'Última sincronización manual: ${DateFormat('dd/MM/yyyy HH:mm').format(provider.lastManualSync!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildManualProcessSection(BuildContext context, bool hasActiveBankAccounts) {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_arrow,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Procesamiento Manual',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              'Procesar manualmente todos los SMS según la configuración actual.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            
            if (!hasActiveBankAccounts) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No hay cuentas bancarias con SMS activo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing || !hasActiveBankAccounts
                    ? null
                    : () => _processMessagesManually(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(
                  _isProcessing ? 'Procesando...' : 'Procesar SMS Ahora',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            if (_processedCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_processedCount mensajes procesados',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, SmsSettingsProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Restablecer Configuración'),
              content: const Text(
                '¿Estás seguro de que quieres restablecer la configuración a los valores por defecto?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Restablecer'),
                ),
              ],
            ),
          );
          
          if (confirm == true && mounted) {
            await provider.resetToDefault();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración restablecida'),
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.restore),
        label: const Text('Restablecer a valores por defecto'),
      ),
    );
  }

  Future<void> _processMessagesManually(BuildContext context) async {
    setState(() {
      _isProcessing = true;
      _processedCount = 0;
    });

    try {
      final smsProvider = context.read<SmsSettingsProvider>();
      
      // Procesar SMS usando el servicio
      final minDate = smsProvider.settings.getEffectiveMinDate();
      await smsService.syncInbox(
        (message) async {
          // Este callback se ejecutará para cada SMS
          smsSyncHandler(message);
          if (mounted) {
            setState(() {
              _processedCount++;
            });
          }
        },
        minDate: minDate,
        autoMode: false, // Modo manual: procesa todos desde minDate
      );
      
      // Registrar la sincronización manual
      await smsProvider.recordManualSync();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_processedCount mensajes procesados exitosamente'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar mensajes: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

