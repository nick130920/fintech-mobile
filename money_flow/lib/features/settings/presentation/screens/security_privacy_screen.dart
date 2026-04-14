import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/settings_widgets.dart';

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  bool _biometricEnabled = false;
  bool _hideBalances = false;
  bool _twoFactorEnabled = false;
  bool _biometricAvailable = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final biometricAvailable = await BiometricService.isBiometricAvailable();
    final biometricEnabled = await StorageService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricAvailable = biometricAvailable;
        _biometricEnabled = biometricEnabled;
        _loading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool enable) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (enable) {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        if (mounted) {
          CustomSnackBar.showWarning(context,
              'No hay sesión activa para asociar con biometría.');
        }
        return;
      }
      final authenticated = await BiometricService.authenticate(
        localizedReason: 'Confirma tu identidad para habilitar el acceso biométrico',
      );
      if (authenticated) {
        await authProvider.toggleBiometricLogin(true);
        if (mounted) {
          setState(() => _biometricEnabled = true);
          CustomSnackBar.showSuccess(context, 'Acceso biométrico habilitado');
        }
      }
    } else {
      await authProvider.toggleBiometricLogin(false);
      if (mounted) {
        setState(() => _biometricEnabled = false);
        CustomSnackBar.showSuccess(context, 'Acceso biométrico deshabilitado');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(theme),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel(theme, 'Protección de la App'),
                          const SizedBox(height: 12),
                          _buildAppProtectionSection(theme, isDark),
                          const SizedBox(height: 28),
                          _buildSectionLabel(theme, 'Cuenta'),
                          const SizedBox(height: 12),
                          _buildAccountSection(theme),
                          const SizedBox(height: 28),
                          _buildSecurityRatingCard(theme),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
      child: Row(
        children: [
          SettingsCircleButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Seguridad y Privacidad',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          SettingsCircleButton(
            icon: Icons.info_outline,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAppProtectionSection(ThemeData theme, bool isDark) {
    return Column(
      children: [
        SettingsToggleTile(
          icon: Icons.fingerprint,
          title: 'Inicio Biométrico',
          subtitle: 'Usa FaceID o huella dactilar',
          value: _biometricEnabled && _biometricAvailable,
          enabled: _biometricAvailable,
          onChanged: _biometricAvailable ? _toggleBiometric : null,
        ),
        const SizedBox(height: 12),
        SettingsToggleTile(
          icon: Icons.visibility_off_outlined,
          title: 'Ocultar saldos al abrir',
          subtitle: 'Enmascara montos hasta que los toques',
          value: _hideBalances,
          onChanged: (v) => setState(() => _hideBalances = v),
        ),
        const SizedBox(height: 12),
        SettingsToggleTile(
          icon: Icons.security,
          title: 'Autenticación en dos pasos',
          subtitle: 'Protege tu cuenta con SMS o app',
          value: _twoFactorEnabled,
          onChanged: (v) => setState(() => _twoFactorEnabled = v),
        ),
      ],
    );
  }

  Widget _buildAccountSection(ThemeData theme) {
    return Column(
      children: [
        // Cambiar contraseña
        _GlassTapTile(
          icon: Icons.lock_reset,
          iconBg: theme.colorScheme.surfaceContainerHighest,
          iconColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          title: 'Cambiar contraseña',
          subtitle: 'Última vez hace 3 meses',
          trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
          onTap: () {
            // TODO: navegar a cambio de contraseña
          },
        ),
        const SizedBox(height: 12),
        // Eliminar cuenta (rojo)
        _buildDeleteAccountTile(theme),
      ],
    );
  }

  Widget _buildDeleteAccountTile(ThemeData theme) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _showDeleteAccountDialog(),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.no_accounts_outlined, color: theme.colorScheme.error, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eliminar cuenta',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    Text(
                      'Elimina permanentemente tus datos',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.error.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityRatingCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.15),
            theme.colorScheme.primary.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Nivel de seguridad: Alto',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Tu cuenta está protegida con todas las funciones de seguridad recomendadas.',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Estás seguro? Esta acción es irreversible y eliminará todos tus datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _GlassTapTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _GlassTapTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : theme.colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

