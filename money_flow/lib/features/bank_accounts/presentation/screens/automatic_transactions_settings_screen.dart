import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/notification_listener_service.dart';
import '../../../../core/services/notification_parser_service.dart';
import '../../../../shared/widgets/glassmorphism_card.dart';

/// Pantalla de configuración para transacciones automáticas
class AutomaticTransactionsSettingsScreen extends StatefulWidget {
  const AutomaticTransactionsSettingsScreen({super.key});

  @override
  State<AutomaticTransactionsSettingsScreen> createState() =>
      _AutomaticTransactionsSettingsScreenState();
}

class _AutomaticTransactionsSettingsScreenState
    extends State<AutomaticTransactionsSettingsScreen> {
  final NotificationListenerService _notificationService = NotificationListenerService();
  
  bool _isListenerEnabled = false;
  bool _isLoading = true;
  bool _isProcessing = false;
  
  static const platform = MethodChannel('notification_listener');

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    // El servicio ya se inicializa globalmente, pero nos aseguramos
    await _notificationService.initialize();
    await _checkListenerStatus();
  }

  Future<void> _checkListenerStatus() async {
    setState(() => _isLoading = true);
    try {
      final isEnabled = await _notificationService.isListenerEnabled();
      setState(() {
        _isListenerEnabled = isEnabled;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking listener status: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleListener(bool value) async {
    setState(() => _isProcessing = true);
    
    try {
      if (value) {
        // Activar listener
        final success = await _notificationService.enableListener();
        if (success) {
          setState(() => _isListenerEnabled = true);
          _showSuccessSnackBar('Listener de notificaciones activado');
          
          // Solicitar al usuario que active el acceso a notificaciones en configuración
          await _showNotificationAccessDialog();
        } else {
          _showErrorSnackBar('No se pudo activar el listener. Verifica los permisos.');
        }
      } else {
        // Desactivar listener
        await _notificationService.disableListener();
        setState(() => _isListenerEnabled = false);
        _showSuccessSnackBar('Listener de notificaciones desactivado');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _showNotificationAccessDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Activar acceso a notificaciones'),
        content: const Text(
          'Para que Money Flow pueda procesar notificaciones automáticamente, '
          'necesitas activar el acceso a notificaciones en la configuración de Android.\n\n'
          '1. Ve a Configuración > Apps > Money Flow\n'
          '2. Selecciona "Acceso a notificaciones"\n'
          '3. Activa el permiso para Money Flow',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Transacciones Automáticas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(colorScheme),
                  const SizedBox(height: 24),
                  
                  // Switch principal
                  _buildMainSwitch(colorScheme),
                  const SizedBox(height: 24),
                  
                  // Información
                  _buildInfoSection(colorScheme),
                  const SizedBox(height: 24),
                  
                  // Bancos soportados
                  _buildSupportedBanksSection(colorScheme),
                  const SizedBox(height: 24),
                  
                  // Cómo funciona
                  _buildHowItWorksSection(colorScheme),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.notifications_active,
              size: 32,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registro Automático',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Procesa notificaciones bancarias automáticamente',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSwitch(ColorScheme colorScheme) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activar Listener',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isListenerEnabled
                      ? 'Las notificaciones se procesan automáticamente'
                      : 'Activa para procesar notificaciones en tiempo real',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _isProcessing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Switch(
                  value: _isListenerEnabled,
                  onChanged: _toggleListener,
                  activeColor: colorScheme.primary,
                ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ColorScheme colorScheme) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '¿Cómo funciona?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            colorScheme,
            '1. Recepción',
            'La app escucha notificaciones de tus bancos en tiempo real',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            colorScheme,
            '2. Procesamiento',
            'Extrae automáticamente el monto, comercio y tipo de transacción',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            colorScheme,
            '3. Guardado',
            'Registra la transacción en tu cuenta automáticamente',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(ColorScheme colorScheme, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportedBanksSection(ColorScheme colorScheme) {
    final banks = NotificationParserService.getSupportedBanks();
    
    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Bancos Soportados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: banks.map((bank) => Chip(
              label: Text(bank),
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              labelStyle: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(ColorScheme colorScheme) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Privacidad y Seguridad',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Tus notificaciones se procesan localmente en tu dispositivo\n'
            '• Solo se leen notificaciones de bancos reconocidos\n'
            '• No se almacenan credenciales ni información sensible\n'
            '• Puedes desactivar el listener en cualquier momento',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // No llamar a dispose del servicio aquí, ya que es un singleton global
    // y se usa en toda la app
    super.dispose();
  }
}



