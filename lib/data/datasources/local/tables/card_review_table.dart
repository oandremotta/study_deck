import 'package:drift/drift.dart';

/// Table for storing individual card review events.
class CardReviewTable extends Table {
  @override
  String get tableName => 'card_reviews';

  /// Unique identifier.
  TextColumn get id => text()();

  /// Card that was reviewed.
  TextColumn get cardId => text()();

  /// Session in which the review occurred.
  TextColumn get sessionId => text()();

  /// User who performed the review.
  TextColumn get userId => text()();

  /// Result (wrong, almost, correct).
  TextColumn get result => text()();

  /// When the review occurred.
  DateTimeColumn get reviewedAt => dateTime()();

  /// How long the user took to respond (in milliseconds).
  IntColumn get responseTimeMs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
