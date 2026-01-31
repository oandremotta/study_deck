import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/ads_service.dart';
import '../../data/services/subscription_service.dart';

/// Provider for ads service.
final adsServiceProvider = Provider<AdsService>((ref) {
  final service = AdsService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for remaining daily ads.
final remainingAdsProvider =
    FutureProvider.family<int, bool>((ref, isPremium) async {
  final service = ref.watch(adsServiceProvider);
  return service.getRemainingAds(isPremium: isPremium);
});

/// Provider for checking if user can watch ads.
final canWatchAdProvider =
    FutureProvider.family<bool, bool>((ref, isPremium) async {
  final service = ref.watch(adsServiceProvider);
  return service.canWatchAd(isPremium: isPremium);
});

/// Provider for ad loaded state.
final isAdLoadedProvider = Provider<bool>((ref) {
  final service = ref.watch(adsServiceProvider);
  return service.isAdReady;
});

// ============ Direct Functions ============

/// UC208: Load a rewarded ad.
Future<bool> loadRewardedAdDirect(AdsService service) async {
  return service.loadRewardedAd();
}

/// UC208-209: Show rewarded ad and grant credits.
///
/// This is the main function to call when user wants to watch an ad.
/// It handles:
/// - UC208: Showing the ad
/// - UC209: Granting credits after successful view
/// - UC210: Checking daily limit
Future<AdWatchResult> watchAdForCreditsDirect(
  AdsService adsService,
  SubscriptionService subscriptionService,
  String userId, {
  required bool isPremium,
}) async {
  // UC210: Check daily limit
  final canWatch = await adsService.canWatchAd(isPremium: isPremium);
  if (!canWatch) {
    return AdWatchResult.limitReached();
  }

  // UC208: Load ad if not loaded
  if (!adsService.isAdReady) {
    final loaded = await adsService.loadRewardedAd();
    if (!loaded) {
      return AdWatchResult.error('Falha ao carregar anuncio');
    }
  }

  // UC208: Show rewarded ad
  final creditsEarned = await adsService.showRewardedAd();

  if (creditsEarned > 0) {
    // UC209: Grant credits after watching
    try {
      await subscriptionService.addCreditsFromAd(userId, creditsEarned);
      return AdWatchResult.success(creditsEarned);
    } catch (e) {
      return AdWatchResult.error('Erro ao adicionar creditos: $e');
    }
  }

  return AdWatchResult.error('Anuncio nao concluido');
}

/// Get daily ads info with cooldown status.
Future<DailyAdsInfo> getDailyAdsInfoDirect(
  AdsService service, {
  required bool isPremium,
}) async {
  final watched = await service.getDailyAdsWatched();
  final remaining = await service.getRemainingAds(isPremium: isPremium);
  final limit =
      isPremium ? AdsService.maxDailyAdsForPremium : AdsService.maxDailyAdsForFree;

  // UC079: Get cooldown info
  final status = await service.getAdAvailabilityStatus(isPremium: isPremium);

  return DailyAdsInfo(
    watched: watched,
    remaining: remaining,
    limit: limit,
    creditsPerAd: AdsService.creditsPerAd,
    cooldownMinutes: status.cooldownMinutes,
    blockReason: status.reason,
    blockMessage: status.blockMessage,
  );
}

/// Daily ads information with cooldown status (UC078-079).
class DailyAdsInfo {
  final int watched;
  final int remaining;
  final int limit;
  final int creditsPerAd;
  final int cooldownMinutes;
  final AdBlockReason? blockReason;
  final String? blockMessage;

  const DailyAdsInfo({
    required this.watched,
    required this.remaining,
    required this.limit,
    required this.creditsPerAd,
    this.cooldownMinutes = 0,
    this.blockReason,
    this.blockMessage,
  });

  /// UC079: Can watch considering both limit and cooldown.
  bool get canWatch => remaining > 0 && cooldownMinutes == 0;

  int get potentialCredits => remaining * creditsPerAd;

  String get displayText {
    if (cooldownMinutes > 0) {
      return 'Aguarde $cooldownMinutes min - $watched/$limit hoje';
    }
    return '$watched/$limit anuncios assistidos hoje';
  }

  /// UC078: Check if daily limit reached.
  bool get isLimitReached => remaining <= 0;

  /// UC079: Check if in cooldown.
  bool get isInCooldown => cooldownMinutes > 0;
}
