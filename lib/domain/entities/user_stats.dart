import 'package:equatable/equatable.dart';

/// User statistics for gamification.
///
/// Tracks XP, level, streaks, and daily goals.
class UserStats extends Equatable {
  final String userId;
  final int totalXp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStudyDate;
  final int dailyGoalCards;
  final int dailyGoalMinutes;
  final int todayCards;
  final int todayMinutes;
  final int totalCardsStudied;
  final int totalSessionsCompleted;
  final Duration totalStudyTime;

  const UserStats({
    required this.userId,
    required this.totalXp,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    this.lastStudyDate,
    required this.dailyGoalCards,
    required this.dailyGoalMinutes,
    required this.todayCards,
    required this.todayMinutes,
    required this.totalCardsStudied,
    required this.totalSessionsCompleted,
    required this.totalStudyTime,
  });

  /// Creates initial stats for a new user.
  factory UserStats.initial(String userId) {
    return UserStats(
      userId: userId,
      totalXp: 0,
      level: 1,
      currentStreak: 0,
      longestStreak: 0,
      dailyGoalCards: 20,
      dailyGoalMinutes: 10,
      todayCards: 0,
      todayMinutes: 0,
      totalCardsStudied: 0,
      totalSessionsCompleted: 0,
      totalStudyTime: Duration.zero,
    );
  }

  /// XP required to reach the next level.
  int get xpForNextLevel => _xpForLevel(level + 1) - _xpForLevel(level);

  /// XP progress within current level (0 to xpForNextLevel).
  int get xpInCurrentLevel => totalXp - _xpForLevel(level);

  /// Progress percentage to next level (0-100).
  double get levelProgress => xpForNextLevel > 0 ? (xpInCurrentLevel / xpForNextLevel) * 100 : 0;

  /// Daily card goal progress (0-100).
  double get dailyCardProgress => dailyGoalCards > 0 ? (todayCards / dailyGoalCards * 100).clamp(0, 100) : 0;

  /// Daily time goal progress (0-100).
  double get dailyTimeProgress =>
      dailyGoalMinutes > 0 ? (todayMinutes / dailyGoalMinutes * 100).clamp(0, 100) : 0;

  /// Whether daily goal is met.
  bool get dailyGoalMet => todayCards >= dailyGoalCards || todayMinutes >= dailyGoalMinutes;

  /// Whether streak is active today.
  bool get streakActiveToday {
    if (lastStudyDate == null) return false;
    final today = DateTime.now();
    return _isSameDay(lastStudyDate!, today);
  }

  /// Whether streak is at risk (last study was yesterday).
  bool get streakAtRisk {
    if (lastStudyDate == null) return currentStreak > 0;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    return _isSameDay(lastStudyDate!, yesterday);
  }

  /// Updates stats after completing a session.
  UserStats recordSession({
    required int cardsReviewed,
    required int xpEarned,
    required Duration sessionTime,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if this is a new day
    bool isNewDay = lastStudyDate == null || !_isSameDay(lastStudyDate!, now);
    int newTodayCards = isNewDay ? cardsReviewed : todayCards + cardsReviewed;
    int newTodayMinutes = isNewDay ? sessionTime.inMinutes : todayMinutes + sessionTime.inMinutes;

    // Update streak
    int newStreak = currentStreak;
    if (isNewDay) {
      if (lastStudyDate == null) {
        newStreak = 1;
      } else {
        final yesterday = today.subtract(const Duration(days: 1));
        if (_isSameDay(lastStudyDate!, yesterday)) {
          // Continuing streak
          newStreak = currentStreak + 1;
        } else if (!_isSameDay(lastStudyDate!, today)) {
          // Streak broken
          newStreak = 1;
        }
      }
    }

    // Calculate new XP and level
    final newTotalXp = totalXp + xpEarned;
    final newLevel = _levelForXp(newTotalXp);

    return copyWith(
      totalXp: newTotalXp,
      level: newLevel,
      currentStreak: newStreak,
      longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
      lastStudyDate: now,
      todayCards: newTodayCards,
      todayMinutes: newTodayMinutes,
      totalCardsStudied: totalCardsStudied + cardsReviewed,
      totalSessionsCompleted: totalSessionsCompleted + 1,
      totalStudyTime: totalStudyTime + sessionTime,
    );
  }

  /// Resets daily counters (call at midnight or on new day detection).
  UserStats resetDaily() {
    return copyWith(
      todayCards: 0,
      todayMinutes: 0,
    );
  }

  /// Updates daily goals.
  UserStats updateGoals({int? cards, int? minutes}) {
    return copyWith(
      dailyGoalCards: cards ?? dailyGoalCards,
      dailyGoalMinutes: minutes ?? dailyGoalMinutes,
    );
  }

  UserStats copyWith({
    String? userId,
    int? totalXp,
    int? level,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastStudyDate,
    int? dailyGoalCards,
    int? dailyGoalMinutes,
    int? todayCards,
    int? todayMinutes,
    int? totalCardsStudied,
    int? totalSessionsCompleted,
    Duration? totalStudyTime,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      dailyGoalCards: dailyGoalCards ?? this.dailyGoalCards,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      todayCards: todayCards ?? this.todayCards,
      todayMinutes: todayMinutes ?? this.todayMinutes,
      totalCardsStudied: totalCardsStudied ?? this.totalCardsStudied,
      totalSessionsCompleted: totalSessionsCompleted ?? this.totalSessionsCompleted,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
    );
  }

  /// Calculates XP required to reach a specific level.
  /// Uses a quadratic formula for increasing difficulty.
  static int _xpForLevel(int level) {
    if (level <= 1) return 0;
    // Formula: 100 * (level - 1)^1.5
    return (100 * _pow(level - 1, 1.5)).round();
  }

  /// Calculates level from total XP.
  static int _levelForXp(int xp) {
    int level = 1;
    while (_xpForLevel(level + 1) <= xp) {
      level++;
    }
    return level;
  }

  static double _pow(int base, double exp) {
    return base.toDouble() * (exp == 1.5 ? base.toDouble().abs() : 1);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  List<Object?> get props => [
        userId,
        totalXp,
        level,
        currentStreak,
        longestStreak,
        lastStudyDate,
        dailyGoalCards,
        dailyGoalMinutes,
        todayCards,
        todayMinutes,
        totalCardsStudied,
        totalSessionsCompleted,
        totalStudyTime,
      ];
}

/// Level information for display.
class LevelInfo {
  final int level;
  final String title;
  final String badgeEmoji;

  const LevelInfo({
    required this.level,
    required this.title,
    required this.badgeEmoji,
  });

  /// Gets level info for a given level number.
  static LevelInfo forLevel(int level) {
    if (level >= 50) return const LevelInfo(level: 50, title: 'Mestre Supremo', badgeEmoji: '');
    if (level >= 40) return LevelInfo(level: level, title: 'Grande Mestre', badgeEmoji: '');
    if (level >= 30) return LevelInfo(level: level, title: 'Mestre', badgeEmoji: '');
    if (level >= 20) return LevelInfo(level: level, title: 'Especialista', badgeEmoji: '');
    if (level >= 15) return LevelInfo(level: level, title: 'Avancado', badgeEmoji: '');
    if (level >= 10) return LevelInfo(level: level, title: 'Intermediario', badgeEmoji: '');
    if (level >= 5) return LevelInfo(level: level, title: 'Aprendiz', badgeEmoji: '');
    return LevelInfo(level: level, title: 'Iniciante', badgeEmoji: '');
  }
}
