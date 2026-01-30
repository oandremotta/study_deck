import 'package:equatable/equatable.dart';

/// Represents a user in the domain layer.
///
/// A user can be either:
/// - Anonymous (local only, [isAnonymous] = true)
/// - Authenticated (synced with cloud, [isAnonymous] = false)
class User extends Equatable {
  /// Unique identifier (UUID for local, Firebase UID for authenticated).
  final String id;

  /// User's email address (null for anonymous users).
  final String? email;

  /// User's display name.
  final String? displayName;

  /// Whether the user is using the app without an account.
  final bool isAnonymous;

  /// When the user profile was created.
  final DateTime createdAt;

  /// When the user's data was last synced with the cloud.
  final DateTime? lastSyncAt;

  /// Remote user ID if linked to a cloud account.
  final String? remoteId;

  const User({
    required this.id,
    this.email,
    this.displayName,
    required this.isAnonymous,
    required this.createdAt,
    this.lastSyncAt,
    this.remoteId,
  });

  /// Creates an anonymous (local) user.
  factory User.anonymous({
    required String id,
    required DateTime createdAt,
  }) {
    return User(
      id: id,
      isAnonymous: true,
      createdAt: createdAt,
    );
  }

  /// Creates a copy of this user with the given fields replaced.
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? lastSyncAt,
    String? remoteId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        isAnonymous,
        createdAt,
        lastSyncAt,
        remoteId,
      ];

  @override
  String toString() =>
      'User(id: $id, email: $email, isAnonymous: $isAnonymous)';
}
