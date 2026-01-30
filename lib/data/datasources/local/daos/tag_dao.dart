import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/tag_table.dart';
import '../tables/card_tag_table.dart';

part 'tag_dao.g.dart';

/// Data Access Object for tag operations.
@DriftAccessor(tables: [TagTable, CardTagTable])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  /// Gets all tags for a user.
  Future<List<TagTableData>> getTags(String userId) async {
    return (select(tagTable)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Gets a tag by ID.
  Future<TagTableData?> getTagById(String id) async {
    return (select(tagTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Gets tags by IDs.
  Future<List<TagTableData>> getTagsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    return (select(tagTable)..where((t) => t.id.isIn(ids))).get();
  }

  /// Creates a new tag.
  Future<void> createTag(TagTableCompanion tag) async {
    await into(tagTable).insert(tag);
  }

  /// Updates a tag.
  Future<void> updateTag(TagTableCompanion tag) async {
    await (update(tagTable)..where((t) => t.id.equals(tag.id.value)))
        .write(tag);
  }

  /// Deletes a tag and removes all its associations.
  Future<int> deleteTag(String id) async {
    await (delete(cardTagTable)..where((t) => t.tagId.equals(id))).go();
    return (delete(tagTable)..where((t) => t.id.equals(id))).go();
  }

  /// Checks if a tag name exists for a user.
  Future<bool> tagNameExists(String userId, String name, {String? excludeId}) async {
    var query = select(tagTable)
      ..where((t) => t.userId.equals(userId) & t.name.equals(name));

    if (excludeId != null) {
      query = select(tagTable)
        ..where((t) =>
            t.userId.equals(userId) &
            t.name.equals(name) &
            t.id.isNotValue(excludeId));
    }

    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// Watches all tags for a user.
  Stream<List<TagTableData>> watchTags(String userId) {
    return (select(tagTable)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Gets card count for each tag.
  Future<Map<String, int>> getTagCardCounts(String userId) async {
    final tags = await getTags(userId);
    final counts = <String, int>{};

    for (final tag in tags) {
      final count = cardTagTable.cardId.count();
      final query = selectOnly(cardTagTable)
        ..addColumns([count])
        ..where(cardTagTable.tagId.equals(tag.id));
      final result = await query.getSingle();
      counts[tag.id] = result.read(count) ?? 0;
    }

    return counts;
  }
}
