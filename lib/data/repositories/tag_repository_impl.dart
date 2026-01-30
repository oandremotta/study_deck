import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/local/database.dart';
import '../models/tag_model.dart';

/// Implementation of [TagRepository].
///
/// Handles tag CRUD operations (UC15).
class TagRepositoryImpl implements TagRepository {
  final AppDatabase _database;
  final Uuid _uuid;

  /// Function to get current user ID. Injected for testability.
  final Future<String?> Function() _getCurrentUserId;

  TagRepositoryImpl({
    required AppDatabase database,
    required Future<String?> Function() getCurrentUserId,
    Uuid? uuid,
  })  : _database = database,
        _getCurrentUserId = getCurrentUserId,
        _uuid = uuid ?? const Uuid();

  @override
  Stream<List<Tag>> watchTags() {
    return _getCurrentUserIdStream().asyncExpand((userId) {
      if (userId == null) return Stream.value(<Tag>[]);

      return _database.tagDao.watchTags(userId).asyncMap((tags) async {
        final counts = await _database.tagDao.getTagCardCounts(userId);
        return tags.map((t) => t.toEntity(cardCount: counts[t.id] ?? 0)).toList();
      });
    });
  }

  Stream<String?> _getCurrentUserIdStream() async* {
    yield await _getCurrentUserId();
  }

  @override
  Future<Either<Failure, List<Tag>>> getTags() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return const Right([]);
      }

      final tags = await _database.tagDao.getTags(userId);
      final counts = await _database.tagDao.getTagCardCounts(userId);
      return Right(
        tags.map((t) => t.toEntity(cardCount: counts[t.id] ?? 0)).toList(),
      );
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to get tags: $e'));
    }
  }

  @override
  Future<Either<Failure, Tag?>> getTagById(String id) async {
    try {
      final tagData = await _database.tagDao.getTagById(id);
      if (tagData == null) return const Right(null);

      final cardCount = await _database.cardDao.getCardCountByTag(id);
      return Right(tagData.toEntity(cardCount: cardCount));
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to get tag: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Tag>>> getTagsByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) return const Right([]);

      final tags = await _database.tagDao.getTagsByIds(ids);
      final result = <Tag>[];
      for (final tag in tags) {
        final cardCount = await _database.cardDao.getCardCountByTag(tag.id);
        result.add(tag.toEntity(cardCount: cardCount));
      }
      return Right(result);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to get tags: $e'));
    }
  }

  @override
  Future<Either<Failure, Tag>> createTag({
    required String name,
    required String color,
  }) async {
    try {
      if (name.trim().isEmpty) {
        return Left(ValidationFailure.empty('Tag name'));
      }

      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Left(const LocalStorageFailure(
          message: 'No user logged in',
        ));
      }

      // Check if name already exists
      final nameExists = await _database.tagDao.tagNameExists(userId, name.trim());
      if (nameExists) {
        return Left(const ValidationFailure(
          message: 'A tag with this name already exists',
          code: 'name-exists',
        ));
      }

      final tag = Tag.create(
        id: _uuid.v4(),
        name: name.trim(),
        color: color,
        userId: userId,
      );

      await _database.tagDao.createTag(tag.toCompanion());

      return Right(tag);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to create tag: $e'));
    }
  }

  @override
  Future<Either<Failure, Tag>> updateTag({
    required String id,
    String? name,
    String? color,
  }) async {
    try {
      final existingTag = await _database.tagDao.getTagById(id);
      if (existingTag == null) {
        return Left(const LocalStorageFailure(
          message: 'Tag not found',
          code: 'not-found',
        ));
      }

      final newName = name?.trim() ?? existingTag.name;
      if (newName.isEmpty) {
        return Left(ValidationFailure.empty('Tag name'));
      }

      // Check if new name already exists (excluding current tag)
      if (newName != existingTag.name) {
        final nameExists = await _database.tagDao.tagNameExists(
          existingTag.userId,
          newName,
          excludeId: id,
        );
        if (nameExists) {
          return Left(const ValidationFailure(
            message: 'A tag with this name already exists',
            code: 'name-exists',
          ));
        }
      }

      final updatedCompanion = TagTableCompanion(
        id: Value(id),
        name: Value(newName),
        color: Value(color ?? existingTag.color),
        userId: Value(existingTag.userId),
        createdAt: Value(existingTag.createdAt),
        isSynced: const Value(false),
        remoteId: Value(existingTag.remoteId),
      );

      await _database.tagDao.updateTag(updatedCompanion);

      final cardCount = await _database.cardDao.getCardCountByTag(id);
      final updatedTag = Tag(
        id: id,
        name: newName,
        color: color ?? existingTag.color,
        userId: existingTag.userId,
        createdAt: existingTag.createdAt,
        isSynced: false,
        remoteId: existingTag.remoteId,
        cardCount: cardCount,
      );

      return Right(updatedTag);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to update tag: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTag(String id) async {
    try {
      final tag = await _database.tagDao.getTagById(id);
      if (tag == null) {
        return Left(const LocalStorageFailure(
          message: 'Tag not found',
          code: 'not-found',
        ));
      }

      await _database.tagDao.deleteTag(id);
      return const Right(null);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(message: 'Failed to delete tag: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> tagNameExists(String name) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return const Right(false);

      final exists = await _database.tagDao.tagNameExists(userId, name.trim());
      return Right(exists);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(
        message: 'Failed to check tag name: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getTagCardCounts() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return const Right({});

      final counts = await _database.tagDao.getTagCardCounts(userId);
      return Right(counts);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(LocalStorageFailure(
        message: 'Failed to get tag card counts: $e',
      ));
    }
  }
}
