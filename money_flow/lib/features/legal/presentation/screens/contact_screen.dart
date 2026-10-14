import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

typedef EmailLauncher = Future<bool> Function(Uri uri);

class ContactScreen extends StatelessWidget {
  static final Uri _supportEmailUri = Uri(scheme: 'mailto', path: supportEmail);
  static const supportEmail = 'support@tatacode.com';

  final EmailLauncher? emailLauncher;

  const ContactScreen({super.key, this.emailLauncher});

  static Future<bool> _launchSupportEmail(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _sendEmail(BuildContext context) async {
    var launched = false;
    try {
      launched = await (emailLauncher ?? _launchSupportEmail)(_supportEmailUri);
    } catch (_) {
      launched = false;
    }

    if (!context.mounted || launched) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo abrir tu aplicación de correo.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Contacto')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Necesitas ayuda?',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Escríbenos y cuéntanos cómo podemos ayudarte con MoneyFlow.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  Text('Correo de soporte', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SelectableText(
                    supportEmail,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    button: true,
                    label: 'Enviar correo a soporte',
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _sendEmail(context),
                        icon: const Icon(Icons.email_outlined),
                        label: const Text('Enviar correo'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
