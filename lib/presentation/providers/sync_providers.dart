import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/sync_service.dart';
import '../../domain/entities/sync_status.dart';

// ============ Service Provider ============

/// Provider for sync service.
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ============ Status Providers ============

/// Provider for sync status.
final syncStatusProvider =
    FutureProvider.family<SyncStatus, String>((ref, userId) async {
  final service = ref.watch(syncServiceProvider);
  return service.getSyncStatus(userId);
});

/// Stream provider for sync status changes.
final syncStatusStreamProvider =
    StreamProvider.family<SyncStatus, String>((ref, userId) async* {
  final service = ref.watch(syncServiceProvider);

  // Emit initial status
  yield await service.getSyncStatus(userId);

  // Emit updates
  yield* service.statusStream.where((s) => s.oduserId == userId);
});

/// Provider for connectivity status.
final isOnlineProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(syncServiceProvider);
  return service.isOnline();
});

/// Stream provider for connectivity changes.
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(syncServiceProvider);
  return service.connectivityStream;
});

// ============ Backup Providers ============

/// Provider for user backups.
final backupsProvider =
    FutureProvider.family<List<BackupInfo>, String>((ref, userId) async {
  final service = ref.watch(syncServiceProvider);
  return service.getBackups(userId);
});

// ============ Offline Changes Providers ============

/// Provider for offline changes.
final offlineChangesProvider =
    FutureProvider.family<List<OfflineChange>, String>((ref, userId) async {
  final service = ref.watch(syncServiceProvider);
  return service.getOfflineChanges(userId);
});

// ============ Conflicts Providers ============

/// Provider for sync conflicts.
final syncConflictsProvider =
    FutureProvider.family<List<SyncConflict>, String>((ref, userId) async {
  final service = ref.watch(syncServiceProvider);
  return service.getConflicts(userId);
});

// ============ Direct Functions ============

/// UC274: Create backup.
Future<BackupInfo> createBackupDirect(
  SyncService service,
  String userId, {
  BackupType type = BackupType.manual,
  required Map<String, dynamic> data,
}) async {
  return service.createBackup(userId, type: type, data: data);
}

/// UC275: Restore from backup.
Future<Map<String, dynamic>> restoreFromBackupDirect(
  SyncService service,
  String userId,
  String backupId,
) async {
  return service.restoreFromBackup(userId, backupId);
}

/// UC276: Sync with cloud.
Future<void> syncDirect(
  SyncService service,
  String userId, {
  required Map<String, dynamic> localData,
  required Future<Map<String, dynamic>> Function() fetchRemote,
  required Future<void> Function(Map<String, dynamic>) pushToRemote,
  required Future<void> Function(Map<String, dynamic>) applyLocal,
}) async {
  return service.sync(
    userId,
    localData: localData,
    fetchRemote: fetchRemote,
    pushToRemote: pushToRemote,
    applyLocal: applyLocal,
  );
}

/// UC277: Resolve conflict.
Future<void> resolveConflictDirect(
  SyncService service,
  String userId,
  String conflictId,
  ConflictResolution resolution,
) async {
  return service.resolveConflict(userId, conflictId, resolution);
}

/// UC277: Resolve all conflicts.
Future<void> resolveAllConflictsDirect(
  SyncService service,
  String userId,
  ConflictResolution resolution,
) async {
  return service.resolveAllConflicts(userId, resolution);
}

/// UC278: Record offline change.
Future<void> recordOfflineChangeDirect(
  SyncService service,
  String userId,
  SyncEntityType entityType,
  String entityId,
  OfflineChangeType changeType,
  Map<String, dynamic> data,
) async {
  return service.recordOfflineChange(
    userId,
    entityType,
    entityId,
    changeType,
    data,
  );
}

/// UC278: Clear offline changes.
Future<void> clearOfflineChangesDirect(
  SyncService service,
  String userId,
) async {
  return service.clearOfflineChanges(userId);
}

/// UC279: Get sync status.
Future<SyncStatus> getSyncStatusDirect(
  SyncService service,
  String userId,
) async {
  return service.getSyncStatus(userId);
}

/// UC280: Get backup limits.
BackupLimits getBackupLimitsDirect(
  SyncService service,
  bool isPremium,
) {
  return service.getBackupLimits(isPremium);
}

/// UC280: Enforce backup limits.
Future<void> enforceBackupLimitsDirect(
  SyncService service,
  String userId,
  bool isPremium,
) async {
  return service.enforceBackupLimits(userId, isPremium);
}

/// Check if online.
Future<bool> isOnlineDirect(SyncService service) async {
  return service.isOnline();
}
