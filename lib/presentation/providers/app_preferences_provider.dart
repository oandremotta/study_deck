import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Layout display mode for home screen.
enum LayoutMode {
  compact,  // Less info, minimal
  expanded, // More metrics, detailed
}

/// Provider for shared preferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

/// Provider for layout mode preference.
final layoutModeProvider = StateNotifierProvider<LayoutModeNotifier, LayoutMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LayoutModeNotifier(prefs);
});

/// Notifier for layout mode state.
class LayoutModeNotifier extends StateNotifier<LayoutMode> {
  static const _key = 'layout_mode';
  final SharedPreferences _prefs;

  LayoutModeNotifier(this._prefs) : super(_loadInitial(_prefs));

  static LayoutMode _loadInitial(SharedPreferences prefs) {
    final value = prefs.getString(_key);
    if (value == 'compact') return LayoutMode.compact;
    return LayoutMode.expanded; // Default to expanded
  }

  /// Toggles between compact and expanded mode.
  void toggle() {
    final newMode = state == LayoutMode.compact
        ? LayoutMode.expanded
        : LayoutMode.compact;
    state = newMode;
    _prefs.setString(_key, newMode.name);
  }

  /// Sets the layout mode directly.
  void setMode(LayoutMode mode) {
    state = mode;
    _prefs.setString(_key, mode.name);
  }
}
