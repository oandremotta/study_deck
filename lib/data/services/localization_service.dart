import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_locale.dart';

/// UC248-UC251: Localization service for i18n.
///
/// Handles:
/// - Language selection (UC248)
/// - System language detection (UC249)
/// - Content adaptation (UC250)
/// - AI content language (UC251)
class LocalizationService {
  static const String _settingsKey = 'localization_settings';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// UC248: Get current localization settings.
  Future<LocalizationSettings> getSettings() async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString(_settingsKey);

      if (json == null) {
        // First launch - detect system language
        final detected = await detectSystemLanguage();
        final settings = LocalizationSettings(
          appLocale: detected,
          autoDetect: true,
        );
        await saveSettings(settings);
        return settings;
      }

      return LocalizationSettings.fromJson(jsonDecode(json));
    } catch (e) {
      debugPrint('LocalizationService: Error getting settings: $e');
      return LocalizationSettings.defaults;
    }
  }

  /// UC248: Save localization settings.
  Future<void> saveSettings(LocalizationSettings settings) async {
    final prefs = await _preferences;
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
    debugPrint('LocalizationService: Settings saved');
  }

  /// UC248: Set app locale.
  Future<LocalizationSettings> setLocale(AppLocale locale) async {
    final current = await getSettings();
    final updated = current.copyWith(
      appLocale: locale,
      autoDetect: false, // User made explicit choice
    );
    await saveSettings(updated);
    debugPrint('LocalizationService: Locale set to ${locale.identifier}');
    return updated;
  }

  /// UC249: Detect system language.
  Future<AppLocale> detectSystemLanguage() async {
    try {
      final systemLocale = ui.PlatformDispatcher.instance.locale;
      final languageCode = systemLocale.languageCode;
      final countryCode = systemLocale.countryCode;

      debugPrint(
        'LocalizationService: System locale: ${languageCode}_$countryCode',
      );

      // Try exact match first
      if (countryCode != null) {
        final exactMatch = AppLocale.supportedLocales.where(
          (l) => l.languageCode == languageCode && l.countryCode == countryCode,
        ).firstOrNull;

        if (exactMatch != null) return exactMatch;
      }

      // Try language only match
      final languageMatch = AppLocale.fromLanguageCode(languageCode);
      if (languageMatch != null) return languageMatch;

      // Default to Portuguese (Brazil)
      return AppLocale.defaultLocale;
    } catch (e) {
      debugPrint('LocalizationService: Error detecting system language: $e');
      return AppLocale.defaultLocale;
    }
  }

  /// UC249: Enable/disable auto-detection.
  Future<LocalizationSettings> setAutoDetect(bool enabled) async {
    final current = await getSettings();

    if (enabled) {
      // Re-detect system language
      final detected = await detectSystemLanguage();
      final updated = current.copyWith(
        appLocale: detected,
        autoDetect: true,
      );
      await saveSettings(updated);
      return updated;
    } else {
      final updated = current.copyWith(autoDetect: false);
      await saveSettings(updated);
      return updated;
    }
  }

  /// UC250: Set date format preference.
  Future<LocalizationSettings> setDateFormat(DateFormatPreference format) async {
    final current = await getSettings();
    final updated = current.copyWith(dateFormat: format);
    await saveSettings(updated);
    return updated;
  }

  /// UC250: Set number format preference.
  Future<LocalizationSettings> setNumberFormat(
    NumberFormatPreference format,
  ) async {
    final current = await getSettings();
    final updated = current.copyWith(numberFormat: format);
    await saveSettings(updated);
    return updated;
  }

  /// UC251: Set AI content language.
  Future<LocalizationSettings> setAiContentLanguage(String languageCode) async {
    final current = await getSettings();
    final updated = current.copyWith(aiContentLanguage: languageCode);
    await saveSettings(updated);
    debugPrint('LocalizationService: AI language set to $languageCode');
    return updated;
  }

  /// UC251: Get AI prompt language instruction.
  String getAiLanguageInstruction(String languageCode) {
    final languageNames = {
      'pt': 'Portuguese (Brazil)',
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'ja': 'Japanese',
      'zh': 'Chinese (Simplified)',
    };

    final languageName = languageNames[languageCode] ?? 'Portuguese (Brazil)';
    return 'Please respond in $languageName. '
        'All generated content should be in $languageName.';
  }

  /// Get available languages for selection.
  List<AppLocale> getAvailableLocales() {
    return AppLocale.supportedLocales;
  }

  /// Get fully supported locales.
  List<AppLocale> getFullySupportedLocales() {
    return AppLocale.supportedLocales.where((l) => l.isFullySupported).toList();
  }

  /// Format date according to settings.
  String formatDate(DateTime date, LocalizationSettings settings) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    switch (settings.dateFormat) {
      case DateFormatPreference.locale:
        // Use locale default (for pt_BR, it's DMY)
        if (settings.appLocale.languageCode == 'en') {
          return '$month/$day/$year';
        }
        return '$day/$month/$year';
      case DateFormatPreference.dmy:
        return '$day/$month/$year';
      case DateFormatPreference.mdy:
        return '$month/$day/$year';
      case DateFormatPreference.ymd:
        return '$year-$month-$day';
    }
  }

  /// Format number according to settings.
  String formatNumber(double number, LocalizationSettings settings) {
    final parts = number.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '00';

    // Add thousand separators
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(settings.numberFormat == NumberFormatPreference.dotSeparator
            ? '.'
            : ',');
      }
      buffer.write(intPart[i]);
    }

    final separator =
        settings.numberFormat == NumberFormatPreference.dotSeparator ? ',' : '.';
    return '${buffer.toString()}$separator$decPart';
  }
}

/// Localized strings container.
/// This is a simplified version - in production, use flutter_localizations.
class AppStrings {
  final String languageCode;

  const AppStrings._(this.languageCode);

  static const AppStrings pt = AppStrings._('pt');
  static const AppStrings en = AppStrings._('en');
  static const AppStrings es = AppStrings._('es');

  static AppStrings fromLanguageCode(String code) {
    switch (code) {
      case 'en':
        return en;
      case 'es':
        return es;
      default:
        return pt;
    }
  }

  // Common strings
  String get appName => _getString('appName');
  String get ok => _getString('ok');
  String get cancel => _getString('cancel');
  String get save => _getString('save');
  String get delete => _getString('delete');
  String get edit => _getString('edit');
  String get create => _getString('create');
  String get search => _getString('search');
  String get settings => _getString('settings');
  String get home => _getString('home');
  String get study => _getString('study');
  String get decks => _getString('decks');
  String get cards => _getString('cards');
  String get folders => _getString('folders');
  String get tags => _getString('tags');
  String get statistics => _getString('statistics');
  String get profile => _getString('profile');

  // Onboarding strings
  String get welcomeTitle => _getString('welcomeTitle');
  String get welcomeSubtitle => _getString('welcomeSubtitle');
  String get useWithoutAccount => _getString('useWithoutAccount');
  String get signInOrCreate => _getString('signInOrCreate');

  // Study strings
  String get startStudy => _getString('startStudy');
  String get continueStudy => _getString('continueStudy');
  String get showAnswer => _getString('showAnswer');
  String get again => _getString('again');
  String get hard => _getString('hard');
  String get good => _getString('good');
  String get easy => _getString('easy');

  String _getString(String key) {
    return _strings[languageCode]?[key] ?? _strings['pt']![key] ?? key;
  }

  static const Map<String, Map<String, String>> _strings = {
    'pt': {
      'appName': 'Study Deck',
      'ok': 'OK',
      'cancel': 'Cancelar',
      'save': 'Salvar',
      'delete': 'Excluir',
      'edit': 'Editar',
      'create': 'Criar',
      'search': 'Buscar',
      'settings': 'Configurações',
      'home': 'Início',
      'study': 'Estudar',
      'decks': 'Decks',
      'cards': 'Cards',
      'folders': 'Pastas',
      'tags': 'Tags',
      'statistics': 'Estatísticas',
      'profile': 'Perfil',
      'welcomeTitle': 'Bem-vindo ao Study Deck',
      'welcomeSubtitle': 'Aprenda com flashcards inteligentes',
      'useWithoutAccount': 'Usar sem conta',
      'signInOrCreate': 'Entrar ou criar conta',
      'startStudy': 'Iniciar estudo',
      'continueStudy': 'Continuar estudo',
      'showAnswer': 'Mostrar resposta',
      'again': 'De novo',
      'hard': 'Difícil',
      'good': 'Bom',
      'easy': 'Fácil',
    },
    'en': {
      'appName': 'Study Deck',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'create': 'Create',
      'search': 'Search',
      'settings': 'Settings',
      'home': 'Home',
      'study': 'Study',
      'decks': 'Decks',
      'cards': 'Cards',
      'folders': 'Folders',
      'tags': 'Tags',
      'statistics': 'Statistics',
      'profile': 'Profile',
      'welcomeTitle': 'Welcome to Study Deck',
      'welcomeSubtitle': 'Learn with smart flashcards',
      'useWithoutAccount': 'Use without account',
      'signInOrCreate': 'Sign in or create account',
      'startStudy': 'Start study',
      'continueStudy': 'Continue study',
      'showAnswer': 'Show answer',
      'again': 'Again',
      'hard': 'Hard',
      'good': 'Good',
      'easy': 'Easy',
    },
    'es': {
      'appName': 'Study Deck',
      'ok': 'Aceptar',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'delete': 'Eliminar',
      'edit': 'Editar',
      'create': 'Crear',
      'search': 'Buscar',
      'settings': 'Configuración',
      'home': 'Inicio',
      'study': 'Estudiar',
      'decks': 'Mazos',
      'cards': 'Tarjetas',
      'folders': 'Carpetas',
      'tags': 'Etiquetas',
      'statistics': 'Estadísticas',
      'profile': 'Perfil',
      'welcomeTitle': 'Bienvenido a Study Deck',
      'welcomeSubtitle': 'Aprende con tarjetas inteligentes',
      'useWithoutAccount': 'Usar sin cuenta',
      'signInOrCreate': 'Iniciar sesión o crear cuenta',
      'startStudy': 'Iniciar estudio',
      'continueStudy': 'Continuar estudio',
      'showAnswer': 'Mostrar respuesta',
      'again': 'Otra vez',
      'hard': 'Difícil',
      'good': 'Bien',
      'easy': 'Fácil',
    },
  };
}
