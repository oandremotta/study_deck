import 'package:drift/drift.dart';

/// Table for storing flashcards locally.
class CardTable extends Table {
  /// Primary key - UUID.
  TextColumn get id => text()();

  /// Parent deck ID.
  TextColumn get deckId => text()();

  /// Front side content (question).
  TextColumn get front => text()();

  /// Back side content (answer).
  TextColumn get back => text()();

  /// Optional hint.
  TextColumn get hint => text().nullable()();

  /// Path to attached media file.
  TextColumn get mediaPath => text().nullable()();

  /// Type of media ('image', 'audio').
  TextColumn get mediaType => text().nullable()();

  /// When the card was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When the card was last updated.
  DateTimeColumn get updatedAt => dateTime()();

  /// When the card was soft-deleted (null = not deleted).
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Whether this card has been synced with cloud.
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Remote card ID if synced.
  TextColumn get remoteId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
