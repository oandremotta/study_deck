import 'package:equatable/equatable.dart';

/// UC274-UC280: Backup and sync entities.
///
/// Supports:
/// - Cloud backup (UC274)
/// - Restore from backup (UC275)
/// - Multi-device sync (UC276)
/// - Conflict resolution (UC277)
/// - Offline mode (UC278)
/// - Sync status display (UC279)
/// - Free user limits (UC280)

/// Overall sync status.
class SyncStatus extends Equatable {
  final String oduserId;
  final SyncState state;
  final DateTime? lastSyncedAt;
  final DateTime? lastBackupAt;
  final int pendingChanges;
  final List<SyncConflict> conflicts;
  final String? errorMessage;
  final double? progress;

  const SyncStatus({
    required this.oduserId,
    this.state = SyncState.idle,
    this.lastSyncedAt,
    this.lastBackupAt,
    this.pendingChanges = 0,
    this.conflicts = const [],
    this.errorMessage,
    this.progress,
  });

  /// Create initial status for user.
  factory SyncStatus.initial(String userId) {
    return SyncStatus(oduserId: userId);
  }

  // ============ Computed Properties ============

  bool get isSyncing => state == SyncState.syncing;

  bool get hasErrors => state == SyncState.error;

  bool get hasConflicts => conflicts.isNotEmpty;

  bool get isOffline => state == SyncState.offline;

  bool get needsSync => pendingChanges > 0;

  /// Time since last sync.
  Duration? get timeSinceLastSync {
    if (lastSyncedAt == null) return null;
    return DateTime.now().difference(lastSyncedAt!);
  }

  /// Human-readable last sync time.
  String get lastSyncDisplay {
    if (lastSyncedAt == null) return 'Nunca sincronizado';

    final diff = DateTime.now().difference(lastSyncedAt!);

    if (diff.inMinutes < 1) return 'Agora mesmo';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    if (diff.inDays < 7) return 'Há ${diff.inDays} dias';

    return '${lastSyncedAt!.day}/${lastSyncedAt!.month}/${lastSyncedAt!.year}';
  }

  SyncStatus copyWith({
    String? oduserId,
    SyncState? state,
    DateTime? lastSyncedAt,
    DateTime? lastBackupAt,
    int? pendingChanges,
    List<SyncConflict>? conflicts,
    String? errorMessage,
    double? progress,
  }) {
    return SyncStatus(
      oduserId: oduserId ?? this.oduserId,
      state: state ?? this.state,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      conflicts: conflicts ?? this.conflicts,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': oduserId,
      'state': state.name,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'lastBackupAt': lastBackupAt?.toIso8601String(),
      'pendingChanges': pendingChanges,
      'conflicts': conflicts.map((c) => c.toJson()).toList(),
      'errorMessage': errorMessage,
      'progress': progress,
    };
  }

  factory SyncStatus.fromJson(Map<String, dynamic> json) {
    return SyncStatus(
      oduserId: json['userId'] as String,
      state: SyncState.values.byName(json['state'] as String? ?? 'idle'),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
      lastBackupAt: json['lastBackupAt'] != null
          ? DateTime.parse(json['lastBackupAt'] as String)
          : null,
      pendingChanges: json['pendingChanges'] as int? ?? 0,
      conflicts: (json['conflicts'] as List<dynamic>?)
              ?.map((e) => SyncConflict.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      errorMessage: json['errorMessage'] as String?,
      progress: (json['progress'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        oduserId,
        state,
        lastSyncedAt,
        lastBackupAt,
        pendingChanges,
        conflicts,
        errorMessage,
        progress,
      ];
}

/// Sync state.
enum SyncState {
  idle,
  syncing,
  backingUp,
  restoring,
  offline,
  error,
  conflict,
}

extension SyncStateExtension on SyncState {
  String get displayName {
    switch (this) {
      case SyncState.idle:
        return 'Sincronizado';
      case SyncState.syncing:
        return 'Sincronizando...';
      case SyncState.backingUp:
        return 'Fazendo backup...';
      case SyncState.restoring:
        return 'Restaurando...';
      case SyncState.offline:
        return 'Offline';
      case SyncState.error:
        return 'Erro de sincronização';
      case SyncState.conflict:
        return 'Conflitos detectados';
    }
  }

  String get icon {
    switch (this) {
      case SyncState.idle:
        return '✓';
      case SyncState.syncing:
      case SyncState.backingUp:
      case SyncState.restoring:
        return '↻';
      case SyncState.offline:
        return '📴';
      case SyncState.error:
        return '⚠';
      case SyncState.conflict:
        return '⚡';
    }
  }
}

/// UC277: Sync conflict.
class SyncConflict extends Equatable {
  final String id;
  final SyncEntityType entityType;
  final String entityId;
  final String entityName;
  final ConflictType conflictType;
  final DateTime localModifiedAt;
  final DateTime remoteModifiedAt;
  final Map<String, dynamic>? localData;
  final Map<String, dynamic>? remoteData;
  final ConflictResolution? resolution;
  final DateTime detectedAt;

  const SyncConflict({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.entityName,
    required this.conflictType,
    required this.localModifiedAt,
    required this.remoteModifiedAt,
    this.localData,
    this.remoteData,
    this.resolution,
    required this.detectedAt,
  });

  bool get isResolved => resolution != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType.name,
      'entityId': entityId,
      'entityName': entityName,
      'conflictType': conflictType.name,
      'localModifiedAt': localModifiedAt.toIso8601String(),
      'remoteModifiedAt': remoteModifiedAt.toIso8601String(),
      'localData': localData,
      'remoteData': remoteData,
      'resolution': resolution?.name,
      'detectedAt': detectedAt.toIso8601String(),
    };
  }

  factory SyncConflict.fromJson(Map<String, dynamic> json) {
    return SyncConflict(
      id: json['id'] as String,
      entityType: SyncEntityType.values.byName(json['entityType'] as String),
      entityId: json['entityId'] as String,
      entityName: json['entityName'] as String,
      conflictType: ConflictType.values.byName(json['conflictType'] as String),
      localModifiedAt: DateTime.parse(json['localModifiedAt'] as String),
      remoteModifiedAt: DateTime.parse(json['remoteModifiedAt'] as String),
      localData: json['localData'] as Map<String, dynamic>?,
      remoteData: json['remoteData'] as Map<String, dynamic>?,
      resolution: json['resolution'] != null
          ? ConflictResolution.values.byName(json['resolution'] as String)
          : null,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        entityType,
        entityId,
        entityName,
        conflictType,
        localModifiedAt,
        remoteModifiedAt,
        resolution,
        detectedAt,
      ];
}

/// Types of entities that can be synced.
enum SyncEntityType {
  deck,
  card,
  folder,
  tag,
  studyProgress,
  settings,
}

extension SyncEntityTypeExtension on SyncEntityType {
  String get displayName {
    switch (this) {
      case SyncEntityType.deck:
        return 'Deck';
      case SyncEntityType.card:
        return 'Card';
      case SyncEntityType.folder:
        return 'Pasta';
      case SyncEntityType.tag:
        return 'Tag';
      case SyncEntityType.studyProgress:
        return 'Progresso';
      case SyncEntityType.settings:
        return 'Configurações';
    }
  }
}

/// Types of conflicts.
enum ConflictType {
  bothModified, // Both local and remote modified
  localDeleted, // Local deleted, remote modified
  remoteDeleted, // Remote deleted, local modified
  duplicateId, // Same ID, different content
}

extension ConflictTypeExtension on ConflictType {
  String get displayName {
    switch (this) {
      case ConflictType.bothModified:
        return 'Ambos modificados';
      case ConflictType.localDeleted:
        return 'Excluído localmente';
      case ConflictType.remoteDeleted:
        return 'Excluído remotamente';
      case ConflictType.duplicateId:
        return 'ID duplicado';
    }
  }

  String get description {
    switch (this) {
      case ConflictType.bothModified:
        return 'Este item foi modificado tanto localmente quanto em outro dispositivo.';
      case ConflictType.localDeleted:
        return 'Você excluiu este item, mas ele foi modificado em outro dispositivo.';
      case ConflictType.remoteDeleted:
        return 'Este item foi excluído em outro dispositivo, mas você o modificou.';
      case ConflictType.duplicateId:
        return 'Dois itens diferentes têm o mesmo identificador.';
    }
  }
}

/// UC277: Conflict resolution options.
enum ConflictResolution {
  keepLocal,
  keepRemote,
  keepBoth,
  merge,
}

extension ConflictResolutionExtension on ConflictResolution {
  String get displayName {
    switch (this) {
      case ConflictResolution.keepLocal:
        return 'Manter versão local';
      case ConflictResolution.keepRemote:
        return 'Manter versão remota';
      case ConflictResolution.keepBoth:
        return 'Manter ambas';
      case ConflictResolution.merge:
        return 'Mesclar alterações';
    }
  }

  String get description {
    switch (this) {
      case ConflictResolution.keepLocal:
        return 'Usar a versão deste dispositivo e descartar alterações remotas.';
      case ConflictResolution.keepRemote:
        return 'Usar a versão do servidor e descartar alterações locais.';
      case ConflictResolution.keepBoth:
        return 'Criar uma cópia para não perder nenhuma versão.';
      case ConflictResolution.merge:
        return 'Combinar as alterações quando possível.';
    }
  }
}

/// UC274: Backup info.
class BackupInfo extends Equatable {
  final String id;
  final String oduserId;
  final DateTime createdAt;
  final int sizeBytes;
  final BackupType type;
  final BackupStatus status;
  final int decksCount;
  final int cardsCount;
  final int foldersCount;
  final String? downloadUrl;
  final DateTime? expiresAt;

  const BackupInfo({
    required this.id,
    required this.oduserId,
    required this.createdAt,
    this.sizeBytes = 0,
    this.type = BackupType.automatic,
    this.status = BackupStatus.completed,
    this.decksCount = 0,
    this.cardsCount = 0,
    this.foldersCount = 0,
    this.downloadUrl,
    this.expiresAt,
  });

  String get sizeDisplay {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  @override
  List<Object?> get props => [
        id,
        oduserId,
        createdAt,
        sizeBytes,
        type,
        status,
        decksCount,
        cardsCount,
        foldersCount,
        downloadUrl,
        expiresAt,
      ];
}

/// Backup types.
enum BackupType {
  automatic,
  manual,
  beforeRestore,
}

extension BackupTypeExtension on BackupType {
  String get displayName {
    switch (this) {
      case BackupType.automatic:
        return 'Automático';
      case BackupType.manual:
        return 'Manual';
      case BackupType.beforeRestore:
        return 'Antes da restauração';
    }
  }
}

/// Backup status.
enum BackupStatus {
  pending,
  inProgress,
  completed,
  failed,
}

extension BackupStatusExtension on BackupStatus {
  String get displayName {
    switch (this) {
      case BackupStatus.pending:
        return 'Pendente';
      case BackupStatus.inProgress:
        return 'Em andamento';
      case BackupStatus.completed:
        return 'Concluído';
      case BackupStatus.failed:
        return 'Falhou';
    }
  }
}

/// UC280: Backup limits for free users.
class BackupLimits {
  final int maxBackupsKept;
  final int backupRetentionDays;
  final bool incrementalBackup;
  final bool autoBackup;

  const BackupLimits({
    required this.maxBackupsKept,
    required this.backupRetentionDays,
    required this.incrementalBackup,
    required this.autoBackup,
  });

  /// Free user limits.
  static const BackupLimits free = BackupLimits(
    maxBackupsKept: 3,
    backupRetentionDays: 7,
    incrementalBackup: false,
    autoBackup: false,
  );

  /// Premium user limits.
  static const BackupLimits premium = BackupLimits(
    maxBackupsKept: 30,
    backupRetentionDays: 90,
    incrementalBackup: true,
    autoBackup: true,
  );
}

/// UC278: Offline change tracking.
class OfflineChange extends Equatable {
  final String id;
  final SyncEntityType entityType;
  final String entityId;
  final OfflineChangeType changeType;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool synced;

  const OfflineChange({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.changeType,
    required this.data,
    required this.createdAt,
    this.synced = false,
  });

  @override
  List<Object?> get props => [
        id,
        entityType,
        entityId,
        changeType,
        data,
        createdAt,
        synced,
      ];
}

/// Types of offline changes.
enum OfflineChangeType {
  create,
  update,
  delete,
}
