import 'package:equatable/equatable.dart';

/// Represents a flashcard within a deck.
///
/// A card has a front (question) and back (answer) side,
/// and supports soft delete via [deletedAt] field.
class Card extends Equatable {
  /// Unique identifier (UUID).
  final String id;

  /// ID of the deck containing this card.
  final String deckId;

  /// Front side content (question).
  final String front;

  /// Back side content (answer).
  final String back;

  /// Optional hint to help remember the answer.
  final String? hint;

  /// Path to attached media file (image/audio).
  final String? mediaPath;

  /// Type of attached media ('image', 'audio', or null).
  final String? mediaType;

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
    this.hint,
    this.mediaPath,
    this.mediaType,
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
    String? hint,
    String? mediaPath,
    String? mediaType,
    List<String> tagIds = const [],
  }) {
    final now = DateTime.now();
    return Card(
      id: id,
      deckId: deckId,
      front: front,
      back: back,
      hint: hint,
      mediaPath: mediaPath,
      mediaType: mediaType,
      createdAt: now,
      updatedAt: now,
      tagIds: tagIds,
    );
  }

  /// Returns true if this card is in the trash.
  bool get isDeleted => deletedAt != null;

  /// Returns true if this card has attached media.
  bool get hasMedia => mediaPath != null && mediaType != null;

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
    String? hint,
    String? mediaPath,
    String? mediaType,
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
      hint: hint ?? this.hint,
      mediaPath: mediaPath ?? this.mediaPath,
      mediaType: mediaType ?? this.mediaType,
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

  @override
  List<Object?> get props => [
        id,
        deckId,
        front,
        back,
        hint,
        mediaPath,
        mediaType,
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
