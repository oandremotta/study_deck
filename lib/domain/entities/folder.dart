import 'package:equatable/equatable.dart';

/// Represents a folder that organizes decks.
///
/// Folders allow users to group related decks together
/// (e.g., by subject, course, or project).
class Folder extends Equatable {
  /// Unique identifier (UUID).
  final String id;

  /// Folder name.
  final String name;

  /// ID of the user who owns this folder.
  final String userId;

  /// When the folder was created.
  final DateTime createdAt;

  /// When the folder was last updated.
  final DateTime updatedAt;

  /// Number of decks in this folder (computed field).
  final int deckCount;

  /// Whether this folder has been synced with the cloud.
  final bool isSynced;

  /// Remote ID if synced with cloud.
  final String? remoteId;

  const Folder({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deckCount = 0,
    this.isSynced = false,
    this.remoteId,
  });

  /// Creates a new folder with the given name.
  factory Folder.create({
    required String id,
    required String name,
    required String userId,
  }) {
    final now = DateTime.now();
    return Folder(
      id: id,
      name: name,
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Returns true if this folder contains any decks.
  bool get hasDecks => deckCount > 0;

  /// Creates a copy of this folder with the given fields replaced.
  Folder copyWith({
    String? id,
    String? name,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? deckCount,
    bool? isSynced,
    String? remoteId,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deckCount: deckCount ?? this.deckCount,
      isSynced: isSynced ?? this.isSynced,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        userId,
        createdAt,
        updatedAt,
        deckCount,
        isSynced,
        remoteId,
      ];

  @override
  String toString() => 'Folder(id: $id, name: $name, deckCount: $deckCount)';
}
