// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studyRepositoryHash() => r'a310ff47294195866f53329dcaa3142d00225a9c';

/// Provider for the study repository.
///
/// Copied from [studyRepository].
@ProviderFor(studyRepository)
final studyRepositoryProvider = Provider<StudyRepository>.internal(
  studyRepository,
  name: r'studyRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$studyRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudyRepositoryRef = ProviderRef<StudyRepository>;
String _$userStatsHash() => r'451cad7c5d41fe0859360f2b6451478b1b805074';

/// Provider for user stats.
///
/// Copied from [userStats].
@ProviderFor(userStats)
final userStatsProvider = AutoDisposeFutureProvider<UserStats>.internal(
  userStats,
  name: r'userStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserStatsRef = AutoDisposeFutureProviderRef<UserStats>;
String _$watchUserStatsHash() => r'a6c0b92fabcf15359a61f5d3db496aa1f7df709f';

/// Stream provider for watching user stats.
///
/// Copied from [watchUserStats].
@ProviderFor(watchUserStats)
final watchUserStatsProvider = AutoDisposeStreamProvider<UserStats>.internal(
  watchUserStats,
  name: r'watchUserStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$watchUserStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchUserStatsRef = AutoDisposeStreamProviderRef<UserStats>;
String _$activeSessionHash() => r'ea95ce46d99e57d818c59df02ef4909794056a01';

/// Provider for active study session.
///
/// Copied from [activeSession].
@ProviderFor(activeSession)
final activeSessionProvider = AutoDisposeFutureProvider<StudySession?>.internal(
  activeSession,
  name: r'activeSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveSessionRef = AutoDisposeFutureProviderRef<StudySession?>;
String _$deckStudyStatsHash() => r'fd070b612a494f2833ab281471f5ae86221f1263';

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

/// Provider for deck study stats.
///
/// Copied from [deckStudyStats].
@ProviderFor(deckStudyStats)
const deckStudyStatsProvider = DeckStudyStatsFamily();

/// Provider for deck study stats.
///
/// Copied from [deckStudyStats].
class DeckStudyStatsFamily extends Family<AsyncValue<DeckStudyStats>> {
  /// Provider for deck study stats.
  ///
  /// Copied from [deckStudyStats].
  const DeckStudyStatsFamily();

  /// Provider for deck study stats.
  ///
  /// Copied from [deckStudyStats].
  DeckStudyStatsProvider call(
    String deckId,
  ) {
    return DeckStudyStatsProvider(
      deckId,
    );
  }

  @override
  DeckStudyStatsProvider getProviderOverride(
    covariant DeckStudyStatsProvider provider,
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
  String? get name => r'deckStudyStatsProvider';
}

/// Provider for deck study stats.
///
/// Copied from [deckStudyStats].
class DeckStudyStatsProvider extends AutoDisposeFutureProvider<DeckStudyStats> {
  /// Provider for deck study stats.
  ///
  /// Copied from [deckStudyStats].
  DeckStudyStatsProvider(
    String deckId,
  ) : this._internal(
          (ref) => deckStudyStats(
            ref as DeckStudyStatsRef,
            deckId,
          ),
          from: deckStudyStatsProvider,
          name: r'deckStudyStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deckStudyStatsHash,
          dependencies: DeckStudyStatsFamily._dependencies,
          allTransitiveDependencies:
              DeckStudyStatsFamily._allTransitiveDependencies,
          deckId: deckId,
        );

  DeckStudyStatsProvider._internal(
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
    FutureOr<DeckStudyStats> Function(DeckStudyStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeckStudyStatsProvider._internal(
        (ref) => create(ref as DeckStudyStatsRef),
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
  AutoDisposeFutureProviderElement<DeckStudyStats> createElement() {
    return _DeckStudyStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeckStudyStatsProvider && other.deckId == deckId;
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
mixin DeckStudyStatsRef on AutoDisposeFutureProviderRef<DeckStudyStats> {
  /// The parameter `deckId` of this provider.
  String get deckId;
}

class _DeckStudyStatsProviderElement
    extends AutoDisposeFutureProviderElement<DeckStudyStats>
    with DeckStudyStatsRef {
  _DeckStudyStatsProviderElement(super.provider);

  @override
  String get deckId => (origin as DeckStudyStatsProvider).deckId;
}

String _$studyQueueHash() => r'3df34b27c48de8373ba1b2acf3cd8e64a2d2dc62';

/// Provider for study queue.
///
/// Copied from [studyQueue].
@ProviderFor(studyQueue)
const studyQueueProvider = StudyQueueFamily();

/// Provider for study queue.
///
/// Copied from [studyQueue].
class StudyQueueFamily extends Family<AsyncValue<List<Card>>> {
  /// Provider for study queue.
  ///
  /// Copied from [studyQueue].
  const StudyQueueFamily();

  /// Provider for study queue.
  ///
  /// Copied from [studyQueue].
  StudyQueueProvider call({
    String? deckId,
    required StudyMode mode,
    int? limit,
  }) {
    return StudyQueueProvider(
      deckId: deckId,
      mode: mode,
      limit: limit,
    );
  }

  @override
  StudyQueueProvider getProviderOverride(
    covariant StudyQueueProvider provider,
  ) {
    return call(
      deckId: provider.deckId,
      mode: provider.mode,
      limit: provider.limit,
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
  String? get name => r'studyQueueProvider';
}

/// Provider for study queue.
///
/// Copied from [studyQueue].
class StudyQueueProvider extends AutoDisposeFutureProvider<List<Card>> {
  /// Provider for study queue.
  ///
  /// Copied from [studyQueue].
  StudyQueueProvider({
    String? deckId,
    required StudyMode mode,
    int? limit,
  }) : this._internal(
          (ref) => studyQueue(
            ref as StudyQueueRef,
            deckId: deckId,
            mode: mode,
            limit: limit,
          ),
          from: studyQueueProvider,
          name: r'studyQueueProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studyQueueHash,
          dependencies: StudyQueueFamily._dependencies,
          allTransitiveDependencies:
              StudyQueueFamily._allTransitiveDependencies,
          deckId: deckId,
          mode: mode,
          limit: limit,
        );

  StudyQueueProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deckId,
    required this.mode,
    required this.limit,
  }) : super.internal();

  final String? deckId;
  final StudyMode mode;
  final int? limit;

  @override
  Override overrideWith(
    FutureOr<List<Card>> Function(StudyQueueRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudyQueueProvider._internal(
        (ref) => create(ref as StudyQueueRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deckId: deckId,
        mode: mode,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Card>> createElement() {
    return _StudyQueueProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyQueueProvider &&
        other.deckId == deckId &&
        other.mode == mode &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deckId.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudyQueueRef on AutoDisposeFutureProviderRef<List<Card>> {
  /// The parameter `deckId` of this provider.
  String? get deckId;

  /// The parameter `mode` of this provider.
  StudyMode get mode;

  /// The parameter `limit` of this provider.
  int? get limit;
}

class _StudyQueueProviderElement
    extends AutoDisposeFutureProviderElement<List<Card>> with StudyQueueRef {
  _StudyQueueProviderElement(super.provider);

  @override
  String? get deckId => (origin as StudyQueueProvider).deckId;
  @override
  StudyMode get mode => (origin as StudyQueueProvider).mode;
  @override
  int? get limit => (origin as StudyQueueProvider).limit;
}

String _$studyNotifierHash() => r'eed7c9abfe9df0b9ca852c96456a49288025a634';

/// Notifier for managing study sessions.
///
/// Copied from [StudyNotifier].
@ProviderFor(StudyNotifier)
final studyNotifierProvider =
    AutoDisposeAsyncNotifierProvider<StudyNotifier, StudySession?>.internal(
  StudyNotifier.new,
  name: r'studyNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$studyNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StudyNotifier = AutoDisposeAsyncNotifier<StudySession?>;
String _$userGoalsNotifierHash() => r'3f0bc4bc7f462db5a7e2b785339b26401db5b682';

/// Notifier for updating user goals.
///
/// Copied from [UserGoalsNotifier].
@ProviderFor(UserGoalsNotifier)
final userGoalsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<UserGoalsNotifier, void>.internal(
  UserGoalsNotifier.new,
  name: r'userGoalsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userGoalsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserGoalsNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
