import 'package:drift/drift.dart';

import '../../domain/entities/folder.dart';
import '../datasources/local/database.dart';
import '../datasources/local/daos/folder_dao.dart';
import '../datasources/remote/contracts/data_remote_datasource.dart';

/// Extension to convert between Folder entity and database/remote models.
extension FolderModelExtension on Folder {
  /// Converts to Drift companion for database operations.
  FolderTableCompanion toCompanion() {
    return FolderTableCompanion(
      id: Value(id),
      name: Value(name),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      remoteId: Value(remoteId),
    );
  }
}

/// Extension to convert database model to domain entity.
extension FolderTableDataExtension on FolderTableData {
  /// Converts to domain Folder entity.
  Folder toEntity({int deckCount = 0}) {
    return Folder(
      id: id,
      name: name,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deckCount: deckCount,
      isSynced: isSynced,
      remoteId: remoteId,
    );
  }
}

/// Extension for FolderWithDeckCount.
extension FolderWithDeckCountExtension on FolderWithDeckCount {
  /// Converts to domain Folder entity.
  Folder toEntity() {
    return folder.toEntity(deckCount: deckCount);
  }
}

/// Extension to convert remote folder to domain entity.
extension RemoteFolderExtension on RemoteFolder {
  /// Converts to domain Folder entity.
  Folder toEntity({
    required String localId,
    int deckCount = 0,
  }) {
    return Folder(
      id: localId,
      name: name,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deckCount: deckCount,
      isSynced: true,
      remoteId: id,
    );
  }
}
