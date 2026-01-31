import 'package:equatable/equatable.dart';

/// UC215-UC220: Notification preferences entity.
///
/// Controls all notification settings to avoid spam and respect user preferences.
class NotificationPreferences extends Equatable {
  /// User ID.
  final String userId;

  /// UC215: Enable daily study reminder.
  final bool dailyReminderEnabled;

  /// Preferred time for daily reminder (hour in 24h format).
  final int dailyReminderHour;

  /// UC218: Enable overdue reviews notification.
  final bool overdueReviewsEnabled;

  /// UC217: Enable streak at risk notification.
  final bool streakAtRiskEnabled;

  /// UC219: Enable weekly summary.
  final bool weeklySummaryEnabled;

  /// Day of week for weekly summary (1=Monday, 7=Sunday).
  final int weeklySummaryDay;

  /// UC220: Number of consecutive ignored notifications.
  final int ignoredNotificationsCount;

  /// UC220: Whether auto-silence is active.
  final bool isAutoSilenced;

  /// Last notification sent timestamp.
  final DateTime? lastNotificationSent;

  /// Last overdue notification sent timestamp.
  final DateTime? lastOverdueNotificationSent;

  /// When preferences were last updated.
  final DateTime updatedAt;

  const NotificationPreferences({
    required this.userId,
    this.dailyReminderEnabled = true,
    this.dailyReminderHour = 19, // 7 PM default
    this.overdueReviewsEnabled = true,
    this.streakAtRiskEnabled = true,
    this.weeklySummaryEnabled = true,
    this.weeklySummaryDay = 7, // Sunday
    this.ignoredNotificationsCount = 0,
    this.isAutoSilenced = false,
    this.lastNotificationSent,
    this.lastOverdueNotificationSent,
    required this.updatedAt,
  });

  /// Create default preferences for a new user.
  factory NotificationPreferences.defaults(String userId) {
    return NotificationPreferences(
      userId: userId,
      updatedAt: DateTime.now(),
    );
  }

  /// UC220: Check if notifications should be silenced.
  bool get shouldSilence => isAutoSilenced || ignoredNotificationsCount >= 3;

  /// Check if daily reminder can be sent today.
  bool canSendDailyReminder(DateTime now) {
    if (!dailyReminderEnabled || shouldSilence) return false;
    if (lastNotificationSent == null) return true;

    // Only one per day
    return !_isSameDay(lastNotificationSent!, now);
  }

  /// UC218: Check if overdue notification can be sent.
  bool canSendOverdueNotification(DateTime now) {
    if (!overdueReviewsEnabled || shouldSilence) return false;
    if (lastOverdueNotificationSent == null) return true;

    // At most once every 48 hours
    final hoursSinceLast = now.difference(lastOverdueNotificationSent!).inHours;
    return hoursSinceLast >= 48;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  NotificationPreferences copyWith({
    String? userId,
    bool? dailyReminderEnabled,
    int? dailyReminderHour,
    bool? overdueReviewsEnabled,
    bool? streakAtRiskEnabled,
    bool? weeklySummaryEnabled,
    int? weeklySummaryDay,
    int? ignoredNotificationsCount,
    bool? isAutoSilenced,
    DateTime? lastNotificationSent,
    DateTime? lastOverdueNotificationSent,
    DateTime? updatedAt,
  }) {
    return NotificationPreferences(
      userId: userId ?? this.userId,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      overdueReviewsEnabled: overdueReviewsEnabled ?? this.overdueReviewsEnabled,
      streakAtRiskEnabled: streakAtRiskEnabled ?? this.streakAtRiskEnabled,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      weeklySummaryDay: weeklySummaryDay ?? this.weeklySummaryDay,
      ignoredNotificationsCount: ignoredNotificationsCount ?? this.ignoredNotificationsCount,
      isAutoSilenced: isAutoSilenced ?? this.isAutoSilenced,
      lastNotificationSent: lastNotificationSent ?? this.lastNotificationSent,
      lastOverdueNotificationSent: lastOverdueNotificationSent ?? this.lastOverdueNotificationSent,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        dailyReminderEnabled,
        dailyReminderHour,
        overdueReviewsEnabled,
        streakAtRiskEnabled,
        weeklySummaryEnabled,
        weeklySummaryDay,
        ignoredNotificationsCount,
        isAutoSilenced,
        lastNotificationSent,
        lastOverdueNotificationSent,
        updatedAt,
      ];
}

/// Notification type enum.
enum NotificationType {
  dailyReminder,
  overdueReviews,
  streakAtRisk,
  weeklySummary,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.dailyReminder:
        return 'Lembrete diário';
      case NotificationType.overdueReviews:
        return 'Revisões vencidas';
      case NotificationType.streakAtRisk:
        return 'Sequência em risco';
      case NotificationType.weeklySummary:
        return 'Resumo semanal';
    }
  }

  String get description {
    switch (this) {
      case NotificationType.dailyReminder:
        return 'Receba um lembrete diário para estudar';
      case NotificationType.overdueReviews:
        return 'Notificação quando há cards para revisar';
      case NotificationType.streakAtRisk:
        return 'Alerta quando sua sequência está em risco';
      case NotificationType.weeklySummary:
        return 'Resumo semanal do seu progresso';
    }
  }
}
