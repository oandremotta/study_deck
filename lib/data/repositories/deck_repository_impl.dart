import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../../domain/entities/deck.dart';
import '../../domain/repositories/deck_repository.dart';
import '../datasources/local/database.dart';
import '../models/deck_model.dart';

/// Implementation of [DeckRepository].
///
/// Handles deck CRUD operations (UC07, UC08, UC09).
class DeckRepositoryImpl implements DeckRepository {
  final AppDatabase _database;
  final Uuid _uuid;

  /// Function to get current user ID. Injected for testability.
  final Future<String?> Function() _getCurrentUserId;

  DeckRepositoryImpl({
    required AppDatabase database,
    required Future<String?> Function() getCurrentUserId,
    Uuid? uuid,
  })  : _database = database,
        _getCurrentUserId = getCurrentUserId,
        _uuid = uuid ?? const Uuid();

  @override
  Stream<List<Deck>> watchDecks() {
    return _getCurrentUserIdStream().asyncExpand((userId) {
      if (userId == null) return Stream.value(<Deck>[]);

      return _database.deckDao.watchDecks(userId).asyncMap((decks) async {
        final result = <Deck>[];
        for (final deck in decks) {
          final cardCount = await _database.cardDao.getCardCount(deck.id);
          result.add(deck.toEntity(cardCount: cardCount));
        }
        return result;
      });
    });
  }

  Stream<String?> _getCurrentUserIdStream() async* {
    yield await _getCurrentUserId();
  }

  @override
  Stream<List<Deck>> watchDecksByFolder(String? folderId) {
    return _database.deckDao.watchDecksByFolder(folderId).asyncMap((decks) async {
      final result = <Deck>[];
      for (final deck in decks) {
        final cardCount = await _database.cardDao.getCardCount(deck.id);
        result.add(deck.toEntity(cardCount: cardCount));
      }
      return result;
    });
  }

  @override
  Future<Either<Failure, List<Deck>>> getDecks() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return const Right([]);
      }

      final decks = await _database.deckDao.getDecks(userId);
      final result = <Deck>[];
      for (final deck in decks) {
        final cardCount = await _database.cardDao.getCardCount(deck.id);
        result.add(deck.toEntity(cardCount: cardCount));
      }
      return Right(result);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to get decks: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Deck>>> getDecksByFolder(String? folderId) async {
    try {
      final decks = await _database.deckDao.getDecksByFolder(folderId);
      final result = <Deck>[];
      for (final deck in decks) {
        final cardCount = await _database.cardDao.getCardCount(deck.id);
        result.add(deck.toEntity(cardCount: cardCount));
      }
      return Right(result);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to get decks: $e'));
    }
  }

  @override
  Future<Either<Failure, Deck?>> getDeckById(String id) async {
    try {
      final deckData = await _database.deckDao.getDeckById(id);
      if (deckData == null) return const Right(null);

      final cardCount = await _database.cardDao.getCardCount(id);
      return Right(deckData.toEntity(cardCount: cardCount));
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to get deck: $e'));
    }
  }

  @override
  Future<Either<Failure, Deck>> createDeck({
    required String name,
    String? description,
    String? folderId,
  }) async {
    try {
      if (name.trim().isEmpty) {
        return Left(ValidationFailure.empty('Deck name'));
      }

      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Left(const LocalStorageFailure(
          message: 'No user logged in',
        ));
      }

      final deck = Deck.create(
        id: _uuid.v4(),
        name: name.trim(),
        description: description?.trim(),
        userId: userId,
        folderId: folderId,
      );

      await _database.deckDao.createDeck(deck.toCompanion());

      return Right(deck);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to create deck: $e'));
    }
  }

  @override
  Future<Either<Failure, Deck>> updateDeck({
    required String id,
    String? name,
    String? description,
    String? folderId,
  }) async {
    try {
      final existingDeck = await _database.deckDao.getDeckById(id);
      if (existingDeck == null) {
        return Left(const LocalStorageFailure(
          message: 'Deck not found',
          code: 'not-found',
        ));
      }

      final newName = name?.trim() ?? existingDeck.name;
      if (newName.isEmpty) {
        return Left(ValidationFailure.empty('Deck name'));
      }

      final now = DateTime.now();
      final updatedCompanion = DeckTableCompanion(
        id: Value(id),
        name: Value(newName),
        description: Value(description?.trim() ?? existingDeck.description),
        userId: Value(existingDeck.userId),
        folderId: Value(folderId ?? existingDeck.folderId),
        createdAt: Value(existingDeck.createdAt),
        updatedAt: Value(now),
        isSynced: const Value(false),
        remoteId: Value(existingDeck.remoteId),
      );

      await _database.deckDao.updateDeck(updatedCompanion);

      final cardCount = await _database.cardDao.getCardCount(id);
      final updatedDeck = Deck(
        id: id,
        name: newName,
        description: description?.trim() ?? existingDeck.description,
        userId: existingDeck.userId,
        folderId: folderId ?? existingDeck.folderId,
        createdAt: existingDeck.createdAt,
        updatedAt: now,
        cardCount: cardCount,
        isSynced: false,
        remoteId: existingDeck.remoteId,
      );

      return Right(updatedDeck);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to update deck: $e'));
    }
  }

  @override
  Future<Either<Failure, Deck>> moveDeck({
    required String id,
    String? folderId,
  }) async {
    return updateDeck(id: id, folderId: folderId);
  }

  @override
  Future<Either<Failure, void>> deleteDeck({
    required String id,
    required DeleteDeckAction action,
  }) async {
    try {
      final deck = await _database.deckDao.getDeckById(id);
      if (deck == null) {
        return Left(const LocalStorageFailure(
          message: 'Deck not found',
          code: 'not-found',
        ));
      }

      switch (action) {
        case DeleteDeckAction.archiveCards:
          await _database.cardDao.softDeleteCardsByDeck(id);
          break;
        case DeleteDeckAction.deleteCards:
          await _database.cardDao.deleteCardsByDeck(id);
          break;
      }

      await _database.deckDao.deleteDeck(id);

      return const Right(null);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to delete deck: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deckNameExists(String name) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return const Right(false);

      final decks = await _database.deckDao.getDecks(userId);
      final exists = decks.any(
        (d) => d.name.toLowerCase() == name.trim().toLowerCase(),
      );
      return Right(exists);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(
        message: 'Failed to check deck name: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, int>> getCardCount(String deckId) async {
    try {
      final count = await _database.cardDao.getCardCount(deckId);
      return Right(count);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(
        message: 'Failed to get card count: $e',
      ));
    }
  }
}
