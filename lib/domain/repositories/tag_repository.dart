import '../entities/tag.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';

/// Contract for tag operations.
///
/// Handles CRUD operations for tags (UC15).
abstract class TagRepository {
  /// Watches all tags for the current user.
  ///
  /// Returns a stream that emits the list of tags whenever it changes.
  Stream<List<Tag>> watchTags();

  /// Gets all tags for the current user.
  Future<Either<Failure, List<Tag>>> getTags();

  /// Gets a single tag by ID.
  Future<Either<Failure, Tag?>> getTagById(String id);

  /// Gets multiple tags by IDs.
  Future<Either<Failure, List<Tag>>> getTagsByIds(List<String> ids);

  /// Creates a new tag.
  ///
  /// UC15 - Manage tags (create).
  Future<Either<Failure, Tag>> createTag({
    required String name,
    required String color,
  });

  /// Updates an existing tag.
  ///
  /// UC15 - Manage tags (edit).
  Future<Either<Failure, Tag>> updateTag({
    required String id,
    String? name,
    String? color,
  });

  /// Deletes a tag.
  ///
  /// UC15 - Manage tags (delete).
  /// All card-tag associations will also be removed.
  Future<Either<Failure, void>> deleteTag(String id);

  /// Checks if a tag with the given name already exists.
  Future<Either<Failure, bool>> tagNameExists(String name);

  /// Gets card count for each tag.
  Future<Either<Failure, Map<String, int>>> getTagCardCounts();
}
