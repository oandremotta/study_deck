import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// RevenueCat Web Billing service for web platform.
///
/// Uses RevenueCat REST API to fetch offerings and manage subscriptions on web.
class RevenueCatWebService {
  /// RevenueCat SDK API Key (same as mobile)
  /// This key works for REST API calls
  static const String _apiKey = 'test_MKwfQqqzjXelZAeMbosAaCQoFaY';

  /// RevenueCat API base URL
  static const String _baseUrl = 'https://api.revenuecat.com/v1';

  /// Project ID from RevenueCat (from dashboard URL)
  static const String _projectId = '9d5b0357';

  /// Entitlement ID
  static const String premiumEntitlement = 'Tech Attom Pro';

  String? _appUserId;

  /// Initialize with user ID
  Future<void> initialize(String? userId) async {
    _appUserId = userId ?? 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
    debugPrint('RevenueCat Web: Initialized with user: $_appUserId');
  }

  /// Get or create customer
  Future<Map<String, dynamic>?> getOrCreateCustomer() async {
    if (_appUserId == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/subscribers/$_appUserId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        // Customer doesn't exist, will be created on first purchase
        return null;
      }

      debugPrint('RevenueCat Web: Get customer error: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('RevenueCat Web: Get customer error: $e');
      return null;
    }
  }

  /// Check if user has premium entitlement
  Future<bool> isPremium() async {
    final customer = await getOrCreateCustomer();
    if (customer == null) return false;

    final subscriber = customer['subscriber'] as Map<String, dynamic>?;
    if (subscriber == null) return false;

    final entitlements = subscriber['entitlements'] as Map<String, dynamic>?;
    if (entitlements == null) return false;

    final premium = entitlements[premiumEntitlement] as Map<String, dynamic>?;
    if (premium == null) return false;

    // Check if entitlement is active
    final expiresDate = premium['expires_date'] as String?;
    if (expiresDate == null) return true; // Lifetime

    final expires = DateTime.tryParse(expiresDate);
    return expires != null && expires.isAfter(DateTime.now());
  }

  /// Get available offerings via REST API
  Future<WebOfferings?> getOfferings() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/subscribers/$_appUserId/offerings'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WebOfferings.fromJson(data);
      }

      debugPrint('RevenueCat Web: Get offerings error: ${response.statusCode}');
      debugPrint('RevenueCat Web: Response: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('RevenueCat Web: Get offerings error: $e');
      return null;
    }
  }

  /// Get the web purchase URL for a package
  /// This redirects the user to RevenueCat's hosted checkout
  String getPurchaseUrl(String packageId) {
    // RevenueCat Web Billing checkout URL format
    // See: https://www.revenuecat.com/docs/web/web-billing
    return 'https://billing.revenuecat.com/rcb-checkout/$_projectId/$packageId?customer_id=$_appUserId';
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'X-Platform': 'stripe',
      };
}

/// Web offerings model
class WebOfferings {
  final WebOffering? current;
  final Map<String, WebOffering> all;

  WebOfferings({this.current, required this.all});

  factory WebOfferings.fromJson(Map<String, dynamic> json) {
    final offeringsData = json['offerings'] as List<dynamic>? ?? [];
    final currentOfferingId = json['current_offering_id'] as String?;

    final allOfferings = <String, WebOffering>{};
    WebOffering? currentOffering;

    for (final offering in offeringsData) {
      final webOffering = WebOffering.fromJson(offering as Map<String, dynamic>);
      allOfferings[webOffering.identifier] = webOffering;

      if (webOffering.identifier == currentOfferingId) {
        currentOffering = webOffering;
      }
    }

    return WebOfferings(
      current: currentOffering,
      all: allOfferings,
    );
  }
}

/// Web offering model
class WebOffering {
  final String identifier;
  final String description;
  final List<WebPackage> packages;

  WebOffering({
    required this.identifier,
    required this.description,
    required this.packages,
  });

  factory WebOffering.fromJson(Map<String, dynamic> json) {
    final packagesData = json['packages'] as List<dynamic>? ?? [];

    return WebOffering(
      identifier: json['identifier'] as String? ?? '',
      description: json['description'] as String? ?? '',
      packages: packagesData
          .map((p) => WebPackage.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Web package model
class WebPackage {
  final String identifier;
  final String platformProductIdentifier;

  WebPackage({
    required this.identifier,
    required this.platformProductIdentifier,
  });

  factory WebPackage.fromJson(Map<String, dynamic> json) {
    return WebPackage(
      identifier: json['identifier'] as String? ?? '',
      platformProductIdentifier: json['platform_product_identifier'] as String? ?? '',
    );
  }

  bool get isMonthly =>
      identifier.toLowerCase().contains('monthly') ||
      identifier == '\$rc_monthly';

  bool get isAnnual =>
      identifier.toLowerCase().contains('annual') ||
      identifier.toLowerCase().contains('yearly') ||
      identifier == '\$rc_annual';

  bool get isLifetime =>
      identifier.toLowerCase().contains('lifetime') ||
      identifier == '\$rc_lifetime';

  String get displayName {
    if (isMonthly) return 'Mensal';
    if (isAnnual) return 'Anual';
    if (isLifetime) return 'Vitalicio';
    return identifier;
  }
}
