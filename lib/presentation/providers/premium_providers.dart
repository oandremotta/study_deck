import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/ai_abuse_service.dart';
import '../../data/services/reengagement_service.dart';
import '../../data/services/time_saved_service.dart';

// ============ Service Providers ============

/// Provider for AI abuse prevention service.
final aiAbuseServiceProvider = Provider<AiAbuseService>((ref) {
  return AiAbuseService();
});

/// Provider for time saved tracking service.
final timeSavedServiceProvider = Provider<TimeSavedService>((ref) {
  return TimeSavedService();
});

/// Provider for reengagement service.
final reengagementServiceProvider = Provider<ReengagementService>((ref) {
  return ReengagementService();
});

// ============ Data Providers ============

/// Provider for time saved statistics.
final timeSavedStatsProvider = FutureProvider<TimeSavedStats>((ref) async {
  final service = ref.watch(timeSavedServiceProvider);
  return service.getTimeSavedStats();
});

/// Provider for user activity status.
final userActivityStatusProvider =
    FutureProvider.family<UserActivityStatus, bool>((ref, isPremium) async {
  final service = ref.watch(reengagementServiceProvider);
  return service.getActivityStatus(isPremium: isPremium);
});

/// Provider for reengagement alerts.
final reengagementAlertProvider =
    FutureProvider.family<ReengagementAlert?, bool>((ref, isPremium) async {
  final service = ref.watch(reengagementServiceProvider);
  return service.checkForAlert(isPremium: isPremium);
});

/// Provider for AI rate limit status.
final aiRateLimitProvider =
    FutureProvider.family<AiRateLimitResult, bool>((ref, isPremium) async {
  final service = ref.watch(aiAbuseServiceProvider);
  return service.checkRateLimit(isPremium: isPremium);
});

/// Provider for AI quality level.
final aiQualityLevelProvider = FutureProvider<AiQualityLevel>((ref) async {
  final service = ref.watch(aiAbuseServiceProvider);
  return service.getQualityLevel();
});

// ============ Direct Functions ============

/// Record AI cards generated.
Future<void> recordAiCardsGeneratedDirect(
  TimeSavedService service,
  int count,
) async {
  await service.recordAiCardsGenerated(count);
}

/// Record study session for time tracking.
Future<void> recordStudySessionDirect(TimeSavedService service) async {
  await service.recordStudySession();
}

/// Record cards studied for time tracking.
Future<void> recordCardsStudiedDirect(
  TimeSavedService service,
  int count,
) async {
  await service.recordCardsStudied(count);
}

/// Record app open for reengagement.
Future<void> recordAppOpenDirect(ReengagementService service) async {
  await service.recordAppOpen();
}

/// Record study activity for reengagement.
Future<void> recordStudyActivityDirect(ReengagementService service) async {
  await service.recordStudyActivity();
}

/// Record AI usage for reengagement.
Future<void> recordAiUsageDirect(ReengagementService service) async {
  await service.recordAiUsage();
}

/// Check AI rate limit before generation.
Future<AiRateLimitResult> checkAiRateLimitDirect(
  AiAbuseService service, {
  bool isPremium = false,
}) async {
  return service.checkRateLimit(isPremium: isPremium);
}

/// Check prompt for spam detection.
Future<PromptCheckResult> checkPromptDirect(
  AiAbuseService service,
  String prompt,
) async {
  return service.checkPrompt(prompt);
}

/// Record AI generation completed.
Future<void> recordAiGenerationDirect(AiAbuseService service) async {
  await service.recordGeneration();
}

/// Record good behavior (reduces abuse score).
Future<void> recordGoodBehaviorDirect(AiAbuseService service) async {
  await service.recordGoodBehavior();
}
