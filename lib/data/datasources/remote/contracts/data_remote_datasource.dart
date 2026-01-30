/// Contract for remote data operations.
///
/// This interface defines all remote data storage operations.
/// Implementations can use Firestore, Supabase, or any other backend.
///
/// **Migration point**: To switch from Firebase to another backend,
/// create a new implementation of this interface.
abstract class DataRemoteDatasource {
  /// Gets all folders for a user from remote storage.
  Future<List<RemoteFolder>> getFolders(String userId);

  /// Creates a folder in remote storage.
  Future<RemoteFolder> createFolder({
    required String userId,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
  });

  /// Updates a folder in remote storage.
  Future<RemoteFolder> updateFolder({
    required String remoteId,
    required String name,
    required DateTime updatedAt,
  });

  /// Deletes a folder from remote storage.
  Future<void> deleteFolder(String remoteId);

  /// Gets all decks for a user from remote storage.
  Future<List<RemoteDeck>> getDecks(String userId);

  /// Creates a deck in remote storage.
  Future<RemoteDeck> createDeck({
    required String userId,
    required String name,
    String? description,
    String? folderId,
    required DateTime createdAt,
    required DateTime updatedAt,
  });

  /// Updates a deck in remote storage.
  Future<RemoteDeck> updateDeck({
    required String remoteId,
    required String name,
    String? description,
    String? folderId,
    required DateTime updatedAt,
  });

  /// Deletes a deck from remote storage.
  Future<void> deleteDeck(String remoteId);

  /// Deletes all decks in a folder.
  Future<void> deleteDecksByFolder(String remoteFolderId);

  /// Moves decks from a folder to root.
  Future<void> moveDecksToRoot(String remoteFolderId);

  /// Gets the last sync timestamp for a user.
  Future<DateTime?> getLastSyncTime(String userId);

  /// Checks if the user has any data in remote storage.
  Future<bool> hasData(String userId);
}

/// Represents a folder from remote storage.
class RemoteFolder {
  final String id;
  final String name;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RemoteFolder({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// Represents a deck from remote storage.
class RemoteDeck {
  final String id;
  final String name;
  final String? description;
  final String userId;
  final String? folderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RemoteDeck({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    this.folderId,
    required this.createdAt,
    required this.updatedAt,
  });
}
