import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/custom_snackbar.dart';
import '../../data/models/trip_models.dart';
import '../providers/active_trip_provider.dart';

class TripMembersScreen extends StatefulWidget {
  final int tripId;
  const TripMembersScreen({super.key, required this.tripId});

  @override
  State<TripMembersScreen> createState() => _TripMembersScreenState();
}

class _TripMembersScreenState extends State<TripMembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActiveTripProvider>().reloadInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveTripProvider>(
      builder: (context, provider, _) {
        final members = provider.members;
        final invitations = provider.invitations;
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openActions,
            icon: const Icon(Icons.person_add),
            label: const Text('Agregar miembro'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Text(
                'Miembros (${members.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (members.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Aún no hay miembros en este viaje. Agrega uno o invita por enlace.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                )
              else
                ...members.map(_buildMemberTile),
              const SizedBox(height: 24),
              Text(
                'Invitaciones pendientes (${invitations.where((i) => i.usedAt == null).length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (invitations.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No hay invitaciones activas.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                )
              else
                ...invitations.map(_buildInvitationTile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMemberTile(TripMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              member.displayName.isNotEmpty
                  ? member.displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${member.role.label}${member.isGhost ? ' (informal)' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (member.role != TripMemberRole.owner)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Quitar miembro',
              onPressed: () => _confirmRemove(member),
            ),
        ],
      ),
    );
  }

  Widget _buildInvitationTile(TripInvitation invitation) {
    final used = invitation.usedAt != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                used ? Icons.check_circle : Icons.mail_outline,
                color: used
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  invitation.email.isNotEmpty
                      ? invitation.email
                      : '(sin correo)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (!used)
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copiar token',
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: invitation.token),
                    );
                    if (!mounted) return;
                    CustomSnackBar.showSuccess(context, 'Token copiado');
                  },
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Rol: ${invitation.role.label}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            used
                ? 'Aceptada'
                : 'Vence: ${invitation.expiresAt.toLocal()}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openActions() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Agregar miembro informal (fantasma)'),
                subtitle: const Text(
                    'Solo para repartir gastos sin invitar a la cuenta.'),
                onTap: () => Navigator.pop(context, 'ghost'),
              ),
              ListTile(
                leading: const Icon(Icons.mail),
                title: const Text('Crear invitación por email'),
                subtitle: const Text('Genera un enlace para invitar a un usuario.'),
                onTap: () => Navigator.pop(context, 'invite'),
              ),
            ],
          ),
        ),
      ),
    );
    if (action == 'ghost') {
      await _addGhost();
    } else if (action == 'invite') {
      await _createInvitation();
    }
  }

  Future<void> _addGhost() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _GhostMemberDialog(),
    );
    if (result == null || !mounted) return;
    final provider = context.read<ActiveTripProvider>();
    final added = await provider.addGhostMember(result);
    if (!mounted) return;
    if (added != null) {
      CustomSnackBar.showSuccess(context, 'Miembro agregado');
    } else {
      CustomSnackBar.showError(
          context, provider.error ?? 'No se pudo agregar el miembro');
    }
  }

  Future<void> _createInvitation() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _InvitationDialog(),
    );
    if (result == null || !mounted) return;
    final provider = context.read<ActiveTripProvider>();
    final invitation = await provider.createInvitation(result);
    if (!mounted) return;
    if (invitation != null) {
      await Clipboard.setData(ClipboardData(text: invitation.token));
      if (!mounted) return;
      CustomSnackBar.showSuccess(
        context,
        'Invitación creada y token copiado al portapapeles',
      );
    } else {
      CustomSnackBar.showError(
          context, provider.error ?? 'No se pudo crear la invitación');
    }
  }

  Future<void> _confirmRemove(TripMember member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Quitar a ${member.displayName}'),
        content: const Text(
            '¿Seguro? Si tiene splits pendientes, primero deben saldarse.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final provider = context.read<ActiveTripProvider>();
    final ok = await provider.removeMember(member.id);
    if (!mounted) return;
    if (ok) {
      CustomSnackBar.showSuccess(context, 'Miembro quitado');
    } else {
      CustomSnackBar.showError(
          context, provider.error ?? 'No se pudo quitar al miembro');
    }
  }
}

class _GhostMemberDialog extends StatefulWidget {
  const _GhostMemberDialog();

  @override
  State<_GhostMemberDialog> createState() => _GhostMemberDialogState();
}

class _GhostMemberDialogState extends State<_GhostMemberDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  TripMemberRole _role = TripMemberRole.member;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo miembro informal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email (opcional)'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<TripMemberRole>(
            initialValue: _role,
            decoration: const InputDecoration(labelText: 'Rol'),
            items: TripMemberRole.values
                .where((r) => r != TripMemberRole.owner)
                .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                .toList(),
            onChanged: (value) => setState(() => _role = value ?? _role),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(context, {
              'display_name': name,
              if (_emailController.text.trim().isNotEmpty)
                'email': _emailController.text.trim(),
              'role': _role.apiValue,
            });
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}

class _InvitationDialog extends StatefulWidget {
  const _InvitationDialog();

  @override
  State<_InvitationDialog> createState() => _InvitationDialogState();
}

class _InvitationDialogState extends State<_InvitationDialog> {
  final _emailController = TextEditingController();
  TripMemberRole _role = TripMemberRole.member;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva invitación'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Correo del invitado'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<TripMemberRole>(
            initialValue: _role,
            decoration: const InputDecoration(labelText: 'Rol'),
            items: TripMemberRole.values
                .where((r) => r != TripMemberRole.owner)
                .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                .toList(),
            onChanged: (value) => setState(() => _role = value ?? _role),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final email = _emailController.text.trim();
            if (email.isEmpty) return;
            Navigator.pop(context, {
              'email': email,
              'role': _role.apiValue,
            });
          },
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
