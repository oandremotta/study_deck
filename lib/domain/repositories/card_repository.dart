import '../entities/card.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';

/// Contract for card operations.
///
/// Handles CRUD operations for cards (UC10, UC11, UC12, UC13, UC14).
abstract class CardRepository {
  /// Watches all active (non-deleted) cards in a deck.
  ///
  /// Returns a stream that emits the list of cards whenever it changes.
  Stream<List<Card>> watchCardsByDeck(String deckId);

  /// Watches deleted cards in a deck (trash).
  Stream<List<Card>> watchDeletedCardsByDeck(String deckId);

  /// Gets all active cards in a deck.
  Future<Either<Failure, List<Card>>> getCardsByDeck(String deckId);

  /// Gets all deleted cards for the current user.
  Future<Either<Failure, List<Card>>> getAllDeletedCards();

  /// Gets a single card by ID.
  Future<Either<Failure, Card?>> getCardById(String id);

  /// Creates a new card with pedagogical format.
  ///
  /// UC10 - Create card (quick mode).
  /// UC115 - Add image to card.
  /// UC173 - Create card with pedagogical fields.
  Future<Either<Failure, Card>> createCard({
    required String deckId,
    required String front,
    required String back,
    String? summary,
    String? keyPhrase,
    String? hint,
    List<String> tagIds,
    String? imageUrl,
    bool imageAsFront = false,
  });

  /// Creates multiple cards at once (batch import).
  Future<Either<Failure, List<Card>>> createCards(List<Card> cards);

  /// Updates an existing card.
  ///
  /// UC11 - Edit card.
  /// UC115/UC116 - Add/Remove image from card.
  /// UC173 - Update card with pedagogical fields.
  Future<Either<Failure, Card>> updateCard({
    required String id,
    String? front,
    String? back,
    String? summary,
    String? keyPhrase,
    String? hint,
    List<String>? tagIds,
    String? imageUrl,
    bool? imageAsFront,
  });

  /// Soft deletes a card (moves to trash).
  ///
  /// UC12 - Delete card.
  Future<Either<Failure, void>> softDeleteCard(String id);

  /// Restores a soft-deleted card from trash.
  ///
  /// UC13 - Restore deleted card.
  Future<Either<Failure, Card>> restoreCard(String id);

  /// Permanently deletes a card.
  Future<Either<Failure, void>> permanentlyDeleteCard(String id);

  /// Attaches media to a card.
  ///
  /// UC14 - Attach media to card.
  Future<Either<Failure, Card>> attachMedia({
    required String cardId,
    required String mediaPath,
    required String mediaType,
  });

  /// Removes media from a card.
  Future<Either<Failure, Card>> removeMedia(String cardId);

  /// Gets cards by tag.
  Future<Either<Failure, List<Card>>> getCardsByTag(String tagId);

  /// Updates tags for a card.
  Future<Either<Failure, Card>> updateCardTags({
    required String cardId,
    required List<String> tagIds,
  });
}
