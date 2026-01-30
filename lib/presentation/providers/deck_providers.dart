import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/deck_repository_impl.dart';
import '../../domain/entities/deck.dart';
import '../../domain/repositories/deck_repository.dart';
import 'auth_providers.dart';
import 'database_providers.dart';

part 'deck_providers.g.dart';

/// Provider for the deck repository.
@Riverpod(keepAlive: true)
DeckRepository deckRepository(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return DeckRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    getCurrentUserId: () async {
      return authRepo.currentUser?.id;
    },
  );
}

/// Stream provider for watching all decks.
@riverpod
Stream<List<Deck>> watchDecks(Ref ref) {
  return ref.watch(deckRepositoryProvider).watchDecks();
}

/// Stream provider for watching decks in a folder.
@riverpod
Stream<List<Deck>> watchDecksByFolder(Ref ref, String? folderId) {
  return ref.watch(deckRepositoryProvider).watchDecksByFolder(folderId);
}

/// Provider for getting all decks.
@riverpod
Future<List<Deck>> decks(Ref ref) async {
  final result = await ref.watch(deckRepositoryProvider).getDecks();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (decks) => decks,
  );
}

/// Provider for getting a single deck.
@riverpod
Future<Deck?> deckById(Ref ref, String id) async {
  final result = await ref.watch(deckRepositoryProvider).getDeckById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (deck) => deck,
  );
}

/// Creates a new deck directly via repository.
Future<Deck> createDeckDirect(
  DeckRepository repository, {
  required String name,
  String? description,
  String? folderId,
}) async {
  final result = await repository.createDeck(
    name: name,
    description: description,
    folderId: folderId,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (deck) => deck,
  );
}

/// Updates a deck directly via repository.
Future<Deck> updateDeckDirect(
  DeckRepository repository, {
  required String id,
  String? name,
  String? description,
  String? folderId,
}) async {
  final result = await repository.updateDeck(
    id: id,
    name: name,
    description: description,
    folderId: folderId,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (deck) => deck,
  );
}

/// Deletes a deck directly via repository.
Future<void> deleteDeckDirect(
  DeckRepository repository,
  String id,
  DeleteDeckAction action,
) async {
  final result = await repository.deleteDeck(id: id, action: action);
  result.fold(
    (failure) => throw Exception(failure.message),
    (_) {},
  );
}

/// Notifier for deck operations.
@riverpod
class DeckNotifier extends _$DeckNotifier {
  @override
  FutureOr<void> build() {
    // Initial state - nothing to load
  }

  /// Creates a new deck.
  Future<Deck?> createDeck({
    required String name,
    String? description,
    String? folderId,
  }) async {
    state = const AsyncLoading();

    final repository = ref.read(deckRepositoryProvider);
    final result = await repository.createDeck(
      name: name,
      description: description,
      folderId: folderId,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (deck) {
        state = const AsyncData(null);
        ref.invalidate(watchDecksProvider);
        if (folderId != null) {
          ref.invalidate(watchDecksByFolderProvider(folderId));
        }
        return deck;
      },
    );
  }

  /// Updates a deck.
  Future<Deck?> updateDeck({
    required String id,
    String? name,
    String? description,
    String? folderId,
  }) async {
    state = const AsyncLoading();

    final repository = ref.read(deckRepositoryProvider);
    final result = await repository.updateDeck(
      id: id,
      name: name,
      description: description,
      folderId: folderId,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (deck) {
        state = const AsyncData(null);
        ref.invalidate(watchDecksProvider);
        ref.invalidate(deckByIdProvider(id));
        return deck;
      },
    );
  }

  /// Moves a deck to a different folder.
  Future<Deck?> moveDeck({
    required String id,
    String? folderId,
  }) async {
    state = const AsyncLoading();

    final repository = ref.read(deckRepositoryProvider);
    final result = await repository.moveDeck(id: id, folderId: folderId);

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (deck) {
        state = const AsyncData(null);
        ref.invalidate(watchDecksProvider);
        ref.invalidate(deckByIdProvider(id));
        return deck;
      },
    );
  }

  /// Deletes a deck.
  Future<bool> deleteDeck(String id, DeleteDeckAction action) async {
    state = const AsyncLoading();

    final repository = ref.read(deckRepositoryProvider);
    final result = await repository.deleteDeck(id: id, action: action);

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(watchDecksProvider);
        return true;
      },
    );
  }
}
