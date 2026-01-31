import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/onboarding_service.dart';
import '../../domain/entities/onboarding_progress.dart';

// ============ Service Provider ============

/// Provider for onboarding service.
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

// ============ Progress Provider ============

/// Provider for onboarding progress.
final onboardingProgressProvider =
    FutureProvider.family<OnboardingProgress?, String>((ref, userId) async {
  final service = ref.watch(onboardingServiceProvider);
  return service.getProgress(userId);
});

// ============ Direct Functions ============

/// UC235: Initialize onboarding progress.
Future<OnboardingProgress> initializeOnboardingDirect(
  OnboardingService service,
  String userId,
) async {
  return service.initializeProgress(userId);
}

/// UC235: Mark welcome shown.
Future<OnboardingProgress> markWelcomeShownDirect(
  OnboardingService service,
  String userId,
) async {
  return service.markWelcomeShown(userId);
}

/// UC236: Mark first deck created.
Future<OnboardingProgress> markFirstDeckCreatedDirect(
  OnboardingService service,
  String userId,
) async {
  return service.markFirstDeckCreated(userId);
}

/// Track deck creation.
Future<OnboardingProgress> trackDeckCreatedDirect(
  OnboardingService service,
  String userId,
) async {
  return service.trackDeckCreated(userId);
}

/// UC237: Mark first card created.
Future<OnboardingProgress> markFirstCardCreatedDirect(
  OnboardingService service,
  String userId,
) async {
  return service.markFirstCardCreated(userId);
}

/// Track card creation.
Future<OnboardingProgress> trackCardCreatedDirect(
  OnboardingService service,
  String userId,
) async {
  return service.trackCardCreated(userId);
}

/// UC238: Mark first study completed.
Future<OnboardingProgress> markFirstStudyCompletedDirect(
  OnboardingService service,
  String userId,
) async {
  return service.markFirstStudyCompleted(userId);
}

/// Track study completion.
Future<OnboardingProgress> trackStudyCompletedDirect(
  OnboardingService service,
  String userId,
) async {
  return service.trackStudyCompleted(userId);
}

/// UC239: Mark organization explained.
Future<OnboardingProgress> markOrganizationExplainedDirect(
  OnboardingService service,
  String userId,
) async {
  return service.markOrganizationExplained(userId);
}

/// UC240: Dismiss a hint.
Future<OnboardingProgress> dismissHintDirect(
  OnboardingService service,
  String userId,
  String hintId,
) async {
  return service.dismissHint(userId, hintId);
}

/// Mark onboarding complete.
Future<OnboardingProgress> markOnboardingCompleteDirect(
  OnboardingService service,
  String userId,
) async {
  return service.markComplete(userId);
}

/// Check if should suggest study.
Future<bool> shouldSuggestStudyDirect(
  OnboardingService service,
  String userId,
) async {
  return service.shouldSuggestStudy(userId);
}

/// Check if should show organization tips.
Future<bool> shouldShowOrganizationTipsDirect(
  OnboardingService service,
  String userId,
) async {
  return service.shouldShowOrganizationTips(userId);
}
