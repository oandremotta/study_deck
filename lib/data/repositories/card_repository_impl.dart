import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../../domain/entities/card.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/local/database.dart';
import '../models/card_model.dart';

/// Implementation of [CardRepository].
///
/// Handles card CRUD operations (UC10, UC11, UC12, UC13, UC14).
class CardRepositoryImpl implements CardRepository {
  final AppDatabase _database;
  final Uuid _uuid;

  /// Function to get current user ID. Injected for testability.
  final Future<String?> Function() _getCurrentUserId;

  /// Function to get deck IDs for current user.
  final Future<List<String>> Function() _getUserDeckIds;

  CardRepositoryImpl({
    required AppDatabase database,
    required Future<String?> Function() getCurrentUserId,
    required Future<List<String>> Function() getUserDeckIds,
    Uuid? uuid,
  })  : _database = database,
        _getCurrentUserId = getCurrentUserId,
        _getUserDeckIds = getUserDeckIds,
        _uuid = uuid ?? const Uuid();

  @override
  Stream<List<Card>> watchCardsByDeck(String deckId) {
    return _database.cardDao.watchCardsByDeck(deckId).asyncMap((cards) async {
      final result = <Card>[];
      for (final card in cards) {
        final tagIds = await _database.cardDao.getTagIdsForCard(card.id);
        result.add(card.toEntity(tagIds: tagIds));
      }
      return result;
    });
  }

  @override
  Stream<List<Card>> watchDeletedCardsByDeck(String deckId) {
    return _database.cardDao.watchDeletedCardsByDeck(deckId).asyncMap((cards) async {
      final result = <Card>[];
      for (final card in cards) {
        final tagIds = await _database.cardDao.getTagIdsForCard(card.id);
        result.add(card.toEntity(tagIds: tagIds));
      }
      return result;
    });
  }

  @override
  Future<Either<Failure, List<Card>>> getCardsByDeck(String deckId) async {
    try {
      final cards = await _database.cardDao.getCardsByDeck(deckId);
      final result = <Card>[];
      for (final card in cards) {
        final tagIds = await _database.cardDao.getTagIdsForCard(card.id);
        result.add(card.toEntity(tagIds: tagIds));
      }
      return Right(result);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to get cards: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Card>>> getAllDeletedCards() async {
    try {
      final deckIds = await _getUserDeckIds();
      if (deckIds.isEmpty) return const Right([]);

      final cards = await _database.cardDao.getAllDeletedCards(deckIds);
      final result = <Card>[];
      for (final card in cards) {
        final tagIds = await _database.cardDao.getTagIdsForCard(card.id);
        result.add(card.toEntity(tagIds: tagIds));
      }
      return Right(result);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to get deleted cards: $e'));
    }
  }

  @override
  Future<Either<Failure, Card?>> getCardById(String id) async {
    try {
      final cardData = await _database.cardDao.getCardById(id);
      if (cardData == null) return const Right(null);

      final tagIds = await _database.cardDao.getTagIdsForCard(id);
      return Right(cardData.toEntity(tagIds: tagIds));
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to get card: $e'));
    }
  }

  @override
  Future<Either<Failure, Card>> createCard({
    required String deckId,
    required String front,
    required String back,
    String? hint,
    List<String> tagIds = const [],
  }) async {
    try {
      if (front.trim().isEmpty) {
        return Left(ValidationFailure.empty('Card front'));
      }
      if (back.trim().isEmpty) {
        return Left(ValidationFailure.empty('Card back'));
      }

      final card = Card.create(
        id: _uuid.v4(),
        deckId: deckId,
        front: front.trim(),
        back: back.trim(),
        hint: hint?.trim(),
        tagIds: tagIds,
      );

      await _database.cardDao.createCard(card.toCompanion());

      if (tagIds.isNotEmpty) {
        await _database.cardDao.setTagsForCard(card.id, tagIds);
      }

      return Right(card);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to create card: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Card>>> createCards(List<Card> cards) async {
    try {
      final createdCards = <Card>[];

      for (final card in cards) {
        final newCard = Card.create(
          id: _uuid.v4(),
          deckId: card.deckId,
          front: card.front.trim(),
          back: card.back.trim(),
          hint: card.hint?.trim(),
          tagIds: card.tagIds,
        );

        await _database.cardDao.createCard(newCard.toCompanion());

        if (newCard.tagIds.isNotEmpty) {
          await _database.cardDao.setTagsForCard(newCard.id, newCard.tagIds);
        }

        createdCards.add(newCard);
      }

      return Right(createdCards);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to create cards: $e'));
    }
  }

  @override
  Future<Either<Failure, Card>> updateCard({
    required String id,
    String? front,
    String? back,
    String? hint,
    List<String>? tagIds,
  }) async {
    try {
      final existingCard = await _database.cardDao.getCardById(id);
      if (existingCard == null) {
        return Left(const LocalStorageFailure(
          message: 'Card not found',
          code: 'not-found',
        ));
      }

      final newFront = front?.trim() ?? existingCard.front;
      final newBack = back?.trim() ?? existingCard.back;

      if (newFront.isEmpty) {
        return Left(ValidationFailure.empty('Card front'));
      }
      if (newBack.isEmpty) {
        return Left(ValidationFailure.empty('Card back'));
      }

      final now = DateTime.now();
      final updatedCompanion = CardTableCompanion(
        id: Value(id),
        deckId: Value(existingCard.deckId),
        front: Value(newFront),
        back: Value(newBack),
        hint: Value(hint?.trim() ?? existingCard.hint),
        mediaPath: Value(existingCard.mediaPath),
        mediaType: Value(existingCard.mediaType),
        createdAt: Value(existingCard.createdAt),
        updatedAt: Value(now),
        deletedAt: Value(existingCard.deletedAt),
        isSynced: const Value(false),
        remoteId: Value(existingCard.remoteId),
      );

      await _database.cardDao.updateCard(updatedCompanion);

      if (tagIds != null) {
        await _database.cardDao.setTagsForCard(id, tagIds);
      }

      final finalTagIds = tagIds ?? await _database.cardDao.getTagIdsForCard(id);

      final updatedCard = Card(
        id: id,
        deckId: existingCard.deckId,
        front: newFront,
        back: newBack,
        hint: hint?.trim() ?? existingCard.hint,
        mediaPath: existingCard.mediaPath,
        mediaType: existingCard.mediaType,
        createdAt: existingCard.createdAt,
        updatedAt: now,
        deletedAt: existingCard.deletedAt,
        isSynced: false,
        remoteId: existingCard.remoteId,
        tagIds: finalTagIds,
      );

      return Right(updatedCard);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to update card: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> softDeleteCard(String id) async {
    try {
      final card = await _database.cardDao.getCardById(id);
      if (card == null) {
        return Left(const LocalStorageFailure(
          message: 'Card not found',
          code: 'not-found',
        ));
      }

      await _database.cardDao.softDeleteCard(id);
      return const Right(null);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to delete card: $e'));
    }
  }

  @override
  Future<Either<Failure, Card>> restoreCard(String id) async {
    try {
      final cardData = await _database.cardDao.getCardById(id);
      if (cardData == null) {
        return Left(const LocalStorageFailure(
          message: 'Card not found',
          code: 'not-found',
        ));
      }

      await _database.cardDao.restoreCard(id);

      final tagIds = await _database.cardDao.getTagIdsForCard(id);
      final restoredCard = cardData.toEntity(tagIds: tagIds).restore();

      return Right(restoredCard);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to restore card: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> permanentlyDeleteCard(String id) async {
    try {
      await _database.cardDao.deleteCard(id);
      return const Right(null);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to delete card: $e'));
    }
  }

  @override
  Future<Either<Failure, Card>> attachMedia({
    required String cardId,
    required String mediaPath,
    required String mediaType,
  }) async {
    try {
      final existingCard = await _database.cardDao.getCardById(cardId);
      if (existingCard == null) {
        return Left(const LocalStorageFailure(
          message: 'Card not found',
          code: 'not-found',
        ));
      }

      if (mediaType != 'image' && mediaType != 'audio') {
        return Left(const ValidationFailure(
          message: 'Invalid media type. Must be "image" or "audio"',
          code: 'invalid-media-type',
        ));
      }

      final now = DateTime.now();
      final updatedCompanion = CardTableCompanion(
        id: Value(cardId),
        deckId: Value(existingCard.deckId),
        front: Value(existingCard.front),
        back: Value(existingCard.back),
        hint: Value(existingCard.hint),
        mediaPath: Value(mediaPath),
        mediaType: Value(mediaType),
        createdAt: Value(existingCard.createdAt),
        updatedAt: Value(now),
        deletedAt: Value(existingCard.deletedAt),
        isSynced: const Value(false),
        remoteId: Value(existingCard.remoteId),
      );

      await _database.cardDao.updateCard(updatedCompanion);

      final tagIds = await _database.cardDao.getTagIdsForCard(cardId);

      return Right(Card(
        id: cardId,
        deckId: existingCard.deckId,
        front: existingCard.front,
        back: existingCard.back,
        hint: existingCard.hint,
        mediaPath: mediaPath,
        mediaType: mediaType,
        createdAt: existingCard.createdAt,
        updatedAt: now,
        deletedAt: existingCard.deletedAt,
        isSynced: false,
        remoteId: existingCard.remoteId,
        tagIds: tagIds,
      ));
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to attach media: $e'));
    }
  }

  @override
  Future<Either<Failure, Card>> removeMedia(String cardId) async {
    try {
      final existingCard = await _database.cardDao.getCardById(cardId);
      if (existingCard == null) {
        return Left(const LocalStorageFailure(
          message: 'Card not found',
          code: 'not-found',
        ));
      }

      final now = DateTime.now();
      final updatedCompanion = CardTableCompanion(
        id: Value(cardId),
        deckId: Value(existingCard.deckId),
        front: Value(existingCard.front),
        back: Value(existingCard.back),
        hint: Value(existingCard.hint),
        mediaPath: const Value(null),
        mediaType: const Value(null),
        createdAt: Value(existingCard.createdAt),
        updatedAt: Value(now),
        deletedAt: Value(existingCard.deletedAt),
        isSynced: const Value(false),
        remoteId: Value(existingCard.remoteId),
      );

      await _database.cardDao.updateCard(updatedCompanion);

      final tagIds = await _database.cardDao.getTagIdsForCard(cardId);

      return Right(Card(
        id: cardId,
        deckId: existingCard.deckId,
        front: existingCard.front,
        back: existingCard.back,
        hint: existingCard.hint,
        mediaPath: null,
        mediaType: null,
        createdAt: existingCard.createdAt,
        updatedAt: now,
        deletedAt: existingCard.deletedAt,
        isSynced: false,
        remoteId: existingCard.remoteId,
        tagIds: tagIds,
      ));
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to remove media: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Card>>> getCardsByTag(String tagId) async {
    try {
      final cards = await _database.cardDao.getCardsByTag(tagId);
      final result = <Card>[];
      for (final card in cards) {
        final tagIds = await _database.cardDao.getTagIdsForCard(card.id);
        result.add(card.toEntity(tagIds: tagIds));
      }
      return Right(result);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to get cards by tag: $e'));
    }
  }

  @override
  Future<Either<Failure, Card>> updateCardTags({
    required String cardId,
    required List<String> tagIds,
  }) async {
    try {
      final existingCard = await _database.cardDao.getCardById(cardId);
      if (existingCard == null) {
        return Left(const LocalStorageFailure(
          message: 'Card not found',
          code: 'not-found',
        ));
      }

      await _database.cardDao.setTagsForCard(cardId, tagIds);

      final now = DateTime.now();
      await _database.cardDao.updateCard(CardTableCompanion(
        id: Value(cardId),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ));

      return Right(existingCard.toEntity(tagIds: tagIds).copyWith(updatedAt: now));
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to update card tags: $e'));
    }
  }
}
