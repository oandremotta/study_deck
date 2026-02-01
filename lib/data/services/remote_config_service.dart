import 'package:shared_preferences/shared_preferences.dart';

/// UC212, UC214: Servico de Remote Config para feature flags.
///
/// Permite controlar recursos remotamente sem atualizar o app.
/// Usa SharedPreferences como fallback quando Firebase nao esta disponivel.
class RemoteConfigService {
  static const String _prefix = 'remote_config_';

  // Defaults
  static const Map<String, dynamic> _defaults = {
    // UC212: Feature flags
    'ai_generation_enabled': true,
    'ads_enabled': true,
    'premium_enabled': true,
    'community_enabled': false,
    'educator_mode_enabled': false,

    // UC214: Limites e configuracoes
    'daily_ad_limit': 5,
    'ad_cooldown_minutes': 5,
    'credits_per_ad': 1,
    'low_balance_threshold': 5,
    'welcome_bonus_credits': 0,

    // Precos (em centavos)
    'premium_monthly_price': 1990,
    'premium_annual_price': 14990,

    // A/B Testing
    'paywall_variant': 'control',
    'onboarding_variant': 'control',

    // Mensagens
    'maintenance_message': '',
    'promo_message': '',
  };

  SharedPreferences? _prefs;
  Map<String, dynamic> _values = {};

  /// Inicializa o servico.
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();

    // TODO: Integrar com Firebase Remote Config
    // await _fetchFromFirebase();
  }

  /// Carrega valores do SharedPreferences.
  void _loadFromPrefs() {
    _values = Map.from(_defaults);

    for (final key in _defaults.keys) {
      final storedValue = _prefs?.get('$_prefix$key');
      if (storedValue != null) {
        _values[key] = storedValue;
      }
    }
  }

  /// Salva um valor localmente (para testes/override).
  Future<void> setValue(String key, dynamic value) async {
    _values[key] = value;

    if (_prefs != null) {
      final prefKey = '$_prefix$key';
      if (value is bool) {
        await _prefs!.setBool(prefKey, value);
      } else if (value is int) {
        await _prefs!.setInt(prefKey, value);
      } else if (value is double) {
        await _prefs!.setDouble(prefKey, value);
      } else if (value is String) {
        await _prefs!.setString(prefKey, value);
      }
    }
  }

  /// Reseta todos os valores para os defaults.
  Future<void> resetToDefaults() async {
    _values = Map.from(_defaults);
    if (_prefs != null) {
      for (final key in _defaults.keys) {
        await _prefs!.remove('$_prefix$key');
      }
    }
  }

  // ============ Feature Flags ============

  /// UC212: IA habilitada?
  bool get isAiEnabled => _getBool('ai_generation_enabled');

  /// UC212: Anuncios habilitados?
  bool get areAdsEnabled => _getBool('ads_enabled');

  /// UC212: Premium habilitado?
  bool get isPremiumEnabled => _getBool('premium_enabled');

  /// UC212: Comunidade habilitada?
  bool get isCommunityEnabled => _getBool('community_enabled');

  /// UC212: Modo educador habilitado?
  bool get isEducatorModeEnabled => _getBool('educator_mode_enabled');

  // ============ Configuracoes de Creditos ============

  /// Limite diario de anuncios.
  int get dailyAdLimit => _getInt('daily_ad_limit');

  /// Cooldown entre anuncios (minutos).
  int get adCooldownMinutes => _getInt('ad_cooldown_minutes');

  /// Creditos por anuncio.
  int get creditsPerAd => _getInt('credits_per_ad');

  /// UC214: Limite para alerta de saldo baixo.
  int get lowBalanceThreshold => _getInt('low_balance_threshold');

  /// Bonus de boas-vindas.
  int get welcomeBonusCredits => _getInt('welcome_bonus_credits');

  // ============ Precos ============

  /// Preco mensal premium (centavos).
  int get premiumMonthlyPrice => _getInt('premium_monthly_price');

  /// Preco anual premium (centavos).
  int get premiumAnnualPrice => _getInt('premium_annual_price');

  // ============ A/B Testing ============

  /// Variante do paywall.
  String get paywallVariant => _getString('paywall_variant');

  /// Variante do onboarding.
  String get onboardingVariant => _getString('onboarding_variant');

  // ============ Mensagens ============

  /// Mensagem de manutencao (vazio = sem manutencao).
  String get maintenanceMessage => _getString('maintenance_message');

  /// Mensagem promocional.
  String get promoMessage => _getString('promo_message');

  /// Verifica se esta em manutencao.
  bool get isInMaintenance => maintenanceMessage.isNotEmpty;

  /// Verifica se tem promocao ativa.
  bool get hasActivePromo => promoMessage.isNotEmpty;

  // ============ Helpers ============

  bool _getBool(String key) {
    final value = _values[key];
    if (value is bool) return value;
    return _defaults[key] as bool? ?? false;
  }

  int _getInt(String key) {
    final value = _values[key];
    if (value is int) return value;
    return _defaults[key] as int? ?? 0;
  }

  String _getString(String key) {
    final value = _values[key];
    if (value is String) return value;
    return _defaults[key] as String? ?? '';
  }

  /// Obtem valor generico.
  T getValue<T>(String key, T defaultValue) {
    final value = _values[key];
    if (value is T) return value;
    return defaultValue;
  }
}
