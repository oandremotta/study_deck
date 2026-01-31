import 'dart:math' as math;

import '../../domain/entities/card.dart';

/// UC206-UC211: Pedagogical analytics service.
///
/// Provides:
/// - Retention calculation (UC206)
/// - False mastery detection (UC207)
/// - Reinforcement suggestions (UC208)
/// - Learning patterns analysis (UC209-UC211)
class PedagogicalAnalyticsService {
  /// UC206: Calculate retention score for a card based on review history.
  ///
  /// Returns a value between 0.0 (forgotten) and 1.0 (fully retained).
  RetentionAnalysis calculateRetention({
    required int totalReviews,
    required int correctReviews,
    required int consecutiveCorrect,
    required DateTime? lastReviewDate,
    required double currentEaseFactor,
  }) {
    if (totalReviews == 0) {
      return const RetentionAnalysis(
        score: 0.0,
        status: RetentionStatus.notStudied,
        trend: RetentionTrend.neutral,
        message: 'Card ainda não foi estudado.',
      );
    }

    // Base retention from accuracy
    final accuracy = correctReviews / totalReviews;

    // Time decay factor (how long since last review)
    double timeDecay = 1.0;
    if (lastReviewDate != null) {
      final daysSinceReview = DateTime.now().difference(lastReviewDate).inDays;
      // Exponential decay based on spaced repetition theory
      timeDecay = math.exp(-0.1 * daysSinceReview / (currentEaseFactor * 2));
      timeDecay = timeDecay.clamp(0.0, 1.0);
    }

    // Streak bonus for consecutive correct answers
    final streakBonus = math.min(consecutiveCorrect * 0.05, 0.2);

    // Calculate final retention score
    final retentionScore = ((accuracy * 0.6) + (timeDecay * 0.3) + streakBonus).clamp(0.0, 1.0);

    // Determine trend based on recent performance
    RetentionTrend trend;
    if (consecutiveCorrect >= 3) {
      trend = RetentionTrend.improving;
    } else if (consecutiveCorrect == 0 && totalReviews > 3) {
      trend = RetentionTrend.declining;
    } else {
      trend = RetentionTrend.stable;
    }

    // Determine status and message
    RetentionStatus status;
    String message;
    if (retentionScore >= 0.9) {
      status = RetentionStatus.excellent;
      message = 'Excelente retenção! Continue assim.';
    } else if (retentionScore >= 0.7) {
      status = RetentionStatus.good;
      message = 'Boa retenção. Revise regularmente.';
    } else if (retentionScore >= 0.5) {
      status = RetentionStatus.moderate;
      message = 'Retenção moderada. Considere revisar mais.';
    } else if (retentionScore >= 0.3) {
      status = RetentionStatus.weak;
      message = 'Retenção fraca. Reforce este conceito.';
    } else {
      status = RetentionStatus.critical;
      message = 'Retenção crítica! Revise urgentemente.';
    }

    return RetentionAnalysis(
      score: retentionScore,
      status: status,
      trend: trend,
      message: message,
      accuracy: accuracy,
      timeDecayFactor: timeDecay,
      streakBonus: streakBonus,
    );
  }

  /// UC207: Detect false mastery (cards that seem learned but aren't).
  ///
  /// False mastery occurs when:
  /// - High ease factor but recent failures
  /// - Long intervals but inconsistent performance
  /// - Quick "correct" responses that may be guessing
  FalseMasteryAnalysis detectFalseMastery({
    required int totalReviews,
    required int correctReviews,
    required int recentFailures, // failures in last 5 reviews
    required double easeFactor,
    required int currentInterval,
    required List<int> responseTimesMs, // last 5 response times
  }) {
    if (totalReviews < 5) {
      return const FalseMasteryAnalysis(
        isFalseMastery: false,
        confidence: 0.0,
        reason: null,
        suggestions: [],
      );
    }

    final reasons = <String>[];
    double falseMasteryScore = 0.0;

    // Check for recent failures despite high ease factor
    if (easeFactor > 2.3 && recentFailures >= 2) {
      falseMasteryScore += 0.4;
      reasons.add('Falhas recentes apesar de intervalo longo');
    }

    // Check for inconsistent performance
    final accuracy = correctReviews / totalReviews;
    final recentAccuracy = (5 - recentFailures) / 5;
    if (accuracy > 0.8 && recentAccuracy < 0.6) {
      falseMasteryScore += 0.3;
      reasons.add('Performance recente inconsistente');
    }

    // Check for suspiciously fast responses (possible guessing)
    if (responseTimesMs.isNotEmpty) {
      final avgResponseTime = responseTimesMs.reduce((a, b) => a + b) / responseTimesMs.length;
      if (avgResponseTime < 1500 && accuracy < 0.9) {
        falseMasteryScore += 0.2;
        reasons.add('Respostas muito rápidas (possível adivinhação)');
      }
    }

    // Check for long interval with moderate accuracy
    if (currentInterval > 30 && accuracy < 0.75) {
      falseMasteryScore += 0.2;
      reasons.add('Intervalo longo com acurácia moderada');
    }

    final isFalseMastery = falseMasteryScore >= 0.5;
    final suggestions = <String>[];

    if (isFalseMastery) {
      suggestions.add('Revise a frase-chave deste card');
      suggestions.add('Tente explicar o conceito em voz alta');
      if (recentFailures >= 2) {
        suggestions.add('Considere reformular a pergunta ou resposta');
      }
    }

    return FalseMasteryAnalysis(
      isFalseMastery: isFalseMastery,
      confidence: falseMasteryScore.clamp(0.0, 1.0),
      reason: reasons.isNotEmpty ? reasons.join('; ') : null,
      suggestions: suggestions,
    );
  }

  /// UC208: Generate reinforcement suggestions for a card.
  ReinforcementSuggestions generateReinforcementSuggestions({
    required Card card,
    required RetentionAnalysis retention,
    required FalseMasteryAnalysis falseMastery,
    required int totalReviews,
    required int failureCount,
  }) {
    final suggestions = <ReinforcementAction>[];
    final priority = _calculatePriority(retention, falseMastery, failureCount);

    // Suggest based on retention status
    if (retention.status == RetentionStatus.critical ||
        retention.status == RetentionStatus.weak) {
      suggestions.add(ReinforcementAction(
        type: ReinforcementType.review,
        title: 'Revisar agora',
        description: 'Este card precisa de reforço imediato.',
        priority: 1,
      ));
    }

    // Suggest if false mastery detected
    if (falseMastery.isFalseMastery) {
      suggestions.add(ReinforcementAction(
        type: ReinforcementType.deepReview,
        title: 'Revisão profunda',
        description: 'Possível falsa memorização detectada. Revise o conceito.',
        priority: 2,
      ));
    }

    // Suggest if card lacks pedagogical fields
    if (card.needsMigration) {
      suggestions.add(ReinforcementAction(
        type: ReinforcementType.enhance,
        title: 'Melhorar card',
        description: 'Adicione resumo e frase-chave para melhor memorização.',
        priority: 3,
      ));
    }

    // Suggest connection with other cards
    if (failureCount > 3 && retention.score < 0.5) {
      suggestions.add(ReinforcementAction(
        type: ReinforcementType.connect,
        title: 'Conectar conceitos',
        description: 'Tente relacionar este conceito com outros já dominados.',
        priority: 4,
      ));
    }

    // Suggest spaced practice
    if (retention.trend == RetentionTrend.declining) {
      suggestions.add(ReinforcementAction(
        type: ReinforcementType.spacedPractice,
        title: 'Prática espaçada',
        description: 'Revise em intervalos menores até estabilizar.',
        priority: 5,
      ));
    }

    return ReinforcementSuggestions(
      cardId: card.id,
      priority: priority,
      actions: suggestions,
      needsAttention: priority <= 2,
    );
  }

  int _calculatePriority(
    RetentionAnalysis retention,
    FalseMasteryAnalysis falseMastery,
    int failureCount,
  ) {
    if (retention.status == RetentionStatus.critical) return 1;
    if (falseMastery.isFalseMastery && falseMastery.confidence > 0.7) return 1;
    if (retention.status == RetentionStatus.weak) return 2;
    if (falseMastery.isFalseMastery) return 2;
    if (failureCount > 5) return 3;
    if (retention.status == RetentionStatus.moderate) return 4;
    return 5;
  }

  /// UC209: Calculate deck-level learning analytics.
  DeckLearningAnalytics calculateDeckAnalytics({
    required List<CardAnalytics> cardAnalytics,
    required int totalCards,
    required int studiedCards,
  }) {
    if (cardAnalytics.isEmpty) {
      return DeckLearningAnalytics(
        totalCards: totalCards,
        studiedCards: studiedCards,
        masteredCards: 0,
        learningCards: 0,
        strugglingCards: 0,
        notStartedCards: totalCards - studiedCards,
        averageRetention: 0.0,
        falseMasteryCount: 0,
        needsAttentionCount: 0,
        estimatedMasteryDate: null,
        weakestCards: [],
        strongestCards: [],
      );
    }

    // Categorize cards
    int masteredCards = 0;
    int learningCards = 0;
    int strugglingCards = 0;
    int falseMasteryCount = 0;
    int needsAttentionCount = 0;
    double totalRetention = 0.0;

    final weakCards = <CardAnalytics>[];
    final strongCards = <CardAnalytics>[];

    for (final analytics in cardAnalytics) {
      totalRetention += analytics.retention.score;

      if (analytics.retention.score >= 0.9) {
        masteredCards++;
        strongCards.add(analytics);
      } else if (analytics.retention.score >= 0.5) {
        learningCards++;
      } else {
        strugglingCards++;
        weakCards.add(analytics);
      }

      if (analytics.falseMastery.isFalseMastery) {
        falseMasteryCount++;
      }

      if (analytics.reinforcement.needsAttention) {
        needsAttentionCount++;
      }
    }

    // Sort and limit weak/strong cards
    weakCards.sort((a, b) => a.retention.score.compareTo(b.retention.score));
    strongCards.sort((a, b) => b.retention.score.compareTo(a.retention.score));

    // Estimate mastery date based on current progress
    DateTime? estimatedMasteryDate;
    if (studiedCards > 0 && masteredCards < totalCards) {
      final cardsRemaining = totalCards - masteredCards;
      final avgDaysPerCard = 14; // Estimate 2 weeks to master each card
      estimatedMasteryDate = DateTime.now().add(
        Duration(days: cardsRemaining * avgDaysPerCard ~/ math.max(1, masteredCards)),
      );
    }

    return DeckLearningAnalytics(
      totalCards: totalCards,
      studiedCards: studiedCards,
      masteredCards: masteredCards,
      learningCards: learningCards,
      strugglingCards: strugglingCards,
      notStartedCards: totalCards - studiedCards,
      averageRetention: cardAnalytics.isNotEmpty ? totalRetention / cardAnalytics.length : 0.0,
      falseMasteryCount: falseMasteryCount,
      needsAttentionCount: needsAttentionCount,
      estimatedMasteryDate: estimatedMasteryDate,
      weakestCards: weakCards.take(5).toList(),
      strongestCards: strongCards.take(5).toList(),
    );
  }
}

// ============ Analytics Models ============

/// UC206: Retention analysis result.
class RetentionAnalysis {
  final double score;
  final RetentionStatus status;
  final RetentionTrend trend;
  final String message;
  final double? accuracy;
  final double? timeDecayFactor;
  final double? streakBonus;

  const RetentionAnalysis({
    required this.score,
    required this.status,
    required this.trend,
    required this.message,
    this.accuracy,
    this.timeDecayFactor,
    this.streakBonus,
  });
}

enum RetentionStatus {
  notStudied,
  critical,
  weak,
  moderate,
  good,
  excellent,
}

extension RetentionStatusExtension on RetentionStatus {
  String get displayName {
    switch (this) {
      case RetentionStatus.notStudied:
        return 'Não estudado';
      case RetentionStatus.critical:
        return 'Crítico';
      case RetentionStatus.weak:
        return 'Fraco';
      case RetentionStatus.moderate:
        return 'Moderado';
      case RetentionStatus.good:
        return 'Bom';
      case RetentionStatus.excellent:
        return 'Excelente';
    }
  }

  String get emoji {
    switch (this) {
      case RetentionStatus.notStudied:
        return '⏸️';
      case RetentionStatus.critical:
        return '🔴';
      case RetentionStatus.weak:
        return '🟠';
      case RetentionStatus.moderate:
        return '🟡';
      case RetentionStatus.good:
        return '🟢';
      case RetentionStatus.excellent:
        return '⭐';
    }
  }
}

enum RetentionTrend {
  improving,
  stable,
  declining,
  neutral,
}

extension RetentionTrendExtension on RetentionTrend {
  String get displayName {
    switch (this) {
      case RetentionTrend.improving:
        return 'Melhorando';
      case RetentionTrend.stable:
        return 'Estável';
      case RetentionTrend.declining:
        return 'Declinando';
      case RetentionTrend.neutral:
        return 'Neutro';
    }
  }

  String get icon {
    switch (this) {
      case RetentionTrend.improving:
        return '↗️';
      case RetentionTrend.stable:
        return '➡️';
      case RetentionTrend.declining:
        return '↘️';
      case RetentionTrend.neutral:
        return '•';
    }
  }
}

/// UC207: False mastery analysis result.
class FalseMasteryAnalysis {
  final bool isFalseMastery;
  final double confidence;
  final String? reason;
  final List<String> suggestions;

  const FalseMasteryAnalysis({
    required this.isFalseMastery,
    required this.confidence,
    this.reason,
    required this.suggestions,
  });
}

/// UC208: Reinforcement suggestions.
class ReinforcementSuggestions {
  final String cardId;
  final int priority; // 1 = highest priority
  final List<ReinforcementAction> actions;
  final bool needsAttention;

  const ReinforcementSuggestions({
    required this.cardId,
    required this.priority,
    required this.actions,
    required this.needsAttention,
  });
}

class ReinforcementAction {
  final ReinforcementType type;
  final String title;
  final String description;
  final int priority;

  const ReinforcementAction({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
  });
}

enum ReinforcementType {
  review,
  deepReview,
  enhance,
  connect,
  spacedPractice,
}

/// UC209-211: Combined analytics for a single card.
class CardAnalytics {
  final String cardId;
  final RetentionAnalysis retention;
  final FalseMasteryAnalysis falseMastery;
  final ReinforcementSuggestions reinforcement;

  const CardAnalytics({
    required this.cardId,
    required this.retention,
    required this.falseMastery,
    required this.reinforcement,
  });
}

/// UC209-211: Deck-level learning analytics.
class DeckLearningAnalytics {
  final int totalCards;
  final int studiedCards;
  final int masteredCards;
  final int learningCards;
  final int strugglingCards;
  final int notStartedCards;
  final double averageRetention;
  final int falseMasteryCount;
  final int needsAttentionCount;
  final DateTime? estimatedMasteryDate;
  final List<CardAnalytics> weakestCards;
  final List<CardAnalytics> strongestCards;

  const DeckLearningAnalytics({
    required this.totalCards,
    required this.studiedCards,
    required this.masteredCards,
    required this.learningCards,
    required this.strugglingCards,
    required this.notStartedCards,
    required this.averageRetention,
    required this.falseMasteryCount,
    required this.needsAttentionCount,
    this.estimatedMasteryDate,
    required this.weakestCards,
    required this.strongestCards,
  });

  /// Percentage of cards mastered.
  double get masteryPercentage => totalCards > 0 ? masteredCards / totalCards : 0.0;

  /// Percentage of cards studied.
  double get studyPercentage => totalCards > 0 ? studiedCards / totalCards : 0.0;
}
