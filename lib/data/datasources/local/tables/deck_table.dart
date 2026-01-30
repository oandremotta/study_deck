import 'package:drift/drift.dart';

/// Table for storing decks locally.
class DeckTable extends Table {
  /// Primary key - UUID.
  TextColumn get id => text()();

  /// Deck name/title.
  TextColumn get name => text()();

  /// Optional description.
  TextColumn get description => text().nullable()();

  /// Owner user ID.
  TextColumn get userId => text()();

  /// Parent folder ID (null = root/no folder).
  TextColumn get folderId => text().nullable()();

  /// When the deck was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When the deck was last updated.
  DateTimeColumn get updatedAt => dateTime()();

  /// Whether this deck has been synced with cloud.
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Remote deck ID if synced.
  TextColumn get remoteId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
