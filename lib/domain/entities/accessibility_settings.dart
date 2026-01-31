import 'package:equatable/equatable.dart';

/// UC252-UC257: Accessibility settings entity.
///
/// Supports:
/// - Screen reader compatibility (UC252)
/// - Text size adjustment (UC253)
/// - High contrast mode (UC254)
/// - Keyboard navigation (UC255)
/// - Reduced animations (UC256)
/// - Color blind modes (UC257)
class AccessibilitySettings extends Equatable {
  /// UC252: Whether screen reader mode is enabled.
  final bool screenReaderEnabled;

  /// UC253: Text scale factor (1.0 = normal, 1.5 = 150%, etc.).
  final double textScaleFactor;

  /// UC254: High contrast mode.
  final HighContrastMode highContrastMode;

  /// UC255: Keyboard navigation enabled.
  final bool keyboardNavigationEnabled;

  /// UC256: Reduced animations.
  final bool reduceAnimations;

  /// UC256: Animation speed multiplier (0.5 = half speed, 2.0 = double).
  final double animationSpeed;

  /// UC257: Color blind mode.
  final ColorBlindMode colorBlindMode;

  /// Whether to show text labels on icons.
  final bool showIconLabels;

  /// Minimum touch target size in logical pixels.
  final double minTouchTargetSize;

  /// Whether to use larger touch targets.
  final bool useLargerTouchTargets;

  /// Focus indicator width.
  final double focusIndicatorWidth;

  /// Whether to announce screen changes.
  final bool announceScreenChanges;

  const AccessibilitySettings({
    this.screenReaderEnabled = false,
    this.textScaleFactor = 1.0,
    this.highContrastMode = HighContrastMode.off,
    this.keyboardNavigationEnabled = false,
    this.reduceAnimations = false,
    this.animationSpeed = 1.0,
    this.colorBlindMode = ColorBlindMode.none,
    this.showIconLabels = false,
    this.minTouchTargetSize = 48.0,
    this.useLargerTouchTargets = false,
    this.focusIndicatorWidth = 2.0,
    this.announceScreenChanges = true,
  });

  /// Default settings.
  static const AccessibilitySettings defaults = AccessibilitySettings();

  /// Effective touch target size.
  double get effectiveTouchTargetSize =>
      useLargerTouchTargets ? 56.0 : minTouchTargetSize;

  /// Effective animation duration multiplier.
  double get animationDurationMultiplier =>
      reduceAnimations ? 0.0 : (1.0 / animationSpeed);

  /// Whether any accessibility feature is enabled.
  bool get hasActiveFeatures =>
      screenReaderEnabled ||
      textScaleFactor != 1.0 ||
      highContrastMode != HighContrastMode.off ||
      keyboardNavigationEnabled ||
      reduceAnimations ||
      colorBlindMode != ColorBlindMode.none ||
      useLargerTouchTargets;

  AccessibilitySettings copyWith({
    bool? screenReaderEnabled,
    double? textScaleFactor,
    HighContrastMode? highContrastMode,
    bool? keyboardNavigationEnabled,
    bool? reduceAnimations,
    double? animationSpeed,
    ColorBlindMode? colorBlindMode,
    bool? showIconLabels,
    double? minTouchTargetSize,
    bool? useLargerTouchTargets,
    double? focusIndicatorWidth,
    bool? announceScreenChanges,
  }) {
    return AccessibilitySettings(
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      keyboardNavigationEnabled:
          keyboardNavigationEnabled ?? this.keyboardNavigationEnabled,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      colorBlindMode: colorBlindMode ?? this.colorBlindMode,
      showIconLabels: showIconLabels ?? this.showIconLabels,
      minTouchTargetSize: minTouchTargetSize ?? this.minTouchTargetSize,
      useLargerTouchTargets:
          useLargerTouchTargets ?? this.useLargerTouchTargets,
      focusIndicatorWidth: focusIndicatorWidth ?? this.focusIndicatorWidth,
      announceScreenChanges:
          announceScreenChanges ?? this.announceScreenChanges,
    );
  }

  /// Convert to JSON for storage.
  Map<String, dynamic> toJson() {
    return {
      'screenReaderEnabled': screenReaderEnabled,
      'textScaleFactor': textScaleFactor,
      'highContrastMode': highContrastMode.name,
      'keyboardNavigationEnabled': keyboardNavigationEnabled,
      'reduceAnimations': reduceAnimations,
      'animationSpeed': animationSpeed,
      'colorBlindMode': colorBlindMode.name,
      'showIconLabels': showIconLabels,
      'minTouchTargetSize': minTouchTargetSize,
      'useLargerTouchTargets': useLargerTouchTargets,
      'focusIndicatorWidth': focusIndicatorWidth,
      'announceScreenChanges': announceScreenChanges,
    };
  }

  /// Create from JSON.
  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      screenReaderEnabled: json['screenReaderEnabled'] as bool? ?? false,
      textScaleFactor: (json['textScaleFactor'] as num?)?.toDouble() ?? 1.0,
      highContrastMode: json['highContrastMode'] != null
          ? HighContrastMode.values.byName(json['highContrastMode'] as String)
          : HighContrastMode.off,
      keyboardNavigationEnabled:
          json['keyboardNavigationEnabled'] as bool? ?? false,
      reduceAnimations: json['reduceAnimations'] as bool? ?? false,
      animationSpeed: (json['animationSpeed'] as num?)?.toDouble() ?? 1.0,
      colorBlindMode: json['colorBlindMode'] != null
          ? ColorBlindMode.values.byName(json['colorBlindMode'] as String)
          : ColorBlindMode.none,
      showIconLabels: json['showIconLabels'] as bool? ?? false,
      minTouchTargetSize:
          (json['minTouchTargetSize'] as num?)?.toDouble() ?? 48.0,
      useLargerTouchTargets: json['useLargerTouchTargets'] as bool? ?? false,
      focusIndicatorWidth:
          (json['focusIndicatorWidth'] as num?)?.toDouble() ?? 2.0,
      announceScreenChanges: json['announceScreenChanges'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        screenReaderEnabled,
        textScaleFactor,
        highContrastMode,
        keyboardNavigationEnabled,
        reduceAnimations,
        animationSpeed,
        colorBlindMode,
        showIconLabels,
        minTouchTargetSize,
        useLargerTouchTargets,
        focusIndicatorWidth,
        announceScreenChanges,
      ];
}

/// UC254: High contrast modes.
enum HighContrastMode {
  off,
  light, // High contrast light
  dark, // High contrast dark
}

extension HighContrastModeExtension on HighContrastMode {
  String get displayName {
    switch (this) {
      case HighContrastMode.off:
        return 'Desativado';
      case HighContrastMode.light:
        return 'Alto contraste claro';
      case HighContrastMode.dark:
        return 'Alto contraste escuro';
    }
  }

  String get description {
    switch (this) {
      case HighContrastMode.off:
        return 'Cores normais do tema';
      case HighContrastMode.light:
        return 'Texto escuro em fundo claro com alto contraste';
      case HighContrastMode.dark:
        return 'Texto claro em fundo escuro com alto contraste';
    }
  }
}

/// UC257: Color blind modes.
enum ColorBlindMode {
  none,
  protanopia, // Red-blind
  deuteranopia, // Green-blind
  tritanopia, // Blue-blind
  achromatopsia, // Total color blindness
}

extension ColorBlindModeExtension on ColorBlindMode {
  String get displayName {
    switch (this) {
      case ColorBlindMode.none:
        return 'Nenhum';
      case ColorBlindMode.protanopia:
        return 'Protanopia';
      case ColorBlindMode.deuteranopia:
        return 'Deuteranopia';
      case ColorBlindMode.tritanopia:
        return 'Tritanopia';
      case ColorBlindMode.achromatopsia:
        return 'Acromatopsia';
    }
  }

  String get description {
    switch (this) {
      case ColorBlindMode.none:
        return 'Visão de cores normal';
      case ColorBlindMode.protanopia:
        return 'Dificuldade com vermelho';
      case ColorBlindMode.deuteranopia:
        return 'Dificuldade com verde';
      case ColorBlindMode.tritanopia:
        return 'Dificuldade com azul';
      case ColorBlindMode.achromatopsia:
        return 'Daltonismo total';
    }
  }
}

/// UC253: Text size presets.
enum TextSizePreset {
  small,
  normal,
  large,
  extraLarge,
  huge,
}

extension TextSizePresetExtension on TextSizePreset {
  double get scaleFactor {
    switch (this) {
      case TextSizePreset.small:
        return 0.85;
      case TextSizePreset.normal:
        return 1.0;
      case TextSizePreset.large:
        return 1.15;
      case TextSizePreset.extraLarge:
        return 1.3;
      case TextSizePreset.huge:
        return 1.5;
    }
  }

  String get displayName {
    switch (this) {
      case TextSizePreset.small:
        return 'Pequeno';
      case TextSizePreset.normal:
        return 'Normal';
      case TextSizePreset.large:
        return 'Grande';
      case TextSizePreset.extraLarge:
        return 'Extra grande';
      case TextSizePreset.huge:
        return 'Enorme';
    }
  }

  String get sampleText {
    switch (this) {
      case TextSizePreset.small:
        return 'Texto pequeno';
      case TextSizePreset.normal:
        return 'Texto normal';
      case TextSizePreset.large:
        return 'Texto grande';
      case TextSizePreset.extraLarge:
        return 'Extra grande';
      case TextSizePreset.huge:
        return 'Enorme';
    }
  }

  static TextSizePreset fromScaleFactor(double factor) {
    if (factor <= 0.9) return TextSizePreset.small;
    if (factor <= 1.05) return TextSizePreset.normal;
    if (factor <= 1.2) return TextSizePreset.large;
    if (factor <= 1.4) return TextSizePreset.extraLarge;
    return TextSizePreset.huge;
  }
}

/// Semantic labels for common UI elements.
class SemanticLabels {
  // Navigation
  static const String homeTab = 'Início, aba de navegação';
  static const String studyTab = 'Estudar, aba de navegação';
  static const String decksTab = 'Decks, aba de navegação';
  static const String profileTab = 'Perfil, aba de navegação';

  // Actions
  static const String createDeck = 'Criar novo deck';
  static const String createCard = 'Criar novo card';
  static const String createFolder = 'Criar nova pasta';
  static const String startStudy = 'Iniciar sessão de estudo';
  static const String showAnswer = 'Mostrar resposta do card';

  // Study ratings
  static const String rateAgain = 'Marcar como errado, revisar em breve';
  static const String rateHard = 'Marcar como difícil';
  static const String rateGood = 'Marcar como bom';
  static const String rateEasy = 'Marcar como fácil, revisar mais tarde';

  // Card parts
  static const String cardFront = 'Frente do card, pergunta';
  static const String cardBack = 'Verso do card, resposta';
  static const String cardHint = 'Dica para este card';

  // Statistics
  static String streakDays(int days) => 'Sequência de $days dias';
  static String cardsToStudy(int count) => '$count cards para estudar hoje';
  static String retention(int percent) => 'Taxa de retenção: $percent porcento';
}
