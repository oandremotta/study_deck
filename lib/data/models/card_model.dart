import 'package:drift/drift.dart';

import '../../domain/entities/card.dart';
import '../datasources/local/database.dart';

/// Extension to convert between Card entity and database models.
extension CardModelExtension on Card {
  /// Converts to Drift companion for database operations.
  CardTableCompanion toCompanion() {
    return CardTableCompanion(
      id: Value(id),
      deckId: Value(deckId),
      front: Value(front),
      back: Value(back),
      summary: Value(summary),
      keyPhrase: Value(keyPhrase),
      hint: Value(hint),
      mediaPath: Value(mediaPath),
      mediaType: Value(mediaType),
      imageUrl: Value(imageUrl),
      imageAsFront: Value(imageAsFront),
      imageUploadStatus: Value(imageUploadStatus),
      audioUrl: Value(audioUrl),
      pronunciationUrl: Value(pronunciationUrl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      isSynced: Value(isSynced),
      remoteId: Value(remoteId),
    );
  }
}

/// Extension to convert database model to domain entity.
extension CardTableDataExtension on CardTableData {
  /// Converts to domain Card entity.
  Card toEntity({List<String> tagIds = const []}) {
    return Card(
      id: id,
      deckId: deckId,
      front: front,
      back: back,
      summary: summary,
      keyPhrase: keyPhrase,
      hint: hint,
      mediaPath: mediaPath,
      mediaType: mediaType,
      imageUrl: imageUrl,
      imageAsFront: imageAsFront,
      imageUploadStatus: imageUploadStatus,
      audioUrl: audioUrl,
      pronunciationUrl: pronunciationUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      isSynced: isSynced,
      remoteId: remoteId,
      tagIds: tagIds,
    );
  }
}
