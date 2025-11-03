import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/currency_provider.dart';
import '../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../data/models/bank_account_model.dart';
import '../providers/bank_account_provider.dart';
import 'edit_bank_account_screen.dart';

class BankAccountDetailScreen extends StatelessWidget {
  final BankAccountModel account;

  const BankAccountDetailScreen({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(account.accountAlias),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showEditOptions(context),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountHeader(context),
            const SizedBox(height: 32),
            _buildAccountInfo(context),
            const SizedBox(height: 24),
            _buildNotificationSettings(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 32),
            _buildRecentActivity(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountHeader(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return GlassmorphismCard(
          style: GlassStyles.dynamic,
          enableHoverEffect: true,
          enableEntryAnimation: true,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(int.parse(account.color.replaceFirst('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getAccountIcon(account.type),
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  account.accountAlias,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${account.shortBankName} • ${account.typeDisplayName}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Balance Actual',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${currencyProvider.currencySymbol}${account.lastBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: account.lastBalance >= 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Actualizado: ${_formatDate(account.lastBalanceUpdate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatusBadge(
                      context,
                      account.isActive ? 'Activa' : 'Inactiva',
                      account.isActive ? Icons.check_circle : Icons.pause_circle,
                      account.isActive
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    if (account.isNotificationEnabled) ...[
                      const SizedBox(width: 8),
                      _buildStatusBadge(
                        context,
                        'Notificaciones',
                        Icons.notifications_active,
                        Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(BuildContext context, String label, IconData icon, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información de la Cuenta',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GlassmorphismCard(
          style: GlassStyles.medium,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(context, 'Banco', account.bankName),
                _buildDivider(context),
                _buildInfoRow(context, 'Sucursal', '${account.branchName} (${account.branchCode})'),
                _buildDivider(context),
                _buildInfoRow(context, 'Número de Cuenta', account.accountNumberMask),
                _buildDivider(context),
                _buildInfoRow(context, 'Tipo', account.typeDisplayName),
                _buildDivider(context),
                _buildInfoRow(context, 'Moneda', account.currency),
                if (account.notes.isNotEmpty) ...[
                  _buildDivider(context),
                  _buildInfoRow(context, 'Notas', account.notes),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración de Notificaciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GlassmorphismCard(
          style: GlassStyles.medium,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  'Estado',
                  account.isNotificationEnabled ? 'Habilitadas' : 'Deshabilitadas',
                  trailing: Icon(
                    account.isNotificationEnabled ? Icons.notifications_active : Icons.notifications_off,
                    color: account.isNotificationEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                if (account.isNotificationEnabled) ...[
                  _buildDivider(context),
                  _buildInfoRow(context, 'Teléfono', account.notificationPhone.isNotEmpty ? account.notificationPhone : 'No configurado'),
                  _buildDivider(context),
                  _buildInfoRow(context, 'Email', account.notificationEmail.isNotEmpty ? account.notificationEmail : 'No configurado'),
                  _buildDivider(context),
                  _buildInfoRow(
                    context,
                    'Monto Mínimo',
                    '\$${account.minAmountToNotify.toStringAsFixed(2)}',
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassmorphismButton(
                style: GlassButtonStyles.secondary,
                onPressed: () => _toggleAccountStatus(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      account.isActive ? Icons.pause : Icons.play_arrow,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.isActive ? 'Desactivar' : 'Activar',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassmorphismButton(
                style: GlassButtonStyles.secondary,
                onPressed: () => _navigateToPatterns(context),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pattern, size: 28),
                    SizedBox(height: 4),
                    Text('Patrones', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassmorphismButton(
                style: GlassButtonStyles.outline,
                onPressed: () => _showDeleteConfirmation(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 28,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Eliminar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Actividad Reciente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                // Funcionalidad de historial completo estará disponible cuando se integre el módulo de transacciones
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Historial completo estará disponible próximamente'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              child: const Text('Ver Todas'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassmorphismCard(
          style: GlassStyles.light,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  'No hay transacciones recientes',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Las transacciones aparecerán aquí',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
      height: 1,
    );
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _showEditOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar Cuenta'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditBankAccountScreen(account: account),
                  ),
                );
                
                // Si se actualizó la cuenta, actualizar la vista
                if (result == true && context.mounted) {
                  // Recargar la cuenta actualizada
                  await context.read<BankAccountProvider>().loadBankAccount(account.id);
                  
                  // Volver atrás para refrescar la lista
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(
                account.isActive ? Icons.pause_circle : Icons.play_circle,
              ),
              title: Text(account.isActive ? 'Desactivar Cuenta' : 'Activar Cuenta'),
              onTap: () {
                Navigator.pop(context);
                _toggleAccountStatus(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.notifications,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Configurar Notificaciones'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditBankAccountScreen(account: account),
                  ),
                );
                
                // Si se actualizó la cuenta, actualizar la vista
                if (result == true && context.mounted) {
                  await context.read<BankAccountProvider>().loadBankAccount(account.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Eliminar Cuenta',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _toggleAccountStatus(BuildContext context) {
    final provider = context.read<BankAccountProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(account.isActive ? 'Desactivar Cuenta' : 'Activar Cuenta'),
        content: Text(
          account.isActive
              ? '¿Deseas desactivar esta cuenta? No recibirás notificaciones y no aparecerá en el balance total.'
              : '¿Deseas activar esta cuenta? Volverás a recibir notificaciones si están habilitadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await provider.setActiveStatus(account.id, !account.isActive);
              
              if (context.mounted) {
                if (success) {
                  Navigator.pop(context); // Volver a la lista de cuentas
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        account.isActive
                            ? 'Cuenta desactivada exitosamente'
                            : 'Cuenta activada exitosamente',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al ${account.isActive ? "desactivar" : "activar"} la cuenta'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: Text(account.isActive ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final provider = context.read<BankAccountProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Cuenta'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${account.accountAlias}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await provider.deleteBankAccount(account.id);
              
              if (context.mounted) {
                if (success) {
                  Navigator.pop(context); // Volver a la lista de cuentas
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cuenta eliminada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Error al eliminar la cuenta'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _navigateToPatterns(BuildContext context) {
    Navigator.of(context).pushNamed('/notification-patterns');
  }
}

