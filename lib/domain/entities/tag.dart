import 'package:equatable/equatable.dart';

/// Represents a tag that can be attached to cards.
///
/// Tags help organize and filter cards within and across decks.
class Tag extends Equatable {
  /// Unique identifier (UUID).
  final String id;

  /// Tag name.
  final String name;

  /// Tag color in hex format (e.g., '#FF5733').
  final String color;

  /// ID of the user who owns this tag.
  final String userId;

  /// When the tag was created.
  final DateTime createdAt;

  /// Whether this tag has been synced with the cloud.
  final bool isSynced;

  /// Remote ID if synced with cloud.
  final String? remoteId;

  /// Number of cards using this tag (computed field).
  final int cardCount;

  const Tag({
    required this.id,
    required this.name,
    required this.color,
    required this.userId,
    required this.createdAt,
    this.isSynced = false,
    this.remoteId,
    this.cardCount = 0,
  });

  /// Creates a new tag with the given name and color.
  factory Tag.create({
    required String id,
    required String name,
    required String color,
    required String userId,
  }) {
    return Tag(
      id: id,
      name: name,
      color: color,
      userId: userId,
      createdAt: DateTime.now(),
    );
  }

  /// Predefined tag colors for user selection.
  static const List<String> availableColors = [
    '#EF4444', // Red
    '#F97316', // Orange
    '#F59E0B', // Amber
    '#EAB308', // Yellow
    '#84CC16', // Lime
    '#22C55E', // Green
    '#14B8A6', // Teal
    '#06B6D4', // Cyan
    '#3B82F6', // Blue
    '#6366F1', // Indigo
    '#8B5CF6', // Violet
    '#A855F7', // Purple
    '#D946EF', // Fuchsia
    '#EC4899', // Pink
    '#64748B', // Slate
  ];

  /// Creates a copy of this tag with the given fields replaced.
  Tag copyWith({
    String? id,
    String? name,
    String? color,
    String? userId,
    DateTime? createdAt,
    bool? isSynced,
    String? remoteId,
    int? cardCount,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      remoteId: remoteId ?? this.remoteId,
      cardCount: cardCount ?? this.cardCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        color,
        userId,
        createdAt,
        isSynced,
        remoteId,
        cardCount,
      ];

  @override
  String toString() => 'Tag(id: $id, name: $name, color: $color)';
}
