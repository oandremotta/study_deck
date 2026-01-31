import '../../domain/entities/card.dart';
import 'pedagogical_analytics_service.dart';

/// UC212-UC214: Card quality service.
///
/// Provides:
/// - Quality alerts (UC212)
/// - AI improvement suggestions (UC213)
/// - Excellence badges (UC214)
class CardQualityService {
  final PedagogicalAnalyticsService _analyticsService;

  CardQualityService({PedagogicalAnalyticsService? analyticsService})
      : _analyticsService = analyticsService ?? PedagogicalAnalyticsService();

  /// UC212: Generate quality alerts for a card.
  List<QualityAlert> generateQualityAlerts(Card card) {
    final alerts = <QualityAlert>[];

    // Check for missing pedagogical fields
    if (card.needsMigration) {
      alerts.add(const QualityAlert(
        type: QualityAlertType.missingFields,
        severity: AlertSeverity.warning,
        title: 'Campos pedagógicos ausentes',
        message: 'Este card não possui resumo e frase-chave. Considere adicionar para melhor memorização.',
        actionLabel: 'Adicionar campos',
      ));
    }

    // Check for question quality
    if (card.front.length < 15) {
      alerts.add(const QualityAlert(
        type: QualityAlertType.shortQuestion,
        severity: AlertSeverity.info,
        title: 'Pergunta muito curta',
        message: 'Perguntas mais elaboradas tendem a gerar melhor aprendizado.',
        actionLabel: 'Editar pergunta',
      ));
    }

    // Check for summary quality
    if (card.summary != null && card.summary!.length < 20) {
      alerts.add(const QualityAlert(
        type: QualityAlertType.shortSummary,
        severity: AlertSeverity.info,
        title: 'Resumo muito curto',
        message: 'Um resumo mais detalhado pode ajudar na compreensão.',
        actionLabel: 'Editar resumo',
      ));
    }

    // Check for keyPhrase ending with question mark
    if (card.keyPhrase != null && card.keyPhrase!.endsWith('?')) {
      alerts.add(const QualityAlert(
        type: QualityAlertType.invalidKeyPhrase,
        severity: AlertSeverity.warning,
        title: 'Frase-chave inválida',
        message: 'A frase-chave deve ser uma afirmação, não uma pergunta.',
        actionLabel: 'Corrigir',
      ));
    }

    // Check for duplicate content between summary and question
    if (card.summary != null &&
        _normalizeText(card.summary!) == _normalizeText(card.front)) {
      alerts.add(const QualityAlert(
        type: QualityAlertType.duplicateContent,
        severity: AlertSeverity.warning,
        title: 'Conteúdo duplicado',
        message: 'O resumo não deve ser igual à pergunta.',
        actionLabel: 'Editar resumo',
      ));
    }

    // Check for missing hint on difficult cards
    if (card.hint == null || card.hint!.isEmpty) {
      // This is just informational, not a warning
      alerts.add(const QualityAlert(
        type: QualityAlertType.noHint,
        severity: AlertSeverity.info,
        title: 'Sem dica',
        message: 'Considere adicionar uma dica para ajudar na memorização.',
        actionLabel: 'Adicionar dica',
      ));
    }

    return alerts;
  }

  String _normalizeText(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// UC213: Generate AI improvement suggestions.
  List<ImprovementSuggestion> generateImprovementSuggestions(Card card) {
    final suggestions = <ImprovementSuggestion>[];

    // Suggest AI generation if fields are missing
    if (card.needsMigration) {
      suggestions.add(const ImprovementSuggestion(
        type: ImprovementType.generateFields,
        title: 'Gerar campos com IA',
        description: 'Use IA para gerar automaticamente o resumo e frase-chave.',
        effort: ImprovementEffort.low,
        impact: ImprovementImpact.high,
      ));
    }

    // Suggest reformulation if question is vague
    if (card.front.length < 20 && !card.front.contains('?')) {
      suggestions.add(const ImprovementSuggestion(
        type: ImprovementType.reformulateQuestion,
        title: 'Reformular pergunta',
        description: 'Adicione mais contexto à pergunta para maior clareza.',
        effort: ImprovementEffort.medium,
        impact: ImprovementImpact.medium,
      ));
    }

    // Suggest adding image for visual learning
    if (!card.hasImage) {
      suggestions.add(const ImprovementSuggestion(
        type: ImprovementType.addImage,
        title: 'Adicionar imagem',
        description: 'Imagens ajudam na memorização visual do conceito.',
        effort: ImprovementEffort.medium,
        impact: ImprovementImpact.medium,
      ));
    }

    // Suggest adding audio
    if (!card.hasAudio) {
      suggestions.add(const ImprovementSuggestion(
        type: ImprovementType.addAudio,
        title: 'Adicionar áudio',
        description: 'Áudio TTS pode ajudar no aprendizado auditivo.',
        effort: ImprovementEffort.low,
        impact: ImprovementImpact.medium,
      ));
    }

    // Suggest elaborating explanation
    if (!card.hasExplanation) {
      suggestions.add(const ImprovementSuggestion(
        type: ImprovementType.addExplanation,
        title: 'Adicionar explicação',
        description: 'Uma explicação detalhada ajuda no entendimento profundo.',
        effort: ImprovementEffort.high,
        impact: ImprovementImpact.high,
      ));
    }

    return suggestions;
  }

  /// UC214: Calculate card quality score and badges.
  CardQualityResult calculateQuality(
    Card card, {
    RetentionAnalysis? retention,
    int? totalReviews,
    int? correctReviews,
  }) {
    double score = 0.0;
    final badges = <QualityBadge>[];
    final factors = <QualityFactor>[];

    // Pedagogical completeness (30%)
    double pedagogicalScore = 0.0;
    if (card.summary != null && card.summary!.isNotEmpty) pedagogicalScore += 0.4;
    if (card.keyPhrase != null && card.keyPhrase!.isNotEmpty) pedagogicalScore += 0.4;
    if (card.hasExplanation) pedagogicalScore += 0.2;
    score += pedagogicalScore * 0.3;
    factors.add(QualityFactor(
      name: 'Campos pedagógicos',
      score: pedagogicalScore,
      weight: 0.3,
    ));

    // Content quality (30%)
    double contentScore = 0.0;
    if (card.front.length >= 15) contentScore += 0.3;
    if (card.summary != null && card.summary!.length >= 30) contentScore += 0.3;
    if (card.hint != null && card.hint!.isNotEmpty) contentScore += 0.2;
    if (card.hasImage) contentScore += 0.2;
    score += contentScore * 0.3;
    factors.add(QualityFactor(
      name: 'Qualidade do conteúdo',
      score: contentScore,
      weight: 0.3,
    ));

    // Learning performance (40%)
    double performanceScore = 0.0;
    if (retention != null) {
      performanceScore = retention.score;
    } else if (totalReviews != null && totalReviews > 0 && correctReviews != null) {
      performanceScore = correctReviews / totalReviews;
    }
    score += performanceScore * 0.4;
    factors.add(QualityFactor(
      name: 'Performance de aprendizado',
      score: performanceScore,
      weight: 0.4,
    ));

    // Award badges
    if (pedagogicalScore >= 1.0) {
      badges.add(QualityBadge.complete);
    }
    if (card.hasImage && card.hasAudio) {
      badges.add(QualityBadge.multimedia);
    }
    if (performanceScore >= 0.9) {
      badges.add(QualityBadge.mastered);
    }
    if (score >= 0.95) {
      badges.add(QualityBadge.excellence);
    }
    if (retention?.trend == RetentionTrend.improving) {
      badges.add(QualityBadge.improving);
    }

    // Determine quality level
    QualityLevel level;
    if (score >= 0.9) {
      level = QualityLevel.excellent;
    } else if (score >= 0.7) {
      level = QualityLevel.good;
    } else if (score >= 0.5) {
      level = QualityLevel.acceptable;
    } else if (score >= 0.3) {
      level = QualityLevel.needsImprovement;
    } else {
      level = QualityLevel.poor;
    }

    return CardQualityResult(
      cardId: card.id,
      score: score,
      level: level,
      badges: badges,
      factors: factors,
      alerts: generateQualityAlerts(card),
      suggestions: generateImprovementSuggestions(card),
    );
  }
}

// ============ Quality Models ============

/// UC212: Quality alert.
class QualityAlert {
  final QualityAlertType type;
  final AlertSeverity severity;
  final String title;
  final String message;
  final String? actionLabel;

  const QualityAlert({
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    this.actionLabel,
  });
}

enum QualityAlertType {
  missingFields,
  shortQuestion,
  shortSummary,
  invalidKeyPhrase,
  duplicateContent,
  noHint,
  lowRetention,
  falseMastery,
}

enum AlertSeverity {
  info,
  warning,
  error,
}

extension AlertSeverityExtension on AlertSeverity {
  String get icon {
    switch (this) {
      case AlertSeverity.info:
        return 'ℹ️';
      case AlertSeverity.warning:
        return '⚠️';
      case AlertSeverity.error:
        return '❌';
    }
  }
}

/// UC213: Improvement suggestion.
class ImprovementSuggestion {
  final ImprovementType type;
  final String title;
  final String description;
  final ImprovementEffort effort;
  final ImprovementImpact impact;

  const ImprovementSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.effort,
    required this.impact,
  });
}

enum ImprovementType {
  generateFields,
  reformulateQuestion,
  addImage,
  addAudio,
  addExplanation,
  addHint,
}

enum ImprovementEffort {
  low,
  medium,
  high,
}

extension ImprovementEffortExtension on ImprovementEffort {
  String get displayName {
    switch (this) {
      case ImprovementEffort.low:
        return 'Baixo';
      case ImprovementEffort.medium:
        return 'Médio';
      case ImprovementEffort.high:
        return 'Alto';
    }
  }
}

enum ImprovementImpact {
  low,
  medium,
  high,
}

extension ImprovementImpactExtension on ImprovementImpact {
  String get displayName {
    switch (this) {
      case ImprovementImpact.low:
        return 'Baixo';
      case ImprovementImpact.medium:
        return 'Médio';
      case ImprovementImpact.high:
        return 'Alto';
    }
  }
}

/// UC214: Quality badge.
enum QualityBadge {
  complete,
  multimedia,
  mastered,
  excellence,
  improving,
}

extension QualityBadgeExtension on QualityBadge {
  String get displayName {
    switch (this) {
      case QualityBadge.complete:
        return 'Completo';
      case QualityBadge.multimedia:
        return 'Multimídia';
      case QualityBadge.mastered:
        return 'Dominado';
      case QualityBadge.excellence:
        return 'Excelência';
      case QualityBadge.improving:
        return 'Melhorando';
    }
  }

  String get emoji {
    switch (this) {
      case QualityBadge.complete:
        return '✅';
      case QualityBadge.multimedia:
        return '🎬';
      case QualityBadge.mastered:
        return '🏆';
      case QualityBadge.excellence:
        return '⭐';
      case QualityBadge.improving:
        return '📈';
    }
  }

  String get description {
    switch (this) {
      case QualityBadge.complete:
        return 'Todos os campos pedagógicos preenchidos';
      case QualityBadge.multimedia:
        return 'Card com imagem e áudio';
      case QualityBadge.mastered:
        return 'Performance excelente nas revisões';
      case QualityBadge.excellence:
        return 'Card com qualidade máxima';
      case QualityBadge.improving:
        return 'Performance em melhoria constante';
    }
  }
}

/// Quality level enum.
enum QualityLevel {
  poor,
  needsImprovement,
  acceptable,
  good,
  excellent,
}

extension QualityLevelExtension on QualityLevel {
  String get displayName {
    switch (this) {
      case QualityLevel.poor:
        return 'Ruim';
      case QualityLevel.needsImprovement:
        return 'Precisa melhorar';
      case QualityLevel.acceptable:
        return 'Aceitável';
      case QualityLevel.good:
        return 'Bom';
      case QualityLevel.excellent:
        return 'Excelente';
    }
  }

  String get emoji {
    switch (this) {
      case QualityLevel.poor:
        return '🔴';
      case QualityLevel.needsImprovement:
        return '🟠';
      case QualityLevel.acceptable:
        return '🟡';
      case QualityLevel.good:
        return '🟢';
      case QualityLevel.excellent:
        return '⭐';
    }
  }
}

/// Quality factor used in score calculation.
class QualityFactor {
  final String name;
  final double score;
  final double weight;

  const QualityFactor({
    required this.name,
    required this.score,
    required this.weight,
  });

  double get weightedScore => score * weight;
}

/// UC214: Complete quality result for a card.
class CardQualityResult {
  final String cardId;
  final double score;
  final QualityLevel level;
  final List<QualityBadge> badges;
  final List<QualityFactor> factors;
  final List<QualityAlert> alerts;
  final List<ImprovementSuggestion> suggestions;

  const CardQualityResult({
    required this.cardId,
    required this.score,
    required this.level,
    required this.badges,
    required this.factors,
    required this.alerts,
    required this.suggestions,
  });

  /// Number of critical alerts.
  int get criticalAlertCount =>
      alerts.where((a) => a.severity == AlertSeverity.error).length;

  /// Number of warnings.
  int get warningCount =>
      alerts.where((a) => a.severity == AlertSeverity.warning).length;

  /// Whether this card has excellent quality.
  bool get isExcellent => level == QualityLevel.excellent;
}
