import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UC151-160: Analytics service for internal metrics tracking.
///
/// Handles:
/// - UC151: Event tracking (anonymous)
/// - UC152: Retention calculation (D1, D7, D30, D90)
/// - UC153: Churn detection
/// - UC154: LTV calculation
/// - UC155: CAC tracking
/// - UC156: Funnel analysis
/// - UC157: Pre-upgrade action patterns
/// - UC158: Rewarded ad ROI
/// - UC159: AI cost per user
/// - UC160: Metrics dashboard data
class AnalyticsService {
  // Storage keys
  static const String _eventsKey = 'analytics_events';
  static const String _firstUseKey = 'analytics_first_use';
  static const String _dailyActiveKey = 'analytics_daily_active';
  static const String _funnelKey = 'analytics_funnel_state';
  static const String _aiCostKey = 'analytics_ai_cost';
  static const String _revenueKey = 'analytics_revenue';
  static const String _adRevenueKey = 'analytics_ad_revenue';

  // Event types
  static const String eventDeckCreated = 'deck_created';
  static const String eventCardCreated = 'card_created';
  static const String eventStudyStarted = 'study_started';
  static const String eventStudyCompleted = 'study_completed';
  static const String eventAiGeneration = 'ai_generation';
  static const String eventUpgrade = 'upgrade';
  static const String eventCancellation = 'cancellation';
  static const String eventAdWatched = 'ad_watched';
  static const String eventCreditPurchase = 'credit_purchase';
  static const String eventAppOpen = 'app_open';
  static const String eventSignup = 'signup';

  // ============ UC151: Event Tracking ============

  /// Track an analytics event.
  Future<void> trackEvent(
    String eventType, {
    Map<String, dynamic>? properties,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;

      final event = AnalyticsEvent(
        type: eventType,
        timestamp: now,
        properties: properties ?? {},
      );

      // Get existing events
      final eventsJson = prefs.getString(_eventsKey) ?? '[]';
      final events = List<Map<String, dynamic>>.from(jsonDecode(eventsJson));

      // Add new event
      events.add(event.toJson());

      // Keep only last 30 days of events
      final thirtyDaysAgo = now - (30 * 24 * 60 * 60 * 1000);
      events.removeWhere((e) => (e['timestamp'] as int) < thirtyDaysAgo);

      await prefs.setString(_eventsKey, jsonEncode(events));

      // Update funnel state if applicable
      await _updateFunnelState(eventType);

      debugPrint('Analytics: Tracked event $eventType');
    } catch (e) {
      debugPrint('Analytics: Error tracking event: $e');
    }
  }

  /// Get events of a specific type.
  Future<List<AnalyticsEvent>> getEvents({
    String? type,
    int? sinceTimestamp,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_eventsKey) ?? '[]';
      final eventsList = List<Map<String, dynamic>>.from(jsonDecode(eventsJson));

      var events = eventsList.map((e) => AnalyticsEvent.fromJson(e)).toList();

      if (type != null) {
        events = events.where((e) => e.type == type).toList();
      }

      if (sinceTimestamp != null) {
        events = events.where((e) => e.timestamp >= sinceTimestamp).toList();
      }

      return events;
    } catch (e) {
      debugPrint('Analytics: Error getting events: $e');
      return [];
    }
  }

  // ============ UC152: Retention ============

  /// Record first use timestamp.
  Future<void> recordFirstUse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getInt(_firstUseKey) == null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt(_firstUseKey, now);
        await trackEvent(eventSignup);
      }
    } catch (e) {
      debugPrint('Analytics: Error recording first use: $e');
    }
  }

  /// Record daily active.
  Future<void> recordDailyActive() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayString();
      final activeDaysJson = prefs.getString(_dailyActiveKey) ?? '[]';
      final activeDays = List<String>.from(jsonDecode(activeDaysJson));

      if (!activeDays.contains(today)) {
        activeDays.add(today);
        // Keep only last 90 days
        if (activeDays.length > 90) {
          activeDays.removeAt(0);
        }
        await prefs.setString(_dailyActiveKey, jsonEncode(activeDays));
      }

      await trackEvent(eventAppOpen);
    } catch (e) {
      debugPrint('Analytics: Error recording daily active: $e');
    }
  }

  /// Calculate retention metrics.
  Future<RetentionMetrics> calculateRetention() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final firstUse = prefs.getInt(_firstUseKey);

      if (firstUse == null) {
        return RetentionMetrics.empty();
      }

      final activeDaysJson = prefs.getString(_dailyActiveKey) ?? '[]';
      final activeDays = List<String>.from(jsonDecode(activeDaysJson));

      final firstUseDate = DateTime.fromMillisecondsSinceEpoch(firstUse);
      final now = DateTime.now();
      final daysSinceFirstUse = now.difference(firstUseDate).inDays;

      // Calculate retention for each milestone
      bool d1 = false, d7 = false, d30 = false, d90 = false;

      if (daysSinceFirstUse >= 1) {
        final d1Date = firstUseDate.add(const Duration(days: 1));
        d1 = activeDays.contains(_dateToString(d1Date));
      }

      if (daysSinceFirstUse >= 7) {
        final d7Date = firstUseDate.add(const Duration(days: 7));
        d7 = activeDays.contains(_dateToString(d7Date));
      }

      if (daysSinceFirstUse >= 30) {
        final d30Date = firstUseDate.add(const Duration(days: 30));
        d30 = activeDays.contains(_dateToString(d30Date));
      }

      if (daysSinceFirstUse >= 90) {
        final d90Date = firstUseDate.add(const Duration(days: 90));
        d90 = activeDays.contains(_dateToString(d90Date));
      }

      return RetentionMetrics(
        d1Retained: d1,
        d7Retained: d7,
        d30Retained: d30,
        d90Retained: d90,
        daysSinceFirstUse: daysSinceFirstUse,
        totalActiveDays: activeDays.length,
      );
    } catch (e) {
      debugPrint('Analytics: Error calculating retention: $e');
      return RetentionMetrics.empty();
    }
  }

  // ============ UC153: Churn ============

  /// Check if user has churned.
  Future<ChurnStatus> checkChurnStatus({int inactiveDaysThreshold = 14}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeDaysJson = prefs.getString(_dailyActiveKey) ?? '[]';
      final activeDays = List<String>.from(jsonDecode(activeDaysJson));

      if (activeDays.isEmpty) {
        return ChurnStatus(
          isChurned: true,
          daysSinceLastActive: 999,
          riskLevel: ChurnRiskLevel.churned,
        );
      }

      final lastActiveStr = activeDays.last;
      final lastActive = _stringToDate(lastActiveStr);
      final daysSince = DateTime.now().difference(lastActive).inDays;

      ChurnRiskLevel riskLevel;
      if (daysSince >= inactiveDaysThreshold) {
        riskLevel = ChurnRiskLevel.churned;
      } else if (daysSince >= inactiveDaysThreshold ~/ 2) {
        riskLevel = ChurnRiskLevel.high;
      } else if (daysSince >= 3) {
        riskLevel = ChurnRiskLevel.medium;
      } else {
        riskLevel = ChurnRiskLevel.low;
      }

      return ChurnStatus(
        isChurned: daysSince >= inactiveDaysThreshold,
        daysSinceLastActive: daysSince,
        riskLevel: riskLevel,
      );
    } catch (e) {
      debugPrint('Analytics: Error checking churn: $e');
      return ChurnStatus(
        isChurned: false,
        daysSinceLastActive: 0,
        riskLevel: ChurnRiskLevel.low,
      );
    }
  }

  // ============ UC154: LTV ============

  /// Record revenue.
  Future<void> recordRevenue({
    required double amount,
    required RevenueType type,
    String? productId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final revenueJson = prefs.getString(_revenueKey) ?? '[]';
      final revenues = List<Map<String, dynamic>>.from(jsonDecode(revenueJson));

      revenues.add({
        'amount': amount,
        'type': type.name,
        'productId': productId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      await prefs.setString(_revenueKey, jsonEncode(revenues));

      await trackEvent(
        type == RevenueType.subscription ? eventUpgrade : eventCreditPurchase,
        properties: {'amount': amount, 'productId': productId},
      );
    } catch (e) {
      debugPrint('Analytics: Error recording revenue: $e');
    }
  }

  /// Calculate LTV.
  Future<LtvMetrics> calculateLtv() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final revenueJson = prefs.getString(_revenueKey) ?? '[]';
      final revenues = List<Map<String, dynamic>>.from(jsonDecode(revenueJson));

      double totalRevenue = 0;
      double subscriptionRevenue = 0;
      double creditRevenue = 0;

      for (final r in revenues) {
        final amount = (r['amount'] as num).toDouble();
        totalRevenue += amount;

        if (r['type'] == RevenueType.subscription.name) {
          subscriptionRevenue += amount;
        } else if (r['type'] == RevenueType.credits.name) {
          creditRevenue += amount;
        }
      }

      final retention = await calculateRetention();
      final monthsActive = retention.daysSinceFirstUse / 30;

      return LtvMetrics(
        totalRevenue: totalRevenue,
        subscriptionRevenue: subscriptionRevenue,
        creditRevenue: creditRevenue,
        monthsActive: monthsActive,
        averageMonthlyRevenue: monthsActive > 0 ? totalRevenue / monthsActive : 0,
      );
    } catch (e) {
      debugPrint('Analytics: Error calculating LTV: $e');
      return LtvMetrics.empty();
    }
  }

  // ============ UC156: Funnel Analysis ============

  /// Update funnel state based on event.
  Future<void> _updateFunnelState(String eventType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final funnelJson = prefs.getString(_funnelKey) ?? '{}';
      final funnel = Map<String, bool>.from(jsonDecode(funnelJson));

      switch (eventType) {
        case eventSignup:
          funnel['signup'] = true;
          break;
        case eventDeckCreated:
          funnel['first_deck'] = true;
          break;
        case eventStudyCompleted:
          funnel['first_study'] = true;
          break;
        case eventAiGeneration:
          funnel['used_ai'] = true;
          break;
        case eventUpgrade:
          funnel['upgraded'] = true;
          break;
      }

      await prefs.setString(_funnelKey, jsonEncode(funnel));
    } catch (e) {
      debugPrint('Analytics: Error updating funnel: $e');
    }
  }

  /// Get funnel state.
  Future<FunnelState> getFunnelState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final funnelJson = prefs.getString(_funnelKey) ?? '{}';
      final funnel = Map<String, bool>.from(jsonDecode(funnelJson));

      return FunnelState(
        signup: funnel['signup'] ?? false,
        firstDeck: funnel['first_deck'] ?? false,
        firstStudy: funnel['first_study'] ?? false,
        usedAi: funnel['used_ai'] ?? false,
        upgraded: funnel['upgraded'] ?? false,
      );
    } catch (e) {
      debugPrint('Analytics: Error getting funnel: $e');
      return FunnelState.empty();
    }
  }

  // ============ UC158: Ad ROI ============

  /// Record ad watch for ROI tracking.
  Future<void> recordAdWatch({required int creditsEarned}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adDataJson = prefs.getString(_adRevenueKey) ?? '{}';
      final adData = Map<String, dynamic>.from(jsonDecode(adDataJson));

      adData['totalAdsWatched'] = (adData['totalAdsWatched'] ?? 0) + 1;
      adData['totalCreditsFromAds'] =
          (adData['totalCreditsFromAds'] ?? 0) + creditsEarned;

      await prefs.setString(_adRevenueKey, jsonEncode(adData));
      await trackEvent(eventAdWatched, properties: {'credits': creditsEarned});
    } catch (e) {
      debugPrint('Analytics: Error recording ad watch: $e');
    }
  }

  /// Get ad ROI metrics.
  Future<AdRoiMetrics> getAdRoiMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adDataJson = prefs.getString(_adRevenueKey) ?? '{}';
      final adData = Map<String, dynamic>.from(jsonDecode(adDataJson));

      final funnel = await getFunnelState();

      return AdRoiMetrics(
        totalAdsWatched: adData['totalAdsWatched'] ?? 0,
        totalCreditsFromAds: adData['totalCreditsFromAds'] ?? 0,
        convertedToPremium: funnel.upgraded,
      );
    } catch (e) {
      debugPrint('Analytics: Error getting ad ROI: $e');
      return AdRoiMetrics.empty();
    }
  }

  // ============ UC159: AI Cost ============

  /// Record AI usage cost.
  Future<void> recordAiCost({
    required int creditsUsed,
    required int cardsGenerated,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final aiDataJson = prefs.getString(_aiCostKey) ?? '{}';
      final aiData = Map<String, dynamic>.from(jsonDecode(aiDataJson));

      aiData['totalCreditsUsed'] =
          (aiData['totalCreditsUsed'] ?? 0) + creditsUsed;
      aiData['totalCardsGenerated'] =
          (aiData['totalCardsGenerated'] ?? 0) + cardsGenerated;
      aiData['generationCount'] = (aiData['generationCount'] ?? 0) + 1;

      await prefs.setString(_aiCostKey, jsonEncode(aiData));
      await trackEvent(eventAiGeneration, properties: {
        'credits': creditsUsed,
        'cards': cardsGenerated,
      });
    } catch (e) {
      debugPrint('Analytics: Error recording AI cost: $e');
    }
  }

  /// Get AI cost metrics.
  Future<AiCostMetrics> getAiCostMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final aiDataJson = prefs.getString(_aiCostKey) ?? '{}';
      final aiData = Map<String, dynamic>.from(jsonDecode(aiDataJson));

      final totalCredits = aiData['totalCreditsUsed'] ?? 0;
      final totalCards = aiData['totalCardsGenerated'] ?? 0;
      final generations = aiData['generationCount'] ?? 0;

      return AiCostMetrics(
        totalCreditsUsed: totalCredits,
        totalCardsGenerated: totalCards,
        generationCount: generations,
        averageCreditsPerGeneration:
            generations > 0 ? totalCredits / generations : 0,
        averageCardsPerGeneration:
            generations > 0 ? totalCards / generations : 0,
      );
    } catch (e) {
      debugPrint('Analytics: Error getting AI cost: $e');
      return AiCostMetrics.empty();
    }
  }

  // ============ UC160: Dashboard Data ============

  /// Get all metrics for dashboard.
  Future<DashboardMetrics> getDashboardMetrics() async {
    final retention = await calculateRetention();
    final churn = await checkChurnStatus();
    final ltv = await calculateLtv();
    final funnel = await getFunnelState();
    final adRoi = await getAdRoiMetrics();
    final aiCost = await getAiCostMetrics();

    return DashboardMetrics(
      retention: retention,
      churn: churn,
      ltv: ltv,
      funnel: funnel,
      adRoi: adRoi,
      aiCost: aiCost,
    );
  }

  // ============ Helpers ============

  String _getTodayString() {
    return _dateToString(DateTime.now());
  }

  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _stringToDate(String str) {
    final parts = str.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}

// ============ Data Classes ============

class AnalyticsEvent {
  final String type;
  final int timestamp;
  final Map<String, dynamic> properties;

  AnalyticsEvent({
    required this.type,
    required this.timestamp,
    required this.properties,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'timestamp': timestamp,
        'properties': properties,
      };

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) => AnalyticsEvent(
        type: json['type'] as String,
        timestamp: json['timestamp'] as int,
        properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      );
}

class RetentionMetrics {
  final bool d1Retained;
  final bool d7Retained;
  final bool d30Retained;
  final bool d90Retained;
  final int daysSinceFirstUse;
  final int totalActiveDays;

  const RetentionMetrics({
    required this.d1Retained,
    required this.d7Retained,
    required this.d30Retained,
    required this.d90Retained,
    required this.daysSinceFirstUse,
    required this.totalActiveDays,
  });

  factory RetentionMetrics.empty() => const RetentionMetrics(
        d1Retained: false,
        d7Retained: false,
        d30Retained: false,
        d90Retained: false,
        daysSinceFirstUse: 0,
        totalActiveDays: 0,
      );

  double get retentionRate =>
      daysSinceFirstUse > 0 ? totalActiveDays / daysSinceFirstUse : 0;
}

enum ChurnRiskLevel { low, medium, high, churned }

class ChurnStatus {
  final bool isChurned;
  final int daysSinceLastActive;
  final ChurnRiskLevel riskLevel;

  const ChurnStatus({
    required this.isChurned,
    required this.daysSinceLastActive,
    required this.riskLevel,
  });
}

enum RevenueType { subscription, credits, b2b }

class LtvMetrics {
  final double totalRevenue;
  final double subscriptionRevenue;
  final double creditRevenue;
  final double monthsActive;
  final double averageMonthlyRevenue;

  const LtvMetrics({
    required this.totalRevenue,
    required this.subscriptionRevenue,
    required this.creditRevenue,
    required this.monthsActive,
    required this.averageMonthlyRevenue,
  });

  factory LtvMetrics.empty() => const LtvMetrics(
        totalRevenue: 0,
        subscriptionRevenue: 0,
        creditRevenue: 0,
        monthsActive: 0,
        averageMonthlyRevenue: 0,
      );
}

class FunnelState {
  final bool signup;
  final bool firstDeck;
  final bool firstStudy;
  final bool usedAi;
  final bool upgraded;

  const FunnelState({
    required this.signup,
    required this.firstDeck,
    required this.firstStudy,
    required this.usedAi,
    required this.upgraded,
  });

  factory FunnelState.empty() => const FunnelState(
        signup: false,
        firstDeck: false,
        firstStudy: false,
        usedAi: false,
        upgraded: false,
      );

  int get completedSteps {
    int count = 0;
    if (signup) count++;
    if (firstDeck) count++;
    if (firstStudy) count++;
    if (usedAi) count++;
    if (upgraded) count++;
    return count;
  }

  double get completionRate => completedSteps / 5;
}

class AdRoiMetrics {
  final int totalAdsWatched;
  final int totalCreditsFromAds;
  final bool convertedToPremium;

  const AdRoiMetrics({
    required this.totalAdsWatched,
    required this.totalCreditsFromAds,
    required this.convertedToPremium,
  });

  factory AdRoiMetrics.empty() => const AdRoiMetrics(
        totalAdsWatched: 0,
        totalCreditsFromAds: 0,
        convertedToPremium: false,
      );
}

class AiCostMetrics {
  final int totalCreditsUsed;
  final int totalCardsGenerated;
  final int generationCount;
  final double averageCreditsPerGeneration;
  final double averageCardsPerGeneration;

  const AiCostMetrics({
    required this.totalCreditsUsed,
    required this.totalCardsGenerated,
    required this.generationCount,
    required this.averageCreditsPerGeneration,
    required this.averageCardsPerGeneration,
  });

  factory AiCostMetrics.empty() => const AiCostMetrics(
        totalCreditsUsed: 0,
        totalCardsGenerated: 0,
        generationCount: 0,
        averageCreditsPerGeneration: 0,
        averageCardsPerGeneration: 0,
      );
}

class DashboardMetrics {
  final RetentionMetrics retention;
  final ChurnStatus churn;
  final LtvMetrics ltv;
  final FunnelState funnel;
  final AdRoiMetrics adRoi;
  final AiCostMetrics aiCost;

  const DashboardMetrics({
    required this.retention,
    required this.churn,
    required this.ltv,
    required this.funnel,
    required this.adRoi,
    required this.aiCost,
  });
}
