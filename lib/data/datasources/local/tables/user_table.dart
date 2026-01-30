import 'package:drift/drift.dart';

/// Table for storing user profiles locally.
class UserTable extends Table {
  /// Primary key - UUID for local users, Firebase UID for authenticated.
  TextColumn get id => text()();

  /// User's email (null for anonymous users).
  TextColumn get email => text().nullable()();

  /// User's display name.
  TextColumn get displayName => text().nullable()();

  /// Whether this is a local-only user.
  BoolColumn get isAnonymous => boolean().withDefault(const Constant(true))();

  /// When the user was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When data was last synced with cloud.
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  /// Remote user ID if linked to cloud account.
  TextColumn get remoteId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
