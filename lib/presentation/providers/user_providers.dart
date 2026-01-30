import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import 'database_providers.dart';
import 'datasource_providers.dart';

part 'user_providers.g.dart';

/// Provider for the user repository.
@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  return UserRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    remoteDatasource: ref.watch(dataRemoteDatasourceProvider),
  );
}

/// Provider to check if onboarding is complete.
@riverpod
Future<bool> isOnboardingComplete(Ref ref) async {
  return ref.watch(userRepositoryProvider).isOnboardingComplete();
}
