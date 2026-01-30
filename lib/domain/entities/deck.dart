import 'package:equatable/equatable.dart';

/// Represents a deck of flashcards.
///
/// A deck belongs to a user and optionally to a folder.
/// It contains flashcards for studying.
class Deck extends Equatable {
  /// Unique identifier (UUID).
  final String id;

  /// Deck name/title.
  final String name;

  /// Optional description of the deck.
  final String? description;

  /// ID of the user who owns this deck.
  final String userId;

  /// ID of the folder containing this deck (null = root/no folder).
  final String? folderId;

  /// When the deck was created.
  final DateTime createdAt;

  /// When the deck was last updated.
  final DateTime updatedAt;

  /// Number of cards in this deck (computed field).
  final int cardCount;

  /// Number of cards due for review (computed field).
  final int dueCardCount;

  /// Whether this deck has been synced with the cloud.
  final bool isSynced;

  /// Remote ID if synced with cloud.
  final String? remoteId;

  const Deck({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    this.folderId,
    required this.createdAt,
    required this.updatedAt,
    this.cardCount = 0,
    this.dueCardCount = 0,
    this.isSynced = false,
    this.remoteId,
  });

  /// Creates a new deck with the given name.
  factory Deck.create({
    required String id,
    required String name,
    String? description,
    required String userId,
    String? folderId,
  }) {
    final now = DateTime.now();
    return Deck(
      id: id,
      name: name,
      description: description,
      userId: userId,
      folderId: folderId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Returns true if this deck has any cards.
  bool get hasCards => cardCount > 0;

  /// Returns true if this deck has cards due for review.
  bool get hasDueCards => dueCardCount > 0;

  /// Returns true if this deck belongs to a folder.
  bool get hasFolder => folderId != null;

  /// Creates a copy of this deck with the given fields replaced.
  Deck copyWith({
    String? id,
    String? name,
    String? description,
    String? userId,
    String? folderId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? cardCount,
    int? dueCardCount,
    bool? isSynced,
    String? remoteId,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      folderId: folderId ?? this.folderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cardCount: cardCount ?? this.cardCount,
      dueCardCount: dueCardCount ?? this.dueCardCount,
      isSynced: isSynced ?? this.isSynced,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        userId,
        folderId,
        createdAt,
        updatedAt,
        cardCount,
        dueCardCount,
        isSynced,
        remoteId,
      ];

  @override
  String toString() =>
      'Deck(id: $id, name: $name, cardCount: $cardCount, folderId: $folderId)';
}
