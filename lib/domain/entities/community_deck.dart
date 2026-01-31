import 'package:equatable/equatable.dart';

/// UC172-182: Community deck entity for curated sharing.
///
/// Supports:
/// - UC172: Publishing decks
/// - UC173: Review before publishing
/// - UC174-175: Browsing and importing
/// - UC176-177: Quality evaluation
/// - UC178-180: Moderation
/// - UC181-182: Anti-competition and creator protection

/// Review status for published decks.
enum DeckReviewStatus {
  pending,
  approved,
  needsChanges,
  rejected;

  String get displayName {
    switch (this) {
      case DeckReviewStatus.pending:
        return 'Em analise';
      case DeckReviewStatus.approved:
        return 'Aprovado';
      case DeckReviewStatus.needsChanges:
        return 'Precisa de ajustes';
      case DeckReviewStatus.rejected:
        return 'Recusado';
    }
  }
}

/// Community deck (published version of a deck).
class CommunityDeck extends Equatable {
  final String id;
  final String originalDeckId;
  final String creatorId;
  final String creatorName;
  final String name;
  final String? description;
  final List<String> tags;
  final String category;
  final int cardCount;
  final DeckReviewStatus reviewStatus;
  final String? reviewFeedback;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final int importCount;
  final int helpfulCount;
  final int notHelpfulCount;
  final bool isHighlighted;
  final bool isRemoved;
  final String? removalReason;
  final DateTime publishedAt;
  final DateTime updatedAt;

  const CommunityDeck({
    required this.id,
    required this.originalDeckId,
    required this.creatorId,
    required this.creatorName,
    required this.name,
    this.description,
    this.tags = const [],
    required this.category,
    required this.cardCount,
    this.reviewStatus = DeckReviewStatus.pending,
    this.reviewFeedback,
    this.reviewedAt,
    this.reviewedBy,
    this.importCount = 0,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
    this.isHighlighted = false,
    this.isRemoved = false,
    this.removalReason,
    required this.publishedAt,
    required this.updatedAt,
  });

  /// UC181: No public ranking - just usefulness indicator.
  /// Returns a quality score for internal sorting (not shown publicly).
  double get _qualityScore {
    if (importCount == 0) return 0;
    final totalVotes = helpfulCount + notHelpfulCount;
    if (totalVotes == 0) return 0.5;
    return helpfulCount / totalVotes;
  }

  /// Is this deck available for browsing?
  bool get isAvailable =>
      reviewStatus == DeckReviewStatus.approved && !isRemoved;

  /// UC177: Check if should be highlighted.
  bool get shouldHighlight =>
      isAvailable && _qualityScore >= 0.8 && importCount >= 10;

  CommunityDeck copyWith({
    String? id,
    String? originalDeckId,
    String? creatorId,
    String? creatorName,
    String? name,
    String? description,
    List<String>? tags,
    String? category,
    int? cardCount,
    DeckReviewStatus? reviewStatus,
    String? reviewFeedback,
    DateTime? reviewedAt,
    String? reviewedBy,
    int? importCount,
    int? helpfulCount,
    int? notHelpfulCount,
    bool? isHighlighted,
    bool? isRemoved,
    String? removalReason,
    DateTime? publishedAt,
    DateTime? updatedAt,
  }) {
    return CommunityDeck(
      id: id ?? this.id,
      originalDeckId: originalDeckId ?? this.originalDeckId,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      cardCount: cardCount ?? this.cardCount,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      reviewFeedback: reviewFeedback ?? this.reviewFeedback,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      importCount: importCount ?? this.importCount,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      notHelpfulCount: notHelpfulCount ?? this.notHelpfulCount,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isRemoved: isRemoved ?? this.isRemoved,
      removalReason: removalReason ?? this.removalReason,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        tags,
        category,
        cardCount,
        reviewStatus,
        reviewFeedback,
        reviewedAt,
        reviewedBy,
        importCount,
        helpfulCount,
        notHelpfulCount,
        isHighlighted,
        isRemoved,
        removalReason,
        publishedAt,
        updatedAt,
      ];
}

/// UC174: Categories for community decks.
enum DeckCategory {
  languages,
  science,
  math,
  history,
  geography,
  arts,
  technology,
  business,
  health,
  exams,
  other;

  String get displayName {
    switch (this) {
      case DeckCategory.languages:
        return 'Idiomas';
      case DeckCategory.science:
        return 'Ciencias';
      case DeckCategory.math:
        return 'Matematica';
      case DeckCategory.history:
        return 'Historia';
      case DeckCategory.geography:
        return 'Geografia';
      case DeckCategory.arts:
        return 'Artes';
      case DeckCategory.technology:
        return 'Tecnologia';
      case DeckCategory.business:
        return 'Negocios';
      case DeckCategory.health:
        return 'Saude';
      case DeckCategory.exams:
        return 'Concursos/Vestibulares';
      case DeckCategory.other:
        return 'Outros';
    }
  }

  String get icon {
    switch (this) {
      case DeckCategory.languages:
        return '🌍';
      case DeckCategory.science:
        return '🔬';
      case DeckCategory.math:
        return '📐';
      case DeckCategory.history:
        return '📜';
      case DeckCategory.geography:
        return '🗺️';
      case DeckCategory.arts:
        return '🎨';
      case DeckCategory.technology:
        return '💻';
      case DeckCategory.business:
        return '💼';
      case DeckCategory.health:
        return '⚕️';
      case DeckCategory.exams:
        return '📝';
      case DeckCategory.other:
        return '📚';
    }
  }
}

/// UC176: Usefulness rating (not public likes).
class DeckRating extends Equatable {
  final String id;
  final String deckId;
  final String usedId;
  final bool isHelpful;
  final DateTime ratedAt;

  const DeckRating({
    required this.id,
    required this.deckId,
    required this.usedId,
    required this.isHelpful,
    required this.ratedAt,
  });

  @override
  List<Object?> get props => [id, deckId, usedId, isHelpful, ratedAt];
}

/// UC178: Report for moderation.
class DeckReport extends Equatable {
  final String id;
  final String deckId;
  final String reporterId;
  final ReportReason reason;
  final String? details;
  final ReportStatus status;
  final String? moderatorNotes;
  final String? moderatorId;
  final DateTime reportedAt;
  final DateTime? resolvedAt;

  const DeckReport({
    required this.id,
    required this.deckId,
    required this.reporterId,
    required this.reason,
    this.details,
    this.status = ReportStatus.pending,
    this.moderatorNotes,
    this.moderatorId,
    required this.reportedAt,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [
        id,
        deckId,
        reporterId,
        reason,
        details,
        status,
        moderatorNotes,
        moderatorId,
        reportedAt,
        resolvedAt,
      ];
}

/// Report reasons.
enum ReportReason {
  inappropriate,
  copyright,
  spam,
  lowQuality,
  incorrect,
  other;

  String get displayName {
    switch (this) {
      case ReportReason.inappropriate:
        return 'Conteudo inapropriado';
      case ReportReason.copyright:
        return 'Violacao de direitos autorais';
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.lowQuality:
        return 'Baixa qualidade';
      case ReportReason.incorrect:
        return 'Informacoes incorretas';
      case ReportReason.other:
        return 'Outro';
    }
  }
}

/// Report status.
enum ReportStatus {
  pending,
  investigating,
  resolved,
  dismissed;

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pendente';
      case ReportStatus.investigating:
        return 'Em investigacao';
      case ReportStatus.resolved:
        return 'Resolvido';
      case ReportStatus.dismissed:
        return 'Descartado';
    }
  }
}

/// UC175: Import record.
class DeckImport extends Equatable {
  final String id;
  final String communityDeckId;
  final String userId;
  final String localDeckId;
  final DateTime importedAt;

  const DeckImport({
    required this.id,
    required this.communityDeckId,
    required this.userId,
    required this.localDeckId,
    required this.importedAt,
  });

  @override
  List<Object?> get props => [
        id,
        communityDeckId,
        userId,
        localDeckId,
        importedAt,
      ];
}

/// UC182: Creator protection - copy tracking.
class DeckCopyProtection extends Equatable {
  final String originalDeckId;
  final String creatorId;
  final List<String> importedByUserIds;
  final bool allowCommunitySharing;
  final DateTime createdAt;

  const DeckCopyProtection({
    required this.originalDeckId,
    required this.creatorId,
    this.importedByUserIds = const [],
    this.allowCommunitySharing = false,
    required this.createdAt,
  });

  /// UC182: Check if re-sharing is blocked.
  bool canUserReshare(String userId) {
    // Only original creator can share to community
    return userId == creatorId;
  }

  @override
  List<Object?> get props => [
        originalDeckId,
        creatorId,
        importedByUserIds,
        allowCommunitySharing,
        createdAt,
      ];
}
