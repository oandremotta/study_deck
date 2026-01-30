import 'package:drift/drift.dart';

import '../../domain/entities/deck.dart';
import '../datasources/local/database.dart';
import '../datasources/remote/contracts/data_remote_datasource.dart';

/// Extension to convert between Deck entity and database/remote models.
extension DeckModelExtension on Deck {
  /// Converts to Drift companion for database operations.
  DeckTableCompanion toCompanion() {
    return DeckTableCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      userId: Value(userId),
      folderId: Value(folderId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      remoteId: Value(remoteId),
    );
  }
}

/// Extension to convert database model to domain entity.
extension DeckTableDataExtension on DeckTableData {
  /// Converts to domain Deck entity.
  Deck toEntity({int cardCount = 0, int dueCardCount = 0}) {
    return Deck(
      id: id,
      name: name,
      description: description,
      userId: userId,
      folderId: folderId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      cardCount: cardCount,
      dueCardCount: dueCardCount,
      isSynced: isSynced,
      remoteId: remoteId,
    );
  }
}

/// Extension to convert remote deck to domain entity.
extension RemoteDeckExtension on RemoteDeck {
  /// Converts to domain Deck entity.
  Deck toEntity({
    required String localId,
    String? localFolderId,
    int cardCount = 0,
    int dueCardCount = 0,
  }) {
    return Deck(
      id: localId,
      name: name,
      description: description,
      userId: userId,
      folderId: localFolderId ?? folderId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      cardCount: cardCount,
      dueCardCount: dueCardCount,
      isSynced: true,
      remoteId: id,
    );
  }
}
