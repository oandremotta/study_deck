// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deckRepositoryHash() => r'5670ed0f776b694bf07a071e852aad78a611ca8e';

/// Provider for the deck repository.
///
/// Copied from [deckRepository].
@ProviderFor(deckRepository)
final deckRepositoryProvider = Provider<DeckRepository>.internal(
  deckRepository,
  name: r'deckRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deckRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeckRepositoryRef = ProviderRef<DeckRepository>;
String _$watchDecksHash() => r'03697c3bd029ec6cb24330d4287747a0d2aec88e';

/// Stream provider for watching all decks.
///
/// Copied from [watchDecks].
@ProviderFor(watchDecks)
final watchDecksProvider = AutoDisposeStreamProvider<List<Deck>>.internal(
  watchDecks,
  name: r'watchDecksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$watchDecksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchDecksRef = AutoDisposeStreamProviderRef<List<Deck>>;
String _$watchDecksByFolderHash() =>
    r'31f829d0e599814ae4c0805cd9e81deeafe91ca7';

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

/// Stream provider for watching decks in a folder.
///
/// Copied from [watchDecksByFolder].
@ProviderFor(watchDecksByFolder)
const watchDecksByFolderProvider = WatchDecksByFolderFamily();

/// Stream provider for watching decks in a folder.
///
/// Copied from [watchDecksByFolder].
class WatchDecksByFolderFamily extends Family<AsyncValue<List<Deck>>> {
  /// Stream provider for watching decks in a folder.
  ///
  /// Copied from [watchDecksByFolder].
  const WatchDecksByFolderFamily();

  /// Stream provider for watching decks in a folder.
  ///
  /// Copied from [watchDecksByFolder].
  WatchDecksByFolderProvider call(
    String? folderId,
  ) {
    return WatchDecksByFolderProvider(
      folderId,
    );
  }

  @override
  WatchDecksByFolderProvider getProviderOverride(
    covariant WatchDecksByFolderProvider provider,
  ) {
    return call(
      provider.folderId,
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
  String? get name => r'watchDecksByFolderProvider';
}

/// Stream provider for watching decks in a folder.
///
/// Copied from [watchDecksByFolder].
class WatchDecksByFolderProvider extends AutoDisposeStreamProvider<List<Deck>> {
  /// Stream provider for watching decks in a folder.
  ///
  /// Copied from [watchDecksByFolder].
  WatchDecksByFolderProvider(
    String? folderId,
  ) : this._internal(
          (ref) => watchDecksByFolder(
            ref as WatchDecksByFolderRef,
            folderId,
          ),
          from: watchDecksByFolderProvider,
          name: r'watchDecksByFolderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$watchDecksByFolderHash,
          dependencies: WatchDecksByFolderFamily._dependencies,
          allTransitiveDependencies:
              WatchDecksByFolderFamily._allTransitiveDependencies,
          folderId: folderId,
        );

  WatchDecksByFolderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.folderId,
  }) : super.internal();

  final String? folderId;

  @override
  Override overrideWith(
    Stream<List<Deck>> Function(WatchDecksByFolderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WatchDecksByFolderProvider._internal(
        (ref) => create(ref as WatchDecksByFolderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        folderId: folderId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Deck>> createElement() {
    return _WatchDecksByFolderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchDecksByFolderProvider && other.folderId == folderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, folderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WatchDecksByFolderRef on AutoDisposeStreamProviderRef<List<Deck>> {
  /// The parameter `folderId` of this provider.
  String? get folderId;
}

class _WatchDecksByFolderProviderElement
    extends AutoDisposeStreamProviderElement<List<Deck>>
    with WatchDecksByFolderRef {
  _WatchDecksByFolderProviderElement(super.provider);

  @override
  String? get folderId => (origin as WatchDecksByFolderProvider).folderId;
}

String _$decksHash() => r'97298247b5b2d35e38568536bf810c3ae7493c55';

/// Provider for getting all decks.
///
/// Copied from [decks].
@ProviderFor(decks)
final decksProvider = AutoDisposeFutureProvider<List<Deck>>.internal(
  decks,
  name: r'decksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$decksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DecksRef = AutoDisposeFutureProviderRef<List<Deck>>;
String _$deckByIdHash() => r'20ff2ccc9bdd7876bda502d18a3bd1e6bf7566ff';

/// Provider for getting a single deck.
///
/// Copied from [deckById].
@ProviderFor(deckById)
const deckByIdProvider = DeckByIdFamily();

/// Provider for getting a single deck.
///
/// Copied from [deckById].
class DeckByIdFamily extends Family<AsyncValue<Deck?>> {
  /// Provider for getting a single deck.
  ///
  /// Copied from [deckById].
  const DeckByIdFamily();

  /// Provider for getting a single deck.
  ///
  /// Copied from [deckById].
  DeckByIdProvider call(
    String id,
  ) {
    return DeckByIdProvider(
      id,
    );
  }

  @override
  DeckByIdProvider getProviderOverride(
    covariant DeckByIdProvider provider,
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
  String? get name => r'deckByIdProvider';
}

/// Provider for getting a single deck.
///
/// Copied from [deckById].
class DeckByIdProvider extends AutoDisposeFutureProvider<Deck?> {
  /// Provider for getting a single deck.
  ///
  /// Copied from [deckById].
  DeckByIdProvider(
    String id,
  ) : this._internal(
          (ref) => deckById(
            ref as DeckByIdRef,
            id,
          ),
          from: deckByIdProvider,
          name: r'deckByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deckByIdHash,
          dependencies: DeckByIdFamily._dependencies,
          allTransitiveDependencies: DeckByIdFamily._allTransitiveDependencies,
          id: id,
        );

  DeckByIdProvider._internal(
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
    FutureOr<Deck?> Function(DeckByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeckByIdProvider._internal(
        (ref) => create(ref as DeckByIdRef),
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
  AutoDisposeFutureProviderElement<Deck?> createElement() {
    return _DeckByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeckByIdProvider && other.id == id;
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
mixin DeckByIdRef on AutoDisposeFutureProviderRef<Deck?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _DeckByIdProviderElement extends AutoDisposeFutureProviderElement<Deck?>
    with DeckByIdRef {
  _DeckByIdProviderElement(super.provider);

  @override
  String get id => (origin as DeckByIdProvider).id;
}

String _$deckNotifierHash() => r'924cb5295329db1bbfbc705a6a997346453b6047';

/// Notifier for deck operations.
///
/// Copied from [DeckNotifier].
@ProviderFor(DeckNotifier)
final deckNotifierProvider =
    AutoDisposeAsyncNotifierProvider<DeckNotifier, void>.internal(
  DeckNotifier.new,
  name: r'deckNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$deckNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeckNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
