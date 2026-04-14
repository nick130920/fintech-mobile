import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/currency_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/settings_widgets.dart';

class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  bool _alertasGastos = true;
  bool _recordatorioPagos = true;
  bool _resumenSemanal = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final available = await BiometricService.isBiometricAvailable();
    final enabled = await StorageService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
      });
    }
  }

  Future<void> _toggleBiometric(bool enable) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (enable) {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        if (mounted) {
          CustomSnackBar.showWarning(context, 'No hay sesión activa para asociar con biometría.');
        }
        return;
      }
      final authenticated = await BiometricService.authenticate(
        localizedReason: 'Confirma tu identidad para habilitar el acceso biométrico',
      );
      if (authenticated) {
        await authProvider.toggleBiometricLogin(true);
        if (mounted) setState(() => _biometricEnabled = true);
      }
    } else {
      await authProvider.toggleBiometricLogin(false);
      if (mounted) setState(() => _biometricEnabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyProvider = context.watch<CurrencyProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: Row(
                children: [
                  SettingsCircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Configuración General',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel(theme, 'Preferencia de Idioma'),
                    const SizedBox(height: 12),
                    _buildGlassSection(theme, [
                      _buildTapRow(
                        theme,
                        icon: Icons.translate,
                        title: 'Idioma de la aplicación',
                        subtitle: 'Español (ES)',
                        onTap: () {},
                        divider: true,
                      ),
                      _buildTapRow(
                        theme,
                        icon: Icons.public,
                        title: 'Región y Moneda',
                        subtitle: '${currencyProvider.currencyDisplayName} (${currencyProvider.currencyCode})',
                        onTap: () => Navigator.pushNamed(context, '/currency-settings'),
                      ),
                    ]),
                    const SizedBox(height: 28),
                    _sectionLabel(theme, 'Notificaciones'),
                    const SizedBox(height: 12),
                    SettingsToggleTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Alertas de Gastos',
                      subtitle: 'Avisar si supero el presupuesto',
                      value: _alertasGastos,
                      onChanged: (v) => setState(() => _alertasGastos = v),
                    ),
                    const SizedBox(height: 12),
                    SettingsToggleTile(
                      icon: Icons.payments_outlined,
                      title: 'Recordatorio de Pagos',
                      subtitle: '2 días antes del vencimiento',
                      value: _recordatorioPagos,
                      onChanged: (v) => setState(() => _recordatorioPagos = v),
                    ),
                    const SizedBox(height: 12),
                    SettingsToggleTile(
                      icon: Icons.insights,
                      title: 'Resumen Semanal',
                      subtitle: 'Cada lunes por la mañana',
                      value: _resumenSemanal,
                      onChanged: (v) => setState(() => _resumenSemanal = v),
                    ),
                    const SizedBox(height: 28),
                    _sectionLabel(theme, 'Seguridad'),
                    const SizedBox(height: 12),
                    SettingsToggleTile(
                      icon: Icons.fingerprint,
                      title: 'Biometría',
                      subtitle: 'FaceID / Huella dactilar',
                      value: _biometricEnabled && _biometricAvailable,
                      enabled: _biometricAvailable,
                      onChanged: _biometricAvailable ? _toggleBiometric : null,
                    ),
                    const SizedBox(height: 28),
                    _sectionLabel(theme, 'Apariencia'),
                    const SizedBox(height: 12),
                    _buildThemeSelector(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildGlassSection(ThemeData theme, List<Widget> children) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildTapRow(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool divider = false,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(divider ? 0 : 16),
              bottomRight: Radius.circular(divider ? 0 : 16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: theme.colorScheme.primary, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            )),
                        Text(subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            )),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                ],
              ),
            ),
          ),
        ),
        if (divider)
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildThemeSelector(ThemeData theme) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modo de la aplicación',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Claro'), icon: Icon(Icons.wb_sunny, size: 16)),
                ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro'), icon: Icon(Icons.nightlight_round, size: 16)),
                ButtonSegment(value: ThemeMode.system, label: Text('Sistema'), icon: Icon(Icons.settings_suggest, size: 16)),
              ],
              selected: {themeProvider.themeMode},
              onSelectionChanged: (s) => themeProvider.setTheme(s.first),
            ),
          ],
        ),
      ),
    );
  }
}
