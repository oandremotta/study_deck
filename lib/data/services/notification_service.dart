import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/notification_preferences.dart';

/// UC215-UC220: Smart notification service.
///
/// Handles notification logic with anti-spam measures:
/// - Contextual daily reminders (UC216)
/// - Streak at risk alerts (UC217)
/// - Overdue review notifications (UC218)
/// - Weekly summaries (UC219)
/// - Auto-silence after ignored notifications (UC220)
class NotificationService {
  static const String _prefsPrefix = 'notification_';

  /// UC216: Check if daily reminder should be sent.
  NotificationDecision shouldSendDailyReminder({
    required NotificationPreferences prefs,
    required bool goalCompleted,
    required bool appOpenedToday,
    required DateTime now,
  }) {
    if (!prefs.dailyReminderEnabled) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Lembrete diário desativado',
      );
    }

    if (prefs.shouldSilence) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Notificações silenciadas automaticamente',
      );
    }

    if (goalCompleted) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Meta do dia já concluída',
      );
    }

    if (appOpenedToday) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Usuário já usou o app hoje',
      );
    }

    if (!prefs.canSendDailyReminder(now)) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Já enviou notificação hoje',
      );
    }

    // Check if it's the right time
    if (now.hour < prefs.dailyReminderHour) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Ainda não chegou o horário configurado',
      );
    }

    return const NotificationDecision(
      shouldSend: true,
      reason: 'Condições atendidas para lembrete',
    );
  }

  /// UC217: Check if streak at risk notification should be sent.
  NotificationDecision shouldSendStreakAtRisk({
    required NotificationPreferences prefs,
    required bool goalCompleted,
    required int currentStreak,
    required DateTime now,
  }) {
    if (!prefs.streakAtRiskEnabled) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Alerta de sequência desativado',
      );
    }

    if (prefs.shouldSilence) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Notificações silenciadas',
      );
    }

    if (goalCompleted) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Meta já concluída',
      );
    }

    if (currentStreak == 0) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Sem sequência ativa',
      );
    }

    // Only send near end of day (after 8 PM)
    if (now.hour < 20) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Ainda não é fim do dia',
      );
    }

    return NotificationDecision(
      shouldSend: true,
      reason: 'Sequência de $currentStreak dias em risco',
    );
  }

  /// UC218: Check if overdue reviews notification should be sent.
  NotificationDecision shouldSendOverdueReviews({
    required NotificationPreferences prefs,
    required int overdueCount,
    required DateTime now,
  }) {
    if (!prefs.overdueReviewsEnabled) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Notificação de revisões desativada',
      );
    }

    if (prefs.shouldSilence) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Notificações silenciadas',
      );
    }

    if (overdueCount == 0) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Nenhum card vencido',
      );
    }

    if (!prefs.canSendOverdueNotification(now)) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Notificação enviada há menos de 48h',
      );
    }

    return NotificationDecision(
      shouldSend: true,
      reason: '$overdueCount cards aguardando revisão',
    );
  }

  /// UC219: Check if weekly summary should be sent.
  NotificationDecision shouldSendWeeklySummary({
    required NotificationPreferences prefs,
    required DateTime now,
  }) {
    if (!prefs.weeklySummaryEnabled) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Resumo semanal desativado',
      );
    }

    if (prefs.shouldSilence) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Notificações silenciadas',
      );
    }

    // Check if it's the configured day
    if (now.weekday != prefs.weeklySummaryDay) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Não é o dia configurado',
      );
    }

    // Send in the morning (9 AM)
    if (now.hour != 9) {
      return const NotificationDecision(
        shouldSend: false,
        reason: 'Não é o horário do resumo',
      );
    }

    return const NotificationDecision(
      shouldSend: true,
      reason: 'Dia e horário do resumo semanal',
    );
  }

  /// UC216: Build daily reminder message.
  NotificationContent buildDailyReminderContent({
    required int cardsToStudy,
    required int currentStreak,
  }) {
    String title;
    String body;

    if (currentStreak > 0) {
      title = 'Continue sua sequência!';
      body = '$cardsToStudy cards esperando. $currentStreak dias seguidos estudando!';
    } else {
      title = 'Hora de estudar';
      body = '$cardsToStudy cards aguardam sua revisão.';
    }

    return NotificationContent(
      title: title,
      body: body,
      type: NotificationType.dailyReminder,
    );
  }

  /// UC217: Build streak at risk message.
  NotificationContent buildStreakAtRiskContent({
    required int currentStreak,
  }) {
    return NotificationContent(
      title: 'Sua sequência está em risco!',
      body: '$currentStreak dias de estudo. Estude hoje para não perder!',
      type: NotificationType.streakAtRisk,
    );
  }

  /// UC218: Build overdue reviews message.
  NotificationContent buildOverdueReviewsContent({
    required int overdueCount,
  }) {
    return NotificationContent(
      title: 'Revisões pendentes',
      body: '$overdueCount cards precisam de revisão para não esquecer.',
      type: NotificationType.overdueReviews,
    );
  }

  /// UC219: Build weekly summary content.
  WeeklySummaryContent buildWeeklySummaryContent({
    required int daysStudied,
    required int cardsReviewed,
    required int cardsMastered,
    required int previousWeekCards,
  }) {
    final improvement = cardsReviewed - previousWeekCards;
    String trend;
    if (improvement > 0) {
      trend = '+$improvement cards comparado à semana anterior';
    } else if (improvement < 0) {
      trend = '${improvement.abs()} cards a menos que semana passada';
    } else {
      trend = 'Mesmo ritmo da semana anterior';
    }

    return WeeklySummaryContent(
      title: 'Seu resumo semanal',
      body: '$daysStudied dias estudados, $cardsReviewed cards revisados',
      daysStudied: daysStudied,
      cardsReviewed: cardsReviewed,
      cardsMastered: cardsMastered,
      trend: trend,
      type: NotificationType.weeklySummary,
    );
  }

  /// UC220: Handle notification ignored.
  Future<NotificationPreferences> handleNotificationIgnored(
    NotificationPreferences prefs,
  ) async {
    final newCount = prefs.ignoredNotificationsCount + 1;
    final shouldAutoSilence = newCount >= 3;

    if (shouldAutoSilence) {
      debugPrint('NotificationService: Auto-silencing after $newCount ignored notifications');
    }

    return prefs.copyWith(
      ignoredNotificationsCount: newCount,
      isAutoSilenced: shouldAutoSilence,
      updatedAt: DateTime.now(),
    );
  }

  /// UC220: Handle notification opened (reset ignored count).
  Future<NotificationPreferences> handleNotificationOpened(
    NotificationPreferences prefs,
  ) async {
    return prefs.copyWith(
      ignoredNotificationsCount: 0,
      updatedAt: DateTime.now(),
    );
  }

  /// UC220: Manually re-enable notifications after auto-silence.
  Future<NotificationPreferences> reEnableNotifications(
    NotificationPreferences prefs,
  ) async {
    return prefs.copyWith(
      isAutoSilenced: false,
      ignoredNotificationsCount: 0,
      updatedAt: DateTime.now(),
    );
  }

  // ============ Persistence ============

  /// Save preferences to SharedPreferences.
  Future<void> savePreferences(NotificationPreferences prefs) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('${_prefsPrefix}daily_enabled', prefs.dailyReminderEnabled);
    await sp.setInt('${_prefsPrefix}daily_hour', prefs.dailyReminderHour);
    await sp.setBool('${_prefsPrefix}overdue_enabled', prefs.overdueReviewsEnabled);
    await sp.setBool('${_prefsPrefix}streak_enabled', prefs.streakAtRiskEnabled);
    await sp.setBool('${_prefsPrefix}weekly_enabled', prefs.weeklySummaryEnabled);
    await sp.setInt('${_prefsPrefix}weekly_day', prefs.weeklySummaryDay);
    await sp.setInt('${_prefsPrefix}ignored_count', prefs.ignoredNotificationsCount);
    await sp.setBool('${_prefsPrefix}auto_silenced', prefs.isAutoSilenced);
    if (prefs.lastNotificationSent != null) {
      await sp.setInt('${_prefsPrefix}last_sent', prefs.lastNotificationSent!.millisecondsSinceEpoch);
    }
    if (prefs.lastOverdueNotificationSent != null) {
      await sp.setInt('${_prefsPrefix}last_overdue', prefs.lastOverdueNotificationSent!.millisecondsSinceEpoch);
    }
  }

  /// Load preferences from SharedPreferences.
  Future<NotificationPreferences> loadPreferences(String userId) async {
    final sp = await SharedPreferences.getInstance();

    DateTime? lastSent;
    final lastSentMs = sp.getInt('${_prefsPrefix}last_sent');
    if (lastSentMs != null) {
      lastSent = DateTime.fromMillisecondsSinceEpoch(lastSentMs);
    }

    DateTime? lastOverdue;
    final lastOverdueMs = sp.getInt('${_prefsPrefix}last_overdue');
    if (lastOverdueMs != null) {
      lastOverdue = DateTime.fromMillisecondsSinceEpoch(lastOverdueMs);
    }

    return NotificationPreferences(
      userId: userId,
      dailyReminderEnabled: sp.getBool('${_prefsPrefix}daily_enabled') ?? true,
      dailyReminderHour: sp.getInt('${_prefsPrefix}daily_hour') ?? 19,
      overdueReviewsEnabled: sp.getBool('${_prefsPrefix}overdue_enabled') ?? true,
      streakAtRiskEnabled: sp.getBool('${_prefsPrefix}streak_enabled') ?? true,
      weeklySummaryEnabled: sp.getBool('${_prefsPrefix}weekly_enabled') ?? true,
      weeklySummaryDay: sp.getInt('${_prefsPrefix}weekly_day') ?? 7,
      ignoredNotificationsCount: sp.getInt('${_prefsPrefix}ignored_count') ?? 0,
      isAutoSilenced: sp.getBool('${_prefsPrefix}auto_silenced') ?? false,
      lastNotificationSent: lastSent,
      lastOverdueNotificationSent: lastOverdue,
      updatedAt: DateTime.now(),
    );
  }
}

/// Decision result for whether to send a notification.
class NotificationDecision {
  final bool shouldSend;
  final String reason;

  const NotificationDecision({
    required this.shouldSend,
    required this.reason,
  });
}

/// Content for a notification.
class NotificationContent {
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;

  const NotificationContent({
    required this.title,
    required this.body,
    required this.type,
    this.data,
  });
}

/// Extended content for weekly summary.
class WeeklySummaryContent extends NotificationContent {
  final int daysStudied;
  final int cardsReviewed;
  final int cardsMastered;
  final String trend;

  const WeeklySummaryContent({
    required super.title,
    required super.body,
    required this.daysStudied,
    required this.cardsReviewed,
    required this.cardsMastered,
    required this.trend,
    required super.type,
  });
}
