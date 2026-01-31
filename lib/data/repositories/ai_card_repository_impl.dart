import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../../domain/entities/ai_project.dart';
import '../../domain/entities/ai_card_draft.dart';
import '../../domain/repositories/ai_card_repository.dart';
import '../datasources/local/database.dart';
import '../models/ai_project_model.dart';
import '../models/ai_card_draft_model.dart';

/// Implementation of [AiCardRepository].
///
/// Handles AI card generation CRUD operations (UC127-UC144).
class AiCardRepositoryImpl implements AiCardRepository {
  final AppDatabase _database;
  final Uuid _uuid;

  /// Function to get current user ID. Injected for testability.
  final Future<String?> Function() _getCurrentUserId;

  AiCardRepositoryImpl({
    required AppDatabase database,
    required Future<String?> Function() getCurrentUserId,
    Uuid? uuid,
  })  : _database = database,
        _getCurrentUserId = getCurrentUserId,
        _uuid = uuid ?? const Uuid();

  // ============ Projects ============

  @override
  Stream<List<AiProject>> watchProjects() {
    return _getCurrentUserIdStream().asyncExpand((userId) {
      if (userId == null) return Stream.value(<AiProject>[]);

      return _database.aiCardDao.watchProjects(userId).map((projects) {
        return projects.map((p) => p.toEntity()).toList();
      });
    });
  }

  Stream<String?> _getCurrentUserIdStream() async* {
    yield await _getCurrentUserId();
  }

  @override
  Future<Either<Failure, List<AiProject>>> getProjects() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return const Right([]);
      }

      final projects = await _database.aiCardDao.getProjects(userId);
      return Right(projects.map((p) => p.toEntity()).toList());
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Erro ao buscar projetos: $e'));
    }
  }

  @override
  Future<Either<Failure, AiProject?>> getProjectById(String id) async {
    try {
      final project = await _database.aiCardDao.getProjectById(id);
      return Right(project?.toEntity());
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Erro ao buscar projeto: $e'));
    }
  }

  @override
  Future<Either<Failure, AiProject>> createProject({
    required AiSourceType sourceType,
    String? fileName,
    String? pdfStoragePath,
    String? extractedText,
    String? topic,
    AiGenerationConfig config = const AiGenerationConfig(),
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Left(const LocalStorageFailure(
          message: 'Usuario nao logado',
        ));
      }

      final project = AiProject.create(
        id: _uuid.v4(),
        userId: userId,
        sourceType: sourceType,
        fileName: fileName,
        pdfStoragePath: pdfStoragePath,
        extractedText: extractedText,
        topic: topic,
        config: config,
      );

      await _database.aiCardDao.createProject(project.toCompanion());
      return Right(project);
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Erro ao criar projeto: $e'));
    }
  }

  @override
  Future<Either<Failure, AiProject>> updateProject({
    required String id,
    AiProjectStatus? status,
    String? errorMessage,
    String? extractedText,
    int? generatedCardCount,
    int? approvedCardCount,
    String? targetDeckId,
    DateTime? completedAt,
  }) async {
    try {
      final existing = await _database.aiCardDao.getProjectById(id);
      if (existing == null) {
        return Left(const LocalStorageFailure(
          message: 'Projeto nao encontrado',
          code: 'not-found',
        ));
      }

      final now = DateTime.now();
      final updatedCompanion = AiProjectTableCompanion(
        id: Value(id),
        userId: Value(existing.userId),
        sourceType: Value(existing.sourceType),
        fileName: Value(existing.fileName),
        pdfStoragePath: Value(existing.pdfStoragePath),
        extractedText: Value(extractedText ?? existing.extractedText),
        topic: Value(existing.topic),
        configJson: Value(existing.configJson),
        status: Value(status?.value ?? existing.status),
        errorMessage: Value(errorMessage ?? existing.errorMessage),
        requestedCardCount: Value(existing.requestedCardCount),
        generatedCardCount:
            Value(generatedCardCount ?? existing.generatedCardCount),
        approvedCardCount:
            Value(approvedCardCount ?? existing.approvedCardCount),
        targetDeckId: Value(targetDeckId ?? existing.targetDeckId),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(now),
        completedAt: Value(completedAt ?? existing.completedAt),
      );

      await _database.aiCardDao.updateProject(updatedCompanion);

      final updated = await _database.aiCardDao.getProjectById(id);
      return Right(updated!.toEntity());
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Erro ao atualizar projeto: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(String id) async {
    try {
      await _database.aiCardDao.deleteProject(id);
      return const Right(null);
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Erro ao excluir projeto: $e'));
    }
  }

  // ============ Drafts ============

  @override
  Stream<List<AiCardDraft>> watchDraftsByProject(String projectId) {
    return _database.aiCardDao.watchDraftsByProject(projectId).map((drafts) {
      return drafts.map((d) => d.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<AiCardDraft>>> getDraftsByProject(
      String projectId) async {
    try {
      final drafts = await _database.aiCardDao.getDraftsByProject(projectId);
      return Right(drafts.map((d) => d.toEntity()).toList());
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Erro ao buscar rascunhos: $e'));
    }
  }

  @override
  Future<Either<Failure, AiCardDraft?>> getDraftById(String id) async {
    try {
      final draft = await _database.aiCardDao.getDraftById(id);
      return Right(draft?.toEntity());
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Erro ao buscar rascunho: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AiCardDraft>>> createDrafts({
    required String projectId,
    required List<AiCardDraftInput> drafts,
  }) async {
    try {
      final now = DateTime.now();
      final draftEntities = <AiCardDraft>[];
      final companions = <AiCardDraftTableCompanion>[];

      for (int i = 0; i < drafts.length; i++) {
        final input = drafts[i];
        final draft = AiCardDraft(
          id: _uuid.v4(),
          projectId: projectId,
          front: input.front,
          back: input.back,
          summary: input.summary,
          keyPhrase: input.keyPhrase,
          hint: input.hint,
          suggestedTags: input.suggestedTags,
          difficulty: input.difficulty,
          confidenceScore: input.confidenceScore,
          needsReview: input.needsReview,
          orderIndex: i,
          createdAt: now,
          updatedAt: now,
        );
        draftEntities.add(draft);
        companions.add(draft.toCompanion());
      }

      await _database.aiCardDao.createDrafts(companions);
      return Right(draftEntities);
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Erro ao criar rascunhos: $e'));
    }
  }

  @override
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
  }) async {
    try {
      final existing = await _database.aiCardDao.getDraftById(id);
      if (existing == null) {
        return Left(const LocalStorageFailure(
          message: 'Rascunho nao encontrado',
          code: 'not-found',
        ));
      }

      final now = DateTime.now();
      final updatedCompanion = AiCardDraftTableCompanion(
        id: Value(id),
        projectId: Value(existing.projectId),
        front: Value(front ?? existing.front),
        back: Value(back ?? existing.back),
        summary: Value(summary ?? existing.summary),
        keyPhrase: Value(keyPhrase ?? existing.keyPhrase),
        hint: Value(hint ?? existing.hint),
        suggestedTagsJson: Value(existing.suggestedTagsJson),
        difficulty: Value(existing.difficulty),
        reviewStatus: Value(reviewStatus?.value ?? existing.reviewStatus),
        isPotentialDuplicate:
            Value(isPotentialDuplicate ?? existing.isPotentialDuplicate),
        similarCardId: Value(similarCardId ?? existing.similarCardId),
        confidenceScore: Value(existing.confidenceScore),
        needsReview: Value(needsReview ?? existing.needsReview),
        orderIndex: Value(existing.orderIndex),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(now),
      );

      await _database.aiCardDao.updateDraft(updatedCompanion);

      final updated = await _database.aiCardDao.getDraftById(id);
      return Right(updated!.toEntity());
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Erro ao atualizar rascunho: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> approveAllPendingDrafts(String projectId) async {
    try {
      final count =
          await _database.aiCardDao.approveAllPendingDrafts(projectId);
      return Right(count);
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Erro ao aprovar rascunhos: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AiCardDraft>>> getApprovedDrafts(
      String projectId) async {
    try {
      final drafts = await _database.aiCardDao.getApprovedDrafts(projectId);
      return Right(drafts.map((d) => d.toEntity()).toList());
    } catch (e) {
      return Left(
          LocalStorageFailure(message: 'Erro ao buscar rascunhos aprovados: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> importDraftsToDeck({
    required String projectId,
    required String deckId,
  }) async {
    try {
      final drafts = await _database.aiCardDao.getApprovedDrafts(projectId);
      if (drafts.isEmpty) {
        return const Right([]);
      }

      final cardIds = <String>[];
      final now = DateTime.now();

      for (final draft in drafts) {
        final cardId = _uuid.v4();

        // Create the card using the card table directly
        // Include pedagogical fields (summary, keyPhrase) from draft
        final cardCompanion = CardTableCompanion(
          id: Value(cardId),
          deckId: Value(deckId),
          front: Value(draft.front),
          back: Value(draft.back),
          summary: Value(draft.summary),
          keyPhrase: Value(draft.keyPhrase),
          hint: Value(draft.hint),
          createdAt: Value(now),
          updatedAt: Value(now),
          isSynced: const Value(false),
        );

        await _database.cardDao.createCard(cardCompanion);
        cardIds.add(cardId);
      }

      // Update project status
      await updateProject(
        id: projectId,
        status: AiProjectStatus.completed,
        approvedCardCount: cardIds.length,
        targetDeckId: deckId,
        completedAt: now,
      );

      return Right(cardIds);
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Erro ao importar cards: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> checkForDuplicates({
    required String projectId,
    required String deckId,
  }) async {
    try {
      final drafts = await _database.aiCardDao.getDraftsByProject(projectId);
      final existingCards = await _database.cardDao.getCardsByDeck(deckId);

      int duplicateCount = 0;

      for (final draft in drafts) {
        // Simple similarity check: same front text (case-insensitive)
        final isDuplicate = existingCards.any((card) =>
            card.front.toLowerCase().trim() ==
            draft.front.toLowerCase().trim());

        if (isDuplicate) {
          await _database.aiCardDao.updateDraft(
            AiCardDraftTableCompanion(
              id: Value(draft.id),
              projectId: Value(draft.projectId),
              front: Value(draft.front),
              back: Value(draft.back),
              hint: Value(draft.hint),
              suggestedTagsJson: Value(draft.suggestedTagsJson),
              difficulty: Value(draft.difficulty),
              reviewStatus: Value(draft.reviewStatus),
              isPotentialDuplicate: const Value(true),
              similarCardId: Value(existingCards
                  .firstWhere((c) =>
                      c.front.toLowerCase().trim() ==
                      draft.front.toLowerCase().trim())
                  .id),
              confidenceScore: Value(draft.confidenceScore),
              orderIndex: Value(draft.orderIndex),
              createdAt: Value(draft.createdAt),
              updatedAt: Value(DateTime.now()),
            ),
          );
          duplicateCount++;
        }
      }

      return Right(duplicateCount);
    } catch (e) {
      return Left(
          LocalStorageFailure(message: 'Erro ao verificar duplicatas: $e'));
    }
  }
}
