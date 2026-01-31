import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/accessibility_service.dart';
import '../../domain/entities/accessibility_settings.dart';

// ============ Service Provider ============

/// Provider for accessibility service.
final accessibilityServiceProvider = Provider<AccessibilityService>((ref) {
  return AccessibilityService();
});

// ============ Settings Provider ============

/// Provider for accessibility settings.
final accessibilitySettingsProvider =
    FutureProvider<AccessibilitySettings>((ref) async {
  final service = ref.watch(accessibilityServiceProvider);
  return service.getSettings();
});

/// Provider for keyboard shortcuts.
final keyboardShortcutsProvider = Provider<Map<String, String>>((ref) {
  final service = ref.watch(accessibilityServiceProvider);
  return service.getKeyboardShortcuts();
});

// ============ Direct Functions ============

/// UC252: Enable/disable screen reader mode.
Future<AccessibilitySettings> setScreenReaderEnabledDirect(
  AccessibilityService service,
  bool enabled,
) async {
  return service.setScreenReaderEnabled(enabled);
}

/// UC253: Set text scale factor.
Future<AccessibilitySettings> setTextScaleFactorDirect(
  AccessibilityService service,
  double factor,
) async {
  return service.setTextScaleFactor(factor);
}

/// UC253: Set text size preset.
Future<AccessibilitySettings> setTextSizePresetDirect(
  AccessibilityService service,
  TextSizePreset preset,
) async {
  return service.setTextSizePreset(preset);
}

/// UC254: Set high contrast mode.
Future<AccessibilitySettings> setHighContrastModeDirect(
  AccessibilityService service,
  HighContrastMode mode,
) async {
  return service.setHighContrastMode(mode);
}

/// UC255: Enable/disable keyboard navigation.
Future<AccessibilitySettings> setKeyboardNavigationEnabledDirect(
  AccessibilityService service,
  bool enabled,
) async {
  return service.setKeyboardNavigationEnabled(enabled);
}

/// UC256: Enable/disable reduced animations.
Future<AccessibilitySettings> setReduceAnimationsDirect(
  AccessibilityService service,
  bool enabled,
) async {
  return service.setReduceAnimations(enabled);
}

/// UC256: Set animation speed.
Future<AccessibilitySettings> setAnimationSpeedDirect(
  AccessibilityService service,
  double speed,
) async {
  return service.setAnimationSpeed(speed);
}

/// UC257: Set color blind mode.
Future<AccessibilitySettings> setColorBlindModeDirect(
  AccessibilityService service,
  ColorBlindMode mode,
) async {
  return service.setColorBlindMode(mode);
}

/// Set larger touch targets.
Future<AccessibilitySettings> setUseLargerTouchTargetsDirect(
  AccessibilityService service,
  bool enabled,
) async {
  return service.setUseLargerTouchTargets(enabled);
}

/// Set icon labels visibility.
Future<AccessibilitySettings> setShowIconLabelsDirect(
  AccessibilityService service,
  bool show,
) async {
  return service.setShowIconLabels(show);
}

/// UC252: Announce text to screen reader.
Future<void> announceDirect(
  AccessibilityService service,
  String message,
) async {
  await service.announce(message);
}

/// Reset accessibility settings to defaults.
Future<AccessibilitySettings> resetAccessibilitySettingsDirect(
  AccessibilityService service,
) async {
  return service.resetToDefaults();
}

/// Get high contrast colors.
HighContrastColors getHighContrastColorsDirect(
  AccessibilityService service,
  HighContrastMode mode,
) {
  return service.getHighContrastColors(mode);
}

/// Get color-blind friendly palette.
ColorBlindPalette getColorBlindPaletteDirect(
  AccessibilityService service,
  ColorBlindMode mode,
) {
  return service.getColorBlindPalette(mode);
}
