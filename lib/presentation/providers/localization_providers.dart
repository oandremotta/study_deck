import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/localization_service.dart';
import '../../domain/entities/app_locale.dart';

// ============ Service Provider ============

/// Provider for localization service.
final localizationServiceProvider = Provider<LocalizationService>((ref) {
  return LocalizationService();
});

// ============ Settings Provider ============

/// Provider for localization settings.
final localizationSettingsProvider =
    FutureProvider<LocalizationSettings>((ref) async {
  final service = ref.watch(localizationServiceProvider);
  return service.getSettings();
});

/// Provider for available locales.
final availableLocalesProvider = Provider<List<AppLocale>>((ref) {
  final service = ref.watch(localizationServiceProvider);
  return service.getAvailableLocales();
});

/// Provider for fully supported locales.
final fullySupportedLocalesProvider = Provider<List<AppLocale>>((ref) {
  final service = ref.watch(localizationServiceProvider);
  return service.getFullySupportedLocales();
});

/// Provider for app strings based on current locale.
final appStringsProvider = Provider<AppStrings>((ref) {
  final settingsAsync = ref.watch(localizationSettingsProvider);
  return settingsAsync.when(
    data: (settings) => AppStrings.fromLanguageCode(
      settings.appLocale.languageCode,
    ),
    loading: () => AppStrings.pt,
    error: (_, __) => AppStrings.pt,
  );
});

// ============ Direct Functions ============

/// UC248: Set app locale.
Future<LocalizationSettings> setLocaleDirect(
  LocalizationService service,
  AppLocale locale,
) async {
  return service.setLocale(locale);
}

/// UC249: Detect system language.
Future<AppLocale> detectSystemLanguageDirect(
  LocalizationService service,
) async {
  return service.detectSystemLanguage();
}

/// UC249: Enable/disable auto-detection.
Future<LocalizationSettings> setAutoDetectDirect(
  LocalizationService service,
  bool enabled,
) async {
  return service.setAutoDetect(enabled);
}

/// UC250: Set date format.
Future<LocalizationSettings> setDateFormatDirect(
  LocalizationService service,
  DateFormatPreference format,
) async {
  return service.setDateFormat(format);
}

/// UC250: Set number format.
Future<LocalizationSettings> setNumberFormatDirect(
  LocalizationService service,
  NumberFormatPreference format,
) async {
  return service.setNumberFormat(format);
}

/// UC251: Set AI content language.
Future<LocalizationSettings> setAiContentLanguageDirect(
  LocalizationService service,
  String languageCode,
) async {
  return service.setAiContentLanguage(languageCode);
}

/// UC251: Get AI language instruction.
String getAiLanguageInstructionDirect(
  LocalizationService service,
  String languageCode,
) {
  return service.getAiLanguageInstruction(languageCode);
}

/// Format date with current settings.
String formatDateWithSettingsDirect(
  LocalizationService service,
  DateTime date,
  LocalizationSettings settings,
) {
  return service.formatDate(date, settings);
}

/// Format number with current settings.
String formatNumberWithSettingsDirect(
  LocalizationService service,
  double number,
  LocalizationSettings settings,
) {
  return service.formatNumber(number, settings);
}
