import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/custom_snackbar.dart';
import '../providers/trip_invitation_provider.dart';
import 'trips_list_screen.dart';

/// Pantalla que recibe un token de invitación (deep link) y lo acepta
class AcceptInvitationScreen extends StatefulWidget {
  final String? initialToken;

  const AcceptInvitationScreen({super.key, this.initialToken});

  @override
  State<AcceptInvitationScreen> createState() => _AcceptInvitationScreenState();
}

class _AcceptInvitationScreenState extends State<AcceptInvitationScreen> {
  late TextEditingController _tokenController;

  @override
  void initState() {
    super.initState();
    final providerToken = context.read<TripInvitationProvider>().pendingToken;
    _tokenController = TextEditingController(
      text: widget.initialToken ?? providerToken ?? '',
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      CustomSnackBar.showWarning(context, 'Ingresa un token de invitación');
      return;
    }
    final provider = context.read<TripInvitationProvider>();
    final member = await provider.accept(token);
    if (!mounted) return;
    if (member != null) {
      CustomSnackBar.showSuccess(context, 'Te uniste al viaje');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TripsListScreen()),
      );
    } else if (provider.error != null) {
      CustomSnackBar.showError(context, provider.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Aceptar invitación'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<TripInvitationProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.travel_explore,
                      size: 32,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Únete al viaje',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pega el token de invitación que te enviaron o úsalo desde el enlace recibido.',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _tokenController,
                    decoration: InputDecoration(
                      labelText: 'Token de invitación',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isProcessing ? null : _accept,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: provider.isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Aceptar invitación',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  if (provider.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
