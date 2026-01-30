import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/remote/contracts/auth_remote_datasource.dart';
import '../../data/datasources/remote/contracts/data_remote_datasource.dart';
import '../../data/datasources/remote/firebase/firebase_auth_datasource.dart';
import '../../data/datasources/remote/firebase/firebase_firestore_datasource.dart';

part 'datasource_providers.g.dart';

/// Provider for the auth remote datasource.
///
/// **Migration point**: To switch from Firebase to another backend,
/// change this provider to return a different implementation.
///
/// Example for Supabase:
/// ```dart
/// @riverpod
/// AuthRemoteDatasource authRemoteDatasource(Ref ref) {
///   return SupabaseAuthDatasource();
/// }
/// ```
@Riverpod(keepAlive: true)
AuthRemoteDatasource authRemoteDatasource(Ref ref) {
  return FirebaseAuthDatasource();
}

/// Provider for the data remote datasource.
///
/// **Migration point**: To switch from Firebase to another backend,
/// change this provider to return a different implementation.
@Riverpod(keepAlive: true)
DataRemoteDatasource dataRemoteDatasource(Ref ref) {
  return FirebaseFirestoreDatasource();
}
