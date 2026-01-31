import 'dart:convert';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/accessibility_settings.dart';

/// UC252-UC257: Accessibility service for A11y features.
///
/// Handles:
/// - Screen reader support (UC252)
/// - Text size adjustment (UC253)
/// - High contrast mode (UC254)
/// - Keyboard navigation (UC255)
/// - Reduced animations (UC256)
/// - Color blind modes (UC257)
class AccessibilityService {
  static const String _settingsKey = 'accessibility_settings';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Get current accessibility settings.
  Future<AccessibilitySettings> getSettings() async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString(_settingsKey);

      if (json == null) {
        // First launch - detect system accessibility settings
        final settings = await _detectSystemSettings();
        await saveSettings(settings);
        return settings;
      }

      return AccessibilitySettings.fromJson(jsonDecode(json));
    } catch (e) {
      debugPrint('AccessibilityService: Error getting settings: $e');
      return AccessibilitySettings.defaults;
    }
  }

  /// Save accessibility settings.
  Future<void> saveSettings(AccessibilitySettings settings) async {
    final prefs = await _preferences;
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
    debugPrint('AccessibilityService: Settings saved');
  }

  /// UC252: Enable/disable screen reader mode.
  Future<AccessibilitySettings> setScreenReaderEnabled(bool enabled) async {
    final current = await getSettings();
    final updated = current.copyWith(
      screenReaderEnabled: enabled,
      // Also enable related features
      announceScreenChanges: enabled,
      showIconLabels: enabled,
    );
    await saveSettings(updated);
    debugPrint('AccessibilityService: Screen reader mode: $enabled');
    return updated;
  }

  /// UC253: Set text scale factor.
  Future<AccessibilitySettings> setTextScaleFactor(double factor) async {
    final clampedFactor = factor.clamp(0.5, 2.0);
    final current = await getSettings();
    final updated = current.copyWith(textScaleFactor: clampedFactor);
    await saveSettings(updated);
    debugPrint('AccessibilityService: Text scale factor: $clampedFactor');
    return updated;
  }

  /// UC253: Set text size preset.
  Future<AccessibilitySettings> setTextSizePreset(TextSizePreset preset) async {
    return setTextScaleFactor(preset.scaleFactor);
  }

  /// UC254: Set high contrast mode.
  Future<AccessibilitySettings> setHighContrastMode(
    HighContrastMode mode,
  ) async {
    final current = await getSettings();
    final updated = current.copyWith(highContrastMode: mode);
    await saveSettings(updated);
    debugPrint('AccessibilityService: High contrast mode: ${mode.name}');
    return updated;
  }

  /// UC255: Enable/disable keyboard navigation.
  Future<AccessibilitySettings> setKeyboardNavigationEnabled(
    bool enabled,
  ) async {
    final current = await getSettings();
    final updated = current.copyWith(
      keyboardNavigationEnabled: enabled,
      focusIndicatorWidth: enabled ? 3.0 : 2.0,
    );
    await saveSettings(updated);
    debugPrint('AccessibilityService: Keyboard navigation: $enabled');
    return updated;
  }

  /// UC256: Enable/disable reduced animations.
  Future<AccessibilitySettings> setReduceAnimations(bool enabled) async {
    final current = await getSettings();
    final updated = current.copyWith(reduceAnimations: enabled);
    await saveSettings(updated);
    debugPrint('AccessibilityService: Reduce animations: $enabled');
    return updated;
  }

  /// UC256: Set animation speed.
  Future<AccessibilitySettings> setAnimationSpeed(double speed) async {
    final clampedSpeed = speed.clamp(0.5, 2.0);
    final current = await getSettings();
    final updated = current.copyWith(animationSpeed: clampedSpeed);
    await saveSettings(updated);
    debugPrint('AccessibilityService: Animation speed: $clampedSpeed');
    return updated;
  }

  /// UC257: Set color blind mode.
  Future<AccessibilitySettings> setColorBlindMode(ColorBlindMode mode) async {
    final current = await getSettings();
    final updated = current.copyWith(colorBlindMode: mode);
    await saveSettings(updated);
    debugPrint('AccessibilityService: Color blind mode: ${mode.name}');
    return updated;
  }

  /// Set larger touch targets.
  Future<AccessibilitySettings> setUseLargerTouchTargets(bool enabled) async {
    final current = await getSettings();
    final updated = current.copyWith(useLargerTouchTargets: enabled);
    await saveSettings(updated);
    debugPrint('AccessibilityService: Larger touch targets: $enabled');
    return updated;
  }

  /// Set icon labels visibility.
  Future<AccessibilitySettings> setShowIconLabels(bool show) async {
    final current = await getSettings();
    final updated = current.copyWith(showIconLabels: show);
    await saveSettings(updated);
    return updated;
  }

  /// UC252: Announce text to screen reader.
  Future<void> announce(String message) async {
    final settings = await getSettings();
    if (!settings.screenReaderEnabled) return;

    try {
      await SemanticsService.announce(message, TextDirection.ltr);
      debugPrint('AccessibilityService: Announced: $message');
    } catch (e) {
      debugPrint('AccessibilityService: Error announcing: $e');
    }
  }

  /// UC255: Handle keyboard shortcut.
  KeyEventResult handleKeyEvent(
    KeyEvent event,
    AccessibilitySettings settings,
    Map<LogicalKeyboardKey, VoidCallback> shortcuts,
  ) {
    if (!settings.keyboardNavigationEnabled) {
      return KeyEventResult.ignored;
    }

    if (event is KeyDownEvent) {
      final callback = shortcuts[event.logicalKey];
      if (callback != null) {
        callback();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  /// Get common keyboard shortcuts.
  Map<String, String> getKeyboardShortcuts() {
    return {
      'Enter': 'Confirmar ação',
      'Escape': 'Cancelar / Voltar',
      'Tab': 'Próximo elemento',
      'Shift+Tab': 'Elemento anterior',
      'Espaço': 'Ativar botão / Mostrar resposta',
      '1': 'Avaliar: De novo',
      '2': 'Avaliar: Difícil',
      '3': 'Avaliar: Bom',
      '4': 'Avaliar: Fácil',
      'H': 'Mostrar dica',
      'S': 'Pular card',
    };
  }

  /// UC254: Get high contrast colors.
  HighContrastColors getHighContrastColors(HighContrastMode mode) {
    switch (mode) {
      case HighContrastMode.off:
        return HighContrastColors.normal;
      case HighContrastMode.light:
        return HighContrastColors.light;
      case HighContrastMode.dark:
        return HighContrastColors.dark;
    }
  }

  /// UC257: Get color-blind friendly colors.
  ColorBlindPalette getColorBlindPalette(ColorBlindMode mode) {
    switch (mode) {
      case ColorBlindMode.none:
        return ColorBlindPalette.normal;
      case ColorBlindMode.protanopia:
        return ColorBlindPalette.protanopia;
      case ColorBlindMode.deuteranopia:
        return ColorBlindPalette.deuteranopia;
      case ColorBlindMode.tritanopia:
        return ColorBlindPalette.tritanopia;
      case ColorBlindMode.achromatopsia:
        return ColorBlindPalette.achromatopsia;
    }
  }

  /// Reset to defaults.
  Future<AccessibilitySettings> resetToDefaults() async {
    final settings = AccessibilitySettings.defaults;
    await saveSettings(settings);
    debugPrint('AccessibilityService: Reset to defaults');
    return settings;
  }

  // ============ Private Methods ============

  Future<AccessibilitySettings> _detectSystemSettings() async {
    // Try to detect if system accessibility features are enabled
    // This is platform-dependent and may not always work

    // For now, return defaults
    // In production, you would use platform channels to detect
    // system-level accessibility settings

    return AccessibilitySettings.defaults;
  }
}

/// High contrast color scheme.
class HighContrastColors {
  final int background;
  final int foreground;
  final int primary;
  final int error;
  final int success;
  final int border;

  const HighContrastColors({
    required this.background,
    required this.foreground,
    required this.primary,
    required this.error,
    required this.success,
    required this.border,
  });

  static const HighContrastColors normal = HighContrastColors(
    background: 0xFFFFFFFF,
    foreground: 0xFF212121,
    primary: 0xFF6750A4,
    error: 0xFFBA1A1A,
    success: 0xFF2E7D32,
    border: 0xFFE0E0E0,
  );

  static const HighContrastColors light = HighContrastColors(
    background: 0xFFFFFFFF,
    foreground: 0xFF000000,
    primary: 0xFF0000CC,
    error: 0xFFCC0000,
    success: 0xFF006600,
    border: 0xFF000000,
  );

  static const HighContrastColors dark = HighContrastColors(
    background: 0xFF000000,
    foreground: 0xFFFFFFFF,
    primary: 0xFF6699FF,
    error: 0xFFFF6666,
    success: 0xFF66FF66,
    border: 0xFFFFFFFF,
  );
}

/// Color-blind friendly palette.
class ColorBlindPalette {
  final int success;
  final int warning;
  final int error;
  final int info;
  final int neutral;

  const ColorBlindPalette({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.neutral,
  });

  // Normal colors
  static const ColorBlindPalette normal = ColorBlindPalette(
    success: 0xFF4CAF50, // Green
    warning: 0xFFFF9800, // Orange
    error: 0xFFF44336, // Red
    info: 0xFF2196F3, // Blue
    neutral: 0xFF9E9E9E, // Grey
  );

  // Protanopia (red-blind) - use blue/yellow contrast
  static const ColorBlindPalette protanopia = ColorBlindPalette(
    success: 0xFF2196F3, // Blue
    warning: 0xFFFFEB3B, // Yellow
    error: 0xFF9C27B0, // Purple
    info: 0xFF00BCD4, // Cyan
    neutral: 0xFF9E9E9E, // Grey
  );

  // Deuteranopia (green-blind) - similar to protanopia
  static const ColorBlindPalette deuteranopia = ColorBlindPalette(
    success: 0xFF2196F3, // Blue
    warning: 0xFFFFEB3B, // Yellow
    error: 0xFF9C27B0, // Purple
    info: 0xFF00BCD4, // Cyan
    neutral: 0xFF9E9E9E, // Grey
  );

  // Tritanopia (blue-blind) - use red/green contrast
  static const ColorBlindPalette tritanopia = ColorBlindPalette(
    success: 0xFF4CAF50, // Green
    warning: 0xFFFF5722, // Deep orange
    error: 0xFFF44336, // Red
    info: 0xFF8BC34A, // Light green
    neutral: 0xFF9E9E9E, // Grey
  );

  // Achromatopsia (total color blindness) - use patterns/shapes instead
  static const ColorBlindPalette achromatopsia = ColorBlindPalette(
    success: 0xFF424242, // Dark grey
    warning: 0xFF757575, // Medium grey
    error: 0xFF212121, // Very dark grey
    info: 0xFF9E9E9E, // Light grey
    neutral: 0xFFBDBDBD, // Lighter grey
  );
}
