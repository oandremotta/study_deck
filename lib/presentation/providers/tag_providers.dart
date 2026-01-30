import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/tag_repository_impl.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import 'auth_providers.dart';
import 'database_providers.dart';

part 'tag_providers.g.dart';

/// Provider for the tag repository.
@Riverpod(keepAlive: true)
TagRepository tagRepository(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return TagRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    getCurrentUserId: () async {
      return authRepo.currentUser?.id;
    },
  );
}

/// Stream provider for watching all tags.
@riverpod
Stream<List<Tag>> watchTags(Ref ref) {
  return ref.watch(tagRepositoryProvider).watchTags();
}

/// Provider for getting all tags.
@riverpod
Future<List<Tag>> tags(Ref ref) async {
  final result = await ref.watch(tagRepositoryProvider).getTags();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (tags) => tags,
  );
}

/// Provider for getting a single tag.
@riverpod
Future<Tag?> tagById(Ref ref, String id) async {
  final result = await ref.watch(tagRepositoryProvider).getTagById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (tag) => tag,
  );
}

/// Provider for getting multiple tags by IDs.
@riverpod
Future<List<Tag>> tagsByIds(Ref ref, List<String> ids) async {
  final result = await ref.watch(tagRepositoryProvider).getTagsByIds(ids);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (tags) => tags,
  );
}

/// Provider for getting tags for a card (by tag IDs).
/// Returns empty list on error or if no tagIds provided.
@riverpod
Future<List<Tag>> tagsForCard(Ref ref, List<String> tagIds) async {
  if (tagIds.isEmpty) return [];
  final result = await ref.watch(tagRepositoryProvider).getTagsByIds(tagIds);
  return result.fold(
    (failure) => [],
    (tags) => tags,
  );
}

/// Creates a new tag directly via repository.
Future<Tag> createTagDirect(
  TagRepository repository, {
  required String name,
  required String color,
}) async {
  final result = await repository.createTag(name: name, color: color);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (tag) => tag,
  );
}

/// Updates a tag directly via repository.
Future<Tag> updateTagDirect(
  TagRepository repository, {
  required String id,
  String? name,
  String? color,
}) async {
  final result = await repository.updateTag(id: id, name: name, color: color);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (tag) => tag,
  );
}

/// Deletes a tag directly via repository.
Future<void> deleteTagDirect(TagRepository repository, String id) async {
  final result = await repository.deleteTag(id);
  result.fold(
    (failure) => throw Exception(failure.message),
    (_) {},
  );
}

/// Notifier for tag operations.
@riverpod
class TagNotifier extends _$TagNotifier {
  @override
  FutureOr<void> build() {
    // Initial state - nothing to load
  }

  /// Creates a new tag.
  Future<Tag?> createTag({
    required String name,
    required String color,
  }) async {
    state = const AsyncLoading();

    final repository = ref.read(tagRepositoryProvider);
    final result = await repository.createTag(name: name, color: color);

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (tag) {
        state = const AsyncData(null);
        ref.invalidate(watchTagsProvider);
        return tag;
      },
    );
  }

  /// Updates a tag.
  Future<Tag?> updateTag({
    required String id,
    String? name,
    String? color,
  }) async {
    state = const AsyncLoading();

    final repository = ref.read(tagRepositoryProvider);
    final result = await repository.updateTag(
      id: id,
      name: name,
      color: color,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (tag) {
        state = const AsyncData(null);
        ref.invalidate(watchTagsProvider);
        ref.invalidate(tagByIdProvider(id));
        return tag;
      },
    );
  }

  /// Deletes a tag.
  Future<bool> deleteTag(String id) async {
    state = const AsyncLoading();

    final repository = ref.read(tagRepositoryProvider);
    final result = await repository.deleteTag(id);

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(watchTagsProvider);
        return true;
      },
    );
  }
}
