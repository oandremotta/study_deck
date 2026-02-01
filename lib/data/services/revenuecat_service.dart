import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat service for managing in-app purchases and subscriptions.
///
/// Handles:
/// - SDK initialization
/// - Fetching available offerings/products
/// - Processing purchases
/// - Checking subscription status
/// - Restoring purchases
class RevenueCatService {
  /// RevenueCat API Keys
  /// Using the same key for both platforms initially (can be split later)
  static const String _apiKey = 'test_MKwfQqqzjXelZAeMbosAaCQoFaY';

  /// Entitlement ID for premium access
  /// Must match the identifier in RevenueCat dashboard
  static const String premiumEntitlement = 'Tech Attom Pro';

  bool _isInitialized = false;

  /// Check if SDK is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize RevenueCat SDK with user ID.
  ///
  /// Should be called when user logs in.
  Future<void> initialize(String? userId) async {
    if (_isInitialized) return;

    // Skip on web - RevenueCat doesn't support web
    if (kIsWeb) {
      debugPrint('RevenueCat: Web platform not supported');
      return;
    }

    try {
      final configuration = PurchasesConfiguration(_apiKey);

      if (userId != null && userId.isNotEmpty) {
        configuration.appUserID = userId;
      }

      await Purchases.configure(configuration);
      _isInitialized = true;

      debugPrint('RevenueCat: Initialized successfully');
      debugPrint('RevenueCat: User ID: ${await Purchases.appUserID}');
    } catch (e) {
      debugPrint('RevenueCat: Initialization error: $e');
    }
  }

  /// Log in a user to RevenueCat.
  ///
  /// Call when user authenticates.
  Future<CustomerInfo?> login(String userId) async {
    if (kIsWeb || !_isInitialized) return null;

    try {
      final result = await Purchases.logIn(userId);
      debugPrint('RevenueCat: User logged in: $userId');
      return result.customerInfo;
    } catch (e) {
      debugPrint('RevenueCat: Login error: $e');
      return null;
    }
  }

  /// Log out the current user.
  Future<CustomerInfo?> logout() async {
    if (kIsWeb || !_isInitialized) return null;

    try {
      final info = await Purchases.logOut();
      debugPrint('RevenueCat: User logged out');
      return info;
    } catch (e) {
      debugPrint('RevenueCat: Logout error: $e');
      return null;
    }
  }

  /// Get available offerings (products/packages).
  Future<Offerings?> getOfferings() async {
    if (kIsWeb || !_isInitialized) return null;

    try {
      final offerings = await Purchases.getOfferings();
      debugPrint('RevenueCat: Offerings fetched');
      debugPrint('RevenueCat: Current offering: ${offerings.current?.identifier}');
      debugPrint('RevenueCat: Available packages: ${offerings.current?.availablePackages.length ?? 0}');
      return offerings;
    } catch (e) {
      debugPrint('RevenueCat: Get offerings error: $e');
      return null;
    }
  }

  /// Get current customer info (subscription status).
  Future<CustomerInfo?> getCustomerInfo() async {
    if (kIsWeb || !_isInitialized) return null;

    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('RevenueCat: Get customer info error: $e');
      return null;
    }
  }

  /// Check if user has active premium subscription.
  Future<bool> isPremium() async {
    if (kIsWeb) return false;
    if (!_isInitialized) return false;

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPremium = customerInfo.entitlements.active.containsKey(premiumEntitlement);
      debugPrint('RevenueCat: isPremium = $isPremium');
      return isPremium;
    } catch (e) {
      debugPrint('RevenueCat: Check premium error: $e');
      return false;
    }
  }

  /// Get active entitlement info.
  Future<EntitlementInfo?> getPremiumEntitlement() async {
    if (kIsWeb || !_isInitialized) return null;

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active[premiumEntitlement];
    } catch (e) {
      debugPrint('RevenueCat: Get entitlement error: $e');
      return null;
    }
  }

  /// Purchase a package.
  ///
  /// Returns CustomerInfo if successful, null if cancelled.
  /// Throws exception on error.
  Future<CustomerInfo?> purchasePackage(Package package) async {
    if (kIsWeb || !_isInitialized) {
      throw Exception('Compras nao disponiveis nesta plataforma');
    }

    try {
      debugPrint('RevenueCat: Purchasing package: ${package.identifier}');
      final customerInfo = await Purchases.purchasePackage(package);
      debugPrint('RevenueCat: Purchase successful');
      return customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('RevenueCat: Purchase cancelled by user');
        return null;
      }

      debugPrint('RevenueCat: Purchase error: $errorCode - ${e.message}');
      throw _mapPurchaseError(errorCode);
    }
  }

  /// Restore previous purchases.
  Future<CustomerInfo?> restorePurchases() async {
    if (kIsWeb || !_isInitialized) return null;

    try {
      debugPrint('RevenueCat: Restoring purchases');
      final customerInfo = await Purchases.restorePurchases();
      debugPrint('RevenueCat: Restore successful');
      return customerInfo;
    } catch (e) {
      debugPrint('RevenueCat: Restore error: $e');
      return null;
    }
  }

  /// Add listener for customer info updates.
  void addCustomerInfoListener(void Function(CustomerInfo) listener) {
    if (kIsWeb || !_isInitialized) return;

    Purchases.addCustomerInfoUpdateListener(listener);
  }

  /// Remove listener for customer info updates.
  void removeCustomerInfoListener(void Function(CustomerInfo) listener) {
    if (kIsWeb || !_isInitialized) return;

    Purchases.removeCustomerInfoUpdateListener(listener);
  }

  /// Map purchase error code to user-friendly message.
  Exception _mapPurchaseError(PurchasesErrorCode errorCode) {
    switch (errorCode) {
      case PurchasesErrorCode.purchaseCancelledError:
        return Exception('Compra cancelada');
      case PurchasesErrorCode.purchaseNotAllowedError:
        return Exception('Compras nao permitidas neste dispositivo');
      case PurchasesErrorCode.purchaseInvalidError:
        return Exception('Compra invalida');
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return Exception('Produto nao disponivel');
      case PurchasesErrorCode.productAlreadyPurchasedError:
        return Exception('Voce ja possui este produto');
      case PurchasesErrorCode.networkError:
        return Exception('Erro de conexao. Verifique sua internet.');
      case PurchasesErrorCode.receiptAlreadyInUseError:
        return Exception('Esta compra ja esta vinculada a outra conta');
      case PurchasesErrorCode.paymentPendingError:
        return Exception('Pagamento pendente. Aguarde a confirmacao.');
      case PurchasesErrorCode.storeProblemError:
        return Exception('Problema com a loja. Tente novamente.');
      default:
        return Exception('Erro ao processar compra. Tente novamente.');
    }
  }
}

/// Helper extension for CustomerInfo.
extension CustomerInfoExtension on CustomerInfo {
  /// Check if user has active premium subscription.
  bool get isPremium =>
      entitlements.active.containsKey(RevenueCatService.premiumEntitlement);

  /// Get premium entitlement info if active.
  EntitlementInfo? get premiumEntitlement =>
      entitlements.active[RevenueCatService.premiumEntitlement];

  /// Get expiration date for premium subscription.
  DateTime? get premiumExpirationDate {
    final entitlement = premiumEntitlement;
    if (entitlement == null) return null;

    final dateStr = entitlement.expirationDate;
    if (dateStr == null) return null;

    return DateTime.tryParse(dateStr);
  }

  /// Check if premium will renew.
  bool get willRenew => premiumEntitlement?.willRenew ?? false;
}

/// Helper extension for Package.
extension PackageExtension on Package {
  /// Get formatted price string.
  String get formattedPrice => storeProduct.priceString;

  /// Get product title.
  String get title => storeProduct.title;

  /// Get product description.
  String get description => storeProduct.description;

  /// Check if this is a monthly subscription.
  bool get isMonthly =>
      packageType == PackageType.monthly ||
      identifier.toLowerCase().contains('monthly');

  /// Check if this is an annual subscription.
  bool get isAnnual =>
      packageType == PackageType.annual ||
      identifier.toLowerCase().contains('annual');
}
