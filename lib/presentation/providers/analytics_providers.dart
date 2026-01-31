import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/analytics_service.dart';
import '../../data/services/card_quality_service.dart';
import '../../data/services/pedagogical_analytics_service.dart';
import '../../domain/entities/card.dart';

// ============ Service Providers ============

/// Provider for the pedagogical analytics service.
final pedagogicalAnalyticsServiceProvider = Provider<PedagogicalAnalyticsService>((ref) {
  return PedagogicalAnalyticsService();
});

/// Provider for the card quality service.
final cardQualityServiceProvider = Provider<CardQualityService>((ref) {
  final analyticsService = ref.watch(pedagogicalAnalyticsServiceProvider);
  return CardQualityService(analyticsService: analyticsService);
});

// ============ Card Quality Provider ============

/// Provider for calculating card quality.
final cardQualityProvider = FutureProvider.family<CardQualityResult, Card>((ref, card) async {
  final qualityService = ref.watch(cardQualityServiceProvider);
  return qualityService.calculateQuality(card);
});

// ============ Retention Analysis Provider ============

/// Provider for calculating retention analysis.
final retentionAnalysisProvider = Provider.family<RetentionAnalysis, RetentionParams>((ref, params) {
  final analyticsService = ref.watch(pedagogicalAnalyticsServiceProvider);
  return analyticsService.calculateRetention(
    totalReviews: params.totalReviews,
    correctReviews: params.correctReviews,
    consecutiveCorrect: params.consecutiveCorrect,
    lastReviewDate: params.lastReviewDate,
    currentEaseFactor: params.currentEaseFactor,
  );
});

/// Parameters for retention analysis.
class RetentionParams {
  final int totalReviews;
  final int correctReviews;
  final int consecutiveCorrect;
  final DateTime? lastReviewDate;
  final double currentEaseFactor;

  const RetentionParams({
    required this.totalReviews,
    required this.correctReviews,
    required this.consecutiveCorrect,
    this.lastReviewDate,
    this.currentEaseFactor = 2.5,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetentionParams &&
          runtimeType == other.runtimeType &&
          totalReviews == other.totalReviews &&
          correctReviews == other.correctReviews &&
          consecutiveCorrect == other.consecutiveCorrect &&
          lastReviewDate == other.lastReviewDate &&
          currentEaseFactor == other.currentEaseFactor;

  @override
  int get hashCode =>
      totalReviews.hashCode ^
      correctReviews.hashCode ^
      consecutiveCorrect.hashCode ^
      lastReviewDate.hashCode ^
      currentEaseFactor.hashCode;
}

// ============ False Mastery Provider ============

/// Provider for detecting false mastery.
final falseMasteryProvider = Provider.family<FalseMasteryAnalysis, FalseMasteryParams>((ref, params) {
  final analyticsService = ref.watch(pedagogicalAnalyticsServiceProvider);
  return analyticsService.detectFalseMastery(
    totalReviews: params.totalReviews,
    correctReviews: params.correctReviews,
    recentFailures: params.recentFailures,
    easeFactor: params.easeFactor,
    currentInterval: params.currentInterval,
    responseTimesMs: params.responseTimesMs,
  );
});

/// Parameters for false mastery detection.
class FalseMasteryParams {
  final int totalReviews;
  final int correctReviews;
  final int recentFailures;
  final double easeFactor;
  final int currentInterval;
  final List<int> responseTimesMs;

  const FalseMasteryParams({
    required this.totalReviews,
    required this.correctReviews,
    required this.recentFailures,
    required this.easeFactor,
    required this.currentInterval,
    this.responseTimesMs = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FalseMasteryParams &&
          runtimeType == other.runtimeType &&
          totalReviews == other.totalReviews &&
          correctReviews == other.correctReviews &&
          recentFailures == other.recentFailures &&
          easeFactor == other.easeFactor &&
          currentInterval == other.currentInterval;

  @override
  int get hashCode =>
      totalReviews.hashCode ^
      correctReviews.hashCode ^
      recentFailures.hashCode ^
      easeFactor.hashCode ^
      currentInterval.hashCode;
}

// ============ Direct Functions ============

/// Calculate retention analysis directly.
RetentionAnalysis calculateRetentionDirect(
  PedagogicalAnalyticsService service, {
  required int totalReviews,
  required int correctReviews,
  required int consecutiveCorrect,
  DateTime? lastReviewDate,
  double currentEaseFactor = 2.5,
}) {
  return service.calculateRetention(
    totalReviews: totalReviews,
    correctReviews: correctReviews,
    consecutiveCorrect: consecutiveCorrect,
    lastReviewDate: lastReviewDate,
    currentEaseFactor: currentEaseFactor,
  );
}

/// Detect false mastery directly.
FalseMasteryAnalysis detectFalseMasteryDirect(
  PedagogicalAnalyticsService service, {
  required int totalReviews,
  required int correctReviews,
  required int recentFailures,
  required double easeFactor,
  required int currentInterval,
  List<int> responseTimesMs = const [],
}) {
  return service.detectFalseMastery(
    totalReviews: totalReviews,
    correctReviews: correctReviews,
    recentFailures: recentFailures,
    easeFactor: easeFactor,
    currentInterval: currentInterval,
    responseTimesMs: responseTimesMs,
  );
}

/// Calculate card quality directly.
CardQualityResult calculateCardQualityDirect(
  CardQualityService service,
  Card card, {
  RetentionAnalysis? retention,
  int? totalReviews,
  int? correctReviews,
}) {
  return service.calculateQuality(
    card,
    retention: retention,
    totalReviews: totalReviews,
    correctReviews: correctReviews,
  );
}

/// Generate quality alerts directly.
List<QualityAlert> generateQualityAlertsDirect(
  CardQualityService service,
  Card card,
) {
  return service.generateQualityAlerts(card);
}

/// Generate improvement suggestions directly.
List<ImprovementSuggestion> generateImprovementSuggestionsDirect(
  CardQualityService service,
  Card card,
) {
  return service.generateImprovementSuggestions(card);
}

// ============ UC151-160: Business Analytics ============

/// Provider for business analytics service.
final businessAnalyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Provider for dashboard metrics.
final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
  final service = ref.watch(businessAnalyticsServiceProvider);
  return service.getDashboardMetrics();
});

/// Provider for business retention metrics (D1, D7, D30, D90).
final businessRetentionProvider = FutureProvider<RetentionMetrics>((ref) async {
  final service = ref.watch(businessAnalyticsServiceProvider);
  return service.calculateRetention();
});

/// Provider for churn status.
final churnStatusProvider = FutureProvider<ChurnStatus>((ref) async {
  final service = ref.watch(businessAnalyticsServiceProvider);
  return service.checkChurnStatus();
});

/// Provider for LTV metrics.
final ltvMetricsProvider = FutureProvider<LtvMetrics>((ref) async {
  final service = ref.watch(businessAnalyticsServiceProvider);
  return service.calculateLtv();
});

/// Provider for funnel state.
final funnelStateProvider = FutureProvider<FunnelState>((ref) async {
  final service = ref.watch(businessAnalyticsServiceProvider);
  return service.getFunnelState();
});

/// Provider for AI cost metrics.
final aiCostMetricsProvider = FutureProvider<AiCostMetrics>((ref) async {
  final service = ref.watch(businessAnalyticsServiceProvider);
  return service.getAiCostMetrics();
});

/// Provider for ad ROI metrics.
final adRoiMetricsProvider = FutureProvider<AdRoiMetrics>((ref) async {
  final service = ref.watch(businessAnalyticsServiceProvider);
  return service.getAdRoiMetrics();
});

// ============ Business Analytics Direct Functions ============

/// UC151: Track analytics event.
Future<void> trackEventDirect(
  AnalyticsService service,
  String eventType, {
  Map<String, dynamic>? properties,
}) async {
  await service.trackEvent(eventType, properties: properties);
}

/// Record first use.
Future<void> recordFirstUseDirect(AnalyticsService service) async {
  await service.recordFirstUse();
}

/// Record daily active.
Future<void> recordDailyActiveDirect(AnalyticsService service) async {
  await service.recordDailyActive();
}

/// UC154: Record revenue.
Future<void> recordRevenueDirect(
  AnalyticsService service, {
  required double amount,
  required RevenueType type,
  String? productId,
}) async {
  await service.recordRevenue(
    amount: amount,
    type: type,
    productId: productId,
  );
}

/// UC158: Record ad watch.
Future<void> recordAdWatchDirect(
  AnalyticsService service, {
  required int creditsEarned,
}) async {
  await service.recordAdWatch(creditsEarned: creditsEarned);
}

/// UC159: Record AI cost.
Future<void> recordAiCostDirect(
  AnalyticsService service, {
  required int creditsUsed,
  required int cardsGenerated,
}) async {
  await service.recordAiCost(
    creditsUsed: creditsUsed,
    cardsGenerated: cardsGenerated,
  );
}
