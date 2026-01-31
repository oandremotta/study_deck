import 'package:equatable/equatable.dart';

/// UC248-UC251: App locale entity.
///
/// Supports internationalization with language selection and content adaptation.
class AppLocale extends Equatable {
  /// Language code (e.g., 'pt', 'en', 'es').
  final String languageCode;

  /// Country code (e.g., 'BR', 'US', 'ES').
  final String? countryCode;

  /// Display name in the language itself.
  final String nativeName;

  /// Display name in the current app language.
  final String displayName;

  /// Whether this locale is RTL (right-to-left).
  final bool isRtl;

  /// Whether this locale is fully supported.
  final bool isFullySupported;

  const AppLocale({
    required this.languageCode,
    this.countryCode,
    required this.nativeName,
    required this.displayName,
    this.isRtl = false,
    this.isFullySupported = true,
  });

  /// Get locale identifier (e.g., 'pt_BR', 'en_US').
  String get identifier =>
      countryCode != null ? '${languageCode}_$countryCode' : languageCode;

  /// Supported locales in the app.
  static const List<AppLocale> supportedLocales = [
    AppLocale(
      languageCode: 'pt',
      countryCode: 'BR',
      nativeName: 'Português (Brasil)',
      displayName: 'Portuguese (Brazil)',
    ),
    AppLocale(
      languageCode: 'en',
      countryCode: 'US',
      nativeName: 'English (US)',
      displayName: 'English (US)',
    ),
    AppLocale(
      languageCode: 'es',
      nativeName: 'Español',
      displayName: 'Spanish',
    ),
    AppLocale(
      languageCode: 'fr',
      nativeName: 'Français',
      displayName: 'French',
      isFullySupported: false,
    ),
    AppLocale(
      languageCode: 'de',
      nativeName: 'Deutsch',
      displayName: 'German',
      isFullySupported: false,
    ),
    AppLocale(
      languageCode: 'it',
      nativeName: 'Italiano',
      displayName: 'Italian',
      isFullySupported: false,
    ),
    AppLocale(
      languageCode: 'ja',
      nativeName: '日本語',
      displayName: 'Japanese',
      isFullySupported: false,
    ),
    AppLocale(
      languageCode: 'zh',
      countryCode: 'CN',
      nativeName: '中文 (简体)',
      displayName: 'Chinese (Simplified)',
      isFullySupported: false,
    ),
  ];

  /// Default locale.
  static const AppLocale defaultLocale = AppLocale(
    languageCode: 'pt',
    countryCode: 'BR',
    nativeName: 'Português (Brasil)',
    displayName: 'Portuguese (Brazil)',
  );

  /// Find locale by language code.
  static AppLocale? fromLanguageCode(String code) {
    return supportedLocales.where((l) => l.languageCode == code).firstOrNull;
  }

  /// Find locale by identifier.
  static AppLocale? fromIdentifier(String identifier) {
    return supportedLocales.where((l) => l.identifier == identifier).firstOrNull;
  }

  @override
  List<Object?> get props => [languageCode, countryCode];
}

/// UC248-UC251: Localization settings.
class LocalizationSettings extends Equatable {
  /// Selected app locale.
  final AppLocale appLocale;

  /// Whether to auto-detect language from device.
  final bool autoDetect;

  /// Preferred language for AI-generated content.
  final String aiContentLanguage;

  /// Date format preference.
  final DateFormatPreference dateFormat;

  /// Number format preference.
  final NumberFormatPreference numberFormat;

  const LocalizationSettings({
    required this.appLocale,
    this.autoDetect = true,
    String? aiContentLanguage,
    this.dateFormat = DateFormatPreference.locale,
    this.numberFormat = NumberFormatPreference.locale,
  }) : aiContentLanguage = aiContentLanguage ?? 'pt';

  /// Default settings.
  static const LocalizationSettings defaults = LocalizationSettings(
    appLocale: AppLocale.defaultLocale,
    autoDetect: true,
    aiContentLanguage: 'pt',
  );

  LocalizationSettings copyWith({
    AppLocale? appLocale,
    bool? autoDetect,
    String? aiContentLanguage,
    DateFormatPreference? dateFormat,
    NumberFormatPreference? numberFormat,
  }) {
    return LocalizationSettings(
      appLocale: appLocale ?? this.appLocale,
      autoDetect: autoDetect ?? this.autoDetect,
      aiContentLanguage: aiContentLanguage ?? this.aiContentLanguage,
      dateFormat: dateFormat ?? this.dateFormat,
      numberFormat: numberFormat ?? this.numberFormat,
    );
  }

  /// Convert to JSON for storage.
  Map<String, dynamic> toJson() {
    return {
      'appLocale': appLocale.identifier,
      'autoDetect': autoDetect,
      'aiContentLanguage': aiContentLanguage,
      'dateFormat': dateFormat.name,
      'numberFormat': numberFormat.name,
    };
  }

  /// Create from JSON.
  factory LocalizationSettings.fromJson(Map<String, dynamic> json) {
    final localeId = json['appLocale'] as String?;
    final locale = localeId != null
        ? AppLocale.fromIdentifier(localeId)
        : null;

    return LocalizationSettings(
      appLocale: locale ?? AppLocale.defaultLocale,
      autoDetect: json['autoDetect'] as bool? ?? true,
      aiContentLanguage: json['aiContentLanguage'] as String? ?? 'pt',
      dateFormat: json['dateFormat'] != null
          ? DateFormatPreference.values.byName(json['dateFormat'] as String)
          : DateFormatPreference.locale,
      numberFormat: json['numberFormat'] != null
          ? NumberFormatPreference.values.byName(json['numberFormat'] as String)
          : NumberFormatPreference.locale,
    );
  }

  @override
  List<Object?> get props => [
        appLocale,
        autoDetect,
        aiContentLanguage,
        dateFormat,
        numberFormat,
      ];
}

/// Date format preferences.
enum DateFormatPreference {
  locale, // Use locale default
  dmy, // Day/Month/Year (31/01/2024)
  mdy, // Month/Day/Year (01/31/2024)
  ymd, // Year/Month/Day (2024-01-31)
}

extension DateFormatPreferenceExtension on DateFormatPreference {
  String get displayName {
    switch (this) {
      case DateFormatPreference.locale:
        return 'Automático (do idioma)';
      case DateFormatPreference.dmy:
        return 'DD/MM/AAAA';
      case DateFormatPreference.mdy:
        return 'MM/DD/AAAA';
      case DateFormatPreference.ymd:
        return 'AAAA-MM-DD';
    }
  }

  String get example {
    switch (this) {
      case DateFormatPreference.locale:
        return '31/01/2024';
      case DateFormatPreference.dmy:
        return '31/01/2024';
      case DateFormatPreference.mdy:
        return '01/31/2024';
      case DateFormatPreference.ymd:
        return '2024-01-31';
    }
  }
}

/// Number format preferences.
enum NumberFormatPreference {
  locale, // Use locale default
  commaSeparator, // 1,234.56
  dotSeparator, // 1.234,56
}

extension NumberFormatPreferenceExtension on NumberFormatPreference {
  String get displayName {
    switch (this) {
      case NumberFormatPreference.locale:
        return 'Automático (do idioma)';
      case NumberFormatPreference.commaSeparator:
        return '1,234.56';
      case NumberFormatPreference.dotSeparator:
        return '1.234,56';
    }
  }
}
