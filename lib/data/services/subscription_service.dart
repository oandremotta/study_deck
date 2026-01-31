import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/subscription.dart';

/// UC258-UC266: Subscription service for monetization.
///
/// Handles:
/// - Plan viewing (UC258)
/// - Subscription management (UC259-UC261)
/// - Free limits (UC262)
/// - Paywall logic (UC263)
/// - AI credits (UC264-UC265)
/// - Restore purchases (UC266)
class SubscriptionService {
  static const String _subscriptionKey = 'user_subscription';
  static const String _paywallShownKey = 'paywall_shown_session';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// UC258: Get all available plans.
  List<SubscriptionPlan> getAvailablePlans() {
    return SubscriptionPlan.values;
  }

  /// UC258: Get plan features for comparison.
  List<PlanFeatures> getPlanFeatures() {
    return [
      PlanFeatures.free,
      PlanFeatures.premium,
    ];
  }

  /// Get user subscription.
  Future<UserSubscription> getSubscription(String userId) async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString('${_subscriptionKey}_$userId');

      if (json == null) {
        // New user - create free subscription
        final subscription = UserSubscription.free(userId);
        await saveSubscription(subscription);
        return subscription;
      }

      return UserSubscription.fromJson(jsonDecode(json));
    } catch (e) {
      debugPrint('SubscriptionService: Error getting subscription: $e');
      return UserSubscription.free(userId);
    }
  }

  /// Save subscription.
  Future<void> saveSubscription(UserSubscription subscription) async {
    final prefs = await _preferences;
    await prefs.setString(
      '${_subscriptionKey}_${subscription.oduserId}',
      jsonEncode(subscription.toJson()),
    );
  }

  /// UC259: Subscribe to a plan.
  Future<UserSubscription> subscribe(
    String userId,
    SubscriptionPlan plan, {
    required String transactionId,
    required String productId,
  }) async {
    final current = await getSubscription(userId);
    final now = DateTime.now();

    final subscription = current.copyWith(
      plan: plan,
      status: SubscriptionStatus.active,
      startDate: now,
      endDate: now.add(Duration(days: plan.periodDays)),
      autoRenew: true,
      transactionId: transactionId,
      productId: productId,
      aiCreditsRemaining: plan.isPremium
          ? PlanFeatures.premium.aiCreditsPerMonth
          : current.aiCreditsRemaining,
      lastCreditRefresh: now,
    );

    await saveSubscription(subscription);
    debugPrint('SubscriptionService: Subscribed to ${plan.displayName}');
    return subscription;
  }

  /// UC260: Renew subscription.
  Future<UserSubscription> renewSubscription(
    String userId, {
    required String transactionId,
  }) async {
    final current = await getSubscription(userId);

    if (!current.isPremium) {
      throw Exception('No active subscription to renew');
    }

    final now = DateTime.now();
    final newEndDate = current.endDate?.isAfter(now) == true
        ? current.endDate!.add(Duration(days: current.plan.periodDays))
        : now.add(Duration(days: current.plan.periodDays));

    final subscription = current.copyWith(
      status: SubscriptionStatus.active,
      endDate: newEndDate,
      transactionId: transactionId,
      aiCreditsRemaining: PlanFeatures.premium.aiCreditsPerMonth,
      lastCreditRefresh: now,
    );

    await saveSubscription(subscription);
    debugPrint('SubscriptionService: Subscription renewed');
    return subscription;
  }

  /// UC261: Cancel subscription.
  Future<UserSubscription> cancelSubscription(String userId) async {
    final current = await getSubscription(userId);

    if (!current.isPremium) {
      throw Exception('No active subscription to cancel');
    }

    final subscription = current.copyWith(
      status: SubscriptionStatus.cancelled,
      cancelledAt: DateTime.now(),
      autoRenew: false,
    );

    await saveSubscription(subscription);
    debugPrint('SubscriptionService: Subscription cancelled');
    return subscription;
  }

  /// UC260: Toggle auto-renewal.
  Future<UserSubscription> toggleAutoRenew(
    String userId, {
    required bool autoRenew,
  }) async {
    final current = await getSubscription(userId);

    if (!current.isPremium) {
      throw Exception('No active subscription');
    }

    final subscription = current.copyWith(autoRenew: autoRenew);
    await saveSubscription(subscription);
    debugPrint('SubscriptionService: Auto-renew set to $autoRenew');
    return subscription;
  }

  /// UC262: Check if user can perform action (within limits).
  Future<LimitCheckResult> checkLimit(
    String userId,
    LimitType limitType, {
    int currentCount = 0,
  }) async {
    final subscription = await getSubscription(userId);
    final features = subscription.features;

    switch (limitType) {
      case LimitType.decks:
        if (features.unlimitedDecks) {
          return LimitCheckResult.allowed();
        }
        if (currentCount >= features.maxDecks) {
          return LimitCheckResult.blocked(
            'Limite de ${features.maxDecks} decks atingido',
            PremiumFeature.unlimitedDecks,
          );
        }
        return LimitCheckResult.allowed(
          remaining: features.maxDecks - currentCount,
        );

      case LimitType.cards:
        if (features.unlimitedCards) {
          return LimitCheckResult.allowed();
        }
        if (currentCount >= features.maxTotalCards) {
          return LimitCheckResult.blocked(
            'Limite de ${features.maxTotalCards} cards atingido',
            PremiumFeature.unlimitedCards,
          );
        }
        return LimitCheckResult.allowed(
          remaining: features.maxTotalCards - currentCount,
        );

      case LimitType.cardsPerDeck:
        if (features.unlimitedCards) {
          return LimitCheckResult.allowed();
        }
        if (currentCount >= features.maxCardsPerDeck) {
          return LimitCheckResult.blocked(
            'Limite de ${features.maxCardsPerDeck} cards por deck atingido',
            PremiumFeature.unlimitedCards,
          );
        }
        return LimitCheckResult.allowed(
          remaining: features.maxCardsPerDeck - currentCount,
        );

      case LimitType.aiGeneration:
        if (subscription.totalAiCredits > 0) {
          return LimitCheckResult.allowed(
            remaining: subscription.totalAiCredits,
          );
        }
        return LimitCheckResult.blocked(
          'Sem créditos de IA disponíveis',
          PremiumFeature.aiGeneration,
        );

      case LimitType.audio:
        if (features.audioFeatures) {
          return LimitCheckResult.allowed();
        }
        return LimitCheckResult.blocked(
          'Recursos de áudio são Premium',
          PremiumFeature.audioFeatures,
        );

      case LimitType.pronunciation:
        if (features.pronunciationRecording) {
          return LimitCheckResult.allowed();
        }
        return LimitCheckResult.blocked(
          'Gravação de pronúncia é Premium',
          PremiumFeature.pronunciation,
        );

      case LimitType.advancedStats:
        if (features.advancedStats) {
          return LimitCheckResult.allowed();
        }
        return LimitCheckResult.blocked(
          'Estatísticas avançadas são Premium',
          PremiumFeature.advancedStats,
        );

      case LimitType.cloudBackup:
        if (features.cloudBackup) {
          return LimitCheckResult.allowed();
        }
        return LimitCheckResult.blocked(
          'Backup na nuvem é Premium',
          PremiumFeature.cloudBackup,
        );
    }
  }

  /// UC263: Check if paywall should be shown.
  Future<bool> shouldShowPaywall(String feature) async {
    final prefs = await _preferences;
    final shownFeatures = prefs.getStringList(_paywallShownKey) ?? [];

    // Don't show same paywall twice in same session
    if (shownFeatures.contains(feature)) {
      return false;
    }

    return true;
  }

  /// UC263: Mark paywall as shown for this session.
  Future<void> markPaywallShown(String feature) async {
    final prefs = await _preferences;
    final shownFeatures = prefs.getStringList(_paywallShownKey) ?? [];
    shownFeatures.add(feature);
    await prefs.setStringList(_paywallShownKey, shownFeatures);
  }

  /// Clear session paywall tracking (call on app start).
  Future<void> clearPaywallSession() async {
    final prefs = await _preferences;
    await prefs.remove(_paywallShownKey);
  }

  /// UC264: Purchase AI credits.
  Future<UserSubscription> purchaseAiCredits(
    String userId,
    AiCreditPackage package, {
    required String transactionId,
  }) async {
    final current = await getSubscription(userId);

    final subscription = current.copyWith(
      aiCreditsPurchased: current.aiCreditsPurchased + package.credits,
    );

    await saveSubscription(subscription);
    debugPrint(
      'SubscriptionService: Purchased ${package.credits} AI credits',
    );
    return subscription;
  }

  /// UC265: Consume AI credits.
  Future<UserSubscription> consumeAiCredits(
    String userId,
    int credits,
  ) async {
    final current = await getSubscription(userId);

    if (current.totalAiCredits < credits) {
      throw Exception('Créditos insuficientes');
    }

    // First use purchased credits, then monthly credits
    int remainingToConsume = credits;
    int newPurchased = current.aiCreditsPurchased;
    int newMonthly = current.aiCreditsRemaining;

    if (newPurchased > 0) {
      final fromPurchased =
          remainingToConsume > newPurchased ? newPurchased : remainingToConsume;
      newPurchased -= fromPurchased;
      remainingToConsume -= fromPurchased;
    }

    if (remainingToConsume > 0) {
      newMonthly -= remainingToConsume;
    }

    final subscription = current.copyWith(
      aiCreditsRemaining: newMonthly,
      aiCreditsPurchased: newPurchased,
    );

    await saveSubscription(subscription);
    debugPrint('SubscriptionService: Consumed $credits AI credits');
    return subscription;
  }

  /// UC265: Refund AI credits (e.g., on failed generation).
  Future<UserSubscription> refundAiCredits(
    String userId,
    int credits,
  ) async {
    final current = await getSubscription(userId);

    // Refund to monthly credits
    final subscription = current.copyWith(
      aiCreditsRemaining: current.aiCreditsRemaining + credits,
    );

    await saveSubscription(subscription);
    debugPrint('SubscriptionService: Refunded $credits AI credits');
    return subscription;
  }

  /// UC209: Add credits from watching rewarded ad.
  Future<UserSubscription> addCreditsFromAd(
    String userId,
    int credits,
  ) async {
    final current = await getSubscription(userId);

    // Add credits to monthly pool (not purchased)
    final subscription = current.copyWith(
      aiCreditsRemaining: current.aiCreditsRemaining + credits,
    );

    await saveSubscription(subscription);
    debugPrint('SubscriptionService: Added $credits credits from ad');
    return subscription;
  }

  /// UC266: Restore purchases.
  Future<UserSubscription> restorePurchases(
    String userId, {
    required List<PurchaseRecord> purchases,
  }) async {
    final current = await getSubscription(userId);

    // Find most recent valid subscription purchase
    PurchaseRecord? validSubscription;
    int totalCredits = 0;

    for (final purchase in purchases) {
      if (purchase.isSubscription && purchase.isValid) {
        if (validSubscription == null ||
            purchase.purchaseDate.isAfter(validSubscription.purchaseDate)) {
          validSubscription = purchase;
        }
      } else if (purchase.isAiCredits) {
        totalCredits += purchase.credits ?? 0;
      }
    }

    UserSubscription subscription = current;

    if (validSubscription != null) {
      subscription = subscription.copyWith(
        plan: validSubscription.plan!,
        status: SubscriptionStatus.active,
        startDate: validSubscription.purchaseDate,
        endDate: validSubscription.expirationDate,
        transactionId: validSubscription.transactionId,
        productId: validSubscription.productId,
      );
    }

    if (totalCredits > 0) {
      subscription = subscription.copyWith(
        aiCreditsPurchased: subscription.aiCreditsPurchased + totalCredits,
      );
    }

    await saveSubscription(subscription);
    debugPrint('SubscriptionService: Purchases restored');
    return subscription;
  }

  /// Refresh monthly credits (call at start of billing period).
  Future<UserSubscription> refreshMonthlyCredits(String userId) async {
    final current = await getSubscription(userId);

    if (!current.isPremium) return current;

    // Check if a month has passed since last refresh
    if (current.lastCreditRefresh != null) {
      final daysSinceRefresh =
          DateTime.now().difference(current.lastCreditRefresh!).inDays;
      if (daysSinceRefresh < 30) return current;
    }

    final subscription = current.copyWith(
      aiCreditsRemaining: PlanFeatures.premium.aiCreditsPerMonth,
      lastCreditRefresh: DateTime.now(),
    );

    await saveSubscription(subscription);
    debugPrint('SubscriptionService: Monthly credits refreshed');
    return subscription;
  }
}

/// Result of limit check.
class LimitCheckResult {
  final bool isAllowed;
  final String? message;
  final PremiumFeature? blockedFeature;
  final int? remaining;

  const LimitCheckResult._({
    required this.isAllowed,
    this.message,
    this.blockedFeature,
    this.remaining,
  });

  factory LimitCheckResult.allowed({int? remaining}) {
    return LimitCheckResult._(
      isAllowed: true,
      remaining: remaining,
    );
  }

  factory LimitCheckResult.blocked(String message, PremiumFeature feature) {
    return LimitCheckResult._(
      isAllowed: false,
      message: message,
      blockedFeature: feature,
    );
  }
}

/// Types of limits to check.
enum LimitType {
  decks,
  cards,
  cardsPerDeck,
  aiGeneration,
  audio,
  pronunciation,
  advancedStats,
  cloudBackup,
}

/// Purchase record for restore.
class PurchaseRecord {
  final String transactionId;
  final String productId;
  final DateTime purchaseDate;
  final DateTime? expirationDate;
  final bool isSubscription;
  final bool isAiCredits;
  final SubscriptionPlan? plan;
  final int? credits;

  const PurchaseRecord({
    required this.transactionId,
    required this.productId,
    required this.purchaseDate,
    this.expirationDate,
    this.isSubscription = false,
    this.isAiCredits = false,
    this.plan,
    this.credits,
  });

  bool get isValid =>
      expirationDate == null || DateTime.now().isBefore(expirationDate!);
}
