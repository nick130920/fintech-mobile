import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../data/models/bank_account_model.dart';
import '../../data/models/bank_notification_pattern_model.dart';
import '../providers/bank_account_provider.dart';
import '../providers/bank_notification_pattern_provider.dart';

class AddNotificationPatternScreen extends StatefulWidget {
  const AddNotificationPatternScreen({super.key});

  @override
  State<AddNotificationPatternScreen> createState() =>
      _AddNotificationPatternScreenState();
}

class _AddNotificationPatternScreenState
    extends State<AddNotificationPatternScreen> {
  final _formKey = GlobalKey<FormState>();
  final _exampleMessageController = TextEditingController();

  BankAccountModel? _selectedBankAccount;

  @override
  void dispose() {
    _exampleMessageController.dispose();
    super.dispose();
  }

  Future<void> _createPatternWithAI() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = CreatePatternFromMessageRequest(
      message: _exampleMessageController.text,
      bankAccountId: _selectedBankAccount!.id,
    );

    final provider = context.read<BankNotificationPatternProvider>();
    final success = await provider.createPatternFromMessage(request);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Patrón creado con IA exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (provider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.error}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Crear Patrón con IA'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Consumer<BankNotificationPatternProvider>(
            builder: (context, patternProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildBankAccountSection(),
                  const SizedBox(height: 24),
                  _buildMessageInputSection(),
                  const SizedBox(height: 32),
                  _buildCreateButton(patternProvider),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.smart_toy_outlined,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Creación Rápida con IA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'Pega un mensaje y la IA hará el resto.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankAccountSection() {
    return Consumer<BankAccountProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final accounts = provider.activeBankAccounts;
        if (accounts.isEmpty) {
          return const Text('No hay cuentas bancarias activas.');
        }

        return GlassmorphismCard(
          style: GlassStyles.medium,
          enableEntryAnimation: true,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Selecciona la Cuenta Bancaria',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<BankAccountModel>(
                  value: _selectedBankAccount,
                  items: accounts.map((account) {
                    return DropdownMenuItem(value: account, child: Text(account.accountAlias));
                  }).toList(),
                  onChanged: (account) =>
                      setState(() => _selectedBankAccount = account),
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona una cuenta bancaria';
                    }
                    return null;
                  },
                   decoration: InputDecoration(
                    hintText: 'Selecciona una cuenta bancaria',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInputSection() {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. Pega el Mensaje de Ejemplo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _exampleMessageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Pega aquí el SMS o notificación del banco...',
                 border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El mensaje de ejemplo es requerido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton(BankNotificationPatternProvider patternProvider) {
    return SizedBox(
      width: double.infinity,
      child: GlassmorphismButton(
        style: GlassButtonStyles.primary,
        enablePulseEffect: true,
        onPressed: patternProvider.isGeneratingPattern
            ? null
            : _createPatternWithAI,
        child: patternProvider.isGeneratingPattern
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Crear Patrón con IA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
