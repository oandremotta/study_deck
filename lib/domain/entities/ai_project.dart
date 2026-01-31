import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Source type for AI card generation.
enum AiSourceType {
  /// Generate from PDF file.
  pdf,

  /// Generate from pasted text.
  text,

  /// Generate from topic/subject.
  topic,
}

extension AiSourceTypeExtension on AiSourceType {
  String get displayName {
    switch (this) {
      case AiSourceType.pdf:
        return 'PDF';
      case AiSourceType.text:
        return 'Texto';
      case AiSourceType.topic:
        return 'Assunto';
    }
  }

  String get value {
    switch (this) {
      case AiSourceType.pdf:
        return 'pdf';
      case AiSourceType.text:
        return 'text';
      case AiSourceType.topic:
        return 'topic';
    }
  }

  static AiSourceType fromValue(String value) {
    switch (value) {
      case 'pdf':
        return AiSourceType.pdf;
      case 'text':
        return AiSourceType.text;
      case 'topic':
        return AiSourceType.topic;
      default:
        return AiSourceType.text;
    }
  }
}

/// Status of AI card generation project.
enum AiProjectStatus {
  /// Just created, not started.
  created,

  /// Extracting text from PDF.
  extracting,

  /// AI is generating cards.
  generating,

  /// Ready for user review.
  review,

  /// All cards imported, project complete.
  completed,

  /// An error occurred.
  failed,
}

extension AiProjectStatusExtension on AiProjectStatus {
  String get displayName {
    switch (this) {
      case AiProjectStatus.created:
        return 'Criado';
      case AiProjectStatus.extracting:
        return 'Extraindo texto...';
      case AiProjectStatus.generating:
        return 'Gerando cards...';
      case AiProjectStatus.review:
        return 'Pronto para revisao';
      case AiProjectStatus.completed:
        return 'Concluido';
      case AiProjectStatus.failed:
        return 'Erro';
    }
  }

  String get value {
    switch (this) {
      case AiProjectStatus.created:
        return 'created';
      case AiProjectStatus.extracting:
        return 'extracting';
      case AiProjectStatus.generating:
        return 'generating';
      case AiProjectStatus.review:
        return 'review';
      case AiProjectStatus.completed:
        return 'completed';
      case AiProjectStatus.failed:
        return 'failed';
    }
  }

  static AiProjectStatus fromValue(String value) {
    switch (value) {
      case 'created':
        return AiProjectStatus.created;
      case 'extracting':
        return AiProjectStatus.extracting;
      case 'generating':
        return AiProjectStatus.generating;
      case 'review':
        return AiProjectStatus.review;
      case 'completed':
        return AiProjectStatus.completed;
      case 'failed':
        return AiProjectStatus.failed;
      default:
        return AiProjectStatus.created;
    }
  }

  bool get isInProgress =>
      this == AiProjectStatus.extracting || this == AiProjectStatus.generating;

  bool get canResume => this == AiProjectStatus.failed;
}

/// Configuration for AI card generation.
class AiGenerationConfig extends Equatable {
  /// Number of cards to generate.
  final int cardCount;

  /// Difficulty level: 'easy', 'medium', 'hard', 'mixed'.
  final String difficulty;

  /// Target language for cards.
  final String language;

  /// Whether to include hints.
  final bool includeHints;

  const AiGenerationConfig({
    this.cardCount = 10,
    this.difficulty = 'medium',
    this.language = 'pt-BR',
    this.includeHints = true,
  });

  factory AiGenerationConfig.fromJson(Map<String, dynamic> json) {
    return AiGenerationConfig(
      cardCount: json['cardCount'] as int? ?? 10,
      difficulty: json['difficulty'] as String? ?? 'medium',
      language: json['language'] as String? ?? 'pt-BR',
      includeHints: json['includeHints'] as bool? ?? true,
    );
  }

  factory AiGenerationConfig.fromJsonString(String jsonString) {
    if (jsonString.isEmpty) return const AiGenerationConfig();
    try {
      return AiGenerationConfig.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } catch (_) {
      return const AiGenerationConfig();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'cardCount': cardCount,
      'difficulty': difficulty,
      'language': language,
      'includeHints': includeHints,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  AiGenerationConfig copyWith({
    int? cardCount,
    String? difficulty,
    String? language,
    bool? includeHints,
  }) {
    return AiGenerationConfig(
      cardCount: cardCount ?? this.cardCount,
      difficulty: difficulty ?? this.difficulty,
      language: language ?? this.language,
      includeHints: includeHints ?? this.includeHints,
    );
  }

  @override
  List<Object?> get props => [cardCount, difficulty, language, includeHints];
}

/// Represents an AI card generation project.
///
/// Tracks the entire flow from source input to card import.
class AiProject extends Equatable {
  /// Unique identifier.
  final String id;

  /// User who created this project.
  final String userId;

  /// Type of source content.
  final AiSourceType sourceType;

  /// Original file name (for PDF source).
  final String? fileName;

  /// Firebase Storage path for PDF.
  final String? pdfStoragePath;

  /// Extracted or pasted text content.
  final String? extractedText;

  /// Topic/subject for generation (for topic source).
  final String? topic;

  /// Generation configuration.
  final AiGenerationConfig config;

  /// Current status.
  final AiProjectStatus status;

  /// Error message if failed.
  final String? errorMessage;

  /// Number of cards requested.
  final int requestedCardCount;

  /// Number of cards actually generated.
  final int generatedCardCount;

  /// Number of cards approved by user.
  final int approvedCardCount;

  /// Target deck for import.
  final String? targetDeckId;

  /// When the project was created.
  final DateTime createdAt;

  /// When the project was last updated.
  final DateTime updatedAt;

  /// When the project was completed.
  final DateTime? completedAt;

  const AiProject({
    required this.id,
    required this.userId,
    required this.sourceType,
    this.fileName,
    this.pdfStoragePath,
    this.extractedText,
    this.topic,
    this.config = const AiGenerationConfig(),
    this.status = AiProjectStatus.created,
    this.errorMessage,
    this.requestedCardCount = 10,
    this.generatedCardCount = 0,
    this.approvedCardCount = 0,
    this.targetDeckId,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  /// Creates a new AI project.
  factory AiProject.create({
    required String id,
    required String userId,
    required AiSourceType sourceType,
    String? fileName,
    String? pdfStoragePath,
    String? extractedText,
    String? topic,
    AiGenerationConfig config = const AiGenerationConfig(),
  }) {
    final now = DateTime.now();
    return AiProject(
      id: id,
      userId: userId,
      sourceType: sourceType,
      fileName: fileName,
      pdfStoragePath: pdfStoragePath,
      extractedText: extractedText,
      topic: topic,
      config: config,
      requestedCardCount: config.cardCount,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Display name for the project.
  String get displayName {
    if (fileName != null) return fileName!;
    if (topic != null) return topic!;
    if (extractedText != null && extractedText!.length > 50) {
      return '${extractedText!.substring(0, 50)}...';
    }
    return extractedText ?? 'Projeto ${id.substring(0, 8)}';
  }

  /// Whether the project is in progress.
  bool get isInProgress => status.isInProgress;

  /// Whether the project can be resumed.
  bool get canResume => status.canResume;

  /// Whether the project has drafts ready for review.
  bool get hasReviewableDrafts => status == AiProjectStatus.review;

  /// Progress percentage (0-100).
  double get progress {
    if (requestedCardCount == 0) return 0;
    return generatedCardCount / requestedCardCount * 100;
  }

  AiProject copyWith({
    String? id,
    String? userId,
    AiSourceType? sourceType,
    String? fileName,
    String? pdfStoragePath,
    String? extractedText,
    String? topic,
    AiGenerationConfig? config,
    AiProjectStatus? status,
    String? errorMessage,
    int? requestedCardCount,
    int? generatedCardCount,
    int? approvedCardCount,
    String? targetDeckId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return AiProject(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sourceType: sourceType ?? this.sourceType,
      fileName: fileName ?? this.fileName,
      pdfStoragePath: pdfStoragePath ?? this.pdfStoragePath,
      extractedText: extractedText ?? this.extractedText,
      topic: topic ?? this.topic,
      config: config ?? this.config,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      requestedCardCount: requestedCardCount ?? this.requestedCardCount,
      generatedCardCount: generatedCardCount ?? this.generatedCardCount,
      approvedCardCount: approvedCardCount ?? this.approvedCardCount,
      targetDeckId: targetDeckId ?? this.targetDeckId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        sourceType,
        fileName,
        pdfStoragePath,
        extractedText,
        topic,
        config,
        status,
        errorMessage,
        requestedCardCount,
        generatedCardCount,
        approvedCardCount,
        targetDeckId,
        createdAt,
        updatedAt,
        completedAt,
      ];

  @override
  String toString() =>
      'AiProject(id: $id, sourceType: $sourceType, status: $status)';
}
