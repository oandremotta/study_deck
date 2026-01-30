import 'package:drift/drift.dart';

/// Junction table for many-to-many relationship between cards and tags.
class CardTagTable extends Table {
  /// Card ID.
  TextColumn get cardId => text()();

  /// Tag ID.
  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {cardId, tagId};
}
