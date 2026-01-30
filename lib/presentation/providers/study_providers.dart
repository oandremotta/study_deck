import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/study_repository_impl.dart';
import '../../domain/entities/card.dart';
import '../../domain/entities/card_review.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/study_repository.dart';
import 'auth_providers.dart';
import 'database_providers.dart';

part 'study_providers.g.dart';

/// Provider for the study repository.
@Riverpod(keepAlive: true)
StudyRepository studyRepository(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return StudyRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    getCurrentUserId: () async {
      return authRepo.currentUser?.id;
    },
  );
}

/// Provider for user stats.
@riverpod
Future<UserStats> userStats(Ref ref) async {
  final result = await ref.watch(studyRepositoryProvider).getUserStats();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats,
  );
}

/// Stream provider for watching user stats.
@riverpod
Stream<UserStats> watchUserStats(Ref ref) {
  return ref.watch(studyRepositoryProvider).watchUserStats();
}

/// Provider for active study session.
@riverpod
Future<StudySession?> activeSession(Ref ref) async {
  final result = await ref.watch(studyRepositoryProvider).getActiveSession();
  return result.fold(
    (failure) => null,
    (session) => session,
  );
}

/// Provider for fetching a session by ID (for viewing completed sessions).
/// Defined manually to avoid build_runner issues.
final sessionByIdProvider = FutureProvider.family<StudySession?, String>((ref, sessionId) async {
  final result = await ref.watch(studyRepositoryProvider).getSessionById(sessionId);
  return result.fold(
    (failure) => null,
    (session) => session,
  );
});

/// Provider for deck study stats.
@riverpod
Future<DeckStudyStats> deckStudyStats(Ref ref, String deckId) async {
  final result = await ref.watch(studyRepositoryProvider).getDeckStudyStats(deckId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats,
  );
}

/// Provider for study queue.
@riverpod
Future<List<Card>> studyQueue(
  Ref ref, {
  String? deckId,
  required StudyMode mode,
  int? limit,
}) async {
  final result = await ref.watch(studyRepositoryProvider).getStudyQueue(
    deckId: deckId,
    mode: mode,
    limit: limit,
  );
  return result.fold(
    (failure) => [],
    (cards) => cards,
  );
}

/// Notifier for managing study sessions.
/// Uses keepAlive to preserve session state during navigation.
@Riverpod(keepAlive: true)
class StudyNotifier extends _$StudyNotifier {
  @override
  FutureOr<StudySession?> build() async {
    final result = await ref.read(studyRepositoryProvider).getActiveSession();
    return result.fold(
      (failure) => null,
      (session) => session,
    );
  }

  /// Starts a new study session.
  Future<StudySession?> startSession({
    String? deckId,
    required StudyMode mode,
  }) async {
    state = const AsyncLoading();

    final repository = ref.read(studyRepositoryProvider);
    final result = await repository.createSession(
      deckId: deckId,
      mode: mode,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (session) {
        state = AsyncData(session);
        ref.invalidate(activeSessionProvider);
        ref.invalidate(userStatsProvider);
        return session;
      },
    );
  }

  /// Records a card review.
  Future<CardSRS?> recordReview({
    required String cardId,
    required ReviewResult result,
    required Duration responseTime,
  }) async {
    final currentSession = state.valueOrNull;
    if (currentSession == null) return null;

    final repository = ref.read(studyRepositoryProvider);
    final reviewResult = await repository.recordReview(
      sessionId: currentSession.id,
      cardId: cardId,
      result: result,
      responseTime: responseTime,
    );

    return reviewResult.fold(
      (failure) => null,
      (srs) {
        // Update session state locally
        final updatedSession = currentSession.recordReview(result);
        state = AsyncData(updatedSession);
        return srs;
      },
    );
  }

  /// Pauses the current session.
  Future<void> pauseSession() async {
    final currentSession = state.valueOrNull;
    if (currentSession == null) return;

    final repository = ref.read(studyRepositoryProvider);
    final result = await repository.pauseSession(currentSession.id);

    result.fold(
      (failure) => null,
      (session) {
        state = AsyncData(session);
        ref.invalidate(activeSessionProvider);
      },
    );
  }

  /// Resumes a paused session.
  Future<void> resumeSession() async {
    final currentSession = state.valueOrNull;
    if (currentSession == null) return;

    final repository = ref.read(studyRepositoryProvider);
    final result = await repository.resumeSession(currentSession.id);

    result.fold(
      (failure) => null,
      (session) {
        state = AsyncData(session);
        ref.invalidate(activeSessionProvider);
      },
    );
  }

  /// Completes the current session.
  Future<StudySession?> completeSession() async {
    var currentSession = state.valueOrNull;

    // If state is null, try to fetch active session from DB
    if (currentSession == null) {
      final repository = ref.read(studyRepositoryProvider);
      final activeResult = await repository.getActiveSession();
      currentSession = activeResult.fold(
        (failure) => null,
        (session) => session,
      );
      if (currentSession == null) {
        return null;
      }
    }

    final repository = ref.read(studyRepositoryProvider);
    final result = await repository.completeSession(currentSession.id);

    return result.fold(
      (failure) => null,
      (session) {
        state = AsyncData(session);
        ref.invalidate(activeSessionProvider);
        ref.invalidate(userStatsProvider);
        ref.invalidate(watchUserStatsProvider);
        return session;
      },
    );
  }

  /// Clears the current session state.
  void clearSession() {
    state = const AsyncData(null);
  }
}

// ==================== Direct Functions (avoid "Future already completed") ====================

/// Marks a card as mastered (UC27).
Future<CardSRS> markCardAsMasteredDirect(
  StudyRepository repository,
  String cardId,
) async {
  final result = await repository.markCardAsMastered(cardId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (srs) => srs,
  );
}

/// Resets a card's SRS progress (UC28).
Future<CardSRS> resetCardProgressDirect(
  StudyRepository repository,
  String cardId,
) async {
  final result = await repository.resetCardProgress(cardId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (srs) => srs,
  );
}

/// Resets all SRS progress for a deck (UC28).
Future<void> resetDeckProgressDirect(
  StudyRepository repository,
  String deckId,
) async {
  final result = await repository.resetDeckProgress(deckId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) {},
  );
}

/// Notifier for updating user goals.
@riverpod
class UserGoalsNotifier extends _$UserGoalsNotifier {
  @override
  FutureOr<void> build() {
    // Initial state - nothing to load
  }

  /// Updates daily goals.
  Future<bool> updateGoals({int? cards, int? minutes}) async {
    state = const AsyncLoading();

    final repository = ref.read(studyRepositoryProvider);
    final result = await repository.updateDailyGoals(
      cards: cards,
      minutes: minutes,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(userStatsProvider);
        ref.invalidate(watchUserStatsProvider);
        return true;
      },
    );
  }
}
