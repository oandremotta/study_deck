import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/user_table.dart';

part 'user_dao.g.dart';

/// Data Access Object for user operations.
@DriftAccessor(tables: [UserTable])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  /// Gets the current local user.
  Future<UserTableData?> getUser() async {
    return (select(userTable)..limit(1)).getSingleOrNull();
  }

  /// Gets a user by ID.
  Future<UserTableData?> getUserById(String id) async {
    return (select(userTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Creates or updates a user.
  Future<void> upsertUser(UserTableCompanion user) async {
    await into(userTable).insertOnConflictUpdate(user);
  }

  /// Deletes a user by ID.
  Future<int> deleteUser(String id) async {
    return (delete(userTable)..where((t) => t.id.equals(id))).go();
  }

  /// Watches the current user.
  Stream<UserTableData?> watchUser() {
    return (select(userTable)..limit(1)).watchSingleOrNull();
  }

  /// Checks if there's a local user.
  Future<bool> hasLocalUser() async {
    final user = await getUser();
    return user != null;
  }
}
