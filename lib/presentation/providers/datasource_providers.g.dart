// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datasource_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRemoteDatasourceHash() =>
    r'0d856544fdc64937ae75085a1f90df8c73748dbd';

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
///
/// Copied from [authRemoteDatasource].
@ProviderFor(authRemoteDatasource)
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>.internal(
  authRemoteDatasource,
  name: r'authRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRemoteDatasourceRef = ProviderRef<AuthRemoteDatasource>;
String _$dataRemoteDatasourceHash() =>
    r'beb31ebefbd87df363c595dec13764ba59920b02';

/// Provider for the data remote datasource.
///
/// **Migration point**: To switch from Firebase to another backend,
/// change this provider to return a different implementation.
///
/// Copied from [dataRemoteDatasource].
@ProviderFor(dataRemoteDatasource)
final dataRemoteDatasourceProvider = Provider<DataRemoteDatasource>.internal(
  dataRemoteDatasource,
  name: r'dataRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dataRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DataRemoteDatasourceRef = ProviderRef<DataRemoteDatasource>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
