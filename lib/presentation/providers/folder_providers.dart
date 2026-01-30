import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../data/repositories/folder_repository_impl.dart';
import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';
import 'auth_providers.dart';
import 'database_providers.dart';

part 'folder_providers.g.dart';

/// Provider for the folder repository.
@Riverpod(keepAlive: true)
FolderRepository folderRepository(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return FolderRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    getCurrentUserId: () async {
      // Get userId directly from auth repository to avoid stream complexity
      return authRepo.currentUser?.id;
    },
  );
}

/// Stream provider for watching all folders.
@riverpod
Stream<List<Folder>> watchFolders(Ref ref) {
  return ref.watch(folderRepositoryProvider).watchFolders();
}

/// Provider for getting all folders.
@riverpod
Future<List<Folder>> folders(Ref ref) async {
  final result = await ref.watch(folderRepositoryProvider).getFolders();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (folders) => folders,
  );
}

/// Creates a new folder directly via repository.
Future<Folder> createFolderDirect(FolderRepository repository, String name) async {
  final result = await repository.createFolder(name);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (folder) => folder,
  );
}

/// Updates a folder directly via repository.
Future<Folder> updateFolderDirect(FolderRepository repository, String id, String name) async {
  final result = await repository.updateFolder(id: id, name: name);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (folder) => folder,
  );
}

/// Deletes a folder directly via repository.
Future<void> deleteFolderDirect(FolderRepository repository, String id, DeleteFolderAction action) async {
  final result = await repository.deleteFolder(id: id, action: action);
  result.fold(
    (failure) => throw Exception(failure.message),
    (_) {},
  );
}
