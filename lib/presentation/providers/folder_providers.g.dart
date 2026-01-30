// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$folderRepositoryHash() => r'0450a80dcb049ff8c85b5fc8e9f1f20b81e24915';

/// Provider for the folder repository.
///
/// Copied from [folderRepository].
@ProviderFor(folderRepository)
final folderRepositoryProvider = Provider<FolderRepository>.internal(
  folderRepository,
  name: r'folderRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$folderRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FolderRepositoryRef = ProviderRef<FolderRepository>;
String _$watchFoldersHash() => r'fb5351a5d8e10e80ccbd969c2c6f3876cf639665';

/// Stream provider for watching all folders.
///
/// Copied from [watchFolders].
@ProviderFor(watchFolders)
final watchFoldersProvider = AutoDisposeStreamProvider<List<Folder>>.internal(
  watchFolders,
  name: r'watchFoldersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$watchFoldersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchFoldersRef = AutoDisposeStreamProviderRef<List<Folder>>;
String _$foldersHash() => r'910c8f0bd4d0daf470df1160a02e6beebd4b383f';

/// Provider for getting all folders.
///
/// Copied from [folders].
@ProviderFor(folders)
final foldersProvider = AutoDisposeFutureProvider<List<Folder>>.internal(
  folders,
  name: r'foldersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$foldersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FoldersRef = AutoDisposeFutureProviderRef<List<Folder>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
