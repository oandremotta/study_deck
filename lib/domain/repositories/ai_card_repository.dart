import '../entities/ai_project.dart';
import '../entities/ai_card_draft.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';

/// Contract for AI card generation operations.
///
/// Handles CRUD for AI projects and drafts (UC127-UC144).
abstract class AiCardRepository {
  // ============ Projects ============

  /// Watches all projects for the current user.
  Stream<List<AiProject>> watchProjects();

  /// Gets all projects for the current user.
  Future<Either<Failure, List<AiProject>>> getProjects();

  /// Gets a project by ID.
  Future<Either<Failure, AiProject?>> getProjectById(String id);

  /// Creates a new AI project.
  Future<Either<Failure, AiProject>> createProject({
    required AiSourceType sourceType,
    String? fileName,
    String? pdfStoragePath,
    String? extractedText,
    String? topic,
    AiGenerationConfig config,
  });

  /// Updates a project.
  Future<Either<Failure, AiProject>> updateProject({
    required String id,
    AiProjectStatus? status,
    String? errorMessage,
    String? extractedText,
    int? generatedCardCount,
    int? approvedCardCount,
    String? targetDeckId,
    DateTime? completedAt,
  });

  /// Deletes a project and its drafts.
  Future<Either<Failure, void>> deleteProject(String id);

  // ============ Drafts ============

  /// Watches drafts for a project.
  Stream<List<AiCardDraft>> watchDraftsByProject(String projectId);

  /// Gets all drafts for a project.
  Future<Either<Failure, List<AiCardDraft>>> getDraftsByProject(String projectId);

  /// Gets a draft by ID.
  Future<Either<Failure, AiCardDraft?>> getDraftById(String id);

  /// Creates drafts in batch.
  Future<Either<Failure, List<AiCardDraft>>> createDrafts({
    required String projectId,
    required List<AiCardDraftInput> drafts,
  });

  /// Updates a draft.
  Future<Either<Failure, AiCardDraft>> updateDraft({
    required String id,
    String? front,
    String? back,
    String? summary,
    String? keyPhrase,
    String? hint,
    DraftReviewStatus? reviewStatus,
    bool? isPotentialDuplicate,
    String? similarCardId,
    bool? needsReview,
  });

  /// Approves all pending drafts in a project.
  Future<Either<Failure, int>> approveAllPendingDrafts(String projectId);

  /// Gets approved drafts for a project.
  Future<Either<Failure, List<AiCardDraft>>> getApprovedDrafts(String projectId);

  /// Imports approved drafts as real cards to a deck.
  ///
  /// Returns the list of created card IDs.
  Future<Either<Failure, List<String>>> importDraftsToDeck({
    required String projectId,
    required String deckId,
  });

  /// Checks for duplicate cards between drafts and existing deck.
  Future<Either<Failure, int>> checkForDuplicates({
    required String projectId,
    required String deckId,
  });
}

/// Input for creating a draft (from AI generation).
class AiCardDraftInput {
  final String front;
  final String back;
  final String? summary;
  final String? keyPhrase;
  final String? hint;
  final List<String> suggestedTags;
  final String difficulty;
  final double confidenceScore;
  final bool needsReview;

  const AiCardDraftInput({
    required this.front,
    required this.back,
    this.summary,
    this.keyPhrase,
    this.hint,
    this.suggestedTags = const [],
    this.difficulty = 'medium',
    this.confidenceScore = 0.8,
    this.needsReview = false,
  });
}
