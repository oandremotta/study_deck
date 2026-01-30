import 'package:equatable/equatable.dart';

import 'study_session.dart';

/// Represents a single card review event.
///
/// Tracks when a card was reviewed, the result, and SRS scheduling data.
class CardReview extends Equatable {
  final String id;
  final String cardId;
  final String sessionId;
  final String userId;
  final ReviewResult result;
  final DateTime reviewedAt;
  final Duration responseTime;

  const CardReview({
    required this.id,
    required this.cardId,
    required this.sessionId,
    required this.userId,
    required this.result,
    required this.reviewedAt,
    required this.responseTime,
  });

  /// Creates a new card review.
  factory CardReview.create({
    required String id,
    required String cardId,
    required String sessionId,
    required String userId,
    required ReviewResult result,
    required Duration responseTime,
  }) {
    return CardReview(
      id: id,
      cardId: cardId,
      sessionId: sessionId,
      userId: userId,
      result: result,
      reviewedAt: DateTime.now(),
      responseTime: responseTime,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cardId,
        sessionId,
        userId,
        result,
        reviewedAt,
        responseTime,
      ];
}

/// SRS (Spaced Repetition System) data for a card.
///
/// Tracks the learning state and next review date for each card.
class CardSRS extends Equatable {
  final String cardId;
  final String deckId;
  final String userId;
  final SRSState state;
  final int repetitions;
  final double easeFactor;
  final int interval; // days
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;
  final int consecutiveCorrect;
  final int totalReviews;
  final int totalCorrect;

  const CardSRS({
    required this.cardId,
    required this.deckId,
    required this.userId,
    required this.state,
    required this.repetitions,
    required this.easeFactor,
    required this.interval,
    this.lastReviewedAt,
    this.nextReviewAt,
    required this.consecutiveCorrect,
    required this.totalReviews,
    required this.totalCorrect,
  });

  /// Creates initial SRS data for a new card.
  factory CardSRS.initial({
    required String cardId,
    required String deckId,
    required String userId,
  }) {
    return CardSRS(
      cardId: cardId,
      deckId: deckId,
      userId: userId,
      state: SRSState.newCard,
      repetitions: 0,
      easeFactor: 2.5, // Default ease factor
      interval: 0,
      consecutiveCorrect: 0,
      totalReviews: 0,
      totalCorrect: 0,
    );
  }

  /// Returns whether the card is due for review.
  bool get isDue {
    if (state == SRSState.newCard) return true;
    if (nextReviewAt == null) return true;
    return DateTime.now().isAfter(nextReviewAt!);
  }

  /// Returns whether the card is new (never reviewed).
  bool get isNew => state == SRSState.newCard;

  /// Returns the mastery percentage (0-100).
  double get mastery {
    if (totalReviews == 0) return 0;
    // Combine accuracy with retention (interval length)
    final accuracy = totalCorrect / totalReviews;
    final retention = (interval / 365).clamp(0.0, 1.0); // Max 1 year
    return ((accuracy * 0.7) + (retention * 0.3)) * 100;
  }

  /// Processes a review result and returns updated SRS data.
  CardSRS processReview(ReviewResult result) {
    final now = DateTime.now();

    // SM-2 algorithm implementation with modifications
    double newEase = easeFactor;
    int newInterval = interval;
    int newReps = repetitions;
    int newConsecutive = consecutiveCorrect;
    SRSState newState = state;

    switch (result) {
      case ReviewResult.wrong:
        // Reset to learning state
        newReps = 0;
        newConsecutive = 0;
        newInterval = 1; // Review tomorrow
        newEase = (easeFactor - 0.2).clamp(1.3, 2.5);
        newState = SRSState.learning;
        break;

      case ReviewResult.almost:
        // Partial success - slower progression
        newReps = repetitions + 1;
        newConsecutive = 0;
        newEase = (easeFactor - 0.1).clamp(1.3, 2.5);
        if (state == SRSState.newCard || state == SRSState.learning) {
          newInterval = 1;
          newState = SRSState.learning;
        } else {
          // Keep same interval or slight increase
          newInterval = (interval * 1.2).round().clamp(1, 365);
          newState = SRSState.review;
        }
        break;

      case ReviewResult.correct:
        newReps = repetitions + 1;
        newConsecutive = consecutiveCorrect + 1;
        newEase = (easeFactor + 0.1).clamp(1.3, 2.5);

        if (state == SRSState.newCard) {
          // First review - start learning
          newInterval = 1;
          newState = SRSState.learning;
        } else if (state == SRSState.learning) {
          if (newConsecutive >= 2) {
            // Graduate to review after 2 consecutive correct
            newInterval = 4;
            newState = SRSState.review;
          } else {
            newInterval = 1;
          }
        } else {
          // Standard SM-2 interval calculation
          if (newReps == 1) {
            newInterval = 1;
          } else if (newReps == 2) {
            newInterval = 6;
          } else {
            newInterval = (interval * newEase).round().clamp(1, 365);
          }
          newState = SRSState.review;
        }
        break;
    }

    return CardSRS(
      cardId: cardId,
      deckId: deckId,
      userId: userId,
      state: newState,
      repetitions: newReps,
      easeFactor: newEase,
      interval: newInterval,
      lastReviewedAt: now,
      nextReviewAt: now.add(Duration(days: newInterval)),
      consecutiveCorrect: newConsecutive,
      totalReviews: totalReviews + 1,
      totalCorrect: result == ReviewResult.correct ? totalCorrect + 1 : totalCorrect,
    );
  }

  CardSRS copyWith({
    String? cardId,
    String? deckId,
    String? userId,
    SRSState? state,
    int? repetitions,
    double? easeFactor,
    int? interval,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
    int? consecutiveCorrect,
    int? totalReviews,
    int? totalCorrect,
  }) {
    return CardSRS(
      cardId: cardId ?? this.cardId,
      deckId: deckId ?? this.deckId,
      userId: userId ?? this.userId,
      state: state ?? this.state,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      totalReviews: totalReviews ?? this.totalReviews,
      totalCorrect: totalCorrect ?? this.totalCorrect,
    );
  }

  @override
  List<Object?> get props => [
        cardId,
        deckId,
        userId,
        state,
        repetitions,
        easeFactor,
        interval,
        lastReviewedAt,
        nextReviewAt,
        consecutiveCorrect,
        totalReviews,
        totalCorrect,
      ];
}

/// SRS learning state.
enum SRSState {
  /// Card has never been reviewed.
  newCard,

  /// Card is being learned (short intervals).
  learning,

  /// Card is in regular review cycle.
  review,
}

extension SRSStateExtension on SRSState {
  String get displayName {
    switch (this) {
      case SRSState.newCard:
        return 'Novo';
      case SRSState.learning:
        return 'Aprendendo';
      case SRSState.review:
        return 'Revisando';
    }
  }
}
