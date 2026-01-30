import 'package:drift/drift.dart';

import '../../domain/entities/tag.dart';
import '../datasources/local/database.dart';

/// Extension to convert between Tag entity and database models.
extension TagModelExtension on Tag {
  /// Converts to Drift companion for database operations.
  TagTableCompanion toCompanion() {
    return TagTableCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      userId: Value(userId),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
      remoteId: Value(remoteId),
    );
  }
}

/// Extension to convert database model to domain entity.
extension TagTableDataExtension on TagTableData {
  /// Converts to domain Tag entity.
  Tag toEntity({int cardCount = 0}) {
    return Tag(
      id: id,
      name: name,
      color: color,
      userId: userId,
      createdAt: createdAt,
      isSynced: isSynced,
      remoteId: remoteId,
      cardCount: cardCount,
    );
  }
}
