import 'package:drift/drift.dart';

/// Table for storing tags locally.
class TagTable extends Table {
  /// Primary key - UUID.
  TextColumn get id => text()();

  /// Tag name.
  TextColumn get name => text()();

  /// Tag color in hex format.
  TextColumn get color => text()();

  /// Owner user ID.
  TextColumn get userId => text()();

  /// When the tag was created.
  DateTimeColumn get createdAt => dateTime()();

  /// Whether this tag has been synced with cloud.
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Remote tag ID if synced.
  TextColumn get remoteId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
