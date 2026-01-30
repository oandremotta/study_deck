import 'package:uuid/uuid.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../../domain/entities/card.dart';
import '../../domain/entities/card_review.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/study_repository.dart';
import '../datasources/local/database.dart';
import '../datasources/local/daos/study_dao.dart';

/// Implementation of [StudyRepository] using Drift database.
class StudyRepositoryImpl implements StudyRepository {
  final AppDatabase _database;
  final Future<String?> Function() _getCurrentUserId;
  final _uuid = const Uuid();

  StudyRepositoryImpl({
    required AppDatabase database,
    required Future<String?> Function() getCurrentUserId,
  })  : _database = database,
        _getCurrentUserId = getCurrentUserId;

  StudyDao get _studyDao => _database.studyDao;

  // ==================== Study Sessions ====================

  @override
  Future<Either<Failure, StudySession>> createSession({
    String? deckId,
    required StudyMode mode,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      // Get queue to determine total cards
      final queueResult = await getStudyQueue(
        deckId: deckId,
        mode: mode,
        limit: mode == StudyMode.turbo ? 12 : null,
      );

      return queueResult.fold(
        (failure) => Left(failure),
        (queue) async {
          if (queue.isEmpty) {
            return Left(LocalStorageFailure(message: 'No cards to study'));
          }

          final sessionId = _uuid.v4();
          final session = StudySession.create(
            id: sessionId,
            deckId: deckId,
            userId: userId,
            mode: mode,
            totalCards: queue.length,
          );

          final data = _sessionToData(session);
          await _studyDao.createSession(data);

          return Right(session);
        },
      );
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudySession?>> getActiveSession() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return const Right(null);
      }

      final data = await _studyDao.getActiveSession(userId);
      if (data == null) {
        return const Right(null);
      }

      return Right(_dataToSession(data));
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudySession>> updateSession(StudySession session) async {
    try {
      final data = _sessionToData(session);
      await _studyDao.updateSession(data);
      return Right(session);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudySession>> pauseSession(String sessionId) async {
    try {
      final data = await _studyDao.getSessionById(sessionId);
      if (data == null) {
        return Left(LocalStorageFailure(message: 'Session not found'));
      }

      final session = _dataToSession(data).pause();
      await _studyDao.updateSession(_sessionToData(session));
      return Right(session);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudySession>> resumeSession(String sessionId) async {
    try {
      final data = await _studyDao.getSessionById(sessionId);
      if (data == null) {
        return Left(LocalStorageFailure(message: 'Session not found'));
      }

      final session = _dataToSession(data).resume();
      await _studyDao.updateSession(_sessionToData(session));
      return Right(session);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudySession>> completeSession(String sessionId) async {
    try {
      final data = await _studyDao.getSessionById(sessionId);
      if (data == null) {
        return Left(LocalStorageFailure(message: 'Session not found'));
      }

      final session = _dataToSession(data).complete();
      await _studyDao.updateSession(_sessionToData(session));

      // Update user stats
      final userId = await _getCurrentUserId();
      if (userId != null) {
        final statsData = await _studyDao.getOrCreateUserStats(userId);
        final stats = _dataToUserStats(statsData);
        final updatedStats = stats.recordSession(
          cardsReviewed: session.reviewedCards,
          xpEarned: session.xpEarned,
          sessionTime: session.totalTime,
        );
        await _studyDao.updateUserStats(_userStatsToData(updatedStats));
      }

      return Right(session);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudySession>>> getRecentSessions({int limit = 10}) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return const Right([]);
      }

      final dataList = await _studyDao.getRecentSessions(userId, limit: limit);
      return Right(dataList.map(_dataToSession).toList());
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  // ==================== Study Queue ====================

  @override
  Future<Either<Failure, List<Card>>> getStudyQueue({
    String? deckId,
    required StudyMode mode,
    int? limit,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return const Right([]);
      }

      List<String> cardIds = [];

      switch (mode) {
        case StudyMode.studyNow:
        case StudyMode.newAndReviews:
          // Get due cards first
          final dueCards = await _studyDao.getDueCards(
            userId: userId,
            deckId: deckId,
          );
          cardIds.addAll(dueCards.map((c) => c.cardId));

          // Add new cards if needed
          if (mode == StudyMode.newAndReviews || cardIds.length < (limit ?? 20)) {
            final newCards = await _studyDao.getNewCards(
              userId: userId,
              deckId: deckId,
              limit: limit != null ? limit - cardIds.length : 10,
            );
            cardIds.addAll(newCards.map((c) => c.cardId));
          }
          break;

        case StudyMode.reviewsToday:
          final dueCards = await _studyDao.getDueCards(
            userId: userId,
            deckId: deckId,
            limit: limit,
          );
          cardIds = dueCards.map((c) => c.cardId).toList();
          break;

        case StudyMode.errorsOnly:
          cardIds = await _studyDao.getRecentErrorCardIds(
            userId: userId,
            deckId: deckId,
            limit: limit,
          );
          break;

        case StudyMode.turbo:
          // Quick session - mix of due and new, limited to ~12 cards
          final dueCards = await _studyDao.getDueCards(
            userId: userId,
            deckId: deckId,
            limit: 8,
          );
          cardIds.addAll(dueCards.map((c) => c.cardId));

          if (cardIds.length < 12) {
            final newCards = await _studyDao.getNewCards(
              userId: userId,
              deckId: deckId,
              limit: 12 - cardIds.length,
            );
            cardIds.addAll(newCards.map((c) => c.cardId));
          }
          break;
      }

      if (cardIds.isEmpty) {
        return const Right([]);
      }

      // Fetch actual cards
      final cards = await _database.cardDao.getCardsByIds(cardIds);

      // Apply limit if specified
      if (limit != null && cards.length > limit) {
        return Right(cards.take(limit).map(_cardDataToEntity).toList());
      }

      return Right(cards.map(_cardDataToEntity).toList());
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Card>>> getErrorCards({
    String? deckId,
    int days = 7,
    int? limit,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return const Right([]);
      }

      final cardIds = await _studyDao.getRecentErrorCardIds(
        userId: userId,
        deckId: deckId,
        days: days,
        limit: limit,
      );

      if (cardIds.isEmpty) {
        return const Right([]);
      }

      final cards = await _database.cardDao.getCardsByIds(cardIds);
      return Right(cards.map(_cardDataToEntity).toList());
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  // ==================== Card Reviews ====================

  @override
  Future<Either<Failure, CardSRS>> recordReview({
    required String sessionId,
    required String cardId,
    required ReviewResult result,
    required Duration responseTime,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      // Get card to know deck ID
      final cardData = await _database.cardDao.getCardById(cardId);
      if (cardData == null) {
        return Left(LocalStorageFailure(message: 'Card not found'));
      }

      // Record the review event
      final reviewId = _uuid.v4();
      final review = CardReviewTableData(
        id: reviewId,
        cardId: cardId,
        sessionId: sessionId,
        userId: userId,
        result: result.name,
        reviewedAt: DateTime.now(),
        responseTimeMs: responseTime.inMilliseconds,
      );
      await _studyDao.recordReview(review);

      // Get or create SRS data
      final srsData = await _studyDao.getOrCreateCardSrs(
        cardId: cardId,
        deckId: cardData.deckId,
        userId: userId,
      );

      // Process the review using SRS algorithm
      final currentSrs = _dataToCardSrs(srsData);
      final updatedSrs = currentSrs.processReview(result);

      // Save updated SRS data
      await _studyDao.updateCardSrs(_cardSrsToData(updatedSrs));

      // Update session stats
      final sessionData = await _studyDao.getSessionById(sessionId);
      if (sessionData != null) {
        final session = _dataToSession(sessionData).recordReview(result);
        await _studyDao.updateSession(_sessionToData(session));
      }

      return Right(updatedSrs);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CardSRS>> getCardSRS(String cardId) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      // Get card to know deck ID
      final cardData = await _database.cardDao.getCardById(cardId);
      if (cardData == null) {
        return Left(LocalStorageFailure(message: 'Card not found'));
      }

      final srsData = await _studyDao.getOrCreateCardSrs(
        cardId: cardId,
        deckId: cardData.deckId,
        userId: userId,
      );

      return Right(_dataToCardSrs(srsData));
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeckStudyStats>> getDeckStudyStats(String deckId) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      final stats = await _studyDao.getDeckSrsStats(
        userId: userId,
        deckId: deckId,
      );

      // Calculate mastery percentage
      double mastery = 0;
      if (stats.totalCards > 0) {
        mastery = (stats.reviewCount / stats.totalCards) * 100;
      }

      return Right(DeckStudyStats(
        deckId: deckId,
        totalCards: stats.totalCards,
        newCards: stats.newCount,
        learningCards: stats.learningCount,
        reviewCards: stats.reviewCount,
        dueCards: stats.dueCount,
        masteryPercent: mastery,
      ));
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  // ==================== User Stats ====================

  @override
  Future<Either<Failure, UserStats>> getUserStats() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      final data = await _studyDao.getOrCreateUserStats(userId);
      return Right(_dataToUserStats(data));
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  @override
  Stream<UserStats> watchUserStats() async* {
    final userId = await _getCurrentUserId();
    if (userId == null) {
      yield UserStats.initial('anonymous');
      return;
    }

    yield* _studyDao.watchUserStats(userId).map((data) {
      if (data == null) {
        return UserStats.initial(userId);
      }
      return _dataToUserStats(data);
    });
  }

  @override
  Future<Either<Failure, UserStats>> updateDailyGoals({
    int? cards,
    int? minutes,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      final data = await _studyDao.getOrCreateUserStats(userId);
      final stats = _dataToUserStats(data);
      final updated = stats.updateGoals(cards: cards, minutes: minutes);

      await _studyDao.updateUserStats(_userStatsToData(updated));
      return Right(updated);
    } catch (e) {
      return Left(LocalStorageFailure(message: e.toString()));
    }
  }

  // ==================== Converters ====================

  StudySessionTableData _sessionToData(StudySession session) {
    return StudySessionTableData(
      id: session.id,
      deckId: session.deckId,
      userId: session.userId,
      mode: session.mode.name,
      status: session.status.name,
      startedAt: session.startedAt,
      pausedAt: session.pausedAt,
      completedAt: session.completedAt,
      totalCards: session.totalCards,
      reviewedCards: session.reviewedCards,
      correctCount: session.correctCount,
      almostCount: session.almostCount,
      wrongCount: session.wrongCount,
      xpEarned: session.xpEarned,
      totalTimeSeconds: session.totalTime.inSeconds,
    );
  }

  StudySession _dataToSession(StudySessionTableData data) {
    return StudySession(
      id: data.id,
      deckId: data.deckId,
      userId: data.userId,
      mode: StudyMode.values.byName(data.mode),
      status: SessionStatus.values.byName(data.status),
      startedAt: data.startedAt,
      pausedAt: data.pausedAt,
      completedAt: data.completedAt,
      totalCards: data.totalCards,
      reviewedCards: data.reviewedCards,
      correctCount: data.correctCount,
      almostCount: data.almostCount,
      wrongCount: data.wrongCount,
      xpEarned: data.xpEarned,
      totalTime: Duration(seconds: data.totalTimeSeconds),
    );
  }

  CardSRS _dataToCardSrs(CardSrsTableData data) {
    return CardSRS(
      cardId: data.cardId,
      deckId: data.deckId,
      userId: data.userId,
      state: SRSState.values.byName(data.state),
      repetitions: data.repetitions,
      easeFactor: data.easeFactor,
      interval: data.intervalDays,
      lastReviewedAt: data.lastReviewedAt,
      nextReviewAt: data.nextReviewAt,
      consecutiveCorrect: data.consecutiveCorrect,
      totalReviews: data.totalReviews,
      totalCorrect: data.totalCorrect,
    );
  }

  CardSrsTableData _cardSrsToData(CardSRS srs) {
    return CardSrsTableData(
      cardId: srs.cardId,
      deckId: srs.deckId,
      userId: srs.userId,
      state: srs.state.name,
      repetitions: srs.repetitions,
      easeFactor: srs.easeFactor,
      intervalDays: srs.interval,
      lastReviewedAt: srs.lastReviewedAt,
      nextReviewAt: srs.nextReviewAt,
      consecutiveCorrect: srs.consecutiveCorrect,
      totalReviews: srs.totalReviews,
      totalCorrect: srs.totalCorrect,
    );
  }

  UserStats _dataToUserStats(UserStatsTableData data) {
    return UserStats(
      userId: data.userId,
      totalXp: data.totalXp,
      level: data.level,
      currentStreak: data.currentStreak,
      longestStreak: data.longestStreak,
      lastStudyDate: data.lastStudyDate,
      dailyGoalCards: data.dailyGoalCards,
      dailyGoalMinutes: data.dailyGoalMinutes,
      todayCards: data.todayCards,
      todayMinutes: data.todayMinutes,
      totalCardsStudied: data.totalCardsStudied,
      totalSessionsCompleted: data.totalSessionsCompleted,
      totalStudyTime: Duration(seconds: data.totalStudyTimeSeconds),
    );
  }

  UserStatsTableData _userStatsToData(UserStats stats) {
    return UserStatsTableData(
      userId: stats.userId,
      totalXp: stats.totalXp,
      level: stats.level,
      currentStreak: stats.currentStreak,
      longestStreak: stats.longestStreak,
      lastStudyDate: stats.lastStudyDate,
      dailyGoalCards: stats.dailyGoalCards,
      dailyGoalMinutes: stats.dailyGoalMinutes,
      todayCards: stats.todayCards,
      todayMinutes: stats.todayMinutes,
      totalCardsStudied: stats.totalCardsStudied,
      totalSessionsCompleted: stats.totalSessionsCompleted,
      totalStudyTimeSeconds: stats.totalStudyTime.inSeconds,
      todayResetDate: DateTime.now(),
    );
  }

  Card _cardDataToEntity(CardTableData data) {
    return Card(
      id: data.id,
      deckId: data.deckId,
      front: data.front,
      back: data.back,
      hint: data.hint,
      mediaPath: data.mediaPath,
      mediaType: data.mediaType,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deletedAt: data.deletedAt,
      isSynced: data.isSynced,
      remoteId: data.remoteId,
      tagIds: const [],
    );
  }
}
