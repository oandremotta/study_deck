import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'database_providers.dart';
import 'datasource_providers.dart';

part 'auth_providers.g.dart';

/// Provider for the auth repository.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    remoteDatasource: ref.watch(authRemoteDatasourceProvider),
    database: ref.watch(appDatabaseProvider),
  );
}

/// Stream provider for auth state changes.
///
/// Emits the current user whenever auth state changes.
@riverpod
Stream<User?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// Provider for the current user.
///
/// Simply reads the current user from the auth repository.
@riverpod
User? currentUser(Ref ref) {
  // Just read the current user directly - simpler approach
  return ref.watch(authRepositoryProvider).currentUser;
}

/// Provider to check if user is authenticated.
@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(authRepositoryProvider).isAuthenticated;
}

/// Provider to check if user is anonymous.
@riverpod
bool isAnonymous(Ref ref) {
  return ref.watch(authRepositoryProvider).isAnonymous;
}
