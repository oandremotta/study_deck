import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/card_repository_impl.dart';
import '../../domain/entities/card.dart';
import '../../domain/repositories/card_repository.dart';
import 'auth_providers.dart';
import 'database_providers.dart';
import 'deck_providers.dart';

part 'card_providers.g.dart';

/// Provider for the card repository.
@Riverpod(keepAlive: true)
CardRepository cardRepository(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return CardRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    getCurrentUserId: () async {
      return authRepo.currentUser?.id;
    },
    getUserDeckIds: () async {
      final decksResult = await ref.read(deckRepositoryProvider).getDecks();
      return decksResult.fold(
        (failure) => [],
        (decks) => decks.map((d) => d.id).toList(),
      );
    },
  );
}

/// Stream provider for watching cards in a deck.
@riverpod
Stream<List<Card>> watchCardsByDeck(Ref ref, String deckId) {
  return ref.watch(cardRepositoryProvider).watchCardsByDeck(deckId);
}

/// Stream provider for watching deleted cards in a deck (trash).
@riverpod
Stream<List<Card>> watchDeletedCardsByDeck(Ref ref, String deckId) {
  return ref.watch(cardRepositoryProvider).watchDeletedCardsByDeck(deckId);
}

/// Provider for getting cards in a deck.
@riverpod
Future<List<Card>> cardsByDeck(Ref ref, String deckId) async {
  final result = await ref.watch(cardRepositoryProvider).getCardsByDeck(deckId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (cards) => cards,
  );
}

/// Provider for getting all deleted cards.
@riverpod
Future<List<Card>> deletedCards(Ref ref) async {
  final result = await ref.watch(cardRepositoryProvider).getAllDeletedCards();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (cards) => cards,
  );
}

/// Provider for getting a single card.
@riverpod
Future<Card?> cardById(Ref ref, String id) async {
  final result = await ref.watch(cardRepositoryProvider).getCardById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (card) => card,
  );
}

/// Notifier for card operations.
@riverpod
class CardNotifier extends _$CardNotifier {
  @override
  FutureOr<void> build() {
    // Initial state - nothing to load
  }

  /// Creates a new card.
  Future<Card?> createCard({
    required String deckId,
    required String front,
    required String back,
    String? hint,
    List<String> tagIds = const [],
  }) async {
    state = const AsyncLoading();

    final repository = ref.read(cardRepositoryProvider);
    final result = await repository.createCard(
      deckId: deckId,
      front: front,
      back: back,
      hint: hint,
      tagIds: tagIds,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (card) {
        state = const AsyncData(null);
        ref.invalidate(watchCardsByDeckProvider(deckId));
        ref.invalidate(watchDecksProvider);
        return card;
      },
    );
  }

  /// Creates multiple cards at once.
  Future<List<Card>?> createCards(List<Card> cards) async {
    state = const AsyncLoading();

    final repository = ref.read(cardRepositoryProvider);
    final result = await repository.createCards(cards);

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (createdCards) {
        state = const AsyncData(null);
        // Invalidate all affected decks
        final deckIds = cards.map((c) => c.deckId).toSet();
        for (final deckId in deckIds) {
          ref.invalidate(watchCardsByDeckProvider(deckId));
        }
        ref.invalidate(watchDecksProvider);
        return createdCards;
      },
    );
  }

  /// Updates a card.
  Future<Card?> updateCard({
    required String id,
    required String deckId,
    String? front,
    String? back,
    String? hint,
    List<String>? tagIds,
  }) async {
    state = const AsyncLoading();

    final repository = ref.read(cardRepositoryProvider);
    final result = await repository.updateCard(
      id: id,
      front: front,
      back: back,
      hint: hint,
      tagIds: tagIds,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (card) {
        state = const AsyncData(null);
        ref.invalidate(watchCardsByDeckProvider(deckId));
        ref.invalidate(cardByIdProvider(id));
        return card;
      },
    );
  }

  /// Soft deletes a card (moves to trash).
  Future<bool> softDeleteCard(String id, String deckId) async {
    state = const AsyncLoading();

    final repository = ref.read(cardRepositoryProvider);
    final result = await repository.softDeleteCard(id);

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(watchCardsByDeckProvider(deckId));
        ref.invalidate(watchDeletedCardsByDeckProvider(deckId));
        ref.invalidate(deletedCardsProvider);
        ref.invalidate(watchDecksProvider);
        return true;
      },
    );
  }

  /// Restores a card from trash.
  Future<Card?> restoreCard(String id, String deckId) async {
    state = const AsyncLoading();

    final repository = ref.read(cardRepositoryProvider);
    final result = await repository.restoreCard(id);

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (card) {
        state = const AsyncData(null);
        ref.invalidate(watchCardsByDeckProvider(deckId));
        ref.invalidate(watchDeletedCardsByDeckProvider(deckId));
        ref.invalidate(deletedCardsProvider);
        ref.invalidate(watchDecksProvider);
        return card;
      },
    );
  }

  /// Permanently deletes a card.
  Future<bool> permanentlyDeleteCard(String id, String deckId) async {
    state = const AsyncLoading();

    final repository = ref.read(cardRepositoryProvider);
    final result = await repository.permanentlyDeleteCard(id);

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(watchDeletedCardsByDeckProvider(deckId));
        ref.invalidate(deletedCardsProvider);
        return true;
      },
    );
  }

  /// Attaches media to a card.
  Future<Card?> attachMedia({
    required String cardId,
    required String deckId,
    required String mediaPath,
    required String mediaType,
  }) async {
    state = const AsyncLoading();

    final repository = ref.read(cardRepositoryProvider);
    final result = await repository.attachMedia(
      cardId: cardId,
      mediaPath: mediaPath,
      mediaType: mediaType,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (card) {
        state = const AsyncData(null);
        ref.invalidate(watchCardsByDeckProvider(deckId));
        ref.invalidate(cardByIdProvider(cardId));
        return card;
      },
    );
  }

  /// Removes media from a card.
  Future<Card?> removeMedia(String cardId, String deckId) async {
    state = const AsyncLoading();

    final repository = ref.read(cardRepositoryProvider);
    final result = await repository.removeMedia(cardId);

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (card) {
        state = const AsyncData(null);
        ref.invalidate(watchCardsByDeckProvider(deckId));
        ref.invalidate(cardByIdProvider(cardId));
        return card;
      },
    );
  }

  /// Updates card tags.
  Future<Card?> updateCardTags({
    required String cardId,
    required String deckId,
    required List<String> tagIds,
  }) async {
    state = const AsyncLoading();

    final repository = ref.read(cardRepositoryProvider);
    final result = await repository.updateCardTags(
      cardId: cardId,
      tagIds: tagIds,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (card) {
        state = const AsyncData(null);
        ref.invalidate(watchCardsByDeckProvider(deckId));
        ref.invalidate(cardByIdProvider(cardId));
        return card;
      },
    );
  }
}

/// Creates a card directly via repository.
Future<Card> createCardDirect(
  CardRepository repository, {
  required String deckId,
  required String front,
  required String back,
  String? hint,
  List<String> tagIds = const [],
}) async {
  final result = await repository.createCard(
    deckId: deckId,
    front: front,
    back: back,
    hint: hint,
    tagIds: tagIds,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (card) => card,
  );
}

/// Updates a card directly via repository.
Future<Card> updateCardDirect(
  CardRepository repository, {
  required String id,
  String? front,
  String? back,
  String? hint,
  List<String>? tagIds,
}) async {
  final result = await repository.updateCard(
    id: id,
    front: front,
    back: back,
    hint: hint,
    tagIds: tagIds,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (card) => card,
  );
}

/// Soft deletes a card directly via repository.
Future<void> softDeleteCardDirect(CardRepository repository, String id) async {
  final result = await repository.softDeleteCard(id);
  result.fold(
    (failure) => throw Exception(failure.message),
    (_) {},
  );
}

/// Restores a card directly via repository.
Future<Card> restoreCardDirect(CardRepository repository, String id) async {
  final result = await repository.restoreCard(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (card) => card,
  );
}

/// Permanently deletes a card directly via repository.
Future<void> permanentlyDeleteCardDirect(CardRepository repository, String id) async {
  final result = await repository.permanentlyDeleteCard(id);
  result.fold(
    (failure) => throw Exception(failure.message),
    (_) {},
  );
}

/// Creates multiple cards directly via repository.
Future<List<Card>> createCardsDirect(
  CardRepository repository,
  List<Card> cards,
) async {
  final result = await repository.createCards(cards);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (createdCards) => createdCards,
  );
}
