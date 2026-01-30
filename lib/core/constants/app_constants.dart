/// Application-wide constants.
abstract final class AppConstants {
  /// Database name for local storage.
  static const String databaseName = 'study_deck.db';

  /// Default folder name for decks without a folder.
  static const String defaultFolderName = 'Sem pasta';

  /// Shared preferences keys.
  static const String prefKeyOnboardingComplete = 'onboarding_complete';
  static const String prefKeyLocalUserId = 'local_user_id';
  static const String prefKeyLastSyncTime = 'last_sync_time';

  /// Sync strategies.
  static const String syncStrategyKeepLocal = 'keep_local';
  static const String syncStrategyDownloadRemote = 'download_remote';
  static const String syncStrategyMerge = 'merge';
}

/// Sync strategy options for UC03 (link local data).
enum SyncStrategy {
  /// Keep local data and upload to cloud.
  keepLocal,

  /// Download cloud data and replace local.
  downloadRemote,

  /// Merge local and cloud data (if available).
  merge,
}

/// Action to take when deleting a folder that contains decks.
enum DeleteFolderAction {
  /// Move decks to root (no folder).
  moveDecksToRoot,

  /// Delete decks along with the folder.
  deleteDecks,
}
