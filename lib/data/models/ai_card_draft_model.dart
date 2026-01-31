import 'package:drift/drift.dart';

import '../../domain/entities/ai_card_draft.dart';
import '../datasources/local/database.dart';

/// Extension to convert between AiCardDraft entity and database models.
extension AiCardDraftModelExtension on AiCardDraft {
  /// Converts to Drift companion for database operations.
  AiCardDraftTableCompanion toCompanion() {
    return AiCardDraftTableCompanion(
      id: Value(id),
      projectId: Value(projectId),
      front: Value(front),
      back: Value(back),
      summary: Value(summary),
      keyPhrase: Value(keyPhrase),
      hint: Value(hint),
      suggestedTagsJson: Value(AiCardDraft.tagsToJson(suggestedTags)),
      difficulty: Value(difficulty),
      reviewStatus: Value(reviewStatus.value),
      isPotentialDuplicate: Value(isPotentialDuplicate),
      similarCardId: Value(similarCardId),
      confidenceScore: Value(confidenceScore),
      needsReview: Value(needsReview),
      orderIndex: Value(orderIndex),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}

/// Extension to convert database model to domain entity.
extension AiCardDraftTableDataExtension on AiCardDraftTableData {
  /// Converts to domain AiCardDraft entity.
  AiCardDraft toEntity() {
    return AiCardDraft(
      id: id,
      projectId: projectId,
      front: front,
      back: back,
      summary: summary,
      keyPhrase: keyPhrase,
      hint: hint,
      suggestedTags: AiCardDraft.tagsFromJson(suggestedTagsJson),
      difficulty: difficulty,
      reviewStatus: DraftReviewStatusExtension.fromValue(reviewStatus),
      isPotentialDuplicate: isPotentialDuplicate,
      similarCardId: similarCardId,
      confidenceScore: confidenceScore,
      needsReview: needsReview,
      orderIndex: orderIndex,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
