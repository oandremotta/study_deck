import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/study_session_table.dart';
import '../tables/card_srs_table.dart';
import '../tables/card_review_table.dart';
import '../tables/user_stats_table.dart';

part 'study_dao.g.dart';

/// Data Access Object for study-related operations.
@DriftAccessor(tables: [
  StudySessionTable,
  CardSrsTable,
  CardReviewTable,
  UserStatsTable,
])
class StudyDao extends DatabaseAccessor<AppDatabase> with _$StudyDaoMixin {
  StudyDao(super.db);

  // ==================== Study Sessions ====================

  /// Creates a new study session.
  Future<void> createSession(StudySessionTableData session) {
    return into(studySessionTable).insert(session);
  }

  /// Updates a study session.
  Future<void> updateSession(StudySessionTableData session) {
    return update(studySessionTable).replace(session);
  }

  /// Gets a session by ID.
  Future<StudySessionTableData?> getSessionById(String id) {
    return (select(studySessionTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Gets the active (in-progress or paused) session for a user.
  Future<StudySessionTableData?> getActiveSession(String userId) {
    return (select(studySessionTable)
          ..where((t) => t.userId.equals(userId))
          ..where((t) => t.status.isIn(['inProgress', 'paused']))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Gets recent completed sessions for a user.
  Future<List<StudySessionTableData>> getRecentSessions(
    String userId, {
    int limit = 10,
  }) {
    return (select(studySessionTable)
          ..where((t) => t.userId.equals(userId))
          ..where((t) => t.status.equals('completed'))
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
          ..limit(limit))
        .get();
  }

  /// Deletes a session.
  Future<void> deleteSession(String id) {
    return (delete(studySessionTable)..where((t) => t.id.equals(id))).go();
  }

  // ==================== Card SRS ====================

  /// Gets or creates SRS data for a card.
  Future<CardSrsTableData> getOrCreateCardSrs({
    required String cardId,
    required String deckId,
    required String userId,
  }) async {
    final existing = await (select(cardSrsTable)
          ..where((t) => t.cardId.equals(cardId) & t.userId.equals(userId)))
        .getSingleOrNull();

    if (existing != null) return existing;

    final newSrs = CardSrsTableCompanion.insert(
      cardId: cardId,
      deckId: deckId,
      userId: userId,
      state: 'newCard',
    );
    await into(cardSrsTable).insert(newSrs);

    return (select(cardSrsTable)
          ..where((t) => t.cardId.equals(cardId) & t.userId.equals(userId)))
        .getSingle();
  }

  /// Updates SRS data for a card.
  Future<void> updateCardSrs(CardSrsTableData srs) {
    return update(cardSrsTable).replace(srs);
  }

  /// Gets all due cards for a user (across all decks or specific deck).
  Future<List<CardSrsTableData>> getDueCards({
    required String userId,
    String? deckId,
    int? limit,
  }) {
    final now = DateTime.now();
    var query = select(cardSrsTable)
      ..where((t) => t.userId.equals(userId))
      ..where((t) =>
          t.nextReviewAt.isNull() | t.nextReviewAt.isSmallerOrEqualValue(now))
      ..orderBy([
        // Prioritize: overdue cards first, then by next review date
        (t) => OrderingTerm.asc(t.nextReviewAt),
      ]);

    if (deckId != null) {
      query = query..where((t) => t.deckId.equals(deckId));
    }

    if (limit != null) {
      query = query..limit(limit);
    }

    return query.get();
  }

  /// Gets new cards (never reviewed) for a deck.
  Future<List<CardSrsTableData>> getNewCards({
    required String userId,
    String? deckId,
    int? limit,
  }) {
    var query = select(cardSrsTable)
      ..where((t) => t.userId.equals(userId))
      ..where((t) => t.state.equals('newCard'));

    if (deckId != null) {
      query = query..where((t) => t.deckId.equals(deckId));
    }

    if (limit != null) {
      query = query..limit(limit);
    }

    return query.get();
  }

  /// Gets the next scheduled review time for a user.
  /// Returns null if there are no future reviews scheduled.
  Future<DateTime?> getNextReviewTime({
    required String userId,
    String? deckId,
  }) async {
    final now = DateTime.now();
    var query = select(cardSrsTable)
      ..where((t) => t.userId.equals(userId))
      ..where((t) => t.nextReviewAt.isBiggerThanValue(now))
      ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)])
      ..limit(1);

    if (deckId != null) {
      query = query..where((t) => t.deckId.equals(deckId));
    }

    final result = await query.getSingleOrNull();
    return result?.nextReviewAt;
  }

  /// Gets cards with recent errors for a user.
  Future<List<String>> getRecentErrorCardIds({
    required String userId,
    String? deckId,
    int days = 7,
    int? limit,
  }) async {
    final since = DateTime.now().subtract(Duration(days: days));

    var query = selectOnly(cardReviewTable)
      ..addColumns([cardReviewTable.cardId])
      ..where(cardReviewTable.userId.equals(userId))
      ..where(cardReviewTable.result.equals('wrong'))
      ..where(cardReviewTable.reviewedAt.isBiggerOrEqualValue(since))
      ..groupBy([cardReviewTable.cardId])
      ..orderBy([OrderingTerm.desc(cardReviewTable.reviewedAt)]);

    if (limit != null) {
      query = query..limit(limit);
    }

    final results = await query.get();
    return results.map((row) => row.read(cardReviewTable.cardId)!).toList();
  }

  /// Gets SRS statistics for a deck.
  Future<DeckSrsStats> getDeckSrsStats({
    required String userId,
    required String deckId,
  }) async {
    final now = DateTime.now();

    final allCards = await (select(cardSrsTable)
          ..where((t) => t.userId.equals(userId) & t.deckId.equals(deckId)))
        .get();

    int newCount = 0;
    int learningCount = 0;
    int reviewCount = 0;
    int dueCount = 0;

    for (final card in allCards) {
      switch (card.state) {
        case 'newCard':
          newCount++;
          dueCount++;
          break;
        case 'learning':
          learningCount++;
          if (card.nextReviewAt == null || card.nextReviewAt!.isBefore(now)) {
            dueCount++;
          }
          break;
        case 'review':
          reviewCount++;
          if (card.nextReviewAt == null || card.nextReviewAt!.isBefore(now)) {
            dueCount++;
          }
          break;
      }
    }

    return DeckSrsStats(
      totalCards: allCards.length,
      newCount: newCount,
      learningCount: learningCount,
      reviewCount: reviewCount,
      dueCount: dueCount,
    );
  }

  // ==================== Card Reviews ====================

  /// Records a card review.
  Future<void> recordReview(CardReviewTableData review) {
    return into(cardReviewTable).insert(review);
  }

  /// Gets review history for a card.
  Future<List<CardReviewTableData>> getCardReviewHistory(
    String cardId, {
    int limit = 10,
  }) {
    return (select(cardReviewTable)
          ..where((t) => t.cardId.equals(cardId))
          ..orderBy([(t) => OrderingTerm.desc(t.reviewedAt)])
          ..limit(limit))
        .get();
  }

  // ==================== User Stats ====================

  /// Gets or creates user stats.
  Future<UserStatsTableData> getOrCreateUserStats(String userId) async {
    final existing = await (select(userStatsTable)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();

    if (existing != null) {
      // Check if we need to reset daily counters
      final today = DateTime.now();
      if (existing.todayResetDate != null &&
          !_isSameDay(existing.todayResetDate!, today)) {
        final updated = existing.copyWith(
          todayCards: 0,
          todayMinutes: 0,
          todayResetDate: Value(today),
        );
        await update(userStatsTable).replace(updated);
        return updated;
      }
      return existing;
    }

    final newStats = UserStatsTableCompanion.insert(
      userId: userId,
      todayResetDate: Value(DateTime.now()),
    );
    await into(userStatsTable).insert(newStats);

    return (select(userStatsTable)..where((t) => t.userId.equals(userId)))
        .getSingle();
  }

  /// Updates user stats.
  Future<void> updateUserStats(UserStatsTableData stats) {
    return update(userStatsTable).replace(stats);
  }

  /// Watches user stats for reactive updates.
  Stream<UserStatsTableData?> watchUserStats(String userId) {
    return (select(userStatsTable)..where((t) => t.userId.equals(userId)))
        .watchSingleOrNull();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Statistics for SRS state of a deck.
class DeckSrsStats {
  final int totalCards;
  final int newCount;
  final int learningCount;
  final int reviewCount;
  final int dueCount;

  DeckSrsStats({
    required this.totalCards,
    required this.newCount,
    required this.learningCount,
    required this.reviewCount,
    required this.dueCount,
  });
}
