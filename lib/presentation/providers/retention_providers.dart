import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/retention_service.dart';
import '../../domain/entities/retention_milestone.dart';

// ============ Service Provider ============

/// Provider for retention service.
final retentionServiceProvider = Provider<RetentionService>((ref) {
  return RetentionService();
});

// ============ Milestone Providers ============

/// Provider for user milestones.
final milestonesProvider =
    FutureProvider.family<List<RetentionMilestone>, String>((ref, userId) async {
  final service = ref.watch(retentionServiceProvider);
  return service.getMilestones(userId);
});

/// Provider for next uncompleted milestone.
final nextMilestoneProvider =
    FutureProvider.family<RetentionMilestone?, String>((ref, userId) async {
  final service = ref.watch(retentionServiceProvider);
  return service.getNextMilestone(userId);
});

/// Provider for achieved milestones.
final achievedMilestonesProvider =
    FutureProvider.family<List<RetentionMilestone>, String>((ref, userId) async {
  final service = ref.watch(retentionServiceProvider);
  return service.getAchievedMilestones(userId);
});

// ============ Risk Detection Providers ============

/// Provider for churn risk detection.
final churnRiskProvider =
    FutureProvider.family<ChurnRiskInfo, String>((ref, userId) async {
  final service = ref.watch(retentionServiceProvider);
  return service.detectChurnRisk(userId);
});

/// Provider for plateau detection.
final plateauDetectionProvider =
    FutureProvider.family<PlateauDetection, String>((ref, userId) async {
  final service = ref.watch(retentionServiceProvider);
  return service.detectPlateau(userId);
});

// ============ Direct Functions ============

/// UC241-UC243: Initialize milestones.
Future<List<RetentionMilestone>> initializeMilestonesDirect(
  RetentionService service,
  String userId,
) async {
  return service.initializeMilestones(userId);
}

/// UC241-UC243: Update milestone progress.
Future<List<RetentionMilestone>> updateMilestoneProgressDirect(
  RetentionService service,
  String userId, {
  required int sessionsToday,
  required int cardsReviewed,
  required double retention,
  required int currentStreak,
}) async {
  return service.updateProgress(
    userId,
    sessionsToday: sessionsToday,
    cardsReviewed: cardsReviewed,
    retention: retention,
    currentStreak: currentStreak,
  );
}

/// UC244: Detect churn risk.
Future<ChurnRiskInfo> detectChurnRiskDirect(
  RetentionService service,
  String userId,
) async {
  return service.detectChurnRisk(userId);
}

/// UC245: Detect plateau.
Future<PlateauDetection> detectPlateauDirect(
  RetentionService service,
  String userId,
) async {
  return service.detectPlateau(userId);
}

/// UC246-UC247: Get re-engagement message.
String getReengagementMessageDirect(
  RetentionService service,
  ChurnRiskLevel level,
  int daysInactive,
) {
  return service.getReengagementMessage(level, daysInactive);
}

/// Get celebration message.
String getCelebrationMessageDirect(
  RetentionService service,
  MilestoneType type,
  RetentionMilestone milestone,
) {
  return service.getCelebrationMessage(type, milestone);
}
