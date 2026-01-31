import 'package:drift/drift.dart';

import '../../domain/entities/ai_project.dart';
import '../datasources/local/database.dart';

/// Extension to convert between AiProject entity and database models.
extension AiProjectModelExtension on AiProject {
  /// Converts to Drift companion for database operations.
  AiProjectTableCompanion toCompanion() {
    return AiProjectTableCompanion(
      id: Value(id),
      userId: Value(userId),
      sourceType: Value(sourceType.value),
      fileName: Value(fileName),
      pdfStoragePath: Value(pdfStoragePath),
      extractedText: Value(extractedText),
      topic: Value(topic),
      configJson: Value(config.toJsonString()),
      status: Value(status.value),
      errorMessage: Value(errorMessage),
      requestedCardCount: Value(requestedCardCount),
      generatedCardCount: Value(generatedCardCount),
      approvedCardCount: Value(approvedCardCount),
      targetDeckId: Value(targetDeckId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: Value(completedAt),
    );
  }
}

/// Extension to convert database model to domain entity.
extension AiProjectTableDataExtension on AiProjectTableData {
  /// Converts to domain AiProject entity.
  AiProject toEntity() {
    return AiProject(
      id: id,
      userId: userId,
      sourceType: AiSourceTypeExtension.fromValue(sourceType),
      fileName: fileName,
      pdfStoragePath: pdfStoragePath,
      extractedText: extractedText,
      topic: topic,
      config: AiGenerationConfig.fromJsonString(configJson),
      status: AiProjectStatusExtension.fromValue(status),
      errorMessage: errorMessage,
      requestedCardCount: requestedCardCount,
      generatedCardCount: generatedCardCount,
      approvedCardCount: approvedCardCount,
      targetDeckId: targetDeckId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
    );
  }
}
