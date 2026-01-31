import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/ai_project_table.dart';
import '../tables/ai_card_draft_table.dart';

part 'ai_card_dao.g.dart';

/// Data Access Object for AI card generation operations.
@DriftAccessor(tables: [AiProjectTable, AiCardDraftTable])
class AiCardDao extends DatabaseAccessor<AppDatabase> with _$AiCardDaoMixin {
  AiCardDao(super.db);

  // ============ AI Projects ============

  /// Gets all projects for a user.
  Future<List<AiProjectTableData>> getProjects(String userId) async {
    return (select(aiProjectTable)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Gets a project by ID.
  Future<AiProjectTableData?> getProjectById(String id) async {
    return (select(aiProjectTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Creates a new project.
  Future<void> createProject(AiProjectTableCompanion project) async {
    await into(aiProjectTable).insert(project);
  }

  /// Updates a project.
  Future<void> updateProject(AiProjectTableCompanion project) async {
    await (update(aiProjectTable)..where((t) => t.id.equals(project.id.value)))
        .write(project);
  }

  /// Deletes a project and its drafts.
  Future<void> deleteProject(String id) async {
    await (delete(aiCardDraftTable)..where((t) => t.projectId.equals(id))).go();
    await (delete(aiProjectTable)..where((t) => t.id.equals(id))).go();
  }

  /// Watches all projects for a user.
  Stream<List<AiProjectTableData>> watchProjects(String userId) {
    return (select(aiProjectTable)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Gets projects by status.
  Future<List<AiProjectTableData>> getProjectsByStatus(
    String userId,
    String status,
  ) async {
    return (select(aiProjectTable)
          ..where((t) => t.userId.equals(userId) & t.status.equals(status))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  // ============ AI Card Drafts ============

  /// Gets all drafts for a project.
  Future<List<AiCardDraftTableData>> getDraftsByProject(String projectId) async {
    return (select(aiCardDraftTable)
          ..where((t) => t.projectId.equals(projectId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }

  /// Gets a draft by ID.
  Future<AiCardDraftTableData?> getDraftById(String id) async {
    return (select(aiCardDraftTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Creates a new draft.
  Future<void> createDraft(AiCardDraftTableCompanion draft) async {
    await into(aiCardDraftTable).insert(draft);
  }

  /// Creates multiple drafts in batch.
  Future<void> createDrafts(List<AiCardDraftTableCompanion> drafts) async {
    await batch((batch) {
      batch.insertAll(aiCardDraftTable, drafts);
    });
  }

  /// Updates a draft.
  Future<void> updateDraft(AiCardDraftTableCompanion draft) async {
    await (update(aiCardDraftTable)..where((t) => t.id.equals(draft.id.value)))
        .write(draft);
  }

  /// Deletes a draft.
  Future<int> deleteDraft(String id) async {
    return (delete(aiCardDraftTable)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes all drafts for a project.
  Future<int> deleteDraftsByProject(String projectId) async {
    return (delete(aiCardDraftTable)
          ..where((t) => t.projectId.equals(projectId)))
        .go();
  }

  /// Watches drafts for a project.
  Stream<List<AiCardDraftTableData>> watchDraftsByProject(String projectId) {
    return (select(aiCardDraftTable)
          ..where((t) => t.projectId.equals(projectId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .watch();
  }

  /// Gets drafts by status for a project.
  Future<List<AiCardDraftTableData>> getDraftsByStatus(
    String projectId,
    String reviewStatus,
  ) async {
    return (select(aiCardDraftTable)
          ..where((t) =>
              t.projectId.equals(projectId) &
              t.reviewStatus.equals(reviewStatus))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }

  /// Gets approved drafts for a project (approved or edited).
  Future<List<AiCardDraftTableData>> getApprovedDrafts(String projectId) async {
    return (select(aiCardDraftTable)
          ..where((t) =>
              t.projectId.equals(projectId) &
              (t.reviewStatus.equals('approved') |
                  t.reviewStatus.equals('edited')))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }

  /// Updates all pending drafts to approved.
  Future<int> approveAllPendingDrafts(String projectId) async {
    return (update(aiCardDraftTable)
          ..where((t) =>
              t.projectId.equals(projectId) &
              t.reviewStatus.equals('pending')))
        .write(AiCardDraftTableCompanion(
          reviewStatus: const Value('approved'),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Counts drafts by status for a project.
  Future<int> countDraftsByStatus(String projectId, String reviewStatus) async {
    final result = await (select(aiCardDraftTable)
          ..where((t) =>
              t.projectId.equals(projectId) &
              t.reviewStatus.equals(reviewStatus)))
        .get();
    return result.length;
  }

  /// Counts approved drafts for a project.
  Future<int> countApprovedDrafts(String projectId) async {
    final result = await (select(aiCardDraftTable)
          ..where((t) =>
              t.projectId.equals(projectId) &
              (t.reviewStatus.equals('approved') |
                  t.reviewStatus.equals('edited'))))
        .get();
    return result.length;
  }
}
