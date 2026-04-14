import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/locale_provider.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Idioma'),
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0),
        elevation: 0,
      ),
      body: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildLanguageTile(
                context,
                localeProvider: localeProvider,
                code: 'es',
                label: 'Español',
                subtitle: 'Predeterminado para Latinoamérica',
              ),
              _buildLanguageTile(
                context,
                localeProvider: localeProvider,
                code: 'en',
                label: 'English',
                subtitle: 'Fallback global',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required LocaleProvider localeProvider,
    required String code,
    required String label,
    required String subtitle,
  }) {
    final selected = localeProvider.locale.languageCode == code;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: RadioListTile<String>(
        value: code,
        groupValue: localeProvider.locale.languageCode,
        onChanged: (value) {
          if (value == null) return;
          localeProvider.setLocale(value);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Idioma actualizado a $label')),
          );
        },
        title: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}
