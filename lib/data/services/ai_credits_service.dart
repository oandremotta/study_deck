import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/ai_credit.dart';

/// UC183-UC195: Servico de gerenciamento de creditos IA.
///
/// Implementa toda a logica de creditos para visitantes e usuarios logados.
class AiCreditsService {
  static const _uuid = Uuid();

  // Configuracoes (podem vir do Remote Config)
  static const int dailyAdLimit = 5;
  static const Duration adCooldown = Duration(minutes: 5);
  static const int welcomeBonus = 3;
  static const int creditsPerAd = 1;

  // Pacotes de creditos avulsos (Bloco Final C)
  static const List<AiCreditPackage> creditPackages = [
    AiCreditPackage(
      id: 'credits_50',
      name: '50 Creditos',
      credits: 50,
      price: 9.90,
      priceDisplay: 'R\$ 9,90',
      stripePriceId: '', // Criar no Stripe
    ),
    AiCreditPackage(
      id: 'credits_150',
      name: '150 Creditos',
      credits: 150,
      price: 24.90,
      priceDisplay: 'R\$ 24,90',
      stripePriceId: '', // Criar no Stripe
      isPopular: true,
    ),
    AiCreditPackage(
      id: 'credits_500',
      name: '500 Creditos',
      credits: 500,
      price: 69.90,
      priceDisplay: 'R\$ 69,90',
      stripePriceId: '', // Criar no Stripe
    ),
  ];

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ============ UC183: Credito temporario para visitante ============

  /// Verifica se visitante tem credito temporario disponivel.
  ///
  /// UC183: Visitante pode ter no maximo 1 credito temporario por vez.
  Future<bool> hasTemporaryCredit() async {
    final prefs = await _preferences;
    final hasCredit = prefs.getBool('visitor_has_temp_credit') ?? false;
    final expiresAt = prefs.getInt('visitor_temp_credit_expires');

    if (!hasCredit) return false;

    // Verificar expiracao
    if (expiresAt != null) {
      final expires = DateTime.fromMillisecondsSinceEpoch(expiresAt);
      if (DateTime.now().isAfter(expires)) {
        await _clearTemporaryCredit();
        return false;
      }
    }

    return true;
  }

  /// Concede credito temporario para visitante apos assistir anuncio.
  ///
  /// UC183: Credito expira apos uso ou em 5 minutos.
  Future<void> grantTemporaryCredit() async {
    final prefs = await _preferences;
    final expiresAt = DateTime.now().add(const Duration(minutes: 5));

    await prefs.setBool('visitor_has_temp_credit', true);
    await prefs.setInt(
        'visitor_temp_credit_expires', expiresAt.millisecondsSinceEpoch);

    debugPrint('AiCredits: Temporary credit granted, expires at $expiresAt');
  }

  /// Consome credito temporario de visitante.
  ///
  /// UC183: Credito expira imediatamente apos uso.
  Future<bool> consumeTemporaryCredit() async {
    if (!await hasTemporaryCredit()) return false;

    await _clearTemporaryCredit();
    debugPrint('AiCredits: Temporary credit consumed');
    return true;
  }

  Future<void> _clearTemporaryCredit() async {
    final prefs = await _preferences;
    await prefs.remove('visitor_has_temp_credit');
    await prefs.remove('visitor_temp_credit_expires');
  }

  // ============ UC187-UC188: Creditos persistentes para usuario logado ============

  /// Obtem saldo de creditos do usuario logado.
  Future<AiCreditBalance> getBalance(String userId) async {
    final prefs = await _preferences;
    final prefix = 'user_${userId}_';

    return AiCreditBalance(
      userId: userId,
      available: prefs.getInt('${prefix}credits_available') ?? 0,
      usedToday: prefs.getInt('${prefix}credits_used_today') ?? 0,
      usedThisMonth: prefs.getInt('${prefix}credits_used_month') ?? 0,
      totalEarned: prefs.getInt('${prefix}credits_total_earned') ?? 0,
      totalUsed: prefs.getInt('${prefix}credits_total_used') ?? 0,
      lastAdWatched: _getDateTime(prefs, '${prefix}last_ad_watched'),
      adsWatchedToday: prefs.getInt('${prefix}ads_watched_today') ?? 0,
    );
  }

  DateTime? _getDateTime(SharedPreferences prefs, String key) {
    final ms = prefs.getInt(key);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  /// UC187: Inicializa usuario sem creditos (ou com bonus de boas-vindas).
  Future<void> initializeUser(String userId, {bool withWelcomeBonus = false}) async {
    final prefs = await _preferences;
    final prefix = 'user_${userId}_';

    // Verificar se ja foi inicializado
    if (prefs.containsKey('${prefix}initialized')) return;

    await prefs.setBool('${prefix}initialized', true);

    if (withWelcomeBonus) {
      await prefs.setInt('${prefix}credits_available', welcomeBonus);
      await prefs.setInt('${prefix}credits_total_earned', welcomeBonus);
      debugPrint('AiCredits: User $userId initialized with $welcomeBonus welcome bonus');
    } else {
      await prefs.setInt('${prefix}credits_available', 0);
      debugPrint('AiCredits: User $userId initialized with 0 credits');
    }
  }

  /// UC188: Adiciona credito persistente por anuncio para usuario logado.
  Future<AiCreditBalance> addCreditFromAd(String userId) async {
    final balance = await getBalance(userId);

    // Verificar limite diario
    if (!balance.canWatchAd(dailyAdLimit)) {
      throw Exception('Limite diario de anuncios atingido');
    }

    // Verificar cooldown
    if (balance.isInAdCooldown(adCooldown)) {
      final remaining = balance.remainingCooldown(adCooldown);
      throw Exception(
          'Aguarde ${remaining?.inSeconds ?? 0} segundos para assistir outro anuncio');
    }

    final prefs = await _preferences;
    final prefix = 'user_${userId}_';

    final newBalance = balance.copyWith(
      available: balance.available + creditsPerAd,
      totalEarned: balance.totalEarned + creditsPerAd,
      lastAdWatched: DateTime.now(),
      adsWatchedToday: balance.adsWatchedToday + 1,
    );

    await prefs.setInt('${prefix}credits_available', newBalance.available);
    await prefs.setInt('${prefix}credits_total_earned', newBalance.totalEarned);
    await prefs.setInt(
        '${prefix}last_ad_watched', DateTime.now().millisecondsSinceEpoch);
    await prefs.setInt('${prefix}ads_watched_today', newBalance.adsWatchedToday);

    debugPrint('AiCredits: User $userId earned $creditsPerAd credit from ad');
    return newBalance;
  }

  /// Adiciona creditos de compra de pacote.
  Future<AiCreditBalance> addCreditsFromPurchase(
      String userId, int credits) async {
    final balance = await getBalance(userId);
    final prefs = await _preferences;
    final prefix = 'user_${userId}_';

    final newBalance = balance.copyWith(
      available: balance.available + credits,
      totalEarned: balance.totalEarned + credits,
    );

    await prefs.setInt('${prefix}credits_available', newBalance.available);
    await prefs.setInt('${prefix}credits_total_earned', newBalance.totalEarned);

    debugPrint('AiCredits: User $userId purchased $credits credits');
    return newBalance;
  }

  /// Adiciona creditos de assinatura premium.
  Future<AiCreditBalance> addSubscriptionCredits(
      String userId, int credits) async {
    final balance = await getBalance(userId);
    final prefs = await _preferences;
    final prefix = 'user_${userId}_';

    final newBalance = balance.copyWith(
      available: balance.available + credits,
      totalEarned: balance.totalEarned + credits,
    );

    await prefs.setInt('${prefix}credits_available', newBalance.available);
    await prefs.setInt('${prefix}credits_total_earned', newBalance.totalEarned);

    debugPrint('AiCredits: User $userId received $credits subscription credits');
    return newBalance;
  }

  /// Consome credito do usuario logado.
  Future<bool> consumeCredit(String userId) async {
    final balance = await getBalance(userId);

    if (balance.available <= 0) return false;

    final prefs = await _preferences;
    final prefix = 'user_${userId}_';

    final newBalance = balance.copyWith(
      available: balance.available - 1,
      usedToday: balance.usedToday + 1,
      usedThisMonth: balance.usedThisMonth + 1,
      totalUsed: balance.totalUsed + 1,
    );

    await prefs.setInt('${prefix}credits_available', newBalance.available);
    await prefs.setInt('${prefix}credits_used_today', newBalance.usedToday);
    await prefs.setInt('${prefix}credits_used_month', newBalance.usedThisMonth);
    await prefs.setInt('${prefix}credits_total_used', newBalance.totalUsed);

    debugPrint('AiCredits: User $userId consumed 1 credit');
    return true;
  }

  // ============ UC194: Prevencao de farm de anuncios ============

  /// Verifica se visitante pode assistir anuncio.
  ///
  /// UC194: Visitante so pode assistir 1 anuncio por vez.
  Future<bool> canVisitorWatchAd() async {
    // Se ja tem credito temporario, nao pode assistir outro
    if (await hasTemporaryCredit()) return false;
    return true;
  }

  /// Verifica se usuario logado pode assistir anuncio.
  Future<bool> canUserWatchAd(String userId) async {
    final balance = await getBalance(userId);
    return balance.canWatchAd(dailyAdLimit) &&
        !balance.isInAdCooldown(adCooldown);
  }

  // ============ Reset diario/mensal ============

  /// Reseta contadores diarios (chamar a meia-noite).
  Future<void> resetDailyCounters(String userId) async {
    final prefs = await _preferences;
    final prefix = 'user_${userId}_';

    await prefs.setInt('${prefix}credits_used_today', 0);
    await prefs.setInt('${prefix}ads_watched_today', 0);
  }

  /// Reseta contadores mensais (chamar no primeiro dia do mes).
  Future<void> resetMonthlyCounters(String userId) async {
    final prefs = await _preferences;
    final prefix = 'user_${userId}_';

    await prefs.setInt('${prefix}credits_used_month', 0);
  }

  // ============ UC195: Microcopy helpers ============

  /// Retorna mensagem contextual para visitante.
  String getVisitorMessage() {
    return 'Assista um anuncio para gerar 1 card agora';
  }

  /// Retorna mensagem contextual para usuario logado.
  String getLoggedUserMessage(AiCreditBalance balance) {
    if (balance.available > 0) {
      return 'Voce tem ${balance.available} credito${balance.available > 1 ? 's' : ''} disponivel${balance.available > 1 ? 'is' : ''}';
    }
    return 'Voce nao tem creditos. Assista um anuncio ou compre um pacote.';
  }

  /// Retorna mensagem para usuario premium.
  String getPremiumMessage() {
    return 'IA liberada - bom estudo!';
  }

  /// Retorna mensagem quando limite de anuncios foi atingido.
  String getAdLimitReachedMessage() {
    return 'Volte amanha para mais anuncios gratuitos, ou faca upgrade para IA ilimitada!';
  }

  /// Retorna mensagem de cooldown entre anuncios.
  String getAdCooldownMessage(Duration remaining) {
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    if (minutes > 0) {
      return 'Aguarde $minutes min para o proximo anuncio';
    }
    return 'Aguarde $seconds seg para o proximo anuncio';
  }

  /// Retorna mensagem de sucesso ao ganhar credito.
  String getCreditEarnedMessage(int credits, {bool fromAd = false}) {
    if (fromAd) {
      return 'Voce ganhou $credits credito${credits > 1 ? 's' : ''} com o anuncio!';
    }
    return '$credits credito${credits > 1 ? 's' : ''} adicionado${credits > 1 ? 's' : ''}!';
  }

  /// Retorna descricao da origem do credito.
  String getCreditSourceDescription(AiCreditSource source) {
    switch (source) {
      case AiCreditSource.welcomeBonus:
        return 'Bonus de boas-vindas';
      case AiCreditSource.rewardedAd:
        return 'Anuncio assistido';
      case AiCreditSource.purchase:
        return 'Compra de pacote';
      case AiCreditSource.subscription:
        return 'Assinatura Premium';
      case AiCreditSource.promo:
        return 'Codigo promocional';
    }
  }
}
