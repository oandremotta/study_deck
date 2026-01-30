import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/study_session.dart';
import '../../domain/entities/user_stats.dart';
import 'deck_providers.dart';
import 'study_providers.dart';

/// Home screen summary data.
class HomeSummary {
  final int totalDueCards;
  final int totalNewCards;
  final int totalDecks;
  final DateTime? nextReviewTime;
  final UserStats stats;
  final StudySession? activeSession;
  final int estimatedMinutes;

  const HomeSummary({
    required this.totalDueCards,
    required this.totalNewCards,
    required this.totalDecks,
    this.nextReviewTime,
    required this.stats,
    this.activeSession,
    required this.estimatedMinutes,
  });

  /// Total cards to study (due + new).
  int get totalCardsToStudy => totalDueCards + totalNewCards;

  /// Whether there are cards to study.
  bool get hasCardsToStudy => totalCardsToStudy > 0;

  /// Whether there's an active session to resume.
  bool get hasActiveSession =>
      activeSession != null &&
      (activeSession!.status == SessionStatus.inProgress ||
          activeSession!.status == SessionStatus.paused);
}

/// Provider for home summary data.
final homeSummaryProvider = FutureProvider<HomeSummary>((ref) async {
  // Watch user stats
  final statsAsync = ref.watch(watchUserStatsProvider);
  final stats = statsAsync.valueOrNull ?? UserStats.initial('temp');

  // Watch active session
  final activeSession = await ref.watch(activeSessionProvider.future);

  // Watch all decks and calculate total pending cards
  final decksAsync = ref.watch(watchDecksProvider);
  final decks = decksAsync.valueOrNull ?? [];

  int totalDueCards = 0;
  int totalNewCards = 0;

  // Get stats for each deck
  for (final deck in decks) {
    try {
      final deckStats = await ref.read(deckStudyStatsProvider(deck.id).future);
      totalDueCards += deckStats.dueCards;
      totalNewCards += deckStats.newCards;
    } catch (_) {
      // Ignore individual deck errors
    }
  }

  // Get next scheduled review time (UC67)
  DateTime? nextReviewTime;
  try {
    final studyRepo = ref.read(studyRepositoryProvider);
    final result = await studyRepo.getNextReviewTime();
    nextReviewTime = result.getOrNull();
  } catch (_) {
    // Ignore errors
  }

  // Estimate study time (~30 seconds per card average)
  final totalCards = totalDueCards + totalNewCards;
  final estimatedMinutes = (totalCards * 0.5).ceil(); // 30 sec per card

  return HomeSummary(
    totalDueCards: totalDueCards,
    totalNewCards: totalNewCards,
    totalDecks: decks.length,
    nextReviewTime: nextReviewTime,
    stats: stats,
    activeSession: activeSession,
    estimatedMinutes: estimatedMinutes > 0 ? estimatedMinutes : 1,
  );
});

/// Default shortcuts configuration.
enum HomeShortcut {
  folders('Pastas', 'folders'),
  decks('Decks', 'decks'),
  stats('Estatisticas', 'stats'),
  tags('Tags', 'tags');

  final String label;
  final String id;
  const HomeShortcut(this.label, this.id);
}

/// Contextual message based on user state.
String getContextualMessage(HomeSummary summary) {
  final stats = summary.stats;
  final now = DateTime.now();
  final hour = now.hour;

  // Check if returning after absence
  if (stats.lastStudyDate != null) {
    final daysSinceStudy = now.difference(stats.lastStudyDate!).inDays;

    if (daysSinceStudy > 7) {
      return 'Sentimos sua falta! Que tal retomar os estudos?';
    } else if (daysSinceStudy > 2) {
      return 'Faz $daysSinceStudy dias desde seu ultimo estudo. Vamos voltar?';
    }
  }

  // Check streak at risk
  if (stats.streakAtRisk && stats.currentStreak > 0) {
    return 'Sua sequencia de ${stats.currentStreak} dias esta em risco!';
  }

  // Check if daily goal met
  if (stats.dailyGoalMet) {
    return 'Parabens! Meta diaria concluida!';
  }

  // Check progress milestones
  final progress = stats.dailyCardProgress;
  if (progress >= 75 && progress < 100) {
    return 'Quase la! Faltam poucos cards para a meta.';
  } else if (progress >= 50) {
    return 'Metade do caminho! Continue assim.';
  }

  // Time-based greetings
  if (hour < 12) {
    return 'Bom dia! Pronto para estudar?';
  } else if (hour < 18) {
    return 'Boa tarde! Hora de revisar.';
  } else {
    return 'Boa noite! Uma sessao rapida antes de dormir?';
  }
}

/// Get CTA button text based on state.
String getCtaText(HomeSummary summary) {
  if (summary.hasActiveSession) {
    final session = summary.activeSession!;
    if (session.status == SessionStatus.paused) {
      return 'Continuar sessao';
    }
    return 'Retomar estudo';
  }

  if (!summary.hasCardsToStudy) {
    return 'Nenhum card para revisar';
  }

  if (summary.estimatedMinutes <= 5) {
    return 'Estudar agora (~${summary.estimatedMinutes} min)';
  }

  return 'Estudar agora (${summary.totalCardsToStudy} cards)';
}

/// Get CTA subtitle based on state.
String getCtaSubtitle(HomeSummary summary) {
  if (summary.hasActiveSession) {
    return 'Voce tem uma sessao em andamento';
  }

  if (!summary.hasCardsToStudy) {
    return 'Adicione cards para comecar';
  }

  final parts = <String>[];
  if (summary.totalDueCards > 0) {
    parts.add('${summary.totalDueCards} para revisar');
  }
  if (summary.totalNewCards > 0) {
    parts.add('${summary.totalNewCards} novos');
  }

  return parts.join(' • ');
}
