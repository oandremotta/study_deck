import 'package:drift/drift.dart';

/// Table for storing flashcards locally.
class CardTable extends Table {
  /// Primary key - UUID.
  TextColumn get id => text()();

  /// Parent deck ID.
  TextColumn get deckId => text()();

  /// Front side content (question).
  TextColumn get front => text()();

  /// Back side content (full explanation/answer).
  TextColumn get back => text()();

  /// Short answer/summary (≤240 chars) - required for new cards.
  TextColumn get summary => text().nullable()();

  /// Memory anchor phrase (≤120 chars) - required for new cards.
  TextColumn get keyPhrase => text().nullable()();

  /// Optional hint.
  TextColumn get hint => text().nullable()();

  /// Path to attached media file (local).
  TextColumn get mediaPath => text().nullable()();

  /// Type of media ('image', 'audio').
  TextColumn get mediaType => text().nullable()();

  /// URL of the image in Firebase Storage.
  TextColumn get imageUrl => text().nullable()();

  /// Whether to use the image as the front of the card (UC125).
  BoolColumn get imageAsFront => boolean().withDefault(const Constant(false))();

  /// Status of image upload ('pending', 'uploading', 'completed', 'failed').
  TextColumn get imageUploadStatus => text().nullable()();

  /// UC201-202: URL of AI-generated TTS audio in Firebase Storage.
  TextColumn get audioUrl => text().nullable()();

  /// UC203: URL of user-recorded pronunciation audio.
  TextColumn get pronunciationUrl => text().nullable()();

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
