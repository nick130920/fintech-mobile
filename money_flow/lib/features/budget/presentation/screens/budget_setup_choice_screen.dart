import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/sms_service.dart';
import '../providers/budget_setup_provider.dart';
import '../providers/budget_suggestions_provider.dart';
import 'budget_setup_wrapper.dart';

/// Pantalla intermedia para usuarios nuevos: elegir configurar manualmente o con sugerencias (SMS/extracto).
class BudgetSetupChoiceScreen extends StatelessWidget {
  final VoidCallback onSetupComplete;

  const BudgetSetupChoiceScreen({
    super.key,
    required this.onSetupComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Configura tu presupuesto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Así podrás llevar el control de tus gastos e ingresos.',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _goToSetup(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Configurar mi presupuesto',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                '¿Quieres que te sugieran montos?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 16),
              _SmsOption(onSetupComplete: onSetupComplete),
              const SizedBox(height: 12),
              _ExtractoOption(onSetupComplete: onSetupComplete),
            ],
          ),
        ),
      ),
    );
  }

  void _goToSetup(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BudgetSetupWrapper(onSetupComplete: onSetupComplete),
      ),
    );
  }
}

class _SmsOption extends StatelessWidget {
  final VoidCallback onSetupComplete;

  const _SmsOption({required this.onSetupComplete});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSuggestionsProvider>(
      builder: (context, suggestionsProvider, _) {
        final isAnalyzing = suggestionsProvider.isAnalyzing;
        return InkWell(
          onTap: isAnalyzing
              ? null
              : () => _onTapSms(context, suggestionsProvider),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sms_outlined,
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
                        'Usar mis SMS (últimos 3 meses)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Solo en este dispositivo, solo para sugerencias. No se crean transacciones.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAnalyzing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onTapSms(
    BuildContext context,
    BudgetSuggestionsProvider suggestionsProvider,
  ) async {
    final goSetup = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surface,
        title: Text(
          'Sugerencias con tus SMS',
          style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
        ),
        content: Text(
          'Para sugerirte presupuestos podemos leer solo los SMS de tu banco de los últimos 3 meses. '
          'No guardamos esos mensajes ni creamos transacciones. ¿Quieres activar esto?',
          style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.9)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No, configurar yo mismo'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí, usar mis SMS'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (goSetup != true) return;

    final hasPermission = await SmsService().requestPermissions();
    if (!context.mounted) return;
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sin problema, puedes configurar todo manualmente'),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await suggestionsProvider.analyzeLast3Months();
    if (!context.mounted) return;
    if (suggestionsProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(suggestionsProvider.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final suggestion = suggestionsProvider.suggestion;
    if (suggestion != null && (suggestion.totalSuggested > 0 || suggestion.byCategory.isNotEmpty)) {
      await context.read<BudgetSetupProvider>().initialize();
      if (!context.mounted) return;
      context.read<BudgetSetupProvider>().prefillFromSuggestions(suggestion);
    }
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BudgetSetupWrapper(onSetupComplete: onSetupComplete),
      ),
    );
  }
}

class _ExtractoOption extends StatelessWidget {
  final VoidCallback onSetupComplete;

  const _ExtractoOption({required this.onSetupComplete});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSuggestionsProvider>(
      builder: (context, suggestionsProvider, _) {
        final isAnalyzing = suggestionsProvider.isAnalyzing;
        return InkWell(
          onTap: isAnalyzing ? null : () => _onTapExtracto(context, suggestionsProvider),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.upload_file,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subir un extracto (PDF o imagen)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'El archivo se analiza solo para sugerirte montos. No se guarda.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAnalyzing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onTapExtracto(
    BuildContext context,
    BudgetSuggestionsProvider suggestionsProvider,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
    );
    if (result == null || result.files.isEmpty || result.files.single.path == null) return;
    final path = result.files.single.path!;

    await suggestionsProvider.analyzeStatement(path);
    if (!context.mounted) return;
    if (suggestionsProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(suggestionsProvider.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final suggestion = suggestionsProvider.suggestion;
    if (suggestion != null) {
      await context.read<BudgetSetupProvider>().initialize();
      if (!context.mounted) return;
      context.read<BudgetSetupProvider>().prefillFromSuggestions(suggestion);
    }
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BudgetSetupWrapper(onSetupComplete: onSetupComplete),
      ),
    );
  }
}
