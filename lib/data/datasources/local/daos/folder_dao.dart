import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/folder_table.dart';
import '../tables/deck_table.dart';

part 'folder_dao.g.dart';

/// Data Access Object for folder operations.
@DriftAccessor(tables: [FolderTable, DeckTable])
class FolderDao extends DatabaseAccessor<AppDatabase> with _$FolderDaoMixin {
  FolderDao(super.db);

  /// Gets all folders for a user.
  Future<List<FolderTableData>> getFolders(String userId) async {
    return (select(folderTable)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Gets a folder by ID.
  Future<FolderTableData?> getFolderById(String id) async {
    return (select(folderTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Creates a new folder.
  Future<void> createFolder(FolderTableCompanion folder) async {
    await into(folderTable).insert(folder);
  }

  /// Updates a folder.
  Future<void> updateFolder(FolderTableCompanion folder) async {
    await (update(folderTable)
          ..where((t) => t.id.equals(folder.id.value)))
        .write(folder);
  }

  /// Deletes a folder.
  Future<int> deleteFolder(String id) async {
    return (delete(folderTable)..where((t) => t.id.equals(id))).go();
  }

  /// Watches all folders for a user.
  Stream<List<FolderTableData>> watchFolders(String userId) {
    return (select(folderTable)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Checks if a folder name exists for a user.
  Future<bool> folderNameExists(String userId, String name) async {
    final result = await (select(folderTable)
          ..where((t) => t.userId.equals(userId) & t.name.equals(name)))
        .getSingleOrNull();
    return result != null;
  }

  /// Gets the deck count for a folder.
  Future<int> getDeckCount(String folderId) async {
    final count = deckTable.id.count();
    final query = selectOnly(deckTable)
      ..addColumns([count])
      ..where(deckTable.folderId.equals(folderId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Gets all folders with deck counts.
  Future<List<FolderWithDeckCount>> getFoldersWithDeckCount(
      String userId) async {
    final folders = await getFolders(userId);
    final result = <FolderWithDeckCount>[];

    for (final folder in folders) {
      final deckCount = await getDeckCount(folder.id);
      result.add(FolderWithDeckCount(folder: folder, deckCount: deckCount));
    }

    return result;
  }

  /// Watches all folders with deck counts.
  Stream<List<FolderWithDeckCount>> watchFoldersWithDeckCount(String userId) {
    return watchFolders(userId).asyncMap((folders) async {
      final result = <FolderWithDeckCount>[];
      for (final folder in folders) {
        final deckCount = await getDeckCount(folder.id);
        result.add(FolderWithDeckCount(folder: folder, deckCount: deckCount));
      }
      return result;
    });
  }
}

/// Folder with its deck count.
class FolderWithDeckCount {
  final FolderTableData folder;
  final int deckCount;

  const FolderWithDeckCount({
    required this.folder,
    required this.deckCount,
  });
}
