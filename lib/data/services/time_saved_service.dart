import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UC129: Service to track and calculate time saved using AI features.
///
/// Estimates time savings based on:
/// - Cards generated with AI vs manual creation
/// - Flashcard review time with SRS optimization
/// - Study session efficiency
class TimeSavedService {
  // Storage keys
  static const String _cardsGeneratedKey = 'ai_cards_generated_total';
  static const String _cardsStudiedKey = 'cards_studied_total';
  static const String _studySessionsKey = 'study_sessions_total';
  static const String _monthlyCardsKey = 'ai_cards_generated_month';
  static const String _monthKey = 'time_saved_month';

  // Time estimates (in minutes)
  static const double minutesPerManualCard = 3.0; // Time to create a card manually
  static const double minutesPerAiCard = 0.5; // Time to review/approve AI card
  static const double minutesSavedPerSrsReview = 0.5; // Efficiency from SRS
  static const double minutesSavedPerStudySession = 5.0; // Session optimization

  /// Record AI-generated cards.
  Future<void> recordAiCardsGenerated(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Total count
      final total = prefs.getInt(_cardsGeneratedKey) ?? 0;
      await prefs.setInt(_cardsGeneratedKey, total + count);

      // Monthly count
      final currentMonth = _getCurrentMonth();
      final savedMonth = prefs.getString(_monthKey);

      if (savedMonth != currentMonth) {
        await prefs.setString(_monthKey, currentMonth);
        await prefs.setInt(_monthlyCardsKey, count);
      } else {
        final monthly = prefs.getInt(_monthlyCardsKey) ?? 0;
        await prefs.setInt(_monthlyCardsKey, monthly + count);
      }

      debugPrint('TimeSavedService: Recorded $count AI cards generated');
    } catch (e) {
      debugPrint('TimeSavedService: Error recording cards: $e');
    }
  }

  /// Record cards studied.
  Future<void> recordCardsStudied(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final total = prefs.getInt(_cardsStudiedKey) ?? 0;
      await prefs.setInt(_cardsStudiedKey, total + count);
    } catch (e) {
      debugPrint('TimeSavedService: Error recording studied: $e');
    }
  }

  /// Record study session completed.
  Future<void> recordStudySession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final total = prefs.getInt(_studySessionsKey) ?? 0;
      await prefs.setInt(_studySessionsKey, total + 1);
    } catch (e) {
      debugPrint('TimeSavedService: Error recording session: $e');
    }
  }

  /// Get total time saved (in minutes).
  Future<TimeSavedStats> getTimeSavedStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final aiCards = prefs.getInt(_cardsGeneratedKey) ?? 0;
      final studiedCards = prefs.getInt(_cardsStudiedKey) ?? 0;
      final sessions = prefs.getInt(_studySessionsKey) ?? 0;

      // Calculate time saved from AI card generation
      final cardCreationSaved = aiCards * (minutesPerManualCard - minutesPerAiCard);

      // Calculate time saved from SRS efficiency
      final srsSaved = studiedCards * minutesSavedPerSrsReview;

      // Calculate time saved from optimized sessions
      final sessionSaved = sessions * minutesSavedPerStudySession;

      final totalMinutes = cardCreationSaved + srsSaved + sessionSaved;

      return TimeSavedStats(
        totalMinutes: totalMinutes,
        cardCreationMinutes: cardCreationSaved,
        srsMinutes: srsSaved,
        sessionMinutes: sessionSaved,
        aiCardsGenerated: aiCards,
        cardsStudied: studiedCards,
        studySessions: sessions,
      );
    } catch (e) {
      debugPrint('TimeSavedService: Error getting stats: $e');
      return TimeSavedStats.empty();
    }
  }

  /// Get monthly AI cards generated.
  Future<int> getMonthlyAiCardsGenerated() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final currentMonth = _getCurrentMonth();
      final savedMonth = prefs.getString(_monthKey);

      if (savedMonth != currentMonth) {
        return 0;
      }

      return prefs.getInt(_monthlyCardsKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  String _getCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }
}

/// Statistics about time saved.
class TimeSavedStats {
  final double totalMinutes;
  final double cardCreationMinutes;
  final double srsMinutes;
  final double sessionMinutes;
  final int aiCardsGenerated;
  final int cardsStudied;
  final int studySessions;

  const TimeSavedStats({
    required this.totalMinutes,
    required this.cardCreationMinutes,
    required this.srsMinutes,
    required this.sessionMinutes,
    required this.aiCardsGenerated,
    required this.cardsStudied,
    required this.studySessions,
  });

  factory TimeSavedStats.empty() => const TimeSavedStats(
        totalMinutes: 0,
        cardCreationMinutes: 0,
        srsMinutes: 0,
        sessionMinutes: 0,
        aiCardsGenerated: 0,
        cardsStudied: 0,
        studySessions: 0,
      );

  /// Get total hours saved.
  double get totalHours => totalMinutes / 60;

  /// Format as display string (e.g., "2h 30min").
  String get displayText {
    if (totalMinutes < 1) return '< 1 min';
    if (totalMinutes < 60) return '${totalMinutes.round()} min';

    final hours = (totalMinutes / 60).floor();
    final minutes = (totalMinutes % 60).round();

    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}min';
  }

  /// Format as short display (e.g., "~2h").
  String get shortDisplayText {
    if (totalMinutes < 60) return '~${totalMinutes.round()}min';
    return '~${totalHours.round()}h';
  }
}
