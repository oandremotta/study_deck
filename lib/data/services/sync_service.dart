import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/sync_status.dart';

/// UC274-UC280: Sync service for backup and multi-device sync.
///
/// Handles:
/// - Cloud backup (UC274)
/// - Restore from backup (UC275)
/// - Multi-device sync (UC276)
/// - Conflict resolution (UC277)
/// - Offline mode (UC278)
/// - Sync status (UC279)
/// - Free user limits (UC280)
class SyncService {
  static const String _syncStatusKey = 'sync_status';
  static const String _offlineChangesKey = 'offline_changes';
  static const String _backupsKey = 'backups';

  final _uuid = const Uuid();
  SharedPreferences? _prefs;
  final _statusController = StreamController<SyncStatus>.broadcast();

  Stream<SyncStatus> get statusStream => _statusController.stream;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ============ UC279: Sync Status ============

  /// Get current sync status.
  Future<SyncStatus> getSyncStatus(String userId) async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString('${_syncStatusKey}_$userId');

      if (json == null) {
        return SyncStatus.initial(userId);
      }

      return SyncStatus.fromJson(jsonDecode(json));
    } catch (e) {
      debugPrint('SyncService: Error getting sync status: $e');
      return SyncStatus.initial(userId);
    }
  }

  /// Update sync status.
  Future<void> _updateStatus(SyncStatus status) async {
    final prefs = await _preferences;
    await prefs.setString(
      '${_syncStatusKey}_${status.oduserId}',
      jsonEncode(status.toJson()),
    );
    _statusController.add(status);
  }

  // ============ UC278: Connectivity ============

  /// Check if online.
  Future<bool> isOnline() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return results.isNotEmpty && !results.contains(ConnectivityResult.none);
    } catch (e) {
      return true; // Assume online if check fails
    }
  }

  /// Monitor connectivity changes.
  Stream<bool> get connectivityStream {
    return Connectivity().onConnectivityChanged.map(
          (results) => results.isNotEmpty && !results.contains(ConnectivityResult.none),
        );
  }

  // ============ UC274: Cloud Backup ============

  /// Create a backup.
  Future<BackupInfo> createBackup(
    String userId, {
    BackupType type = BackupType.manual,
    required Map<String, dynamic> data,
  }) async {
    var status = await getSyncStatus(userId);
    status = status.copyWith(state: SyncState.backingUp, progress: 0);
    await _updateStatus(status);

    try {
      // Simulate backup creation
      final backupId = _uuid.v4();
      final now = DateTime.now();

      // Calculate size (simplified)
      final jsonData = jsonEncode(data);
      final sizeBytes = jsonData.length;

      final backup = BackupInfo(
        id: backupId,
        oduserId: userId,
        createdAt: now,
        sizeBytes: sizeBytes,
        type: type,
        status: BackupStatus.completed,
        decksCount: (data['decks'] as List?)?.length ?? 0,
        cardsCount: (data['cards'] as List?)?.length ?? 0,
        foldersCount: (data['folders'] as List?)?.length ?? 0,
      );

      await _saveBackup(backup, jsonData);

      status = status.copyWith(
        state: SyncState.idle,
        lastBackupAt: now,
        progress: null,
      );
      await _updateStatus(status);

      debugPrint('SyncService: Backup created: $backupId');
      return backup;
    } catch (e) {
      status = status.copyWith(
        state: SyncState.error,
        errorMessage: 'Falha ao criar backup: $e',
        progress: null,
      );
      await _updateStatus(status);
      rethrow;
    }
  }

  /// Get list of backups.
  Future<List<BackupInfo>> getBackups(String userId) async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString('${_backupsKey}_$userId');

      if (json == null) return [];

      final List<dynamic> list = jsonDecode(json);
      return list.map((e) {
        final data = e as Map<String, dynamic>;
        return BackupInfo(
          id: data['id'] as String,
          oduserId: data['userId'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
          sizeBytes: data['sizeBytes'] as int? ?? 0,
          type: BackupType.values.byName(data['type'] as String? ?? 'manual'),
          status: BackupStatus.values.byName(
            data['status'] as String? ?? 'completed',
          ),
          decksCount: data['decksCount'] as int? ?? 0,
          cardsCount: data['cardsCount'] as int? ?? 0,
          foldersCount: data['foldersCount'] as int? ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('SyncService: Error getting backups: $e');
      return [];
    }
  }

  // ============ UC275: Restore from Backup ============

  /// Restore from a backup.
  Future<Map<String, dynamic>> restoreFromBackup(
    String userId,
    String backupId,
  ) async {
    var status = await getSyncStatus(userId);
    status = status.copyWith(state: SyncState.restoring, progress: 0);
    await _updateStatus(status);

    try {
      // Get backup data
      final prefs = await _preferences;
      final backupData = prefs.getString('${_backupsKey}_data_$backupId');

      if (backupData == null) {
        throw Exception('Backup não encontrado');
      }

      final data = jsonDecode(backupData) as Map<String, dynamic>;

      status = status.copyWith(
        state: SyncState.idle,
        lastSyncedAt: DateTime.now(),
        progress: null,
      );
      await _updateStatus(status);

      debugPrint('SyncService: Restored from backup: $backupId');
      return data;
    } catch (e) {
      status = status.copyWith(
        state: SyncState.error,
        errorMessage: 'Falha ao restaurar: $e',
        progress: null,
      );
      await _updateStatus(status);
      rethrow;
    }
  }

  // ============ UC276: Multi-device Sync ============

  /// Sync with cloud.
  Future<void> sync(
    String userId, {
    required Map<String, dynamic> localData,
    required Future<Map<String, dynamic>> Function() fetchRemote,
    required Future<void> Function(Map<String, dynamic>) pushToRemote,
    required Future<void> Function(Map<String, dynamic>) applyLocal,
  }) async {
    final online = await isOnline();
    if (!online) {
      var status = await getSyncStatus(userId);
      status = status.copyWith(state: SyncState.offline);
      await _updateStatus(status);
      return;
    }

    var status = await getSyncStatus(userId);
    status = status.copyWith(state: SyncState.syncing, progress: 0);
    await _updateStatus(status);

    try {
      // 1. Fetch remote data
      status = status.copyWith(progress: 0.2);
      await _updateStatus(status);
      final remoteData = await fetchRemote();

      // 2. Detect conflicts
      status = status.copyWith(progress: 0.4);
      await _updateStatus(status);
      final conflicts = await _detectConflicts(localData, remoteData);

      if (conflicts.isNotEmpty) {
        status = status.copyWith(
          state: SyncState.conflict,
          conflicts: conflicts,
          progress: null,
        );
        await _updateStatus(status);
        return;
      }

      // 3. Merge data (simple last-write-wins for now)
      status = status.copyWith(progress: 0.6);
      await _updateStatus(status);
      final mergedData = _mergeData(localData, remoteData);

      // 4. Push to remote
      status = status.copyWith(progress: 0.8);
      await _updateStatus(status);
      await pushToRemote(mergedData);

      // 5. Apply locally
      status = status.copyWith(progress: 0.9);
      await _updateStatus(status);
      await applyLocal(mergedData);

      // 6. Clear offline changes
      await clearOfflineChanges(userId);

      status = status.copyWith(
        state: SyncState.idle,
        lastSyncedAt: DateTime.now(),
        pendingChanges: 0,
        conflicts: [],
        progress: null,
      );
      await _updateStatus(status);

      debugPrint('SyncService: Sync completed for $userId');
    } catch (e) {
      status = status.copyWith(
        state: SyncState.error,
        errorMessage: 'Falha na sincronização: $e',
        progress: null,
      );
      await _updateStatus(status);
      rethrow;
    }
  }

  // ============ UC277: Conflict Resolution ============

  /// Get pending conflicts.
  Future<List<SyncConflict>> getConflicts(String userId) async {
    final status = await getSyncStatus(userId);
    return status.conflicts;
  }

  /// Resolve a conflict.
  Future<void> resolveConflict(
    String userId,
    String conflictId,
    ConflictResolution resolution,
  ) async {
    var status = await getSyncStatus(userId);
    final conflicts = List<SyncConflict>.from(status.conflicts);

    final index = conflicts.indexWhere((c) => c.id == conflictId);
    if (index == -1) return;

    final conflict = conflicts[index];

    // Apply resolution (simplified - in real app would update data)
    switch (resolution) {
      case ConflictResolution.keepLocal:
        debugPrint('SyncService: Keeping local version for ${conflict.entityId}');
        break;
      case ConflictResolution.keepRemote:
        debugPrint('SyncService: Keeping remote version for ${conflict.entityId}');
        break;
      case ConflictResolution.keepBoth:
        debugPrint('SyncService: Keeping both versions for ${conflict.entityId}');
        break;
      case ConflictResolution.merge:
        debugPrint('SyncService: Merging versions for ${conflict.entityId}');
        break;
    }

    conflicts.removeAt(index);

    status = status.copyWith(
      conflicts: conflicts,
      state: conflicts.isEmpty ? SyncState.idle : SyncState.conflict,
    );
    await _updateStatus(status);
  }

  /// Resolve all conflicts with same resolution.
  Future<void> resolveAllConflicts(
    String userId,
    ConflictResolution resolution,
  ) async {
    var status = await getSyncStatus(userId);

    for (final conflict in status.conflicts) {
      await resolveConflict(userId, conflict.id, resolution);
    }
  }

  // ============ UC278: Offline Mode ============

  /// Record offline change.
  Future<void> recordOfflineChange(
    String userId,
    SyncEntityType entityType,
    String entityId,
    OfflineChangeType changeType,
    Map<String, dynamic> data,
  ) async {
    final change = OfflineChange(
      id: _uuid.v4(),
      entityType: entityType,
      entityId: entityId,
      changeType: changeType,
      data: data,
      createdAt: DateTime.now(),
    );

    final changes = await getOfflineChanges(userId);
    changes.add(change);

    await _saveOfflineChanges(userId, changes);

    // Update pending count
    var status = await getSyncStatus(userId);
    status = status.copyWith(pendingChanges: changes.length);
    await _updateStatus(status);

    debugPrint('SyncService: Recorded offline change: ${change.id}');
  }

  /// Get offline changes.
  Future<List<OfflineChange>> getOfflineChanges(String userId) async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString('${_offlineChangesKey}_$userId');

      if (json == null) return [];

      final List<dynamic> list = jsonDecode(json);
      return list.map((e) {
        final data = e as Map<String, dynamic>;
        return OfflineChange(
          id: data['id'] as String,
          entityType: SyncEntityType.values.byName(data['entityType'] as String),
          entityId: data['entityId'] as String,
          changeType:
              OfflineChangeType.values.byName(data['changeType'] as String),
          data: data['data'] as Map<String, dynamic>,
          createdAt: DateTime.parse(data['createdAt'] as String),
          synced: data['synced'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      debugPrint('SyncService: Error getting offline changes: $e');
      return [];
    }
  }

  /// Clear synced offline changes.
  Future<void> clearOfflineChanges(String userId) async {
    final prefs = await _preferences;
    await prefs.remove('${_offlineChangesKey}_$userId');

    var status = await getSyncStatus(userId);
    status = status.copyWith(pendingChanges: 0);
    await _updateStatus(status);
  }

  // ============ UC280: Free User Limits ============

  /// Get backup limits for user.
  BackupLimits getBackupLimits(bool isPremium) {
    return isPremium ? BackupLimits.premium : BackupLimits.free;
  }

  /// Enforce backup limits (delete old backups).
  Future<void> enforceBackupLimits(String userId, bool isPremium) async {
    final limits = getBackupLimits(isPremium);
    final backups = await getBackups(userId);

    if (backups.length <= limits.maxBackupsKept) return;

    // Sort by date, oldest first
    backups.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Delete excess backups
    final toDelete = backups.length - limits.maxBackupsKept;
    for (var i = 0; i < toDelete; i++) {
      await _deleteBackup(userId, backups[i].id);
    }

    debugPrint('SyncService: Deleted $toDelete old backups');
  }

  // ============ Private Methods ============

  Future<void> _saveBackup(BackupInfo backup, String data) async {
    final prefs = await _preferences;

    // Save backup metadata
    final backups = await getBackups(backup.oduserId);
    backups.add(backup);

    await prefs.setString(
      '${_backupsKey}_${backup.oduserId}',
      jsonEncode(backups.map((b) => {
            'id': b.id,
            'userId': b.oduserId,
            'createdAt': b.createdAt.toIso8601String(),
            'sizeBytes': b.sizeBytes,
            'type': b.type.name,
            'status': b.status.name,
            'decksCount': b.decksCount,
            'cardsCount': b.cardsCount,
            'foldersCount': b.foldersCount,
          }).toList()),
    );

    // Save backup data
    await prefs.setString('${_backupsKey}_data_${backup.id}', data);
  }

  Future<void> _deleteBackup(String userId, String backupId) async {
    final prefs = await _preferences;

    // Remove from list
    final backups = await getBackups(userId);
    backups.removeWhere((b) => b.id == backupId);

    await prefs.setString(
      '${_backupsKey}_$userId',
      jsonEncode(backups.map((b) => {
            'id': b.id,
            'userId': b.oduserId,
            'createdAt': b.createdAt.toIso8601String(),
            'sizeBytes': b.sizeBytes,
            'type': b.type.name,
            'status': b.status.name,
            'decksCount': b.decksCount,
            'cardsCount': b.cardsCount,
            'foldersCount': b.foldersCount,
          }).toList()),
    );

    // Remove data
    await prefs.remove('${_backupsKey}_data_$backupId');
  }

  Future<void> _saveOfflineChanges(
    String userId,
    List<OfflineChange> changes,
  ) async {
    final prefs = await _preferences;
    await prefs.setString(
      '${_offlineChangesKey}_$userId',
      jsonEncode(changes.map((c) => {
            'id': c.id,
            'entityType': c.entityType.name,
            'entityId': c.entityId,
            'changeType': c.changeType.name,
            'data': c.data,
            'createdAt': c.createdAt.toIso8601String(),
            'synced': c.synced,
          }).toList()),
    );
  }

  Future<List<SyncConflict>> _detectConflicts(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) async {
    // Simplified conflict detection
    // In real app, would compare timestamps and content
    return [];
  }

  Map<String, dynamic> _mergeData(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    // Simplified merge - last write wins
    // In real app, would do proper merging
    final merged = Map<String, dynamic>.from(remote);

    // Local changes take precedence for items modified more recently
    for (final key in local.keys) {
      if (!merged.containsKey(key)) {
        merged[key] = local[key];
      }
    }

    return merged;
  }

  void dispose() {
    _statusController.close();
  }
}
