import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/accessibility_settings.dart';
import '../../providers/accessibility_providers.dart';

/// UC252-UC257: Accessibility settings screen.
class AccessibilitySettingsScreen extends ConsumerStatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  ConsumerState<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends ConsumerState<AccessibilitySettingsScreen> {
  AccessibilitySettings? _settings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final service = ref.read(accessibilityServiceProvider);
    final settings = await service.getSettings();
    if (mounted) {
      setState(() => _settings = settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acessibilidade'),
      ),
      body: _settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // UC252: Screen Reader
                _buildSection(
                  title: 'Leitor de Tela',
                  icon: Icons.record_voice_over,
                  children: [
                    SwitchListTile(
                      title: const Text('Modo leitor de tela'),
                      subtitle: const Text(
                        'Otimiza a interface para leitores de tela',
                      ),
                      value: _settings!.screenReaderEnabled,
                      onChanged: _isLoading ? null : _setScreenReaderEnabled,
                    ),
                    SwitchListTile(
                      title: const Text('Anunciar mudanças de tela'),
                      subtitle: const Text(
                        'Anuncia quando você navega para uma nova tela',
                      ),
                      value: _settings!.announceScreenChanges,
                      onChanged: _isLoading ? null : _setAnnounceScreenChanges,
                    ),
                    SwitchListTile(
                      title: const Text('Mostrar rótulos em ícones'),
                      subtitle: const Text(
                        'Exibe texto junto aos ícones',
                      ),
                      value: _settings!.showIconLabels,
                      onChanged: _isLoading ? null : _setShowIconLabels,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // UC253: Text Size
                _buildSection(
                  title: 'Tamanho do Texto',
                  icon: Icons.text_fields,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Escala: ${(_settings!.textScaleFactor * 100).toInt()}%',
                            style: context.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Slider(
                            value: _settings!.textScaleFactor,
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                            label:
                                '${(_settings!.textScaleFactor * 100).toInt()}%',
                            onChanged: _isLoading ? null : _setTextScaleFactor,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: TextSizePreset.values.map((preset) {
                              final isSelected = (_settings!.textScaleFactor -
                                          preset.scaleFactor)
                                      .abs() <
                                  0.05;
                              return ChoiceChip(
                                label: Text(preset.displayName),
                                selected: isSelected,
                                onSelected: _isLoading
                                    ? null
                                    : (_) => _setTextSizePreset(preset),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Texto de exemplo',
                              style: context.textTheme.bodyLarge?.copyWith(
                                fontSize: 16 * _settings!.textScaleFactor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // UC254: High Contrast
                _buildSection(
                  title: 'Alto Contraste',
                  icon: Icons.contrast,
                  children: [
                    ...HighContrastMode.values.map((mode) {
                      return RadioListTile<HighContrastMode>(
                        title: Text(mode.displayName),
                        subtitle: Text(mode.description),
                        value: mode,
                        groupValue: _settings!.highContrastMode,
                        onChanged:
                            _isLoading ? null : (m) => _setHighContrastMode(m!),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                // UC255: Keyboard Navigation
                _buildSection(
                  title: 'Navegação por Teclado',
                  icon: Icons.keyboard,
                  children: [
                    SwitchListTile(
                      title: const Text('Navegação por teclado'),
                      subtitle: const Text(
                        'Permite navegar usando Tab e Enter',
                      ),
                      value: _settings!.keyboardNavigationEnabled,
                      onChanged: _isLoading ? null : _setKeyboardNavigation,
                    ),
                    if (_settings!.keyboardNavigationEnabled)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildKeyboardShortcuts(),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // UC256: Animations
                _buildSection(
                  title: 'Animações',
                  icon: Icons.animation,
                  children: [
                    SwitchListTile(
                      title: const Text('Reduzir animações'),
                      subtitle: const Text(
                        'Desativa ou minimiza animações',
                      ),
                      value: _settings!.reduceAnimations,
                      onChanged: _isLoading ? null : _setReduceAnimations,
                    ),
                    if (!_settings!.reduceAnimations)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Velocidade: ${(_settings!.animationSpeed * 100).toInt()}%',
                              style: context.textTheme.bodyMedium,
                            ),
                            Slider(
                              value: _settings!.animationSpeed,
                              min: 0.5,
                              max: 2.0,
                              divisions: 6,
                              label:
                                  '${(_settings!.animationSpeed * 100).toInt()}%',
                              onChanged:
                                  _isLoading ? null : _setAnimationSpeed,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // UC257: Color Blind Mode
                _buildSection(
                  title: 'Modo Daltonismo',
                  icon: Icons.palette,
                  children: [
                    ...ColorBlindMode.values.map((mode) {
                      return RadioListTile<ColorBlindMode>(
                        title: Text(mode.displayName),
                        subtitle: Text(mode.description),
                        value: mode,
                        groupValue: _settings!.colorBlindMode,
                        onChanged:
                            _isLoading ? null : (m) => _setColorBlindMode(m!),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                // Touch Targets
                _buildSection(
                  title: 'Alvos de Toque',
                  icon: Icons.touch_app,
                  children: [
                    SwitchListTile(
                      title: const Text('Alvos maiores'),
                      subtitle: const Text(
                        'Aumenta a área de toque dos botões',
                      ),
                      value: _settings!.useLargerTouchTargets,
                      onChanged: _isLoading ? null : _setLargerTouchTargets,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Reset
                Center(
                  child: TextButton.icon(
                    onPressed: _isLoading ? null : _resetToDefaults,
                    icon: const Icon(Icons.restore),
                    label: const Text('Restaurar padrões'),
                  ),
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

  Widget _buildKeyboardShortcuts() {
    final shortcuts = ref.watch(keyboardShortcutsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Atalhos de teclado',
          style: context.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...shortcuts.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: context.colorScheme.outline,
                    ),
                  ),
                  child: Text(
                    entry.key,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(entry.value),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ============ Actions ============

  Future<void> _setScreenReaderEnabled(bool enabled) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(accessibilityServiceProvider);
      final updated = await setScreenReaderEnabledDirect(service, enabled);
      setState(() => _settings = updated);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setAnnounceScreenChanges(bool enabled) async {
    if (_settings == null) return;
    final service = ref.read(accessibilityServiceProvider);
    final updated = _settings!.copyWith(announceScreenChanges: enabled);
    await service.saveSettings(updated);
    setState(() => _settings = updated);
  }

  Future<void> _setShowIconLabels(bool show) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(accessibilityServiceProvider);
      final updated = await setShowIconLabelsDirect(service, show);
      setState(() => _settings = updated);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setTextScaleFactor(double factor) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(accessibilityServiceProvider);
      final updated = await setTextScaleFactorDirect(service, factor);
      setState(() => _settings = updated);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setTextSizePreset(TextSizePreset preset) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(accessibilityServiceProvider);
      final updated = await setTextSizePresetDirect(service, preset);
      setState(() => _settings = updated);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setHighContrastMode(HighContrastMode mode) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(accessibilityServiceProvider);
      final updated = await setHighContrastModeDirect(service, mode);
      setState(() => _settings = updated);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setKeyboardNavigation(bool enabled) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(accessibilityServiceProvider);
      final updated = await setKeyboardNavigationEnabledDirect(service, enabled);
      setState(() => _settings = updated);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setReduceAnimations(bool enabled) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(accessibilityServiceProvider);
      final updated = await setReduceAnimationsDirect(service, enabled);
      setState(() => _settings = updated);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setAnimationSpeed(double speed) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(accessibilityServiceProvider);
      final updated = await setAnimationSpeedDirect(service, speed);
      setState(() => _settings = updated);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setColorBlindMode(ColorBlindMode mode) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(accessibilityServiceProvider);
      final updated = await setColorBlindModeDirect(service, mode);
      setState(() => _settings = updated);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setLargerTouchTargets(bool enabled) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(accessibilityServiceProvider);
      final updated = await setUseLargerTouchTargetsDirect(service, enabled);
      setState(() => _settings = updated);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetToDefaults() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar padrões?'),
        content: const Text(
          'Todas as configurações de acessibilidade serão restauradas para os valores padrão.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final service = ref.read(accessibilityServiceProvider);
      final updated = await resetAccessibilitySettingsDirect(service);
      setState(() => _settings = updated);
      if (mounted) {
        context.showSnackBar('Configurações restauradas');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
