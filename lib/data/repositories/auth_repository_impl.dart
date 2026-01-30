import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/database.dart';
import '../datasources/remote/contracts/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Implementation of [AuthRepository].
///
/// Coordinates between remote authentication and local storage.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final AppDatabase _database;
  final Uuid _uuid;

  User? _currentUser;
  StreamController<User?>? _authStateController;
  bool _isListenerSetUp = false;

  AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDatasource,
    required AppDatabase database,
    Uuid? uuid,
  })  : _remoteDatasource = remoteDatasource,
        _database = database,
        _uuid = uuid ?? const Uuid();

  @override
  Stream<User?> get authStateChanges {
    _authStateController ??= StreamController<User?>.broadcast();

    // Only set up listener once
    if (!_isListenerSetUp) {
      _isListenerSetUp = true;

      // Listen to remote auth changes
      _remoteDatasource.authStateChanges.listen((remoteUser) async {
        if (remoteUser != null) {
          // User signed in remotely, update local state
          final localUser = await _database.userDao.getUser();
          if (localUser != null) {
            _currentUser = localUser.toEntity();
          }
        } else {
          // Check if we have a local anonymous user
          final localUser = await _database.userDao.getUser();
          if (localUser != null && localUser.isAnonymous) {
            _currentUser = localUser.toEntity();
          } else {
            _currentUser = null;
          }
        }
        _authStateController?.add(_currentUser);
      });

      // Also check local user on init
      _initLocalUser();
    }

    return _authStateController!.stream;
  }

  Future<void> _initLocalUser() async {
    final localUser = await _database.userDao.getUser();
    if (localUser != null) {
      _currentUser = localUser.toEntity();
      _authStateController?.add(_currentUser);
    }
  }

  @override
  User? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  bool get isAnonymous => _currentUser?.isAnonymous ?? true;

  @override
  Future<Either<Failure, User>> useWithoutAccount() async {
    try {
      // Check if user already exists
      final existingUser = await _database.userDao.getUser();
      if (existingUser != null) {
        _currentUser = existingUser.toEntity();
        _authStateController?.add(_currentUser);
        return Right(_currentUser!);
      }

      // Create new anonymous user
      final user = User.anonymous(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
      );

      await _database.userDao.upsertUser(user.toCompanion());

      _currentUser = user;
      _authStateController?.add(_currentUser);

      return Right(user);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(
        message: 'Failed to create local profile: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final remoteUser = await _remoteDatasource.signInWithGoogle();
      return _handleRemoteSignIn(remoteUser);
    } on AuthException catch (e) {
      if (e.code == 'google-sign-in-cancelled') {
        return Left(AuthFailure.cancelled());
      }
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      final remoteUser = await _remoteDatasource.signInWithApple();
      return _handleRemoteSignIn(remoteUser);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final remoteUser = await _remoteDatasource.signInWithEmail(
        email: email,
        password: password,
      );
      return _handleRemoteSignIn(remoteUser);
    } on AuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return Left(AuthFailure.invalidCredentials());
      }
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final remoteUser = await _remoteDatasource.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      return _handleRemoteSignIn(remoteUser);
    } on AuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return Left(AuthFailure.emailInUse());
      }
      if (e.code == 'weak-password') {
        return Left(AuthFailure.weakPassword());
      }
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure.unknown(e.toString()));
    }
  }

  Future<Either<Failure, User>> _handleRemoteSignIn(RemoteUser remoteUser) async {
    try {
      // Check if we have a local user
      final localUser = await _database.userDao.getUser();

      if (localUser != null && localUser.isAnonymous) {
        // Local anonymous user exists - will need to handle sync
        // For now, just update the local user with remote info
        final updatedUser = User(
          id: localUser.id,
          email: remoteUser.email,
          displayName: remoteUser.displayName,
          isAnonymous: false,
          createdAt: localUser.createdAt,
          lastSyncAt: DateTime.now(),
          remoteId: remoteUser.id,
        );

        await _database.userDao.upsertUser(updatedUser.toCompanion());
        _currentUser = updatedUser;
      } else {
        // No local user or already authenticated - create/update
        final user = remoteUser.toEntity(
          createdAt: DateTime.now(),
          lastSyncAt: DateTime.now(),
        );

        await _database.userDao.upsertUser(user.toCompanion());
        _currentUser = user;
      }

      _authStateController?.add(_currentUser);
      return Right(_currentUser!);
    } catch (e) {
      return Left(LocalStorageFailure(
        message: 'Failed to save user locally: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDatasource.signOut();

      // Keep local data but mark as anonymous
      final localUser = await _database.userDao.getUser();
      if (localUser != null) {
        final anonymousUser = User(
          id: localUser.id,
          email: null,
          displayName: null,
          isAnonymous: true,
          createdAt: localUser.createdAt,
          lastSyncAt: null,
          remoteId: null,
        );
        await _database.userDao.upsertUser(anonymousUser.toCompanion());
        _currentUser = anonymousUser;
      } else {
        _currentUser = null;
      }

      _authStateController?.add(_currentUser);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure.unknown(e.toString()));
    }
  }

  void dispose() {
    _authStateController?.close();
  }
}
