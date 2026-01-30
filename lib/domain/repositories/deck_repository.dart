import '../entities/deck.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';

/// Action to take when deleting a deck that contains cards.
enum DeleteDeckAction {
  /// Archive cards (soft delete) before deleting the deck.
  archiveCards,

  /// Permanently delete cards along with the deck.
  deleteCards,
}

/// Contract for deck operations.
///
/// Handles CRUD operations for decks (UC07, UC08, UC09).
abstract class DeckRepository {
  /// Watches all decks for the current user.
  ///
  /// Returns a stream that emits the list of decks whenever it changes.
  Stream<List<Deck>> watchDecks();

  /// Watches decks in a specific folder.
  ///
  /// Pass null for [folderId] to get decks at root level (no folder).
  Stream<List<Deck>> watchDecksByFolder(String? folderId);

  /// Gets all decks for the current user.
  Future<Either<Failure, List<Deck>>> getDecks();

  /// Gets decks in a specific folder.
  Future<Either<Failure, List<Deck>>> getDecksByFolder(String? folderId);

  /// Gets a single deck by ID.
  Future<Either<Failure, Deck?>> getDeckById(String id);

  /// Creates a new deck.
  ///
  /// UC07 - Create deck.
  Future<Either<Failure, Deck>> createDeck({
    required String name,
    String? description,
    String? folderId,
  });

  /// Updates an existing deck.
  ///
  /// UC08 - Edit deck.
  Future<Either<Failure, Deck>> updateDeck({
    required String id,
    String? name,
    String? description,
    String? folderId,
  });

  /// Moves a deck to a different folder.
  Future<Either<Failure, Deck>> moveDeck({
    required String id,
    String? folderId,
  });

  /// Deletes a deck.
  ///
  /// UC09 - Delete deck.
  ///
  /// If the deck contains cards, [action] determines what happens to them:
  /// - [DeleteDeckAction.archiveCards]: Cards are soft-deleted (moved to trash)
  /// - [DeleteDeckAction.deleteCards]: Cards are permanently deleted
  Future<Either<Failure, void>> deleteDeck({
    required String id,
    required DeleteDeckAction action,
  });

  /// Checks if a deck with the given name already exists.
  Future<Either<Failure, bool>> deckNameExists(String name);

  /// Gets the card count for a deck.
  Future<Either<Failure, int>> getCardCount(String deckId);
}
