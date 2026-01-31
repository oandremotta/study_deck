import 'package:equatable/equatable.dart';

/// UC227-UC234: Public deck entity for community sharing.
class PublicDeck extends Equatable {
  /// Unique identifier.
  final String id;

  /// Original deck ID (in creator's account).
  final String originalDeckId;

  /// Creator user ID.
  final String creatorId;

  /// Creator display name.
  final String creatorName;

  /// Deck name.
  final String name;

  /// Deck description.
  final String? description;

  /// Category/topic.
  final String category;

  /// Number of cards in the deck.
  final int cardCount;

  /// Number of imports.
  final int importCount;

  /// Number of "useful" ratings.
  final int usefulCount;

  /// Number of "not useful" ratings.
  final int notUsefulCount;

  /// UC231: Whether this deck is featured/recommended.
  final bool isRecommended;

  /// Average retention of users who imported this deck.
  final double? averageRetention;

  /// Sample card fronts (for preview).
  final List<String> sampleCards;

  /// Tags for discovery.
  final List<String> tags;

  /// When the deck was shared.
  final DateTime sharedAt;

  /// When the deck was last updated.
  final DateTime updatedAt;

  /// UC232: Moderation status.
  final ModerationStatus moderationStatus;

  /// UC232: Report count.
  final int reportCount;

  const PublicDeck({
    required this.id,
    required this.originalDeckId,
    required this.creatorId,
    required this.creatorName,
    required this.name,
    this.description,
    required this.category,
    required this.cardCount,
    this.importCount = 0,
    this.usefulCount = 0,
    this.notUsefulCount = 0,
    this.isRecommended = false,
    this.averageRetention,
    this.sampleCards = const [],
    this.tags = const [],
    required this.sharedAt,
    required this.updatedAt,
    this.moderationStatus = ModerationStatus.pending,
    this.reportCount = 0,
  });

  // ============ Computed Properties ============

  /// Usefulness ratio (0-1).
  double get usefulnessRatio {
    final total = usefulCount + notUsefulCount;
    return total > 0 ? usefulCount / total : 0.5;
  }

  /// UC231: Check if deck qualifies for recommendation.
  bool get qualifiesForRecommendation {
    return importCount >= 10 &&
        usefulnessRatio >= 0.7 &&
        (averageRetention == null || averageRetention! >= 0.6) &&
        moderationStatus == ModerationStatus.approved;
  }

  /// Whether deck is visible to users.
  bool get isVisible =>
      moderationStatus == ModerationStatus.approved ||
      moderationStatus == ModerationStatus.pending;

  PublicDeck copyWith({
    String? id,
    String? originalDeckId,
    String? creatorId,
    String? creatorName,
    String? name,
    String? description,
    String? category,
    int? cardCount,
    int? importCount,
    int? usefulCount,
    int? notUsefulCount,
    bool? isRecommended,
    double? averageRetention,
    List<String>? sampleCards,
    List<String>? tags,
    DateTime? sharedAt,
    DateTime? updatedAt,
    ModerationStatus? moderationStatus,
    int? reportCount,
  }) {
    return PublicDeck(
      id: id ?? this.id,
      originalDeckId: originalDeckId ?? this.originalDeckId,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      cardCount: cardCount ?? this.cardCount,
      importCount: importCount ?? this.importCount,
      usefulCount: usefulCount ?? this.usefulCount,
      notUsefulCount: notUsefulCount ?? this.notUsefulCount,
      isRecommended: isRecommended ?? this.isRecommended,
      averageRetention: averageRetention ?? this.averageRetention,
      sampleCards: sampleCards ?? this.sampleCards,
      tags: tags ?? this.tags,
      sharedAt: sharedAt ?? this.sharedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      reportCount: reportCount ?? this.reportCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        originalDeckId,
        creatorId,
        creatorName,
        name,
        description,
        category,
        cardCount,
        importCount,
        usefulCount,
        notUsefulCount,
        isRecommended,
        averageRetention,
        sampleCards,
        tags,
        sharedAt,
        updatedAt,
        moderationStatus,
        reportCount,
      ];
}

/// UC233: Moderation status.
enum ModerationStatus {
  pending,
  approved,
  rejected,
  removed,
}

extension ModerationStatusExtension on ModerationStatus {
  String get displayName {
    switch (this) {
      case ModerationStatus.pending:
        return 'Aguardando moderação';
      case ModerationStatus.approved:
        return 'Aprovado';
      case ModerationStatus.rejected:
        return 'Rejeitado';
      case ModerationStatus.removed:
        return 'Removido';
    }
  }
}

/// UC228: Community category.
class CommunityCategory {
  final String id;
  final String name;
  final String icon;
  final int deckCount;

  const CommunityCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.deckCount = 0,
  });

  static const List<CommunityCategory> defaultCategories = [
    CommunityCategory(id: 'languages', name: 'Idiomas', icon: '🌍'),
    CommunityCategory(id: 'exams', name: 'Concursos', icon: '📝'),
    CommunityCategory(id: 'health', name: 'Saúde', icon: '🏥'),
    CommunityCategory(id: 'tech', name: 'Tecnologia', icon: '💻'),
    CommunityCategory(id: 'science', name: 'Ciências', icon: '🔬'),
    CommunityCategory(id: 'history', name: 'História', icon: '📜'),
    CommunityCategory(id: 'arts', name: 'Artes', icon: '🎨'),
    CommunityCategory(id: 'other', name: 'Outros', icon: '📚'),
  ];
}

/// UC230: Deck rating.
enum DeckRating {
  useful,
  notUseful,
}

extension DeckRatingExtension on DeckRating {
  String get displayName {
    switch (this) {
      case DeckRating.useful:
        return 'Útil';
      case DeckRating.notUseful:
        return 'Não útil';
    }
  }

  String get emoji {
    switch (this) {
      case DeckRating.useful:
        return '👍';
      case DeckRating.notUseful:
        return '👎';
    }
  }
}

/// UC232: Report reason.
enum ReportReason {
  inappropriate,
  spam,
  copyright,
  incorrect,
  other,
}

extension ReportReasonExtension on ReportReason {
  String get displayName {
    switch (this) {
      case ReportReason.inappropriate:
        return 'Conteúdo impróprio';
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.copyright:
        return 'Violação de direitos autorais';
      case ReportReason.incorrect:
        return 'Informações incorretas';
      case ReportReason.other:
        return 'Outro';
    }
  }
}

/// UC232: Report entity.
class DeckReport extends Equatable {
  final String id;
  final String publicDeckId;
  final String reporterUserId;
  final ReportReason reason;
  final String? details;
  final DateTime createdAt;
  final ReportStatus status;

  const DeckReport({
    required this.id,
    required this.publicDeckId,
    required this.reporterUserId,
    required this.reason,
    this.details,
    required this.createdAt,
    this.status = ReportStatus.pending,
  });

  @override
  List<Object?> get props => [
        id,
        publicDeckId,
        reporterUserId,
        reason,
        details,
        createdAt,
        status,
      ];
}

enum ReportStatus {
  pending,
  reviewed,
  actionTaken,
  dismissed,
}
