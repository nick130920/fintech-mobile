import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil y Configuración'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildUserInfo(context, authProvider),
          const Divider(height: 40),
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
          const Divider(height: 40),
          _buildSectionTitle(context, 'Seguridad'),
          const SizedBox(height: 8),
          _buildSecurityOptions(context),
          const Divider(height: 40),
          _buildSectionTitle(context, 'Cuenta'),
          const SizedBox(height: 8),
          _buildAccountOptions(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;
    
    if (user == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 30,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
          const Divider(height: 1),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.notifications_active,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                size: 20,
              ),
            ),
            title: const Text('Transacciones Automáticas'),
            subtitle: const Text('Activa el registro automático en tiempo real'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, '/automatic-transactions-settings'),
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
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
                size: 20,
              ),
            ),
            title: const Text('Notificaciones'),
            subtitle: const Text('Gestionar alertas y avisos'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implementar pantalla de notificaciones
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.language,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
                size: 20,
              ),
            ),
            title: const Text('Idioma'),
            subtitle: const Text('Español (Colombia)'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implementar cambio de idioma
            },
          ),
        ],
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

  Widget _buildSecurityOptions(BuildContext context) {
    return FutureBuilder<bool>(
      future: BiometricService.isBiometricAvailable(),
      builder: (context, snapshot) {
        final isBiometricAvailable = snapshot.data ?? false;
        
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              if (isBiometricAvailable) ...[
                FutureBuilder<bool>(
                  future: StorageService.isBiometricEnabled(),
                  builder: (context, snapshot) {
                    final isEnabled = snapshot.data ?? false;
                    
                    return SwitchListTile(
                      secondary: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.fingerprint,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                      ),
                      title: const Text('Autenticación Biométrica'),
                      subtitle: Text(
                        isEnabled 
                          ? 'Iniciar sesión con huella dactilar habilitado'
                          : 'Habilitar inicio de sesión con huella',
                      ),
                      value: isEnabled,
                      onChanged: (value) async {
                        await _toggleBiometric(context, value);
                      },
                    );
                  },
                ),
              ] else ...[
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.fingerprint_outlined,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      size: 20,
                    ),
                  ),
                  title: const Text('Autenticación Biométrica'),
                  subtitle: const Text('No disponible en este dispositivo'),
                  enabled: false,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountOptions(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.onErrorContainer,
                size: 20,
              ),
            ),
            title: Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text('Salir de tu cuenta'),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.error,
            ),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBiometric(BuildContext context, bool enable) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (enable) {
      // Si quiere habilitar, verificar que tenga credenciales guardadas
      final savedEmail = await StorageService.getSavedEmail();
      
      if (savedEmail == null) {
        if (context.mounted) {
          CustomSnackBar.showWarning(
            context,
            'Inicia sesión con el checkbox de biometría marcado primero',
          );
        }
        return;
      }
      
      // Autenticar para confirmar
      final authenticated = await BiometricService.authenticate(
        localizedReason: 'Autentica para habilitar inicio con biometría',
      );
      
      if (authenticated) {
        await authProvider.toggleBiometricLogin(true);
        if (context.mounted) {
          CustomSnackBar.showSuccess(
            context,
            'Inicio con biometría habilitado',
          );
        }
      }
    } else {
      // Deshabilitar
      await authProvider.toggleBiometricLogin(false);
      if (context.mounted) {
        CustomSnackBar.showSuccess(
          context,
          'Inicio con biometría deshabilitado',
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Estás seguro que deseas cerrar sesión?'),
              const SizedBox(height: 16),
              FutureBuilder<bool>(
                future: StorageService.isBiometricEnabled(),
                builder: (context, snapshot) {
                  final isEnabled = snapshot.data ?? false;
                  
                  if (!isEnabled) return const SizedBox.shrink();
                  
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.fingerprint,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mantener inicio con biometría habilitado',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FutureBuilder<bool>(
              future: StorageService.isBiometricEnabled(),
              builder: (context, snapshot) {
                final isEnabled = snapshot.data ?? false;
                
                return FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _handleLogout(context, keepBiometric: isEnabled);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Cerrar Sesión'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context, {bool keepBiometric = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await authProvider.logout(keepBiometricCredentials: keepBiometric);
      
      if (context.mounted) {
        CustomSnackBar.showSuccess(
          context,
          'Sesión cerrada exitosamente',
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          'Error al cerrar sesión: $e',
        );
      }
    }
  }
}
