import '../entities/folder.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../../core/constants/app_constants.dart';

/// Contract for folder operations.
///
/// Handles CRUD operations for folders (UC04, UC05, UC06).
abstract class FolderRepository {
  /// Watches all folders for the current user.
  ///
  /// Returns a stream that emits the list of folders whenever it changes.
  Stream<List<Folder>> watchFolders();

  /// Gets all folders for the current user.
  Future<Either<Failure, List<Folder>>> getFolders();

  /// Gets a single folder by ID.
  Future<Either<Failure, Folder?>> getFolderById(String id);

  /// Creates a new folder.
  ///
  /// UC04 - Create folder.
  Future<Either<Failure, Folder>> createFolder(String name);

  /// Updates an existing folder.
  ///
  /// UC05 - Edit folder.
  Future<Either<Failure, Folder>> updateFolder({
    required String id,
    required String name,
  });

  /// Deletes a folder.
  ///
  /// UC06 - Delete folder.
  ///
  /// If the folder contains decks, [action] determines what happens to them:
  /// - [DeleteFolderAction.moveDecksToRoot]: Decks are moved to root (no folder)
  /// - [DeleteFolderAction.deleteDecks]: Decks are deleted along with the folder
  Future<Either<Failure, void>> deleteFolder({
    required String id,
    required DeleteFolderAction action,
  });

  /// Checks if a folder with the given name already exists.
  Future<Either<Failure, bool>> folderNameExists(String name);
}
