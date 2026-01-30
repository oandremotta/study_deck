import '../entities/user.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../../core/constants/app_constants.dart';

/// Contract for user profile operations.
///
/// Handles local user management and cloud synchronization.
abstract class UserRepository {
  /// Gets the local user profile.
  Future<Either<Failure, User?>> getLocalUser();

  /// Creates a new local user profile.
  ///
  /// Used for UC01 - Use without account.
  Future<Either<Failure, User>> createLocalUser();

  /// Updates the local user profile.
  Future<Either<Failure, User>> updateLocalUser(User user);

  /// Links a local user to a remote (authenticated) account.
  ///
  /// UC03 - Link local data to account.
  Future<Either<Failure, User>> linkLocalToRemote({
    required String remoteId,
    required String? email,
    required String? displayName,
  });

  /// Checks if there are local data that need to be synced.
  ///
  /// Used in UC03 to detect if user has local data.
  Future<Either<Failure, bool>> hasLocalData();

  /// Checks if there are remote data for the given user.
  ///
  /// Used in UC03 to detect if user has cloud data.
  Future<Either<Failure, bool>> hasRemoteData(String remoteId);

  /// Detects sync conflicts between local and remote data.
  ///
  /// UC03 - Determines which sync strategies are available.
  Future<Either<Failure, SyncConflictInfo>> detectSyncConflict(String remoteId);

  /// Executes the chosen sync strategy.
  ///
  /// UC03 - Sync local data with cloud based on user choice.
  Future<Either<Failure, void>> executeSyncStrategy({
    required String remoteId,
    required SyncStrategy strategy,
  });

  /// Marks the user as having completed onboarding.
  Future<Either<Failure, void>> setOnboardingComplete();

  /// Checks if the user has completed onboarding.
  Future<bool> isOnboardingComplete();
}

/// Information about sync conflicts.
class SyncConflictInfo {
  /// Whether local data exists.
  final bool hasLocalData;

  /// Whether remote data exists.
  final bool hasRemoteData;

  /// Timestamp of last local modification.
  final DateTime? localLastModified;

  /// Timestamp of last remote modification.
  final DateTime? remoteLastModified;

  /// Available sync strategies based on the conflict state.
  final List<SyncStrategy> availableStrategies;

  const SyncConflictInfo({
    required this.hasLocalData,
    required this.hasRemoteData,
    this.localLastModified,
    this.remoteLastModified,
    required this.availableStrategies,
  });

  /// Returns true if there's a conflict (both local and remote have data).
  bool get hasConflict => hasLocalData && hasRemoteData;
}
