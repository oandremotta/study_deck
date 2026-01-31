import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/subscription_service.dart';
import '../../domain/entities/subscription.dart';

// ============ Service Provider ============

/// Provider for subscription service.
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

// ============ Subscription Providers ============

/// Provider for user subscription.
final userSubscriptionProvider =
    FutureProvider.family<UserSubscription, String>((ref, userId) async {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getSubscription(userId);
});

/// Provider for available plans.
final availablePlansProvider = Provider<List<SubscriptionPlan>>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getAvailablePlans();
});

/// Provider for plan features comparison.
final planFeaturesProvider = Provider<List<PlanFeatures>>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getPlanFeatures();
});

// ============ Direct Functions ============

/// UC259: Subscribe to a plan.
Future<UserSubscription> subscribeDirect(
  SubscriptionService service,
  String userId,
  SubscriptionPlan plan, {
  required String transactionId,
  required String productId,
}) async {
  return service.subscribe(
    userId,
    plan,
    transactionId: transactionId,
    productId: productId,
  );
}

/// UC260: Renew subscription.
Future<UserSubscription> renewSubscriptionDirect(
  SubscriptionService service,
  String userId, {
  required String transactionId,
}) async {
  return service.renewSubscription(userId, transactionId: transactionId);
}

/// UC261: Cancel subscription.
Future<UserSubscription> cancelSubscriptionDirect(
  SubscriptionService service,
  String userId,
) async {
  return service.cancelSubscription(userId);
}

/// UC260: Toggle auto-renewal.
Future<UserSubscription> toggleAutoRenewDirect(
  SubscriptionService service,
  String userId, {
  required bool autoRenew,
}) async {
  return service.toggleAutoRenew(userId, autoRenew: autoRenew);
}

/// UC262: Check limit.
Future<LimitCheckResult> checkLimitDirect(
  SubscriptionService service,
  String userId,
  LimitType limitType, {
  int currentCount = 0,
}) async {
  return service.checkLimit(userId, limitType, currentCount: currentCount);
}

/// UC263: Check if paywall should be shown.
Future<bool> shouldShowPaywallDirect(
  SubscriptionService service,
  String feature,
) async {
  return service.shouldShowPaywall(feature);
}

/// UC263: Mark paywall as shown.
Future<void> markPaywallShownDirect(
  SubscriptionService service,
  String feature,
) async {
  await service.markPaywallShown(feature);
}

/// UC264: Purchase AI credits.
Future<UserSubscription> purchaseAiCreditsDirect(
  SubscriptionService service,
  String userId,
  AiCreditPackage package, {
  required String transactionId,
}) async {
  return service.purchaseAiCredits(
    userId,
    package,
    transactionId: transactionId,
  );
}

/// UC265: Consume AI credits.
Future<UserSubscription> consumeAiCreditsDirect(
  SubscriptionService service,
  String userId,
  int credits,
) async {
  return service.consumeAiCredits(userId, credits);
}

/// UC265: Refund AI credits.
Future<UserSubscription> refundAiCreditsDirect(
  SubscriptionService service,
  String userId,
  int credits,
) async {
  return service.refundAiCredits(userId, credits);
}

/// UC266: Restore purchases.
Future<UserSubscription> restorePurchasesDirect(
  SubscriptionService service,
  String userId, {
  required List<PurchaseRecord> purchases,
}) async {
  return service.restorePurchases(userId, purchases: purchases);
}

/// Refresh monthly credits.
Future<UserSubscription> refreshMonthlyCreditsDirect(
  SubscriptionService service,
  String userId,
) async {
  return service.refreshMonthlyCredits(userId);
}
