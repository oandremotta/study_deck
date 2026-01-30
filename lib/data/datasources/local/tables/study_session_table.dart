import 'package:drift/drift.dart';

/// Table for storing study sessions.
class StudySessionTable extends Table {
  @override
  String get tableName => 'study_sessions';

  /// Unique identifier.
  TextColumn get id => text()();

  /// Deck being studied (null for cross-deck study).
  TextColumn get deckId => text().nullable()();

  /// User who owns this session.
  TextColumn get userId => text()();

  /// Study mode (studyNow, reviewsToday, etc.).
  TextColumn get mode => text()();

  /// Session status (inProgress, paused, completed).
  TextColumn get status => text()();

  /// When the session started.
  DateTimeColumn get startedAt => dateTime()();

  /// When the session was paused (if applicable).
  DateTimeColumn get pausedAt => dateTime().nullable()();

  /// When the session was completed (if applicable).
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Total cards in the session queue.
  IntColumn get totalCards => integer()();

  /// Number of cards reviewed.
  IntColumn get reviewedCards => integer().withDefault(const Constant(0))();

  /// Number of correct answers.
  IntColumn get correctCount => integer().withDefault(const Constant(0))();

  /// Number of "almost" answers.
  IntColumn get almostCount => integer().withDefault(const Constant(0))();

  /// Number of wrong answers.
  IntColumn get wrongCount => integer().withDefault(const Constant(0))();

  /// XP earned in this session.
  IntColumn get xpEarned => integer().withDefault(const Constant(0))();

  /// Total time spent (in seconds).
  IntColumn get totalTimeSeconds => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
