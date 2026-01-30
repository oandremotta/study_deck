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
  // UC34: Streak freeze
  final int streakFreezes;
  // UC33: Weekly challenges
  final int weeklyCardsGoal;
  final int weeklyCardsStudied;
  final int weeklySessionsGoal;
  final int weeklySessionsCompleted;
  final DateTime? weekStartDate;

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
    this.streakFreezes = 0,
    this.weeklyCardsGoal = 100,
    this.weeklyCardsStudied = 0,
    this.weeklySessionsGoal = 7,
    this.weeklySessionsCompleted = 0,
    this.weekStartDate,
  });

  /// Creates initial stats for a new user.
  factory UserStats.initial(String userId) {
    final now = DateTime.now();
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
      streakFreezes: 1, // Start with 1 free freeze
      weeklyCardsGoal: 100,
      weeklyCardsStudied: 0,
      weeklySessionsGoal: 7,
      weeklySessionsCompleted: 0,
      weekStartDate: _getWeekStart(now),
    );
  }

  /// Gets the start of the week (Monday) for a given date.
  static DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
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

  /// Weekly cards challenge progress (0-100).
  double get weeklyCardsProgress =>
      weeklyCardsGoal > 0 ? (weeklyCardsStudied / weeklyCardsGoal * 100).clamp(0, 100) : 0;

  /// Weekly sessions challenge progress (0-100).
  double get weeklySessionsProgress =>
      weeklySessionsGoal > 0 ? (weeklySessionsCompleted / weeklySessionsGoal * 100).clamp(0, 100) : 0;

  /// Whether weekly cards challenge is complete.
  bool get weeklyCardsChallengeMet => weeklyCardsStudied >= weeklyCardsGoal;

  /// Whether weekly sessions challenge is complete.
  bool get weeklySessionsChallengeMet => weeklySessionsCompleted >= weeklySessionsGoal;

  /// Whether both weekly challenges are complete.
  bool get allWeeklyChallengesMet => weeklyCardsChallengeMet && weeklySessionsChallengeMet;

  /// Whether user has streak freezes available.
  bool get hasStreakFreeze => streakFreezes > 0;

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

    // Update weekly progress
    final currentWeekStart = _getWeekStart(now);
    final isNewWeek = weekStartDate == null || !_isSameDay(weekStartDate!, currentWeekStart);
    int newWeeklyCards = isNewWeek ? cardsReviewed : weeklyCardsStudied + cardsReviewed;
    int newWeeklySessions = isNewWeek ? 1 : weeklySessionsCompleted + 1;

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
      weeklyCardsStudied: newWeeklyCards,
      weeklySessionsCompleted: newWeeklySessions,
      weekStartDate: currentWeekStart,
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
    int? streakFreezes,
    int? weeklyCardsGoal,
    int? weeklyCardsStudied,
    int? weeklySessionsGoal,
    int? weeklySessionsCompleted,
    DateTime? weekStartDate,
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
      streakFreezes: streakFreezes ?? this.streakFreezes,
      weeklyCardsGoal: weeklyCardsGoal ?? this.weeklyCardsGoal,
      weeklyCardsStudied: weeklyCardsStudied ?? this.weeklyCardsStudied,
      weeklySessionsGoal: weeklySessionsGoal ?? this.weeklySessionsGoal,
      weeklySessionsCompleted: weeklySessionsCompleted ?? this.weeklySessionsCompleted,
      weekStartDate: weekStartDate ?? this.weekStartDate,
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
        streakFreezes,
        weeklyCardsGoal,
        weeklyCardsStudied,
        weeklySessionsGoal,
        weeklySessionsCompleted,
        weekStartDate,
      ];

  /// Uses a streak freeze to prevent streak loss.
  UserStats useStreakFreeze() {
    if (streakFreezes <= 0) return this;
    return copyWith(streakFreezes: streakFreezes - 1);
  }

  /// Adds streak freezes (e.g., as reward).
  UserStats addStreakFreezes(int count) {
    return copyWith(streakFreezes: streakFreezes + count);
  }
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
