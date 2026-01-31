import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/app_locale.dart';
import '../../providers/localization_providers.dart';

/// UC248-UC251: Language settings screen.
class LanguageSettingsScreen extends ConsumerStatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  ConsumerState<LanguageSettingsScreen> createState() =>
      _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState
    extends ConsumerState<LanguageSettingsScreen> {
  LocalizationSettings? _settings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final service = ref.read(localizationServiceProvider);
    final settings = await service.getSettings();
    if (mounted) {
      setState(() => _settings = settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locales = ref.watch(availableLocalesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Idioma'),
      ),
      body: _settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // UC249: Auto-detection
                Card(
                  child: SwitchListTile(
                    title: const Text('Detectar automaticamente'),
                    subtitle: const Text(
                      'Usa o idioma do sistema',
                    ),
                    value: _settings!.autoDetect,
                    onChanged: _isLoading ? null : _setAutoDetect,
                    secondary: const Icon(Icons.auto_awesome),
                  ),
                ),

                const SizedBox(height: 24),

                // UC248: App Language
                _buildSection(
                  title: 'Idioma do App',
                  icon: Icons.language,
                  children: [
                    ...locales.map((locale) {
                      final isSelected =
                          locale.identifier == _settings!.appLocale.identifier;
                      return ListTile(
                        title: Text(locale.nativeName),
                        subtitle: Text(locale.displayName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!locale.isFullySupported)
                              Tooltip(
                                message: 'Suporte parcial',
                                child: Icon(
                                  Icons.warning_amber,
                                  color: context.colorScheme.error,
                                  size: 20,
                                ),
                              ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: context.colorScheme.primary,
                              ),
                          ],
                        ),
                        onTap: _isLoading
                            ? null
                            : () => _setLocale(locale),
                        selected: isSelected,
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                // UC251: AI Content Language
                _buildSection(
                  title: 'Idioma do Conteúdo IA',
                  icon: Icons.smart_toy,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cards gerados por IA usarão este idioma:',
                            style: context.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _settings!.aiContentLanguage,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Idioma',
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: 'pt',
                                child: Text('Português'),
                              ),
                              const DropdownMenuItem(
                                value: 'en',
                                child: Text('English'),
                              ),
                              const DropdownMenuItem(
                                value: 'es',
                                child: Text('Español'),
                              ),
                              const DropdownMenuItem(
                                value: 'fr',
                                child: Text('Français'),
                              ),
                              const DropdownMenuItem(
                                value: 'de',
                                child: Text('Deutsch'),
                              ),
                            ],
                            onChanged: _isLoading
                                ? null
                                : (value) => _setAiContentLanguage(value!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // UC250: Date Format
                _buildSection(
                  title: 'Formato de Data',
                  icon: Icons.calendar_today,
                  children: [
                    ...DateFormatPreference.values.map((format) {
                      return RadioListTile<DateFormatPreference>(
                        title: Text(format.displayName),
                        subtitle: Text('Ex: ${format.example}'),
                        value: format,
                        groupValue: _settings!.dateFormat,
                        onChanged: _isLoading
                            ? null
                            : (f) => _setDateFormat(f!),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                // UC250: Number Format
                _buildSection(
                  title: 'Formato de Números',
                  icon: Icons.numbers,
                  children: [
                    ...NumberFormatPreference.values.map((format) {
                      return RadioListTile<NumberFormatPreference>(
                        title: Text(format.displayName),
                        value: format,
                        groupValue: _settings!.numberFormat,
                        onChanged: _isLoading
                            ? null
                            : (f) => _setNumberFormat(f!),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: context.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  // ============ Actions ============

  Future<void> _setAutoDetect(bool enabled) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(localizationServiceProvider);
      final updated = await setAutoDetectDirect(service, enabled);
      setState(() => _settings = updated);
      if (mounted) {
        context.showSnackBar(
          enabled
              ? 'Detectando idioma do sistema...'
              : 'Detecção automática desativada',
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setLocale(AppLocale locale) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(localizationServiceProvider);
      final updated = await setLocaleDirect(service, locale);
      setState(() => _settings = updated);
      if (mounted) {
        context.showSnackBar('Idioma alterado para ${locale.nativeName}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setAiContentLanguage(String languageCode) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(localizationServiceProvider);
      final updated = await setAiContentLanguageDirect(service, languageCode);
      setState(() => _settings = updated);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setDateFormat(DateFormatPreference format) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(localizationServiceProvider);
      final updated = await setDateFormatDirect(service, format);
      setState(() => _settings = updated);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setNumberFormat(NumberFormatPreference format) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(localizationServiceProvider);
      final updated = await setNumberFormatDirect(service, format);
      setState(() => _settings = updated);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
