import 'package:drift/drift.dart';

/// Table for storing user statistics and gamification data.
class UserStatsTable extends Table {
  @override
  String get tableName => 'user_stats';

  /// User ID (primary key).
  TextColumn get userId => text()();

  /// Total XP earned.
  IntColumn get totalXp => integer().withDefault(const Constant(0))();

  /// Current level.
  IntColumn get level => integer().withDefault(const Constant(1))();

  /// Current streak (consecutive days).
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();

  /// Longest streak achieved.
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();

  /// Last date the user studied.
  DateTimeColumn get lastStudyDate => dateTime().nullable()();

  /// Daily goal: number of cards.
  IntColumn get dailyGoalCards => integer().withDefault(const Constant(20))();

  /// Daily goal: minutes of study.
  IntColumn get dailyGoalMinutes => integer().withDefault(const Constant(10))();

  /// Cards studied today.
  IntColumn get todayCards => integer().withDefault(const Constant(0))();

  /// Minutes studied today.
  IntColumn get todayMinutes => integer().withDefault(const Constant(0))();

  /// Total cards studied all time.
  IntColumn get totalCardsStudied => integer().withDefault(const Constant(0))();

  /// Total sessions completed.
  IntColumn get totalSessionsCompleted => integer().withDefault(const Constant(0))();

  /// Total study time in seconds.
  IntColumn get totalStudyTimeSeconds => integer().withDefault(const Constant(0))();

  /// Date when today counters were last reset.
  DateTimeColumn get todayResetDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}
