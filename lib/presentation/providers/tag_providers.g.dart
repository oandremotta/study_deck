// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tagRepositoryHash() => r'69b7dffc88847c64e411bcc86b3272de692d957f';

/// Provider for the tag repository.
///
/// Copied from [tagRepository].
@ProviderFor(tagRepository)
final tagRepositoryProvider = Provider<TagRepository>.internal(
  tagRepository,
  name: r'tagRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tagRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TagRepositoryRef = ProviderRef<TagRepository>;
String _$watchTagsHash() => r'7f9164caee856a8d33cb9b27c659aa77ed1c2908';

/// Stream provider for watching all tags.
///
/// Copied from [watchTags].
@ProviderFor(watchTags)
final watchTagsProvider = AutoDisposeStreamProvider<List<Tag>>.internal(
  watchTags,
  name: r'watchTagsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$watchTagsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchTagsRef = AutoDisposeStreamProviderRef<List<Tag>>;
String _$tagsHash() => r'c283c59dd826fc88a3cc3c9e3ea61a7b597ae3fa';

/// Provider for getting all tags.
///
/// Copied from [tags].
@ProviderFor(tags)
final tagsProvider = AutoDisposeFutureProvider<List<Tag>>.internal(
  tags,
  name: r'tagsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tagsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TagsRef = AutoDisposeFutureProviderRef<List<Tag>>;
String _$tagByIdHash() => r'12c698abc0ee25f5fb483e8a2b0be84f65aa2bb1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for getting a single tag.
///
/// Copied from [tagById].
@ProviderFor(tagById)
const tagByIdProvider = TagByIdFamily();

/// Provider for getting a single tag.
///
/// Copied from [tagById].
class TagByIdFamily extends Family<AsyncValue<Tag?>> {
  /// Provider for getting a single tag.
  ///
  /// Copied from [tagById].
  const TagByIdFamily();

  /// Provider for getting a single tag.
  ///
  /// Copied from [tagById].
  TagByIdProvider call(
    String id,
  ) {
    return TagByIdProvider(
      id,
    );
  }

  @override
  TagByIdProvider getProviderOverride(
    covariant TagByIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tagByIdProvider';
}

/// Provider for getting a single tag.
///
/// Copied from [tagById].
class TagByIdProvider extends AutoDisposeFutureProvider<Tag?> {
  /// Provider for getting a single tag.
  ///
  /// Copied from [tagById].
  TagByIdProvider(
    String id,
  ) : this._internal(
          (ref) => tagById(
            ref as TagByIdRef,
            id,
          ),
          from: tagByIdProvider,
          name: r'tagByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tagByIdHash,
          dependencies: TagByIdFamily._dependencies,
          allTransitiveDependencies: TagByIdFamily._allTransitiveDependencies,
          id: id,
        );

  TagByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Tag?> Function(TagByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TagByIdProvider._internal(
        (ref) => create(ref as TagByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Tag?> createElement() {
    return _TagByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TagByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TagByIdRef on AutoDisposeFutureProviderRef<Tag?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TagByIdProviderElement extends AutoDisposeFutureProviderElement<Tag?>
    with TagByIdRef {
  _TagByIdProviderElement(super.provider);

  @override
  String get id => (origin as TagByIdProvider).id;
}

String _$tagsByIdsHash() => r'd94a1cb8c9ffa88d531e11363370f78c40c26a92';

/// Provider for getting multiple tags by IDs.
///
/// Copied from [tagsByIds].
@ProviderFor(tagsByIds)
const tagsByIdsProvider = TagsByIdsFamily();

/// Provider for getting multiple tags by IDs.
///
/// Copied from [tagsByIds].
class TagsByIdsFamily extends Family<AsyncValue<List<Tag>>> {
  /// Provider for getting multiple tags by IDs.
  ///
  /// Copied from [tagsByIds].
  const TagsByIdsFamily();

  /// Provider for getting multiple tags by IDs.
  ///
  /// Copied from [tagsByIds].
  TagsByIdsProvider call(
    List<String> ids,
  ) {
    return TagsByIdsProvider(
      ids,
    );
  }

  @override
  TagsByIdsProvider getProviderOverride(
    covariant TagsByIdsProvider provider,
  ) {
    return call(
      provider.ids,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tagsByIdsProvider';
}

/// Provider for getting multiple tags by IDs.
///
/// Copied from [tagsByIds].
class TagsByIdsProvider extends AutoDisposeFutureProvider<List<Tag>> {
  /// Provider for getting multiple tags by IDs.
  ///
  /// Copied from [tagsByIds].
  TagsByIdsProvider(
    List<String> ids,
  ) : this._internal(
          (ref) => tagsByIds(
            ref as TagsByIdsRef,
            ids,
          ),
          from: tagsByIdsProvider,
          name: r'tagsByIdsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tagsByIdsHash,
          dependencies: TagsByIdsFamily._dependencies,
          allTransitiveDependencies: TagsByIdsFamily._allTransitiveDependencies,
          ids: ids,
        );

  TagsByIdsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.ids,
  }) : super.internal();

  final List<String> ids;

  @override
  Override overrideWith(
    FutureOr<List<Tag>> Function(TagsByIdsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TagsByIdsProvider._internal(
        (ref) => create(ref as TagsByIdsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        ids: ids,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Tag>> createElement() {
    return _TagsByIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TagsByIdsProvider && other.ids == ids;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, ids.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TagsByIdsRef on AutoDisposeFutureProviderRef<List<Tag>> {
  /// The parameter `ids` of this provider.
  List<String> get ids;
}

class _TagsByIdsProviderElement
    extends AutoDisposeFutureProviderElement<List<Tag>> with TagsByIdsRef {
  _TagsByIdsProviderElement(super.provider);

  @override
  List<String> get ids => (origin as TagsByIdsProvider).ids;
}

String _$tagsForCardHash() => r'53668353515796a9ec86b06cc3a50d7bbfaab67d';

/// Provider for getting tags for a card (by tag IDs).
/// Returns empty list on error or if no tagIds provided.
///
/// Copied from [tagsForCard].
@ProviderFor(tagsForCard)
const tagsForCardProvider = TagsForCardFamily();

/// Provider for getting tags for a card (by tag IDs).
/// Returns empty list on error or if no tagIds provided.
///
/// Copied from [tagsForCard].
class TagsForCardFamily extends Family<AsyncValue<List<Tag>>> {
  /// Provider for getting tags for a card (by tag IDs).
  /// Returns empty list on error or if no tagIds provided.
  ///
  /// Copied from [tagsForCard].
  const TagsForCardFamily();

  /// Provider for getting tags for a card (by tag IDs).
  /// Returns empty list on error or if no tagIds provided.
  ///
  /// Copied from [tagsForCard].
  TagsForCardProvider call(
    List<String> tagIds,
  ) {
    return TagsForCardProvider(
      tagIds,
    );
  }

  @override
  TagsForCardProvider getProviderOverride(
    covariant TagsForCardProvider provider,
  ) {
    return call(
      provider.tagIds,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tagsForCardProvider';
}

/// Provider for getting tags for a card (by tag IDs).
/// Returns empty list on error or if no tagIds provided.
///
/// Copied from [tagsForCard].
class TagsForCardProvider extends AutoDisposeFutureProvider<List<Tag>> {
  /// Provider for getting tags for a card (by tag IDs).
  /// Returns empty list on error or if no tagIds provided.
  ///
  /// Copied from [tagsForCard].
  TagsForCardProvider(
    List<String> tagIds,
  ) : this._internal(
          (ref) => tagsForCard(
            ref as TagsForCardRef,
            tagIds,
          ),
          from: tagsForCardProvider,
          name: r'tagsForCardProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tagsForCardHash,
          dependencies: TagsForCardFamily._dependencies,
          allTransitiveDependencies:
              TagsForCardFamily._allTransitiveDependencies,
          tagIds: tagIds,
        );

  TagsForCardProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tagIds,
  }) : super.internal();

  final List<String> tagIds;

  @override
  Override overrideWith(
    FutureOr<List<Tag>> Function(TagsForCardRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TagsForCardProvider._internal(
        (ref) => create(ref as TagsForCardRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tagIds: tagIds,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Tag>> createElement() {
    return _TagsForCardProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TagsForCardProvider && other.tagIds == tagIds;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tagIds.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TagsForCardRef on AutoDisposeFutureProviderRef<List<Tag>> {
  /// The parameter `tagIds` of this provider.
  List<String> get tagIds;
}

class _TagsForCardProviderElement
    extends AutoDisposeFutureProviderElement<List<Tag>> with TagsForCardRef {
  _TagsForCardProviderElement(super.provider);

  @override
  List<String> get tagIds => (origin as TagsForCardProvider).tagIds;
}

String _$tagNotifierHash() => r'29fc6f8ec80dd7337f24cf2c0692788ce5ba0c10';

/// Notifier for tag operations.
///
/// Copied from [TagNotifier].
@ProviderFor(TagNotifier)
final tagNotifierProvider =
    AutoDisposeAsyncNotifierProvider<TagNotifier, void>.internal(
  TagNotifier.new,
  name: r'tagNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tagNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TagNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
