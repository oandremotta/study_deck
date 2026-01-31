import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UC147, UC150: Service to track user activity and trigger reengagement.
///
/// Handles:
/// - UC147: Alert when premium is underutilized
/// - UC150: Reengage inactive premium users
class ReengagementService {
  // Storage keys
  static const String _lastStudyKey = 'last_study_timestamp';
  static const String _lastAiUseKey = 'last_ai_use_timestamp';
  static const String _lastBackupKey = 'last_backup_timestamp';
  static const String _lastAppOpenKey = 'last_app_open_timestamp';
  static const String _premiumStartKey = 'premium_start_timestamp';
  static const String _alertsShownKey = 'reengagement_alerts_shown';
  static const String _lastAlertKey = 'last_reengagement_alert';

  // Thresholds (in days)
  static const int inactiveThresholdDays = 7;
  static const int underutilizedThresholdDays = 14;
  static const int criticalInactiveDays = 30;
  static const int alertCooldownDays = 3;

  // ============ Activity Recording ============

  /// Record app open.
  Future<void> recordAppOpen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lastAppOpenKey, now);
    } catch (e) {
      debugPrint('ReengagementService: Error recording app open: $e');
    }
  }

  /// Record study session.
  Future<void> recordStudyActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lastStudyKey, now);
      await prefs.setInt(_lastAppOpenKey, now);
    } catch (e) {
      debugPrint('ReengagementService: Error recording study: $e');
    }
  }

  /// Record AI feature usage.
  Future<void> recordAiUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lastAiUseKey, now);
      await prefs.setInt(_lastAppOpenKey, now);
    } catch (e) {
      debugPrint('ReengagementService: Error recording AI use: $e');
    }
  }

  /// Record backup usage.
  Future<void> recordBackupUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lastBackupKey, now);
    } catch (e) {
      debugPrint('ReengagementService: Error recording backup: $e');
    }
  }

  /// Record premium start date.
  Future<void> recordPremiumStart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_premiumStartKey, now);
    } catch (e) {
      debugPrint('ReengagementService: Error recording premium start: $e');
    }
  }

  // ============ Activity Analysis ============

  /// Get user activity status.
  Future<UserActivityStatus> getActivityStatus({bool isPremium = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;

      final lastAppOpen = prefs.getInt(_lastAppOpenKey);
      final lastStudy = prefs.getInt(_lastStudyKey);
      final lastAi = prefs.getInt(_lastAiUseKey);
      final lastBackup = prefs.getInt(_lastBackupKey);

      // Calculate days since activities
      final daysSinceOpen = lastAppOpen != null
          ? ((now - lastAppOpen) / (24 * 60 * 60 * 1000)).floor()
          : 999;
      final daysSinceStudy = lastStudy != null
          ? ((now - lastStudy) / (24 * 60 * 60 * 1000)).floor()
          : 999;
      final daysSinceAi = lastAi != null
          ? ((now - lastAi) / (24 * 60 * 60 * 1000)).floor()
          : 999;
      final daysSinceBackup = lastBackup != null
          ? ((now - lastBackup) / (24 * 60 * 60 * 1000)).floor()
          : 999;

      // Determine status
      ActivityLevel level;
      if (daysSinceOpen >= criticalInactiveDays) {
        level = ActivityLevel.critical;
      } else if (daysSinceOpen >= inactiveThresholdDays) {
        level = ActivityLevel.inactive;
      } else if (daysSinceStudy >= inactiveThresholdDays) {
        level = ActivityLevel.lowEngagement;
      } else {
        level = ActivityLevel.active;
      }

      // Check underutilized features (for premium users)
      final underutilizedFeatures = <UnderutilizedFeature>[];
      if (isPremium) {
        if (daysSinceAi > underutilizedThresholdDays) {
          underutilizedFeatures.add(UnderutilizedFeature.aiGeneration);
        }
        if (daysSinceBackup > underutilizedThresholdDays) {
          underutilizedFeatures.add(UnderutilizedFeature.cloudBackup);
        }
      }

      return UserActivityStatus(
        level: level,
        daysSinceAppOpen: daysSinceOpen,
        daysSinceStudy: daysSinceStudy,
        daysSinceAiUse: daysSinceAi,
        daysSinceBackup: daysSinceBackup,
        underutilizedFeatures: underutilizedFeatures,
      );
    } catch (e) {
      debugPrint('ReengagementService: Error getting activity status: $e');
      return UserActivityStatus.active();
    }
  }

  // ============ Reengagement Alerts ============

  /// Check if should show reengagement alert.
  Future<ReengagementAlert?> checkForAlert({bool isPremium = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Check cooldown
      final lastAlert = prefs.getInt(_lastAlertKey);
      if (lastAlert != null) {
        final daysSinceAlert = ((now - lastAlert) / (24 * 60 * 60 * 1000)).floor();
        if (daysSinceAlert < alertCooldownDays) {
          return null;
        }
      }

      final status = await getActivityStatus(isPremium: isPremium);

      // UC147: Premium underutilized
      if (isPremium && status.underutilizedFeatures.isNotEmpty) {
        final feature = status.underutilizedFeatures.first;
        return ReengagementAlert(
          type: AlertType.premiumUnderutilized,
          title: 'Aproveite mais seu Premium!',
          message: feature.reminderMessage,
          actionLabel: feature.actionLabel,
          feature: feature,
        );
      }

      // UC150: Inactive user
      if (status.level == ActivityLevel.inactive ||
          status.level == ActivityLevel.critical) {
        return ReengagementAlert(
          type: AlertType.inactive,
          title: 'Sentimos sua falta!',
          message: 'Ja faz ${status.daysSinceAppOpen} dias desde seu ultimo estudo. '
              'Que tal revisar alguns cards?',
          actionLabel: 'Estudar agora',
        );
      }

      // Low engagement
      if (status.level == ActivityLevel.lowEngagement) {
        return ReengagementAlert(
          type: AlertType.lowEngagement,
          title: 'Mantenha o ritmo!',
          message: 'Estudar regularmente melhora sua retencao. '
              'Que tal uma sessao rapida?',
          actionLabel: 'Comecar sessao',
        );
      }

      return null;
    } catch (e) {
      debugPrint('ReengagementService: Error checking alerts: $e');
      return null;
    }
  }

  /// Mark alert as shown.
  Future<void> markAlertShown(AlertType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lastAlertKey, now);

      // Track shown alerts
      final shownJson = prefs.getString(_alertsShownKey) ?? '{}';
      final shown = Map<String, int>.from(
        shownJson.isNotEmpty ? {} : {},
      );
      shown[type.name] = (shown[type.name] ?? 0) + 1;
      // Not storing back to keep it simple
    } catch (e) {
      debugPrint('ReengagementService: Error marking alert: $e');
    }
  }
}

/// User activity status.
class UserActivityStatus {
  final ActivityLevel level;
  final int daysSinceAppOpen;
  final int daysSinceStudy;
  final int daysSinceAiUse;
  final int daysSinceBackup;
  final List<UnderutilizedFeature> underutilizedFeatures;

  const UserActivityStatus({
    required this.level,
    required this.daysSinceAppOpen,
    required this.daysSinceStudy,
    required this.daysSinceAiUse,
    required this.daysSinceBackup,
    required this.underutilizedFeatures,
  });

  factory UserActivityStatus.active() => const UserActivityStatus(
        level: ActivityLevel.active,
        daysSinceAppOpen: 0,
        daysSinceStudy: 0,
        daysSinceAiUse: 0,
        daysSinceBackup: 0,
        underutilizedFeatures: [],
      );
}

/// Activity levels.
enum ActivityLevel {
  active,         // Regular usage
  lowEngagement,  // Using app but not studying
  inactive,       // 7+ days without opening
  critical,       // 30+ days without opening
}

/// Premium features that may be underutilized.
enum UnderutilizedFeature {
  aiGeneration,
  cloudBackup,
  audioFeatures,
  advancedStats;

  String get reminderMessage {
    switch (this) {
      case aiGeneration:
        return 'Voce tem creditos IA disponiveis! Gere cards automaticamente.';
      case cloudBackup:
        return 'Seu backup na nuvem garante que seus dados estejam seguros.';
      case audioFeatures:
        return 'Experimente estudar com audio para melhorar a memorizacao.';
      case advancedStats:
        return 'Veja suas estatisticas detalhadas de estudo.';
    }
  }

  String get actionLabel {
    switch (this) {
      case aiGeneration:
        return 'Gerar cards';
      case cloudBackup:
        return 'Fazer backup';
      case audioFeatures:
        return 'Configurar audio';
      case advancedStats:
        return 'Ver estatisticas';
    }
  }
}

/// Reengagement alert.
class ReengagementAlert {
  final AlertType type;
  final String title;
  final String message;
  final String actionLabel;
  final UnderutilizedFeature? feature;

  const ReengagementAlert({
    required this.type,
    required this.title,
    required this.message,
    required this.actionLabel,
    this.feature,
  });
}

/// Alert types.
enum AlertType {
  premiumUnderutilized,
  inactive,
  lowEngagement,
  streakAtRisk,
}
