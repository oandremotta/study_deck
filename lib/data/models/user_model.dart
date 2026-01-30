import 'package:drift/drift.dart';

import '../../domain/entities/user.dart';
import '../datasources/local/database.dart';
import '../datasources/remote/contracts/auth_remote_datasource.dart';

/// Extension to convert between User entity and database/remote models.
extension UserModelExtension on User {
  /// Converts to Drift companion for database operations.
  UserTableCompanion toCompanion() {
    return UserTableCompanion(
      id: Value(id),
      email: Value(email),
      displayName: Value(displayName),
      isAnonymous: Value(isAnonymous),
      createdAt: Value(createdAt),
      lastSyncAt: Value(lastSyncAt),
      remoteId: Value(remoteId),
    );
  }
}

/// Extension to convert database model to domain entity.
extension UserTableDataExtension on UserTableData {
  /// Converts to domain User entity.
  User toEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      isAnonymous: isAnonymous,
      createdAt: createdAt,
      lastSyncAt: lastSyncAt,
      remoteId: remoteId,
    );
  }
}

/// Extension to convert remote user to domain entity.
extension RemoteUserExtension on RemoteUser {
  /// Converts to domain User entity.
  User toEntity({
    required DateTime createdAt,
    DateTime? lastSyncAt,
  }) {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      isAnonymous: false,
      createdAt: createdAt,
      lastSyncAt: lastSyncAt,
      remoteId: id,
    );
  }
}
