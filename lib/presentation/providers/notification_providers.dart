import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/notification_service.dart';
import '../../domain/entities/notification_preferences.dart';
import 'auth_providers.dart';

// ============ Service Provider ============

/// Provider for notification service.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ============ Preferences Provider ============

/// Provider for loading notification preferences.
final notificationPreferencesProvider =
    FutureProvider<NotificationPreferences>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  final userId = authRepo.currentUser?.id ?? 'guest';
  return service.loadPreferences(userId);
});

// ============ Direct Functions ============

/// UC215: Update daily reminder setting.
Future<void> updateDailyReminderDirect(
  NotificationService service,
  NotificationPreferences prefs, {
  required bool enabled,
  int? hour,
}) async {
  final updated = prefs.copyWith(
    dailyReminderEnabled: enabled,
    dailyReminderHour: hour,
    updatedAt: DateTime.now(),
  );
  await service.savePreferences(updated);
}

/// UC215: Update overdue reviews setting.
Future<void> updateOverdueReviewsDirect(
  NotificationService service,
  NotificationPreferences prefs, {
  required bool enabled,
}) async {
  final updated = prefs.copyWith(
    overdueReviewsEnabled: enabled,
    updatedAt: DateTime.now(),
  );
  await service.savePreferences(updated);
}

/// UC215: Update streak at risk setting.
Future<void> updateStreakAtRiskDirect(
  NotificationService service,
  NotificationPreferences prefs, {
  required bool enabled,
}) async {
  final updated = prefs.copyWith(
    streakAtRiskEnabled: enabled,
    updatedAt: DateTime.now(),
  );
  await service.savePreferences(updated);
}

/// UC215: Update weekly summary setting.
Future<void> updateWeeklySummaryDirect(
  NotificationService service,
  NotificationPreferences prefs, {
  required bool enabled,
  int? day,
}) async {
  final updated = prefs.copyWith(
    weeklySummaryEnabled: enabled,
    weeklySummaryDay: day,
    updatedAt: DateTime.now(),
  );
  await service.savePreferences(updated);
}

/// UC220: Handle notification ignored.
Future<NotificationPreferences> handleNotificationIgnoredDirect(
  NotificationService service,
  NotificationPreferences prefs,
) async {
  final updated = await service.handleNotificationIgnored(prefs);
  await service.savePreferences(updated);
  return updated;
}

/// UC220: Handle notification opened.
Future<NotificationPreferences> handleNotificationOpenedDirect(
  NotificationService service,
  NotificationPreferences prefs,
) async {
  final updated = await service.handleNotificationOpened(prefs);
  await service.savePreferences(updated);
  return updated;
}

/// UC220: Re-enable notifications after auto-silence.
Future<NotificationPreferences> reEnableNotificationsDirect(
  NotificationService service,
  NotificationPreferences prefs,
) async {
  final updated = await service.reEnableNotifications(prefs);
  await service.savePreferences(updated);
  return updated;
}
