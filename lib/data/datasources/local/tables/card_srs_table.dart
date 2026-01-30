import 'package:drift/drift.dart';

/// Table for storing SRS (Spaced Repetition System) data for cards.
class CardSrsTable extends Table {
  @override
  String get tableName => 'card_srs';

  /// Card ID (foreign key to cards table).
  TextColumn get cardId => text()();

  /// Deck ID for quick filtering.
  TextColumn get deckId => text()();

  /// User who owns this SRS data.
  TextColumn get userId => text()();

  /// Learning state (newCard, learning, review).
  TextColumn get state => text()();

  /// Number of successful repetitions.
  IntColumn get repetitions => integer().withDefault(const Constant(0))();

  /// Ease factor (SM-2 algorithm).
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();

  /// Current interval in days.
  IntColumn get intervalDays => integer().withDefault(const Constant(0))();

  /// When the card was last reviewed.
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();

  /// When the card is due for next review.
  DateTimeColumn get nextReviewAt => dateTime().nullable()();

  /// Consecutive correct answers.
  IntColumn get consecutiveCorrect => integer().withDefault(const Constant(0))();

  /// Total number of reviews.
  IntColumn get totalReviews => integer().withDefault(const Constant(0))();

  /// Total correct answers.
  IntColumn get totalCorrect => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {cardId, userId};
}
