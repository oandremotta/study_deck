import 'package:equatable/equatable.dart';

/// Represents a study session.
///
/// A session tracks the user's progress through a set of cards,
/// including timing, mode, and completion status.
class StudySession extends Equatable {
  final String id;
  final String? deckId; // null for "study now" across all decks
  final String userId;
  final StudyMode mode;
  final SessionStatus status;
  final DateTime startedAt;
  final DateTime? pausedAt;
  final DateTime? completedAt;
  final int totalCards;
  final int reviewedCards;
  final int correctCount;
  final int almostCount;
  final int wrongCount;
  final int xpEarned;
  final Duration totalTime;

  const StudySession({
    required this.id,
    this.deckId,
    required this.userId,
    required this.mode,
    required this.status,
    required this.startedAt,
    this.pausedAt,
    this.completedAt,
    required this.totalCards,
    required this.reviewedCards,
    required this.correctCount,
    required this.almostCount,
    required this.wrongCount,
    required this.xpEarned,
    required this.totalTime,
  });

  /// Creates a new study session.
  factory StudySession.create({
    required String id,
    String? deckId,
    required String userId,
    required StudyMode mode,
    required int totalCards,
  }) {
    return StudySession(
      id: id,
      deckId: deckId,
      userId: userId,
      mode: mode,
      status: SessionStatus.inProgress,
      startedAt: DateTime.now(),
      totalCards: totalCards,
      reviewedCards: 0,
      correctCount: 0,
      almostCount: 0,
      wrongCount: 0,
      xpEarned: 0,
      totalTime: Duration.zero,
    );
  }

  /// Records a card review result.
  StudySession recordReview(ReviewResult result) {
    return copyWith(
      reviewedCards: reviewedCards + 1,
      correctCount: result == ReviewResult.correct ? correctCount + 1 : correctCount,
      almostCount: result == ReviewResult.almost ? almostCount + 1 : almostCount,
      wrongCount: result == ReviewResult.wrong ? wrongCount + 1 : wrongCount,
      xpEarned: xpEarned + result.xpValue,
    );
  }

  /// Pauses the session.
  StudySession pause() {
    if (status != SessionStatus.inProgress) return this;
    return copyWith(
      status: SessionStatus.paused,
      pausedAt: DateTime.now(),
      totalTime: totalTime + DateTime.now().difference(startedAt),
    );
  }

  /// Resumes the session.
  StudySession resume() {
    if (status != SessionStatus.paused) return this;
    return copyWith(
      status: SessionStatus.inProgress,
      pausedAt: null,
    );
  }

  /// Completes the session.
  StudySession complete() {
    final now = DateTime.now();
    Duration finalTime = totalTime;
    if (status == SessionStatus.inProgress) {
      finalTime = totalTime + now.difference(pausedAt ?? startedAt);
    }
    return copyWith(
      status: SessionStatus.completed,
      completedAt: now,
      totalTime: finalTime,
    );
  }

  /// Returns the accuracy percentage.
  double get accuracy {
    if (reviewedCards == 0) return 0;
    return (correctCount + almostCount * 0.5) / reviewedCards * 100;
  }

  /// Returns whether the session is finished.
  bool get isFinished => status == SessionStatus.completed;

  /// Returns whether the session can be resumed.
  bool get canResume => status == SessionStatus.paused;

  /// Returns the remaining cards count.
  int get remainingCards => totalCards - reviewedCards;

  /// Returns the progress percentage (0-100).
  double get progress => totalCards > 0 ? reviewedCards / totalCards * 100 : 0;

  StudySession copyWith({
    String? id,
    String? deckId,
    String? userId,
    StudyMode? mode,
    SessionStatus? status,
    DateTime? startedAt,
    DateTime? pausedAt,
    DateTime? completedAt,
    int? totalCards,
    int? reviewedCards,
    int? correctCount,
    int? almostCount,
    int? wrongCount,
    int? xpEarned,
    Duration? totalTime,
  }) {
    return StudySession(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      userId: userId ?? this.userId,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      completedAt: completedAt ?? this.completedAt,
      totalCards: totalCards ?? this.totalCards,
      reviewedCards: reviewedCards ?? this.reviewedCards,
      correctCount: correctCount ?? this.correctCount,
      almostCount: almostCount ?? this.almostCount,
      wrongCount: wrongCount ?? this.wrongCount,
      xpEarned: xpEarned ?? this.xpEarned,
      totalTime: totalTime ?? this.totalTime,
    );
  }

  @override
  List<Object?> get props => [
        id,
        deckId,
        userId,
        mode,
        status,
        startedAt,
        pausedAt,
        completedAt,
        totalCards,
        reviewedCards,
        correctCount,
        almostCount,
        wrongCount,
        xpEarned,
        totalTime,
      ];
}

/// Study modes available.
enum StudyMode {
  /// Smart queue with due reviews + new cards.
  studyNow,

  /// Only due reviews for today.
  reviewsToday,

  /// New cards + reviews.
  newAndReviews,

  /// Only cards marked as wrong recently.
  errorsOnly,

  /// Quick 3-minute session (turbo mode).
  turbo,
}

extension StudyModeExtension on StudyMode {
  String get displayName {
    switch (this) {
      case StudyMode.studyNow:
        return 'Estudar agora';
      case StudyMode.reviewsToday:
        return 'Revisoes de hoje';
      case StudyMode.newAndReviews:
        return 'Novos + Revisoes';
      case StudyMode.errorsOnly:
        return 'Apenas erros';
      case StudyMode.turbo:
        return 'Modo Turbo (3 min)';
    }
  }

  String get description {
    switch (this) {
      case StudyMode.studyNow:
        return 'Fila inteligente com revisoes vencidas e novos cards';
      case StudyMode.reviewsToday:
        return 'Cards que precisam ser revisados hoje';
      case StudyMode.newAndReviews:
        return 'Mistura de cards novos com revisoes';
      case StudyMode.errorsOnly:
        return 'Cards que voce errou recentemente';
      case StudyMode.turbo:
        return 'Sessao rapida de ~12 cards em 3 minutos';
    }
  }
}

/// Session status.
enum SessionStatus {
  inProgress,
  paused,
  completed,
}

/// Result of reviewing a single card.
enum ReviewResult {
  /// User got it wrong.
  wrong,

  /// User almost got it (partial).
  almost,

  /// User got it correct.
  correct,
}

extension ReviewResultExtension on ReviewResult {
  String get displayName {
    switch (this) {
      case ReviewResult.wrong:
        return 'Errei';
      case ReviewResult.almost:
        return 'Quase';
      case ReviewResult.correct:
        return 'Acertei';
    }
  }

  /// XP earned for this result.
  int get xpValue {
    switch (this) {
      case ReviewResult.wrong:
        return 1;
      case ReviewResult.almost:
        return 3;
      case ReviewResult.correct:
        return 5;
    }
  }

  /// Color associated with this result.
  String get colorHex {
    switch (this) {
      case ReviewResult.wrong:
        return '#EF4444'; // red
      case ReviewResult.almost:
        return '#F59E0B'; // amber
      case ReviewResult.correct:
        return '#10B981'; // green
    }
  }
}
