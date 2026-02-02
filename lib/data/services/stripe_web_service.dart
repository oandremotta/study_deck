import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Stripe Web Service for direct Stripe integration on web.
///
/// Uses Firebase Cloud Function to create Stripe Checkout sessions.
class StripeWebService {
  /// Firebase Functions base URL
  static const String _functionsUrl =
      'https://us-central1-studydeck-78bde.cloudfunctions.net';

  /// Available subscription plans with their Stripe Price IDs
  /// These must be created in Stripe Dashboard
  static const Map<String, StripePlan> plans = {
    'monthly': StripePlan(
      id: 'monthly',
      name: 'Mensal',
      description: 'Cobranca mensal, cancele quando quiser',
      priceDisplay: 'R\$ 19,90/mes',
      priceId: 'price_1SvubBGUSTQ8gR9hEwwN1JXm',
      isSubscription: true,
    ),
    'annual': StripePlan(
      id: 'annual',
      name: 'Anual',
      description: 'Economia de mais de 40%',
      priceDisplay: 'R\$ 149,90/ano',
      priceId: 'price_1SvubhGUSTQ8gR9hgHbo2Sy9',
      isSubscription: true,
    ),
    'lifetime': StripePlan(
      id: 'lifetime',
      name: 'Vitalicio',
      description: 'Pague uma vez, use para sempre',
      priceDisplay: 'R\$ 299,90',
      priceId: 'price_1Svuc2GUSTQ8gR9hDC0rKi84a',
      isSubscription: false,
    ),
  };

  /// Credit packages with Stripe Price IDs (one-time purchases)
  /// Created in Stripe Dashboard (Test Mode)
  static const Map<String, StripeCreditPackage> creditPackages = {
    'credits_50': StripeCreditPackage(
      id: 'credits_50',
      name: '50 Creditos',
      credits: 50,
      priceDisplay: 'R\$ 9,90',
      priceId: 'price_1SwB8wGUSTQ8gR9h4Yo6MhiBr',
    ),
    'credits_150': StripeCreditPackage(
      id: 'credits_150',
      name: '150 Creditos',
      credits: 150,
      priceDisplay: 'R\$ 24,90',
      priceId: 'price_1SwB9OGUSTQ8gR9hdh2qmtS2',
    ),
    'credits_500': StripeCreditPackage(
      id: 'credits_500',
      name: '500 Creditos',
      credits: 500,
      priceDisplay: 'R\$ 69,90',
      priceId: 'price_1SwB9gGUSTQ8gR9hwjC7UVsz',
    ),
  };

  /// Create a Stripe Checkout session and return the URL.
  ///
  /// Returns the checkout URL on success, null on error.
  Future<String?> createCheckoutSession({
    required String priceId,
    required String userId,
    String? userEmail,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_functionsUrl/createStripeCheckout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'priceId': priceId,
          'userId': userId,
          'userEmail': userEmail,
          'successUrl': successUrl,
          'cancelUrl': cancelUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String?;
      }

      debugPrint('Stripe checkout error: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Stripe checkout error: $e');
      return null;
    }
  }

  /// Get all available plans.
  List<StripePlan> getPlans() {
    return plans.values.toList();
  }

  /// Create checkout session for credit package purchase.
  ///
  /// Sends packageId to Cloud Function which resolves the priceId
  /// based on environment (dev/prod).
  ///
  /// Returns the checkout URL on success, null on error.
  Future<String?> createCreditPackageCheckout({
    required String packageId,
    required String userId,
    String? userEmail,
    String? successUrl,
    String? cancelUrl,
  }) async {
    final package = creditPackages[packageId];
    if (package == null) {
      debugPrint('Credit package not found: $packageId');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_functionsUrl/createStripeCheckout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'packageId': packageId, // Server resolves priceId from this
          'userId': userId,
          'userEmail': userEmail,
          'successUrl': successUrl,
          'cancelUrl': cancelUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String?;
      }

      debugPrint('Stripe checkout error: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Stripe checkout error: $e');
      return null;
    }
  }

  /// Get credit package by ID.
  StripeCreditPackage? getCreditPackage(String id) {
    return creditPackages[id];
  }
}

/// Stripe plan model.
class StripePlan {
  final String id;
  final String name;
  final String description;
  final String priceDisplay;
  final String priceId;
  final bool isSubscription;

  const StripePlan({
    required this.id,
    required this.name,
    required this.description,
    required this.priceDisplay,
    required this.priceId,
    required this.isSubscription,
  });

  bool get isMonthly => id == 'monthly';
  bool get isAnnual => id == 'annual';
  bool get isLifetime => id == 'lifetime';
}

/// Stripe credit package model for one-time purchases.
class StripeCreditPackage {
  final String id;
  final String name;
  final int credits;
  final String priceDisplay;
  final String priceId;

  const StripeCreditPackage({
    required this.id,
    required this.name,
    required this.credits,
    required this.priceDisplay,
    required this.priceId,
  });

  /// Check if the package has a valid Stripe Price ID configured
  bool get hasValidPriceId =>
      priceId.isNotEmpty && !priceId.contains('REPLACE_ME');
}
