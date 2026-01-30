import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/card_table.dart';
import '../tables/card_tag_table.dart';

part 'card_dao.g.dart';

/// Data Access Object for card operations.
@DriftAccessor(tables: [CardTable, CardTagTable])
class CardDao extends DatabaseAccessor<AppDatabase> with _$CardDaoMixin {
  CardDao(super.db);

  /// Gets all active (non-deleted) cards in a deck.
  Future<List<CardTableData>> getCardsByDeck(String deckId) async {
    return (select(cardTable)
          ..where((t) => t.deckId.equals(deckId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Gets all deleted cards in a deck (trash).
  Future<List<CardTableData>> getDeletedCardsByDeck(String deckId) async {
    return (select(cardTable)
          ..where((t) => t.deckId.equals(deckId) & t.deletedAt.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.deletedAt)]))
        .get();
  }

  /// Gets all deleted cards for a user across all decks.
  Future<List<CardTableData>> getAllDeletedCards(List<String> deckIds) async {
    return (select(cardTable)
          ..where((t) => t.deckId.isIn(deckIds) & t.deletedAt.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.deletedAt)]))
        .get();
  }

  /// Gets a card by ID.
  Future<CardTableData?> getCardById(String id) async {
    return (select(cardTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Gets multiple cards by IDs.
  Future<List<CardTableData>> getCardsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    return (select(cardTable)
          ..where((t) => t.id.isIn(ids) & t.deletedAt.isNull()))
        .get();
  }

  /// Creates a new card.
  Future<void> createCard(CardTableCompanion card) async {
    await into(cardTable).insert(card);
  }

  /// Updates a card.
  Future<void> updateCard(CardTableCompanion card) async {
    await (update(cardTable)..where((t) => t.id.equals(card.id.value)))
        .write(card);
  }

  /// Soft deletes a card (moves to trash).
  Future<void> softDeleteCard(String id) async {
    await (update(cardTable)..where((t) => t.id.equals(id))).write(
      CardTableCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Restores a soft-deleted card.
  Future<void> restoreCard(String id) async {
    await (update(cardTable)..where((t) => t.id.equals(id))).write(
      CardTableCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Permanently deletes a card.
  Future<int> deleteCard(String id) async {
    await (delete(cardTagTable)..where((t) => t.cardId.equals(id))).go();
    return (delete(cardTable)..where((t) => t.id.equals(id))).go();
  }

  /// Permanently deletes all cards in a deck.
  Future<void> deleteCardsByDeck(String deckId) async {
    final cards = await (select(cardTable)
          ..where((t) => t.deckId.equals(deckId)))
        .get();
    final cardIds = cards.map((c) => c.id).toList();

    if (cardIds.isNotEmpty) {
      await (delete(cardTagTable)..where((t) => t.cardId.isIn(cardIds))).go();
    }
    await (delete(cardTable)..where((t) => t.deckId.equals(deckId))).go();
  }

  /// Soft deletes all cards in a deck.
  Future<void> softDeleteCardsByDeck(String deckId) async {
    await (update(cardTable)
          ..where((t) => t.deckId.equals(deckId) & t.deletedAt.isNull()))
        .write(
      CardTableCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Watches active cards in a deck.
  Stream<List<CardTableData>> watchCardsByDeck(String deckId) {
    return (select(cardTable)
          ..where((t) => t.deckId.equals(deckId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Watches deleted cards in a deck.
  Stream<List<CardTableData>> watchDeletedCardsByDeck(String deckId) {
    return (select(cardTable)
          ..where((t) => t.deckId.equals(deckId) & t.deletedAt.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.deletedAt)]))
        .watch();
  }

  /// Gets count of active cards in a deck.
  Future<int> getCardCount(String deckId) async {
    final count = cardTable.id.count();
    final query = selectOnly(cardTable)
      ..addColumns([count])
      ..where(cardTable.deckId.equals(deckId) & cardTable.deletedAt.isNull());
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Gets tag IDs for a card.
  Future<List<String>> getTagIdsForCard(String cardId) async {
    final results = await (select(cardTagTable)
          ..where((t) => t.cardId.equals(cardId)))
        .get();
    return results.map((r) => r.tagId).toList();
  }

  /// Sets tags for a card (replaces existing).
  Future<void> setTagsForCard(String cardId, List<String> tagIds) async {
    await (delete(cardTagTable)..where((t) => t.cardId.equals(cardId))).go();

    for (final tagId in tagIds) {
      await into(cardTagTable).insert(
        CardTagTableCompanion.insert(cardId: cardId, tagId: tagId),
      );
    }
  }

  /// Adds a tag to a card.
  Future<void> addTagToCard(String cardId, String tagId) async {
    await into(cardTagTable).insert(
      CardTagTableCompanion.insert(cardId: cardId, tagId: tagId),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Removes a tag from a card.
  Future<void> removeTagFromCard(String cardId, String tagId) async {
    await (delete(cardTagTable)
          ..where((t) => t.cardId.equals(cardId) & t.tagId.equals(tagId)))
        .go();
  }

  /// Gets cards with a specific tag.
  Future<List<CardTableData>> getCardsByTag(String tagId) async {
    final cardIds = await (select(cardTagTable)
          ..where((t) => t.tagId.equals(tagId)))
        .get();

    if (cardIds.isEmpty) return [];

    return (select(cardTable)
          ..where((t) =>
              t.id.isIn(cardIds.map((c) => c.cardId).toList()) &
              t.deletedAt.isNull()))
        .get();
  }

  /// Gets count of cards using a specific tag.
  Future<int> getCardCountByTag(String tagId) async {
    final count = cardTagTable.cardId.count();
    final query = selectOnly(cardTagTable)
      ..addColumns([count])
      ..where(cardTagTable.tagId.equals(tagId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
