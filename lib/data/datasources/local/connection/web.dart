import 'package:drift/drift.dart';
import 'package:drift/web.dart';

import '../../../../core/constants/app_constants.dart';

/// Creates a database connection for web platform.
/// Uses IndexedDB-based storage (simpler, works without WASM setup).
DatabaseConnection connect() {
  return DatabaseConnection(
    WebDatabase.withStorage(
      DriftWebStorage.indexedDb(
        AppConstants.databaseName,
        migrateFromLocalStorage: false,
      ),
    ),
  );
}

Future<void> validateDatabaseSchema(GeneratedDatabase database) async {
  // Optional: Add schema validation for web
}
