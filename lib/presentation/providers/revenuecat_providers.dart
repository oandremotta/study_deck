import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../data/services/revenuecat_service.dart';
import '../../data/services/revenuecat_web_service.dart';
import 'auth_providers.dart';

// ============ Service Providers ============

/// RevenueCat service provider for mobile (singleton).
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

/// RevenueCat web service provider (singleton).
final revenueCatWebServiceProvider = Provider<RevenueCatWebService>((ref) {
  return RevenueCatWebService();
});

// ============ Initialization ============

/// Initialize RevenueCat when user is available.
///
/// Watch this provider to ensure RevenueCat is initialized.
final revenueCatInitProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(currentUserProvider);

  if (kIsWeb) {
    // Initialize web service
    final webService = ref.watch(revenueCatWebServiceProvider);
    await webService.initialize(user?.id);
    return;
  }

  // Initialize mobile service
  final service = ref.watch(revenueCatServiceProvider);
  await service.initialize(user?.id);

  // If user is logged in, also log in to RevenueCat
  if (user != null) {
    await service.login(user.id);
  }
});

// ============ Customer Info ============

/// Current customer info from RevenueCat.
///
/// Use this to check subscription status.
final customerInfoProvider = FutureProvider<CustomerInfo?>((ref) async {
  if (kIsWeb) return null;

  // Ensure initialized first
  await ref.watch(revenueCatInitProvider.future);

  final service = ref.watch(revenueCatServiceProvider);
  return await service.getCustomerInfo();
});

/// Check if user has premium subscription.
final isPremiumProvider = Provider<bool>((ref) {
  if (kIsWeb) {
    // Check via web service
    final isPremiumWeb = ref.watch(isPremiumWebProvider).valueOrNull;
    return isPremiumWeb ?? false;
  }

  final customerInfo = ref.watch(customerInfoProvider).valueOrNull;
  return customerInfo?.isPremium ?? false;
});

/// Check premium status on web.
final isPremiumWebProvider = FutureProvider<bool>((ref) async {
  await ref.watch(revenueCatInitProvider.future);
  final webService = ref.watch(revenueCatWebServiceProvider);
  return await webService.isPremium();
});

/// Premium entitlement info (if active).
final premiumEntitlementProvider = Provider<EntitlementInfo?>((ref) {
  final customerInfo = ref.watch(customerInfoProvider).valueOrNull;
  return customerInfo?.premiumEntitlement;
});

/// Premium expiration date.
final premiumExpirationProvider = Provider<DateTime?>((ref) {
  final customerInfo = ref.watch(customerInfoProvider).valueOrNull;
  return customerInfo?.premiumExpirationDate;
});

// ============ Offerings ============

/// Available offerings from RevenueCat (mobile).
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  if (kIsWeb) return null;

  // Ensure initialized first
  await ref.watch(revenueCatInitProvider.future);

  final service = ref.watch(revenueCatServiceProvider);
  return await service.getOfferings();
});

/// Available offerings from RevenueCat (web).
final webOfferingsProvider = FutureProvider<WebOfferings?>((ref) async {
  if (!kIsWeb) return null;

  // Ensure initialized first
  await ref.watch(revenueCatInitProvider.future);

  final webService = ref.watch(revenueCatWebServiceProvider);
  return await webService.getOfferings();
});

/// Web packages from current offering.
final webPackagesProvider = Provider<List<WebPackage>>((ref) {
  final offerings = ref.watch(webOfferingsProvider).valueOrNull;
  return offerings?.current?.packages ?? [];
});

/// Current offering (default).
final currentOfferingProvider = Provider<Offering?>((ref) {
  final offerings = ref.watch(offeringsProvider).valueOrNull;
  return offerings?.current;
});

/// Available packages in current offering.
final availablePackagesProvider = Provider<List<Package>>((ref) {
  final offering = ref.watch(currentOfferingProvider);
  return offering?.availablePackages ?? [];
});

/// Monthly package (if available).
final monthlyPackageProvider = Provider<Package?>((ref) {
  final packages = ref.watch(availablePackagesProvider);
  return packages.where((p) => p.isMonthly).firstOrNull;
});

/// Annual package (if available).
final annualPackageProvider = Provider<Package?>((ref) {
  final packages = ref.watch(availablePackagesProvider);
  return packages.where((p) => p.isAnnual).firstOrNull;
});

// ============ Direct Functions ============

/// Purchase a package directly.
///
/// Returns CustomerInfo if successful.
/// Returns null if cancelled by user.
/// Throws exception on error.
Future<CustomerInfo?> purchasePackageDirect(
  RevenueCatService service,
  Package package,
) async {
  return await service.purchasePackage(package);
}

/// Restore purchases directly.
Future<CustomerInfo?> restorePurchasesDirect(
  RevenueCatService service,
) async {
  return await service.restorePurchases();
}

/// Refresh customer info.
///
/// Call this after a purchase to update the UI.
void refreshCustomerInfo(WidgetRef ref) {
  ref.invalidate(customerInfoProvider);
}

/// Refresh offerings.
void refreshOfferings(WidgetRef ref) {
  ref.invalidate(offeringsProvider);
}
