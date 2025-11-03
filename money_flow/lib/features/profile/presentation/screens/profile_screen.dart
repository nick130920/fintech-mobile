import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil y Configuración'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'Gestión Bancaria'),
          const SizedBox(height: 8),
          _buildBankingOptions(context),
          const Divider(height: 40),
          _buildSectionTitle(context, 'Configuración'),
          const SizedBox(height: 8),
          _buildSettingsOptions(context),
          const Divider(height: 40),
          _buildSectionTitle(context, 'Apariencia'),
          const SizedBox(height: 8),
          _buildThemeSelector(context, themeProvider),
          // Aquí se podrían añadir más opciones de configuración
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildBankingOptions(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.account_balance,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            title: const Text('Cuentas Bancarias'),
            subtitle: const Text('Gestiona tus cuentas y configuración'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, '/bank-accounts'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.pattern,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            title: const Text('Patrones de Notificación'),
            subtitle: const Text('Configura el procesamiento automático'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, '/notification-patterns'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.smart_toy,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            title: const Text('Procesar Notificación'),
            subtitle: const Text('Prueba el procesamiento con IA'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, '/process-notification'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOptions(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.attach_money,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: const Text('Divisa de la Aplicación'),
        subtitle: const Text('Configura tu divisa preferida'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pushNamed(context, '/currency-settings'),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modo de la aplicación',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Elige cómo quieres que se vea la aplicación.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Claro'),
                  icon: Icon(Icons.wb_sunny),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Oscuro'),
                  icon: Icon(Icons.nightlight_round),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('Sistema'),
                  icon: Icon(Icons.settings_suggest),
                ),
              ],
              selected: {themeProvider.themeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                themeProvider.setTheme(newSelection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}
