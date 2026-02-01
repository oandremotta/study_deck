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

  /// Available plans with their Stripe Price IDs
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
