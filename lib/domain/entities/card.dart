import 'package:equatable/equatable.dart';

/// Represents a flashcard within a deck.
///
/// A card has a pedagogical structure:
/// - [front]: the question
/// - [summary]: short answer (≤240 chars, mandatory for new cards)
/// - [keyPhrase]: memory anchor phrase (≤120 chars, mandatory for new cards)
/// - [back]: full explanation (optional, for deeper learning)
/// - [hint]: optional hint before revealing answer
///
/// Supports soft delete via [deletedAt] field.
class Card extends Equatable {
  /// Maximum length for summary field.
  static const int maxSummaryLength = 240;

  /// Maximum length for key phrase field.
  static const int maxKeyPhraseLength = 120;

  /// Unique identifier (UUID).
  final String id;

  /// ID of the deck containing this card.
  final String deckId;

  /// Front side content (question).
  final String front;

  /// Short answer/summary (≤240 chars).
  /// This is shown first when revealing the answer.
  final String? summary;

  /// Memory anchor phrase (≤120 chars).
  /// A simple, memorable statement that captures the key concept.
  final String? keyPhrase;

  /// Full explanation/answer (optional).
  /// Shown only when user requests "Ver explicação completa".
  /// Legacy cards store the full answer here.
  final String back;

  /// Optional hint to help remember the answer.
  final String? hint;

  /// Path to attached media file (image/audio) - local path.
  final String? mediaPath;

  /// Type of attached media ('image', 'audio', or null).
  final String? mediaType;

  /// URL of the image in Firebase Storage.
  final String? imageUrl;

  /// Whether to use the image as the front of the card (UC125).
  final bool imageAsFront;

  /// Status of image upload ('pending', 'uploading', 'completed', 'failed').
  final String? imageUploadStatus;

  /// UC201-202: URL of AI-generated TTS audio in Firebase Storage.
  final String? audioUrl;

  /// UC203: URL of user-recorded pronunciation audio.
  final String? pronunciationUrl;

  /// When the card was created.
  final DateTime createdAt;

  /// When the card was last updated.
  final DateTime updatedAt;

  /// When the card was soft-deleted (null = not deleted).
  final DateTime? deletedAt;

  /// Whether this card has been synced with the cloud.
  final bool isSynced;

  /// Remote ID if synced with cloud.
  final String? remoteId;

  /// List of tag IDs associated with this card.
  final List<String> tagIds;

  const Card({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.summary,
    this.keyPhrase,
    this.hint,
    this.mediaPath,
    this.mediaType,
    this.imageUrl,
    this.imageAsFront = false,
    this.imageUploadStatus,
    this.audioUrl,
    this.pronunciationUrl,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isSynced = false,
    this.remoteId,
    this.tagIds = const [],
  });

  /// Creates a new card with the given content.
  factory Card.create({
    required String id,
    required String deckId,
    required String front,
    required String back,
    String? summary,
    String? keyPhrase,
    String? hint,
    String? mediaPath,
    String? mediaType,
    String? imageUrl,
    bool imageAsFront = false,
    String? imageUploadStatus,
    String? audioUrl,
    String? pronunciationUrl,
    List<String> tagIds = const [],
  }) {
    final now = DateTime.now();
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
      createdAt: now,
      updatedAt: now,
      tagIds: tagIds,
    );
  }

  /// Returns true if this card is in the trash.
  bool get isDeleted => deletedAt != null;

  /// Returns true if this card has attached media.
  bool get hasMedia => mediaPath != null && mediaType != null;

  /// Returns true if this card has an image (local or remote).
  bool get hasImage => imageUrl != null || (mediaPath != null && mediaType == 'image');

  /// Returns the display image URL (prefer remote, fallback to local).
  String? get displayImageUrl => imageUrl ?? (mediaType == 'image' ? mediaPath : null);

  /// Returns true if image upload is pending.
  bool get isImageUploadPending => imageUploadStatus == 'pending' || imageUploadStatus == 'uploading';

  /// UC201: Returns true if this card has TTS audio.
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  /// UC203: Returns true if this card has user pronunciation recording.
  bool get hasPronunciation => pronunciationUrl != null && pronunciationUrl!.isNotEmpty;

  /// Returns true if this card has any audio content.
  bool get hasAnyAudio => hasAudio || hasPronunciation;

  /// Returns true if this card has a hint.
  bool get hasHint => hint != null && hint!.isNotEmpty;

  /// Returns true if this card has tags.
  bool get hasTags => tagIds.isNotEmpty;

  /// Creates a copy of this card with the given fields replaced.
  Card copyWith({
    String? id,
    String? deckId,
    String? front,
    String? back,
    String? summary,
    String? keyPhrase,
    String? hint,
    String? mediaPath,
    String? mediaType,
    String? imageUrl,
    bool? imageAsFront,
    String? imageUploadStatus,
    String? audioUrl,
    String? pronunciationUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isSynced,
    String? remoteId,
    List<String>? tagIds,
  }) {
    return Card(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      summary: summary ?? this.summary,
      keyPhrase: keyPhrase ?? this.keyPhrase,
      hint: hint ?? this.hint,
      mediaPath: mediaPath ?? this.mediaPath,
      mediaType: mediaType ?? this.mediaType,
      imageUrl: imageUrl ?? this.imageUrl,
      imageAsFront: imageAsFront ?? this.imageAsFront,
      imageUploadStatus: imageUploadStatus ?? this.imageUploadStatus,
      audioUrl: audioUrl ?? this.audioUrl,
      pronunciationUrl: pronunciationUrl ?? this.pronunciationUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
      remoteId: remoteId ?? this.remoteId,
      tagIds: tagIds ?? this.tagIds,
    );
  }

  /// Creates a copy with deletedAt cleared (for restore).
  Card restore() {
    return copyWith(
      deletedAt: null,
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a copy with deletedAt set (for soft delete).
  Card softDelete() {
    return copyWith(
      deletedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Returns true if this card has the pedagogical fields filled.
  bool get hasPedagogicalFields =>
      summary != null && summary!.isNotEmpty &&
      keyPhrase != null && keyPhrase!.isNotEmpty;

  /// Returns true if this card needs migration (legacy card without summary/keyPhrase).
  bool get needsMigration => !hasPedagogicalFields;

  /// Returns the display summary (fallback to first part of back for legacy cards).
  String get displaySummary {
    if (summary != null && summary!.isNotEmpty) {
      return summary!;
    }
    // Fallback: use first 240 chars of back
    if (back.length <= maxSummaryLength) {
      return back;
    }
    return '${back.substring(0, maxSummaryLength - 3)}...';
  }

  /// Returns the display key phrase (fallback to first sentence for legacy cards).
  String get displayKeyPhrase {
    if (keyPhrase != null && keyPhrase!.isNotEmpty) {
      return keyPhrase!;
    }
    // Fallback: extract first sentence from summary or back
    final source = summary ?? back;
    final firstSentence = source.split(RegExp(r'[.!?]')).first.trim();
    if (firstSentence.length <= maxKeyPhraseLength) {
      return firstSentence;
    }
    return '${firstSentence.substring(0, maxKeyPhraseLength - 3)}...';
  }

  /// Returns true if this card has a long explanation (beyond the summary).
  bool get hasExplanation => back.isNotEmpty && (summary == null || back != summary);

  @override
  List<Object?> get props => [
        id,
        deckId,
        front,
        back,
        summary,
        keyPhrase,
        hint,
        mediaPath,
        mediaType,
        imageUrl,
        imageAsFront,
        imageUploadStatus,
        audioUrl,
        pronunciationUrl,
        createdAt,
        updatedAt,
        deletedAt,
        isSynced,
        remoteId,
        tagIds,
      ];

  @override
  String toString() =>
      'Card(id: $id, front: ${front.length > 20 ? '${front.substring(0, 20)}...' : front}, isDeleted: $isDeleted)';
}
