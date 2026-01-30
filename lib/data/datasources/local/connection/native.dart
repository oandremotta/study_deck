import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../../core/constants/app_constants.dart';

/// Creates a database connection for native platforms (Android, iOS, Windows, macOS, Linux).
DatabaseConnection connect() {
  return DatabaseConnection(
    LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, AppConstants.databaseName));
      return NativeDatabase.createInBackground(file);
    }),
  );
}

Future<void> validateDatabaseSchema(GeneratedDatabase database) async {
  // Optional: Add schema validation for native
}
