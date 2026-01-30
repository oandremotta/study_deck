import 'package:drift/drift.dart';

/// Table for storing folders locally.
class FolderTable extends Table {
  /// Primary key - UUID.
  TextColumn get id => text()();

  /// Folder name.
  TextColumn get name => text()();

  /// Owner user ID.
  TextColumn get userId => text()();

  /// When the folder was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When the folder was last updated.
  DateTimeColumn get updatedAt => dateTime()();

  /// Whether this folder has been synced with cloud.
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Remote folder ID if synced.
  TextColumn get remoteId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
