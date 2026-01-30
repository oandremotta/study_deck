import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';
import '../datasources/local/database.dart';
import '../models/folder_model.dart';

/// Implementation of [FolderRepository].
///
/// Handles folder CRUD operations (UC04, UC05, UC06).
class FolderRepositoryImpl implements FolderRepository {
  final AppDatabase _database;
  final Uuid _uuid;

  /// Function to get current user ID. Injected for testability.
  final Future<String?> Function() _getCurrentUserId;

  FolderRepositoryImpl({
    required AppDatabase database,
    required Future<String?> Function() getCurrentUserId,
    Uuid? uuid,
  })  : _database = database,
        _getCurrentUserId = getCurrentUserId,
        _uuid = uuid ?? const Uuid();

  @override
  Stream<List<Folder>> watchFolders() {
    return _getCurrentUserIdStream().asyncExpand((userId) {
      if (userId == null) return Stream.value(<Folder>[]);

      return _database.folderDao.watchFoldersWithDeckCount(userId).map(
            (folders) => folders.map((f) => f.toEntity()).toList(),
          );
    });
  }

  Stream<String?> _getCurrentUserIdStream() async* {
    yield await _getCurrentUserId();
  }

  @override
  Future<Either<Failure, List<Folder>>> getFolders() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return const Right([]);
      }

      final folders = await _database.folderDao.getFoldersWithDeckCount(userId);
      return Right(folders.map((f) => f.toEntity()).toList());
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to get folders: $e'));
    }
  }

  @override
  Future<Either<Failure, Folder?>> getFolderById(String id) async {
    try {
      final folderData = await _database.folderDao.getFolderById(id);
      if (folderData == null) return const Right(null);

      final deckCount = await _database.folderDao.getDeckCount(id);
      return Right(folderData.toEntity(deckCount: deckCount));
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to get folder: $e'));
    }
  }

  @override
  Future<Either<Failure, Folder>> createFolder(String name) async {
    try {
      // Validate name
      if (name.trim().isEmpty) {
        return Left(ValidationFailure.empty('Folder name'));
      }

      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Left(const LocalStorageFailure(
          message: 'No user logged in',
        ));
      }

      // Check if name already exists
      final nameExists =
          await _database.folderDao.folderNameExists(userId, name.trim());
      if (nameExists) {
        return Left(const ValidationFailure(
          message: 'A folder with this name already exists',
          code: 'name-exists',
        ));
      }

      final folder = Folder.create(
        id: _uuid.v4(),
        name: name.trim(),
        userId: userId,
      );

      await _database.folderDao.createFolder(folder.toCompanion());

      return Right(folder);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to create folder: $e'));
    }
  }

  @override
  Future<Either<Failure, Folder>> updateFolder({
    required String id,
    required String name,
  }) async {
    try {
      // Validate name
      if (name.trim().isEmpty) {
        return Left(ValidationFailure.empty('Folder name'));
      }

      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Left(const LocalStorageFailure(
          message: 'No user logged in',
        ));
      }

      // Get existing folder
      final existingFolder = await _database.folderDao.getFolderById(id);
      if (existingFolder == null) {
        return Left(const LocalStorageFailure(
          message: 'Folder not found',
          code: 'not-found',
        ));
      }

      // Check if new name already exists (excluding current folder)
      if (existingFolder.name != name.trim()) {
        final nameExists =
            await _database.folderDao.folderNameExists(userId, name.trim());
        if (nameExists) {
          return Left(const ValidationFailure(
            message: 'A folder with this name already exists',
            code: 'name-exists',
          ));
        }
      }

      final now = DateTime.now();
      final updatedCompanion = FolderTableCompanion(
        id: Value(id),
        name: Value(name.trim()),
        userId: Value(existingFolder.userId),
        createdAt: Value(existingFolder.createdAt),
        updatedAt: Value(now),
        isSynced: const Value(false), // Mark as not synced
        remoteId: Value(existingFolder.remoteId),
      );

      await _database.folderDao.updateFolder(updatedCompanion);

      final deckCount = await _database.folderDao.getDeckCount(id);
      final updatedFolder = Folder(
        id: id,
        name: name.trim(),
        userId: existingFolder.userId,
        createdAt: existingFolder.createdAt,
        updatedAt: now,
        deckCount: deckCount,
        isSynced: false,
        remoteId: existingFolder.remoteId,
      );

      return Right(updatedFolder);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to update folder: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFolder({
    required String id,
    required DeleteFolderAction action,
  }) async {
    try {
      // Get folder to check if it exists
      final folder = await _database.folderDao.getFolderById(id);
      if (folder == null) {
        return Left(const LocalStorageFailure(
          message: 'Folder not found',
          code: 'not-found',
        ));
      }

      // Handle decks based on action
      switch (action) {
        case DeleteFolderAction.moveDecksToRoot:
          await _database.deckDao.moveDecksToRoot(id);
          break;
        case DeleteFolderAction.deleteDecks:
          await _database.deckDao.deleteDecksByFolder(id);
          break;
      }

      // Delete the folder
      await _database.folderDao.deleteFolder(id);

      return const Right(null);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to delete folder: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> folderNameExists(String name) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return const Right(false);

      final exists =
          await _database.folderDao.folderNameExists(userId, name.trim());
      return Right(exists);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(
        message: 'Failed to check folder name: $e',
      ));
    }
  }
}
