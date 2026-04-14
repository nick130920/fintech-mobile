import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/notification_settings_provider.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Configuración de notificaciones'),
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
        elevation: 0,
      ),
      body: Consumer<NotificationSettingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSwitchTile(
                context,
                icon: Icons.notifications_active_outlined,
                title: 'Notificaciones push',
                subtitle: 'Recibir avisos importantes de la app',
                value: provider.pushEnabled,
                onChanged: provider.setPushEnabled,
              ),
              _buildSwitchTile(
                context,
                icon: Icons.volume_up_outlined,
                title: 'Sonido',
                subtitle: 'Reproducir sonido al recibir avisos',
                value: provider.soundEnabled,
                onChanged: provider.setSoundEnabled,
              ),
              _buildSwitchTile(
                context,
                icon: Icons.account_balance_wallet_outlined,
                title: 'Alertas de presupuesto',
                subtitle: 'Avisos cuando superas límites de gasto',
                value: provider.budgetAlertsEnabled,
                onChanged: provider.setBudgetAlertsEnabled,
              ),
              _buildSwitchTile(
                context,
                icon: Icons.summarize_outlined,
                title: 'Resumen diario',
                subtitle: 'Recibir resumen diario de movimientos',
                value: provider.dailySummaryEnabled,
                onChanged: provider.setDailySummaryEnabled,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
