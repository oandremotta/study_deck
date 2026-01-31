import 'package:equatable/equatable.dart';

/// UC241-UC247: Retention milestone entity.
///
/// Tracks user retention milestones at 7, 30, and 90 days.
class RetentionMilestone extends Equatable {
  /// Unique identifier.
  final String id;

  /// User ID.
  final String userId;

  /// Milestone type.
  final MilestoneType type;

  /// Days since registration.
  final int daysActive;

  /// Total study sessions in period.
  final int totalSessions;

  /// Total cards reviewed.
  final int cardsReviewed;

  /// Average retention rate.
  final double averageRetention;

  /// Longest streak achieved.
  final int longestStreak;

  /// Whether milestone was achieved.
  final bool achieved;

  /// When the milestone was reached.
  final DateTime? achievedAt;

  /// When the milestone tracking started.
  final DateTime startedAt;

  /// Target date for the milestone.
  final DateTime targetDate;

  const RetentionMilestone({
    required this.id,
    required this.userId,
    required this.type,
    required this.daysActive,
    this.totalSessions = 0,
    this.cardsReviewed = 0,
    this.averageRetention = 0.0,
    this.longestStreak = 0,
    this.achieved = false,
    this.achievedAt,
    required this.startedAt,
    required this.targetDate,
  });

  // ============ Computed Properties ============

  /// Days remaining until milestone.
  int get daysRemaining {
    final remaining = targetDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Progress percentage towards milestone.
  double get progressPercentage {
    final totalDays = type.days;
    return (daysActive / totalDays).clamp(0.0, 1.0);
  }

  /// Whether milestone is at risk (low activity).
  bool get isAtRisk {
    // At risk if progress is behind schedule
    final expectedProgress = DateTime.now().difference(startedAt).inDays / type.days;
    return progressPercentage < expectedProgress * 0.7;
  }

  /// UC244: Check if user is in churn risk.
  bool get isChurnRisk {
    // Churn risk: no activity for 3+ days
    return daysActive > 7 && totalSessions == 0;
  }

  RetentionMilestone copyWith({
    String? id,
    String? userId,
    MilestoneType? type,
    int? daysActive,
    int? totalSessions,
    int? cardsReviewed,
    double? averageRetention,
    int? longestStreak,
    bool? achieved,
    DateTime? achievedAt,
    DateTime? startedAt,
    DateTime? targetDate,
  }) {
    return RetentionMilestone(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      daysActive: daysActive ?? this.daysActive,
      totalSessions: totalSessions ?? this.totalSessions,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      averageRetention: averageRetention ?? this.averageRetention,
      longestStreak: longestStreak ?? this.longestStreak,
      achieved: achieved ?? this.achieved,
      achievedAt: achievedAt ?? this.achievedAt,
      startedAt: startedAt ?? this.startedAt,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  /// Convert to JSON for storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'daysActive': daysActive,
      'totalSessions': totalSessions,
      'cardsReviewed': cardsReviewed,
      'averageRetention': averageRetention,
      'longestStreak': longestStreak,
      'achieved': achieved,
      'achievedAt': achievedAt?.toIso8601String(),
      'startedAt': startedAt.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
    };
  }

  /// Create from JSON.
  factory RetentionMilestone.fromJson(Map<String, dynamic> json) {
    return RetentionMilestone(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: MilestoneType.values.byName(json['type'] as String),
      daysActive: json['daysActive'] as int? ?? 0,
      totalSessions: json['totalSessions'] as int? ?? 0,
      cardsReviewed: json['cardsReviewed'] as int? ?? 0,
      averageRetention: (json['averageRetention'] as num?)?.toDouble() ?? 0.0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      achieved: json['achieved'] as bool? ?? false,
      achievedAt: json['achievedAt'] != null
          ? DateTime.parse(json['achievedAt'] as String)
          : null,
      startedAt: DateTime.parse(json['startedAt'] as String),
      targetDate: DateTime.parse(json['targetDate'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        daysActive,
        totalSessions,
        cardsReviewed,
        averageRetention,
        longestStreak,
        achieved,
        achievedAt,
        startedAt,
        targetDate,
      ];
}

/// UC241-UC243: Milestone types.
enum MilestoneType {
  day7,
  day30,
  day90,
}

extension MilestoneTypeExtension on MilestoneType {
  int get days {
    switch (this) {
      case MilestoneType.day7:
        return 7;
      case MilestoneType.day30:
        return 30;
      case MilestoneType.day90:
        return 90;
    }
  }

  String get title {
    switch (this) {
      case MilestoneType.day7:
        return '7 Dias';
      case MilestoneType.day30:
        return '30 Dias';
      case MilestoneType.day90:
        return '90 Dias';
    }
  }

  String get description {
    switch (this) {
      case MilestoneType.day7:
        return 'Primeira semana de estudos';
      case MilestoneType.day30:
        return 'Um mês de dedicação';
      case MilestoneType.day90:
        return 'Três meses de progresso';
    }
  }

  String get badge {
    switch (this) {
      case MilestoneType.day7:
        return '🌱';
      case MilestoneType.day30:
        return '🌿';
      case MilestoneType.day90:
        return '🌳';
    }
  }

  String get celebration {
    switch (this) {
      case MilestoneType.day7:
        return 'Parabéns! Você completou sua primeira semana!';
      case MilestoneType.day30:
        return 'Incrível! Um mês de estudos consistentes!';
      case MilestoneType.day90:
        return 'Fantástico! Você é um mestre da consistência!';
    }
  }

  /// XP reward for reaching milestone.
  int get xpReward {
    switch (this) {
      case MilestoneType.day7:
        return 100;
      case MilestoneType.day30:
        return 500;
      case MilestoneType.day90:
        return 2000;
    }
  }
}

/// UC245: Learning plateau detection.
class PlateauDetection extends Equatable {
  /// User ID.
  final String userId;

  /// Whether a plateau was detected.
  final bool isInPlateau;

  /// Current retention rate.
  final double currentRetention;

  /// Retention rate 7 days ago.
  final double previousRetention;

  /// Days in plateau (no improvement).
  final int daysInPlateau;

  /// Suggested actions.
  final List<PlateauAction> suggestedActions;

  /// Detection timestamp.
  final DateTime detectedAt;

  const PlateauDetection({
    required this.userId,
    required this.isInPlateau,
    required this.currentRetention,
    required this.previousRetention,
    required this.daysInPlateau,
    required this.suggestedActions,
    required this.detectedAt,
  });

  /// Retention change (positive = improvement).
  double get retentionChange => currentRetention - previousRetention;

  /// Whether retention is declining.
  bool get isDecline => retentionChange < -0.05;

  @override
  List<Object?> get props => [
        userId,
        isInPlateau,
        currentRetention,
        previousRetention,
        daysInPlateau,
        suggestedActions,
        detectedAt,
      ];
}

/// UC245: Actions to overcome plateau.
enum PlateauAction {
  reviewDifficult,
  reduceLoad,
  takeBreak,
  changeApproach,
  addNewCards,
}

extension PlateauActionExtension on PlateauAction {
  String get title {
    switch (this) {
      case PlateauAction.reviewDifficult:
        return 'Revisar cards difíceis';
      case PlateauAction.reduceLoad:
        return 'Reduzir carga diária';
      case PlateauAction.takeBreak:
        return 'Fazer uma pausa';
      case PlateauAction.changeApproach:
        return 'Mudar abordagem';
      case PlateauAction.addNewCards:
        return 'Adicionar novos cards';
    }
  }

  String get description {
    switch (this) {
      case PlateauAction.reviewDifficult:
        return 'Foque nos cards que você erra com frequência.';
      case PlateauAction.reduceLoad:
        return 'Reduza o número de cards novos por dia.';
      case PlateauAction.takeBreak:
        return 'Uma pausa de 1-2 dias pode ajudar a consolidar a memória.';
      case PlateauAction.changeApproach:
        return 'Tente reformular os cards ou adicionar dicas.';
      case PlateauAction.addNewCards:
        return 'Cards novos podem reengajar seu aprendizado.';
    }
  }

  String get icon {
    switch (this) {
      case PlateauAction.reviewDifficult:
        return '🎯';
      case PlateauAction.reduceLoad:
        return '📉';
      case PlateauAction.takeBreak:
        return '☕';
      case PlateauAction.changeApproach:
        return '🔄';
      case PlateauAction.addNewCards:
        return '➕';
    }
  }
}

/// UC246-UC247: Churn risk detection.
class ChurnRiskInfo extends Equatable {
  /// User ID.
  final String userId;

  /// Risk level.
  final ChurnRiskLevel level;

  /// Days since last activity.
  final int daysSinceLastActivity;

  /// User's average activity before (sessions per week).
  final double previousActivityRate;

  /// Suggested re-engagement actions.
  final List<String> suggestions;

  /// Detection timestamp.
  final DateTime detectedAt;

  const ChurnRiskInfo({
    required this.userId,
    required this.level,
    required this.daysSinceLastActivity,
    required this.previousActivityRate,
    required this.suggestions,
    required this.detectedAt,
  });

  @override
  List<Object?> get props => [
        userId,
        level,
        daysSinceLastActivity,
        previousActivityRate,
        suggestions,
        detectedAt,
      ];
}

/// UC246: Churn risk levels.
enum ChurnRiskLevel {
  none,
  low,
  medium,
  high,
  critical,
}

extension ChurnRiskLevelExtension on ChurnRiskLevel {
  String get title {
    switch (this) {
      case ChurnRiskLevel.none:
        return 'Ativo';
      case ChurnRiskLevel.low:
        return 'Risco baixo';
      case ChurnRiskLevel.medium:
        return 'Risco médio';
      case ChurnRiskLevel.high:
        return 'Risco alto';
      case ChurnRiskLevel.critical:
        return 'Risco crítico';
    }
  }

  String get message {
    switch (this) {
      case ChurnRiskLevel.none:
        return 'Continue assim!';
      case ChurnRiskLevel.low:
        return 'Que tal uma sessão rápida hoje?';
      case ChurnRiskLevel.medium:
        return 'Sentimos sua falta! Volte a estudar.';
      case ChurnRiskLevel.high:
        return 'Não perca seu progresso! Estudar 5 minutos ajuda.';
      case ChurnRiskLevel.critical:
        return 'Seu streak pode ser perdido. Uma revisão rápida?';
    }
  }

  int get daysThreshold {
    switch (this) {
      case ChurnRiskLevel.none:
        return 0;
      case ChurnRiskLevel.low:
        return 2;
      case ChurnRiskLevel.medium:
        return 4;
      case ChurnRiskLevel.high:
        return 7;
      case ChurnRiskLevel.critical:
        return 14;
    }
  }
}
