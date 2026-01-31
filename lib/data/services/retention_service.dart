import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/retention_milestone.dart';

/// UC241-UC247: Retention service for 7/30/90 day milestones.
///
/// Handles:
/// - 7-day milestone tracking (UC241)
/// - 30-day milestone tracking (UC242)
/// - 90-day milestone tracking (UC243)
/// - Churn detection (UC244)
/// - Plateau detection (UC245)
/// - Re-engagement suggestions (UC246-UC247)
class RetentionService {
  static const String _milestonesKey = 'retention_milestones';
  static const String _activityKey = 'user_activity_log';
  static const String _retentionHistoryKey = 'retention_history';

  final _uuid = const Uuid();
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// UC241-UC243: Get all milestones for user.
  Future<List<RetentionMilestone>> getMilestones(String userId) async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString('${_milestonesKey}_$userId');

      if (json == null) return [];

      final List<dynamic> list = jsonDecode(json);
      return list
          .map((e) => RetentionMilestone.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('RetentionService: Error getting milestones: $e');
      return [];
    }
  }

  /// Initialize milestones for new user.
  Future<List<RetentionMilestone>> initializeMilestones(String userId) async {
    final now = DateTime.now();
    final milestones = [
      RetentionMilestone(
        id: _uuid.v4(),
        userId: userId,
        type: MilestoneType.day7,
        daysActive: 0,
        startedAt: now,
        targetDate: now.add(const Duration(days: 7)),
      ),
      RetentionMilestone(
        id: _uuid.v4(),
        userId: userId,
        type: MilestoneType.day30,
        daysActive: 0,
        startedAt: now,
        targetDate: now.add(const Duration(days: 30)),
      ),
      RetentionMilestone(
        id: _uuid.v4(),
        userId: userId,
        type: MilestoneType.day90,
        daysActive: 0,
        startedAt: now,
        targetDate: now.add(const Duration(days: 90)),
      ),
    ];

    await _saveMilestones(userId, milestones);
    debugPrint('RetentionService: Initialized milestones for $userId');
    return milestones;
  }

  /// UC241-UC243: Update milestone progress.
  Future<List<RetentionMilestone>> updateProgress(
    String userId, {
    required int sessionsToday,
    required int cardsReviewed,
    required double retention,
    required int currentStreak,
  }) async {
    var milestones = await getMilestones(userId);

    if (milestones.isEmpty) {
      milestones = await initializeMilestones(userId);
    }

    final now = DateTime.now();
    final updatedMilestones = <RetentionMilestone>[];

    for (final milestone in milestones) {
      if (milestone.achieved) {
        updatedMilestones.add(milestone);
        continue;
      }

      final daysActive = now.difference(milestone.startedAt).inDays;
      final newSessions = milestone.totalSessions + sessionsToday;
      final newCards = milestone.cardsReviewed + cardsReviewed;

      // Calculate weighted average retention
      final totalReviews = milestone.cardsReviewed + cardsReviewed;
      final newRetention = totalReviews > 0
          ? ((milestone.averageRetention * milestone.cardsReviewed) +
                  (retention * cardsReviewed)) /
              totalReviews
          : retention;

      final updated = milestone.copyWith(
        daysActive: daysActive,
        totalSessions: newSessions,
        cardsReviewed: newCards,
        averageRetention: newRetention,
        longestStreak: currentStreak > milestone.longestStreak
            ? currentStreak
            : milestone.longestStreak,
      );

      // Check if milestone achieved
      if (daysActive >= milestone.type.days && !milestone.achieved) {
        final achieved = updated.copyWith(
          achieved: true,
          achievedAt: now,
        );
        updatedMilestones.add(achieved);
        debugPrint(
          'RetentionService: Milestone ${milestone.type.name} achieved for $userId',
        );
      } else {
        updatedMilestones.add(updated);
      }
    }

    await _saveMilestones(userId, updatedMilestones);
    await _logActivity(userId, sessionsToday, retention);

    return updatedMilestones;
  }

  /// Get next uncompleted milestone.
  Future<RetentionMilestone?> getNextMilestone(String userId) async {
    final milestones = await getMilestones(userId);
    return milestones.where((m) => !m.achieved).firstOrNull;
  }

  /// Get achieved milestones.
  Future<List<RetentionMilestone>> getAchievedMilestones(String userId) async {
    final milestones = await getMilestones(userId);
    return milestones.where((m) => m.achieved).toList();
  }

  /// UC244: Detect churn risk.
  Future<ChurnRiskInfo> detectChurnRisk(String userId) async {
    final activity = await _getActivityLog(userId);
    final now = DateTime.now();

    if (activity.isEmpty) {
      return ChurnRiskInfo(
        userId: userId,
        level: ChurnRiskLevel.none,
        daysSinceLastActivity: 0,
        previousActivityRate: 0,
        suggestions: [],
        detectedAt: now,
      );
    }

    // Find last activity
    final lastActivity = activity.last;
    final daysSinceLastActivity =
        now.difference(lastActivity.date).inDays;

    // Calculate previous activity rate (sessions per week)
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentActivity = activity.where((a) => a.date.isAfter(weekAgo));
    final previousActivityRate = recentActivity.length / 7.0;

    // Determine risk level
    ChurnRiskLevel level;
    if (daysSinceLastActivity <= 1) {
      level = ChurnRiskLevel.none;
    } else if (daysSinceLastActivity <= 3) {
      level = ChurnRiskLevel.low;
    } else if (daysSinceLastActivity <= 5) {
      level = ChurnRiskLevel.medium;
    } else if (daysSinceLastActivity <= 10) {
      level = ChurnRiskLevel.high;
    } else {
      level = ChurnRiskLevel.critical;
    }

    // Generate suggestions based on risk level
    final suggestions = _getReengagementSuggestions(level, daysSinceLastActivity);

    return ChurnRiskInfo(
      userId: userId,
      level: level,
      daysSinceLastActivity: daysSinceLastActivity,
      previousActivityRate: previousActivityRate,
      suggestions: suggestions,
      detectedAt: now,
    );
  }

  /// UC245: Detect learning plateau.
  Future<PlateauDetection> detectPlateau(String userId) async {
    final history = await _getRetentionHistory(userId);
    final now = DateTime.now();

    if (history.length < 7) {
      // Not enough data
      return PlateauDetection(
        userId: userId,
        isInPlateau: false,
        currentRetention: history.isNotEmpty ? history.last.retention : 0.0,
        previousRetention: 0.0,
        daysInPlateau: 0,
        suggestedActions: [],
        detectedAt: now,
      );
    }

    // Get retention from last 7 days vs previous 7 days
    final currentWeek = history.take(7).toList();
    final previousWeek = history.skip(7).take(7).toList();

    final currentRetention =
        currentWeek.map((e) => e.retention).reduce((a, b) => a + b) /
            currentWeek.length;

    final previousRetention = previousWeek.isNotEmpty
        ? previousWeek.map((e) => e.retention).reduce((a, b) => a + b) /
            previousWeek.length
        : currentRetention;

    // Plateau: no improvement or decline
    final isInPlateau = (currentRetention - previousRetention).abs() < 0.02 ||
        currentRetention < previousRetention;

    // Count days in plateau
    int daysInPlateau = 0;
    double? lastRetention;
    for (final entry in history) {
      if (lastRetention != null) {
        if ((entry.retention - lastRetention).abs() < 0.02) {
          daysInPlateau++;
        } else {
          break;
        }
      }
      lastRetention = entry.retention;
    }

    // Generate suggestions
    final suggestedActions = <PlateauAction>[];
    if (isInPlateau) {
      if (currentRetention < 0.6) {
        suggestedActions.add(PlateauAction.reviewDifficult);
        suggestedActions.add(PlateauAction.reduceLoad);
      } else if (daysInPlateau > 14) {
        suggestedActions.add(PlateauAction.changeApproach);
        suggestedActions.add(PlateauAction.takeBreak);
      } else {
        suggestedActions.add(PlateauAction.addNewCards);
      }
    }

    return PlateauDetection(
      userId: userId,
      isInPlateau: isInPlateau,
      currentRetention: currentRetention,
      previousRetention: previousRetention,
      daysInPlateau: daysInPlateau,
      suggestedActions: suggestedActions,
      detectedAt: now,
    );
  }

  /// UC246-UC247: Get re-engagement message.
  String getReengagementMessage(ChurnRiskLevel level, int daysInactive) {
    switch (level) {
      case ChurnRiskLevel.none:
        return 'Continue assim! Você está no caminho certo.';
      case ChurnRiskLevel.low:
        return 'Que tal uma sessão rápida de 5 minutos?';
      case ChurnRiskLevel.medium:
        return 'Sentimos sua falta! Seus cards estão esperando.';
      case ChurnRiskLevel.high:
        return 'Volte a estudar para não perder seu progresso!';
      case ChurnRiskLevel.critical:
        return 'Faz $daysInactive dias! Uma revisão rápida pode ajudar.';
    }
  }

  /// Get celebration message for milestone.
  String getCelebrationMessage(MilestoneType type, RetentionMilestone milestone) {
    final sessionsText = milestone.totalSessions == 1
        ? '1 sessão'
        : '${milestone.totalSessions} sessões';
    final cardsText = milestone.cardsReviewed == 1
        ? '1 card'
        : '${milestone.cardsReviewed} cards';

    switch (type) {
      case MilestoneType.day7:
        return '${type.celebration}\n\n'
            'Você completou $sessionsText e revisou $cardsText.\n'
            'Streak máximo: ${milestone.longestStreak} dias 🔥';
      case MilestoneType.day30:
        return '${type.celebration}\n\n'
            'Em 30 dias, você fez $sessionsText e revisou $cardsText.\n'
            'Taxa de retenção: ${(milestone.averageRetention * 100).toInt()}% 📈';
      case MilestoneType.day90:
        return '${type.celebration}\n\n'
            'Três meses de dedicação! $sessionsText e $cardsText revisados.\n'
            'Você é um exemplo de consistência! 🏆';
    }
  }

  // ============ Private Methods ============

  Future<void> _saveMilestones(
    String userId,
    List<RetentionMilestone> milestones,
  ) async {
    final prefs = await _preferences;
    await prefs.setString(
      '${_milestonesKey}_$userId',
      jsonEncode(milestones.map((m) => m.toJson()).toList()),
    );
  }

  Future<void> _logActivity(
    String userId,
    int sessions,
    double retention,
  ) async {
    final activity = await _getActivityLog(userId);
    activity.add(ActivityEntry(
      date: DateTime.now(),
      sessions: sessions,
      retention: retention,
    ));

    // Keep only last 90 days
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    final filtered = activity.where((a) => a.date.isAfter(cutoff)).toList();

    final prefs = await _preferences;
    await prefs.setString(
      '${_activityKey}_$userId',
      jsonEncode(filtered.map((a) => a.toJson()).toList()),
    );

    // Also update retention history
    await _updateRetentionHistory(userId, retention);
  }

  Future<List<ActivityEntry>> _getActivityLog(String userId) async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString('${_activityKey}_$userId');

      if (json == null) return [];

      final List<dynamic> list = jsonDecode(json);
      return list
          .map((e) => ActivityEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _updateRetentionHistory(String userId, double retention) async {
    final history = await _getRetentionHistory(userId);
    history.insert(0, RetentionEntry(
      date: DateTime.now(),
      retention: retention,
    ));

    // Keep only last 30 entries
    final trimmed = history.take(30).toList();

    final prefs = await _preferences;
    await prefs.setString(
      '${_retentionHistoryKey}_$userId',
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<RetentionEntry>> _getRetentionHistory(String userId) async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString('${_retentionHistoryKey}_$userId');

      if (json == null) return [];

      final List<dynamic> list = jsonDecode(json);
      return list
          .map((e) => RetentionEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<String> _getReengagementSuggestions(
    ChurnRiskLevel level,
    int daysInactive,
  ) {
    switch (level) {
      case ChurnRiskLevel.none:
        return [];
      case ChurnRiskLevel.low:
        return ['Revise 5 cards para manter o ritmo'];
      case ChurnRiskLevel.medium:
        return [
          'Comece com uma sessão curta de 5 minutos',
          'Revise apenas os cards mais fáceis',
        ];
      case ChurnRiskLevel.high:
        return [
          'Seus cards mais fáceis estão esperando',
          'Uma revisão rápida preserva seu progresso',
          'Defina uma meta pequena: 3 cards',
        ];
      case ChurnRiskLevel.critical:
        return [
          'Reinicie com calma - 1 card por vez',
          'Que tal criar um novo deck do seu interesse?',
          'Configure lembretes para não esquecer',
        ];
    }
  }
}

/// Activity log entry.
class ActivityEntry {
  final DateTime date;
  final int sessions;
  final double retention;

  const ActivityEntry({
    required this.date,
    required this.sessions,
    required this.retention,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'sessions': sessions,
        'retention': retention,
      };

  factory ActivityEntry.fromJson(Map<String, dynamic> json) => ActivityEntry(
        date: DateTime.parse(json['date'] as String),
        sessions: json['sessions'] as int,
        retention: (json['retention'] as num).toDouble(),
      );
}

/// Retention history entry.
class RetentionEntry {
  final DateTime date;
  final double retention;

  const RetentionEntry({
    required this.date,
    required this.retention,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'retention': retention,
      };

  factory RetentionEntry.fromJson(Map<String, dynamic> json) => RetentionEntry(
        date: DateTime.parse(json['date'] as String),
        retention: (json['retention'] as num).toDouble(),
      );
}
