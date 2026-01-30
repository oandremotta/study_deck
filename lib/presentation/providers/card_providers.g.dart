// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cardRepositoryHash() => r'50bfa57397c5e155d5640482554fcb1658068175';

/// Provider for the card repository.
///
/// Copied from [cardRepository].
@ProviderFor(cardRepository)
final cardRepositoryProvider = Provider<CardRepository>.internal(
  cardRepository,
  name: r'cardRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cardRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CardRepositoryRef = ProviderRef<CardRepository>;
String _$watchCardsByDeckHash() => r'a6e326b87301a1b8c17cb85944b33d66ff961963';

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

/// Stream provider for watching cards in a deck.
///
/// Copied from [watchCardsByDeck].
@ProviderFor(watchCardsByDeck)
const watchCardsByDeckProvider = WatchCardsByDeckFamily();

/// Stream provider for watching cards in a deck.
///
/// Copied from [watchCardsByDeck].
class WatchCardsByDeckFamily extends Family<AsyncValue<List<Card>>> {
  /// Stream provider for watching cards in a deck.
  ///
  /// Copied from [watchCardsByDeck].
  const WatchCardsByDeckFamily();

  /// Stream provider for watching cards in a deck.
  ///
  /// Copied from [watchCardsByDeck].
  WatchCardsByDeckProvider call(
    String deckId,
  ) {
    return WatchCardsByDeckProvider(
      deckId,
    );
  }

  @override
  WatchCardsByDeckProvider getProviderOverride(
    covariant WatchCardsByDeckProvider provider,
  ) {
    return call(
      provider.deckId,
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
  String? get name => r'watchCardsByDeckProvider';
}

/// Stream provider for watching cards in a deck.
///
/// Copied from [watchCardsByDeck].
class WatchCardsByDeckProvider extends AutoDisposeStreamProvider<List<Card>> {
  /// Stream provider for watching cards in a deck.
  ///
  /// Copied from [watchCardsByDeck].
  WatchCardsByDeckProvider(
    String deckId,
  ) : this._internal(
          (ref) => watchCardsByDeck(
            ref as WatchCardsByDeckRef,
            deckId,
          ),
          from: watchCardsByDeckProvider,
          name: r'watchCardsByDeckProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$watchCardsByDeckHash,
          dependencies: WatchCardsByDeckFamily._dependencies,
          allTransitiveDependencies:
              WatchCardsByDeckFamily._allTransitiveDependencies,
          deckId: deckId,
        );

  WatchCardsByDeckProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deckId,
  }) : super.internal();

  final String deckId;

  @override
  Override overrideWith(
    Stream<List<Card>> Function(WatchCardsByDeckRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WatchCardsByDeckProvider._internal(
        (ref) => create(ref as WatchCardsByDeckRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deckId: deckId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Card>> createElement() {
    return _WatchCardsByDeckProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchCardsByDeckProvider && other.deckId == deckId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deckId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WatchCardsByDeckRef on AutoDisposeStreamProviderRef<List<Card>> {
  /// The parameter `deckId` of this provider.
  String get deckId;
}

class _WatchCardsByDeckProviderElement
    extends AutoDisposeStreamProviderElement<List<Card>>
    with WatchCardsByDeckRef {
  _WatchCardsByDeckProviderElement(super.provider);

  @override
  String get deckId => (origin as WatchCardsByDeckProvider).deckId;
}

String _$watchDeletedCardsByDeckHash() =>
    r'7d2bb4f639f0c223938b0004a35e92de6b7b93e5';

/// Stream provider for watching deleted cards in a deck (trash).
///
/// Copied from [watchDeletedCardsByDeck].
@ProviderFor(watchDeletedCardsByDeck)
const watchDeletedCardsByDeckProvider = WatchDeletedCardsByDeckFamily();

/// Stream provider for watching deleted cards in a deck (trash).
///
/// Copied from [watchDeletedCardsByDeck].
class WatchDeletedCardsByDeckFamily extends Family<AsyncValue<List<Card>>> {
  /// Stream provider for watching deleted cards in a deck (trash).
  ///
  /// Copied from [watchDeletedCardsByDeck].
  const WatchDeletedCardsByDeckFamily();

  /// Stream provider for watching deleted cards in a deck (trash).
  ///
  /// Copied from [watchDeletedCardsByDeck].
  WatchDeletedCardsByDeckProvider call(
    String deckId,
  ) {
    return WatchDeletedCardsByDeckProvider(
      deckId,
    );
  }

  @override
  WatchDeletedCardsByDeckProvider getProviderOverride(
    covariant WatchDeletedCardsByDeckProvider provider,
  ) {
    return call(
      provider.deckId,
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
  String? get name => r'watchDeletedCardsByDeckProvider';
}

/// Stream provider for watching deleted cards in a deck (trash).
///
/// Copied from [watchDeletedCardsByDeck].
class WatchDeletedCardsByDeckProvider
    extends AutoDisposeStreamProvider<List<Card>> {
  /// Stream provider for watching deleted cards in a deck (trash).
  ///
  /// Copied from [watchDeletedCardsByDeck].
  WatchDeletedCardsByDeckProvider(
    String deckId,
  ) : this._internal(
          (ref) => watchDeletedCardsByDeck(
            ref as WatchDeletedCardsByDeckRef,
            deckId,
          ),
          from: watchDeletedCardsByDeckProvider,
          name: r'watchDeletedCardsByDeckProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$watchDeletedCardsByDeckHash,
          dependencies: WatchDeletedCardsByDeckFamily._dependencies,
          allTransitiveDependencies:
              WatchDeletedCardsByDeckFamily._allTransitiveDependencies,
          deckId: deckId,
        );

  WatchDeletedCardsByDeckProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deckId,
  }) : super.internal();

  final String deckId;

  @override
  Override overrideWith(
    Stream<List<Card>> Function(WatchDeletedCardsByDeckRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WatchDeletedCardsByDeckProvider._internal(
        (ref) => create(ref as WatchDeletedCardsByDeckRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deckId: deckId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Card>> createElement() {
    return _WatchDeletedCardsByDeckProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchDeletedCardsByDeckProvider && other.deckId == deckId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deckId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WatchDeletedCardsByDeckRef on AutoDisposeStreamProviderRef<List<Card>> {
  /// The parameter `deckId` of this provider.
  String get deckId;
}

class _WatchDeletedCardsByDeckProviderElement
    extends AutoDisposeStreamProviderElement<List<Card>>
    with WatchDeletedCardsByDeckRef {
  _WatchDeletedCardsByDeckProviderElement(super.provider);

  @override
  String get deckId => (origin as WatchDeletedCardsByDeckProvider).deckId;
}

String _$cardsByDeckHash() => r'7a128bb640d2f619793a798b8b20a41e26299180';

/// Provider for getting cards in a deck.
///
/// Copied from [cardsByDeck].
@ProviderFor(cardsByDeck)
const cardsByDeckProvider = CardsByDeckFamily();

/// Provider for getting cards in a deck.
///
/// Copied from [cardsByDeck].
class CardsByDeckFamily extends Family<AsyncValue<List<Card>>> {
  /// Provider for getting cards in a deck.
  ///
  /// Copied from [cardsByDeck].
  const CardsByDeckFamily();

  /// Provider for getting cards in a deck.
  ///
  /// Copied from [cardsByDeck].
  CardsByDeckProvider call(
    String deckId,
  ) {
    return CardsByDeckProvider(
      deckId,
    );
  }

  @override
  CardsByDeckProvider getProviderOverride(
    covariant CardsByDeckProvider provider,
  ) {
    return call(
      provider.deckId,
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
  String? get name => r'cardsByDeckProvider';
}

/// Provider for getting cards in a deck.
///
/// Copied from [cardsByDeck].
class CardsByDeckProvider extends AutoDisposeFutureProvider<List<Card>> {
  /// Provider for getting cards in a deck.
  ///
  /// Copied from [cardsByDeck].
  CardsByDeckProvider(
    String deckId,
  ) : this._internal(
          (ref) => cardsByDeck(
            ref as CardsByDeckRef,
            deckId,
          ),
          from: cardsByDeckProvider,
          name: r'cardsByDeckProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cardsByDeckHash,
          dependencies: CardsByDeckFamily._dependencies,
          allTransitiveDependencies:
              CardsByDeckFamily._allTransitiveDependencies,
          deckId: deckId,
        );

  CardsByDeckProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deckId,
  }) : super.internal();

  final String deckId;

  @override
  Override overrideWith(
    FutureOr<List<Card>> Function(CardsByDeckRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CardsByDeckProvider._internal(
        (ref) => create(ref as CardsByDeckRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deckId: deckId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Card>> createElement() {
    return _CardsByDeckProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CardsByDeckProvider && other.deckId == deckId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deckId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CardsByDeckRef on AutoDisposeFutureProviderRef<List<Card>> {
  /// The parameter `deckId` of this provider.
  String get deckId;
}

class _CardsByDeckProviderElement
    extends AutoDisposeFutureProviderElement<List<Card>> with CardsByDeckRef {
  _CardsByDeckProviderElement(super.provider);

  @override
  String get deckId => (origin as CardsByDeckProvider).deckId;
}

String _$deletedCardsHash() => r'52d7344e19de075c2cbe8a8aebe46cf570d09765';

/// Provider for getting all deleted cards.
///
/// Copied from [deletedCards].
@ProviderFor(deletedCards)
final deletedCardsProvider = AutoDisposeFutureProvider<List<Card>>.internal(
  deletedCards,
  name: r'deletedCardsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$deletedCardsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeletedCardsRef = AutoDisposeFutureProviderRef<List<Card>>;
String _$cardByIdHash() => r'ffc280fe05da59427c3a425d82dec24aa007a5b7';

/// Provider for getting a single card.
///
/// Copied from [cardById].
@ProviderFor(cardById)
const cardByIdProvider = CardByIdFamily();

/// Provider for getting a single card.
///
/// Copied from [cardById].
class CardByIdFamily extends Family<AsyncValue<Card?>> {
  /// Provider for getting a single card.
  ///
  /// Copied from [cardById].
  const CardByIdFamily();

  /// Provider for getting a single card.
  ///
  /// Copied from [cardById].
  CardByIdProvider call(
    String id,
  ) {
    return CardByIdProvider(
      id,
    );
  }

  @override
  CardByIdProvider getProviderOverride(
    covariant CardByIdProvider provider,
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
  String? get name => r'cardByIdProvider';
}

/// Provider for getting a single card.
///
/// Copied from [cardById].
class CardByIdProvider extends AutoDisposeFutureProvider<Card?> {
  /// Provider for getting a single card.
  ///
  /// Copied from [cardById].
  CardByIdProvider(
    String id,
  ) : this._internal(
          (ref) => cardById(
            ref as CardByIdRef,
            id,
          ),
          from: cardByIdProvider,
          name: r'cardByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cardByIdHash,
          dependencies: CardByIdFamily._dependencies,
          allTransitiveDependencies: CardByIdFamily._allTransitiveDependencies,
          id: id,
        );

  CardByIdProvider._internal(
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
    FutureOr<Card?> Function(CardByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CardByIdProvider._internal(
        (ref) => create(ref as CardByIdRef),
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
  AutoDisposeFutureProviderElement<Card?> createElement() {
    return _CardByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CardByIdProvider && other.id == id;
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
mixin CardByIdRef on AutoDisposeFutureProviderRef<Card?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CardByIdProviderElement extends AutoDisposeFutureProviderElement<Card?>
    with CardByIdRef {
  _CardByIdProviderElement(super.provider);

  @override
  String get id => (origin as CardByIdProvider).id;
}

String _$cardNotifierHash() => r'a8b23668ad497bf66a2c25c8df729e127ee55883';

/// Notifier for card operations.
///
/// Copied from [CardNotifier].
@ProviderFor(CardNotifier)
final cardNotifierProvider =
    AutoDisposeAsyncNotifierProvider<CardNotifier, void>.internal(
  CardNotifier.new,
  name: r'cardNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cardNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CardNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
