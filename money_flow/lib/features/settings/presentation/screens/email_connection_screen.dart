import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/repositories/email_connection_repository.dart';

/// Pantalla para conectar Gmail (OAuth vía backend) y sincronizar.
class EmailConnectionScreen extends StatefulWidget {
  const EmailConnectionScreen({super.key});

  @override
  State<EmailConnectionScreen> createState() => _EmailConnectionScreenState();
}

class _EmailConnectionScreenState extends State<EmailConnectionScreen>
    with WidgetsBindingObserver {
  EmailConnectionStatusDto? _status;
  bool _loading = true;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await EmailConnectionRepository.fetchStatus();
      if (mounted) {
        setState(() {
          _status = s;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _connectGmail() async {
    setState(() => _busy = true);
    try {
      final url = await EmailConnectionRepository.fetchGmailAuthUrl();
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo abrir el navegador'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _sync() async {
    setState(() => _busy = true);
    try {
      final r = await EmailConnectionRepository.syncGmail();
      if (!mounted) return;
      final examined = r['messages_examined'] ?? 0;
      final ai = r['processed_with_ai'] ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Revisados: $examined · Procesados IA: $ai'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _disconnect() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desconectar Gmail'),
        content: const Text(
          'Se dejará de leer correos para detectar movimientos. ¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await EmailConnectionRepository.disconnectGmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gmail desconectado'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Correo Gmail'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Conecta tu Gmail para que el servidor analice avisos bancarios (solo lectura). Tras autorizar en Google, vuelve a esta pantalla.',
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: scheme.error),
                )
              else ...[
                if (_status?.connected == true) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.mark_email_read, color: scheme.primary),
                    title: const Text('Conectado'),
                    subtitle: Text(_status?.emailAddress ?? ''),
                  ),
                  if (_status?.lastSyncedAt != null &&
                      _status!.lastSyncedAt!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Última sync: ${_status!.lastSyncedAt}',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                ] else
                  Text(
                    'No hay cuenta Gmail vinculada.',
                    style: TextStyle(color: scheme.onSurface),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _connectGmail,
                    child: Text(_status?.connected == true
                        ? 'Volver a autorizar Gmail'
                        : 'Conectar Gmail'),
                  ),
                ),
                if (_status?.connected == true) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _busy ? null : _sync,
                      child: const Text('Sincronizar ahora'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _busy ? null : _disconnect,
                      child: Text(
                        'Desconectar',
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
