import '../entities/card.dart';
import '../entities/card_review.dart';
import '../entities/study_session.dart';
import '../entities/user_stats.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';

/// Repository interface for study and SRS operations.
abstract class StudyRepository {
  // ==================== Study Sessions ====================

  /// Creates a new study session.
  Future<Either<Failure, StudySession>> createSession({
    String? deckId,
    required StudyMode mode,
  });

  /// Gets the current active session (in progress or paused).
  Future<Either<Failure, StudySession?>> getActiveSession();

  /// Gets a session by its ID (for viewing completed sessions).
  Future<Either<Failure, StudySession?>> getSessionById(String sessionId);

  /// Updates a study session.
  Future<Either<Failure, StudySession>> updateSession(StudySession session);

  /// Pauses the current session.
  Future<Either<Failure, StudySession>> pauseSession(String sessionId);

  /// Resumes a paused session.
  Future<Either<Failure, StudySession>> resumeSession(String sessionId);

  /// Completes a session and updates user stats.
  Future<Either<Failure, StudySession>> completeSession(String sessionId);

  /// Gets recent completed sessions.
  Future<Either<Failure, List<StudySession>>> getRecentSessions({int limit = 10});

  // ==================== Study Queue ====================

  /// Gets the study queue for a session.
  /// Returns cards ordered by priority (due cards first, then new cards).
  Future<Either<Failure, List<Card>>> getStudyQueue({
    String? deckId,
    required StudyMode mode,
    int? limit,
  });

  /// Gets cards with recent errors for review.
  Future<Either<Failure, List<Card>>> getErrorCards({
    String? deckId,
    int days = 7,
    int? limit,
  });

  // ==================== Card Reviews ====================

  /// Records a card review and updates SRS data.
  Future<Either<Failure, CardSRS>> recordReview({
    required String sessionId,
    required String cardId,
    required ReviewResult result,
    required Duration responseTime,
  });

  /// Gets SRS data for a card.
  Future<Either<Failure, CardSRS>> getCardSRS(String cardId);

  /// Gets SRS statistics for a deck.
  Future<Either<Failure, DeckStudyStats>> getDeckStudyStats(String deckId);

  /// Marks a card as mastered (UC27).
  /// Mastered cards are excluded from regular reviews.
  Future<Either<Failure, CardSRS>> markCardAsMastered(String cardId);

  /// Resets a card's SRS progress (UC28).
  /// Returns the card to "new" state.
  Future<Either<Failure, CardSRS>> resetCardProgress(String cardId);

  /// Resets all SRS progress for a deck (UC28).
  Future<Either<Failure, void>> resetDeckProgress(String deckId);

  // ==================== User Stats ====================

  /// Gets the current user's stats.
  Future<Either<Failure, UserStats>> getUserStats();

  /// Watches user stats for reactive updates.
  Stream<UserStats> watchUserStats();

  /// Updates daily goals.
  Future<Either<Failure, UserStats>> updateDailyGoals({
    int? cards,
    int? minutes,
  });
}

/// Statistics about a deck's study state.
class DeckStudyStats {
  final String deckId;
  final int totalCards;
  final int newCards;
  final int learningCards;
  final int reviewCards;
  final int dueCards;
  final double masteryPercent;

  const DeckStudyStats({
    required this.deckId,
    required this.totalCards,
    required this.newCards,
    required this.learningCards,
    required this.reviewCards,
    required this.dueCards,
    required this.masteryPercent,
  });

  /// Whether there are cards to study.
  bool get hasCardsToStudy => dueCards > 0 || newCards > 0;
}
