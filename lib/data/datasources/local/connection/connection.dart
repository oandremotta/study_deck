import 'package:drift/drift.dart';

/// Stub file for conditional imports.
/// This file is never actually used - it just defines the interface.
DatabaseConnection connect() {
  throw UnsupportedError(
    'Cannot create a database connection without dart:io or dart:html',
  );
}

Future<void> validateDatabaseSchema(GeneratedDatabase database) async {
  // No-op for stub
}
