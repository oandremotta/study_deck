import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/deck_table.dart';

part 'deck_dao.g.dart';

/// Data Access Object for deck operations.
@DriftAccessor(tables: [DeckTable])
class DeckDao extends DatabaseAccessor<AppDatabase> with _$DeckDaoMixin {
  DeckDao(super.db);

  /// Gets all decks for a user.
  Future<List<DeckTableData>> getDecks(String userId) async {
    return (select(deckTable)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Gets all decks in a folder.
  Future<List<DeckTableData>> getDecksByFolder(String? folderId) async {
    if (folderId == null) {
      return (select(deckTable)
            ..where((t) => t.folderId.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();
    }
    return (select(deckTable)
          ..where((t) => t.folderId.equals(folderId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Gets a deck by ID.
  Future<DeckTableData?> getDeckById(String id) async {
    return (select(deckTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Creates a new deck.
  Future<void> createDeck(DeckTableCompanion deck) async {
    await into(deckTable).insert(deck);
  }

  /// Updates a deck.
  Future<void> updateDeck(DeckTableCompanion deck) async {
    await (update(deckTable)..where((t) => t.id.equals(deck.id.value)))
        .write(deck);
  }

  /// Deletes a deck.
  Future<int> deleteDeck(String id) async {
    return (delete(deckTable)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes all decks in a folder.
  Future<int> deleteDecksByFolder(String folderId) async {
    return (delete(deckTable)..where((t) => t.folderId.equals(folderId))).go();
  }

  /// Moves decks from a folder to root (no folder).
  Future<int> moveDecksToRoot(String folderId) async {
    return (update(deckTable)..where((t) => t.folderId.equals(folderId)))
        .write(const DeckTableCompanion(folderId: Value(null)));
  }

  /// Watches all decks for a user.
  Stream<List<DeckTableData>> watchDecks(String userId) {
    return (select(deckTable)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Watches decks in a folder.
  Stream<List<DeckTableData>> watchDecksByFolder(String? folderId) {
    if (folderId == null) {
      return (select(deckTable)
            ..where((t) => t.folderId.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();
    }
    return (select(deckTable)
          ..where((t) => t.folderId.equals(folderId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Checks if there are any decks for a user.
  Future<bool> hasDecks(String userId) async {
    final result = await (select(deckTable)
          ..where((t) => t.userId.equals(userId))
          ..limit(1))
        .getSingleOrNull();
    return result != null;
  }
}
