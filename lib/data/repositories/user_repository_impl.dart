import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/database.dart';
import '../datasources/remote/contracts/data_remote_datasource.dart';
import '../models/user_model.dart';

/// Implementation of [UserRepository].
///
/// Handles user profile management and sync operations.
class UserRepositoryImpl implements UserRepository {
  final AppDatabase _database;
  final DataRemoteDatasource _remoteDatasource;
  final Uuid _uuid;

  // Simple in-memory storage for onboarding state
  // In production, use SharedPreferences
  bool _onboardingComplete = false;

  UserRepositoryImpl({
    required AppDatabase database,
    required DataRemoteDatasource remoteDatasource,
    Uuid? uuid,
  })  : _database = database,
        _remoteDatasource = remoteDatasource,
        _uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, User?>> getLocalUser() async {
    try {
      final userData = await _database.userDao.getUser();
      if (userData == null) return const Right(null);
      return Right(userData.toEntity());
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to get local user: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> createLocalUser() async {
    try {
      final user = User.anonymous(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
      );

      await _database.userDao.upsertUser(user.toCompanion());
      return Right(user);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(
        message: 'Failed to create local user: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> updateLocalUser(User user) async {
    try {
      await _database.userDao.upsertUser(user.toCompanion());
      return Right(user);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(
        message: 'Failed to update local user: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> linkLocalToRemote({
    required String remoteId,
    required String? email,
    required String? displayName,
  }) async {
    try {
      final localUser = await _database.userDao.getUser();
      if (localUser == null) {
        return Left(const LocalStorageFailure(
          message: 'No local user found to link',
        ));
      }

      final linkedUser = User(
        id: localUser.id,
        email: email,
        displayName: displayName,
        isAnonymous: false,
        createdAt: localUser.createdAt,
        lastSyncAt: DateTime.now(),
        remoteId: remoteId,
      );

      await _database.userDao.upsertUser(linkedUser.toCompanion());
      return Right(linkedUser);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(
        message: 'Failed to link local user: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> hasLocalData() async {
    try {
      final user = await _database.userDao.getUser();
      if (user == null) return const Right(false);

      // Check if there are any folders
      final folders = await _database.folderDao.getFolders(user.id);
      if (folders.isNotEmpty) return const Right(true);

      // Check if there are any decks
      final hasDecks = await _database.deckDao.hasDecks(user.id);
      return Right(hasDecks);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(
        message: 'Failed to check local data: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> hasRemoteData(String remoteId) async {
    try {
      final hasData = await _remoteDatasource.hasData(remoteId);
      return Right(hasData);
    } on ServerException catch (e) {
      return Left(NetworkFailure.serverError(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(NetworkFailure.serverError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SyncConflictInfo>> detectSyncConflict(
      String remoteId) async {
    try {
      final hasLocalResult = await hasLocalData();
      final hasRemoteResult = await hasRemoteData(remoteId);

      final hasLocal = hasLocalResult.fold((_) => false, (v) => v);
      final hasRemote = hasRemoteResult.fold((_) => false, (v) => v);

      // Determine available strategies
      final strategies = <SyncStrategy>[];

      if (hasLocal) {
        strategies.add(SyncStrategy.keepLocal);
      }
      if (hasRemote) {
        strategies.add(SyncStrategy.downloadRemote);
      }
      if (hasLocal && hasRemote) {
        strategies.add(SyncStrategy.merge);
      }

      // If no data on either side, default to keeping local
      if (strategies.isEmpty) {
        strategies.add(SyncStrategy.keepLocal);
      }

      DateTime? localLastModified;
      DateTime? remoteLastModified;

      // Get local last modified time from user
      final localUser = await _database.userDao.getUser();
      localLastModified = localUser?.createdAt;

      // Get remote last modified time
      if (hasRemote) {
        remoteLastModified = await _remoteDatasource.getLastSyncTime(remoteId);
      }

      return Right(SyncConflictInfo(
        hasLocalData: hasLocal,
        hasRemoteData: hasRemote,
        localLastModified: localLastModified,
        remoteLastModified: remoteLastModified,
        availableStrategies: strategies,
      ));
    } catch (e) {
      return Left(SyncFailure(message: 'Failed to detect sync conflict: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> executeSyncStrategy({
    required String remoteId,
    required SyncStrategy strategy,
  }) async {
    try {
      switch (strategy) {
        case SyncStrategy.keepLocal:
          // Upload local data to remote (to be implemented)
          // For now, just mark as synced
          break;

        case SyncStrategy.downloadRemote:
          // Download remote data and replace local (to be implemented)
          break;

        case SyncStrategy.merge:
          // Merge data using "most recent wins" strategy (to be implemented)
          break;
      }

      return const Right(null);
    } catch (e) {
      return Left(SyncFailure.mergeFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setOnboardingComplete() async {
    try {
      _onboardingComplete = true;
      // In production, persist this to SharedPreferences
      return const Right(null);
    } catch (e) {
      return Left(LocalStorageFailure(
        message: 'Failed to save onboarding state: $e',
      ));
    }
  }

  @override
  Future<bool> isOnboardingComplete() async {
    // In production, read from SharedPreferences
    return _onboardingComplete;
  }
}
