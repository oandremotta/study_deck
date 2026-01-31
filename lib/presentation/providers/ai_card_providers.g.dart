// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_card_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiCardRepositoryHash() => r'0076c04951bf4c851bcbd27ac29d2b225014a1fb';

/// Provider for the AI card repository.
///
/// Copied from [aiCardRepository].
@ProviderFor(aiCardRepository)
final aiCardRepositoryProvider = Provider<AiCardRepository>.internal(
  aiCardRepository,
  name: r'aiCardRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiCardRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiCardRepositoryRef = ProviderRef<AiCardRepository>;
String _$pdfServiceHash() => r'ef29c24a462b56f410905e5180ed5f4e42e1db97';

/// Provider for the PDF service.
///
/// Copied from [pdfService].
@ProviderFor(pdfService)
final pdfServiceProvider = Provider<PdfService>.internal(
  pdfService,
  name: r'pdfServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$pdfServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PdfServiceRef = ProviderRef<PdfService>;
String _$watchAiProjectsHash() => r'1f180c89062b591b0dd8d7c45373bef869a81fa3';

/// Stream provider for watching all AI projects.
///
/// Copied from [watchAiProjects].
@ProviderFor(watchAiProjects)
final watchAiProjectsProvider =
    AutoDisposeStreamProvider<List<AiProject>>.internal(
  watchAiProjects,
  name: r'watchAiProjectsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$watchAiProjectsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchAiProjectsRef = AutoDisposeStreamProviderRef<List<AiProject>>;
String _$watchDraftsByProjectHash() =>
    r'e0da15527842076ca02472346168d784861aec84';

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

/// Stream provider for watching drafts for a project.
///
/// Copied from [watchDraftsByProject].
@ProviderFor(watchDraftsByProject)
const watchDraftsByProjectProvider = WatchDraftsByProjectFamily();

/// Stream provider for watching drafts for a project.
///
/// Copied from [watchDraftsByProject].
class WatchDraftsByProjectFamily extends Family<AsyncValue<List<AiCardDraft>>> {
  /// Stream provider for watching drafts for a project.
  ///
  /// Copied from [watchDraftsByProject].
  const WatchDraftsByProjectFamily();

  /// Stream provider for watching drafts for a project.
  ///
  /// Copied from [watchDraftsByProject].
  WatchDraftsByProjectProvider call(
    String projectId,
  ) {
    return WatchDraftsByProjectProvider(
      projectId,
    );
  }

  @override
  WatchDraftsByProjectProvider getProviderOverride(
    covariant WatchDraftsByProjectProvider provider,
  ) {
    return call(
      provider.projectId,
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
  String? get name => r'watchDraftsByProjectProvider';
}

/// Stream provider for watching drafts for a project.
///
/// Copied from [watchDraftsByProject].
class WatchDraftsByProjectProvider
    extends AutoDisposeStreamProvider<List<AiCardDraft>> {
  /// Stream provider for watching drafts for a project.
  ///
  /// Copied from [watchDraftsByProject].
  WatchDraftsByProjectProvider(
    String projectId,
  ) : this._internal(
          (ref) => watchDraftsByProject(
            ref as WatchDraftsByProjectRef,
            projectId,
          ),
          from: watchDraftsByProjectProvider,
          name: r'watchDraftsByProjectProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$watchDraftsByProjectHash,
          dependencies: WatchDraftsByProjectFamily._dependencies,
          allTransitiveDependencies:
              WatchDraftsByProjectFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  WatchDraftsByProjectProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
  }) : super.internal();

  final String projectId;

  @override
  Override overrideWith(
    Stream<List<AiCardDraft>> Function(WatchDraftsByProjectRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WatchDraftsByProjectProvider._internal(
        (ref) => create(ref as WatchDraftsByProjectRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<AiCardDraft>> createElement() {
    return _WatchDraftsByProjectProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchDraftsByProjectProvider &&
        other.projectId == projectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WatchDraftsByProjectRef
    on AutoDisposeStreamProviderRef<List<AiCardDraft>> {
  /// The parameter `projectId` of this provider.
  String get projectId;
}

class _WatchDraftsByProjectProviderElement
    extends AutoDisposeStreamProviderElement<List<AiCardDraft>>
    with WatchDraftsByProjectRef {
  _WatchDraftsByProjectProviderElement(super.provider);

  @override
  String get projectId => (origin as WatchDraftsByProjectProvider).projectId;
}

String _$aiProjectsHash() => r'5bd096c7919ecd6e8ac130214ebb945ad7786fb4';

/// Provider for getting all AI projects.
///
/// Copied from [aiProjects].
@ProviderFor(aiProjects)
final aiProjectsProvider = AutoDisposeFutureProvider<List<AiProject>>.internal(
  aiProjects,
  name: r'aiProjectsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$aiProjectsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiProjectsRef = AutoDisposeFutureProviderRef<List<AiProject>>;
String _$aiProjectByIdHash() => r'441536b3d90977518191eb2b0adbb47450eb97f5';

/// Provider for getting a single AI project.
///
/// Copied from [aiProjectById].
@ProviderFor(aiProjectById)
const aiProjectByIdProvider = AiProjectByIdFamily();

/// Provider for getting a single AI project.
///
/// Copied from [aiProjectById].
class AiProjectByIdFamily extends Family<AsyncValue<AiProject?>> {
  /// Provider for getting a single AI project.
  ///
  /// Copied from [aiProjectById].
  const AiProjectByIdFamily();

  /// Provider for getting a single AI project.
  ///
  /// Copied from [aiProjectById].
  AiProjectByIdProvider call(
    String id,
  ) {
    return AiProjectByIdProvider(
      id,
    );
  }

  @override
  AiProjectByIdProvider getProviderOverride(
    covariant AiProjectByIdProvider provider,
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
  String? get name => r'aiProjectByIdProvider';
}

/// Provider for getting a single AI project.
///
/// Copied from [aiProjectById].
class AiProjectByIdProvider extends AutoDisposeFutureProvider<AiProject?> {
  /// Provider for getting a single AI project.
  ///
  /// Copied from [aiProjectById].
  AiProjectByIdProvider(
    String id,
  ) : this._internal(
          (ref) => aiProjectById(
            ref as AiProjectByIdRef,
            id,
          ),
          from: aiProjectByIdProvider,
          name: r'aiProjectByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$aiProjectByIdHash,
          dependencies: AiProjectByIdFamily._dependencies,
          allTransitiveDependencies:
              AiProjectByIdFamily._allTransitiveDependencies,
          id: id,
        );

  AiProjectByIdProvider._internal(
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
    FutureOr<AiProject?> Function(AiProjectByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AiProjectByIdProvider._internal(
        (ref) => create(ref as AiProjectByIdRef),
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
  AutoDisposeFutureProviderElement<AiProject?> createElement() {
    return _AiProjectByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AiProjectByIdProvider && other.id == id;
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
mixin AiProjectByIdRef on AutoDisposeFutureProviderRef<AiProject?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AiProjectByIdProviderElement
    extends AutoDisposeFutureProviderElement<AiProject?> with AiProjectByIdRef {
  _AiProjectByIdProviderElement(super.provider);

  @override
  String get id => (origin as AiProjectByIdProvider).id;
}

String _$draftsByProjectHash() => r'a88f39e5b3753ca84d195ffccf903dfc782676c1';

/// Provider for getting drafts for a project.
///
/// Copied from [draftsByProject].
@ProviderFor(draftsByProject)
const draftsByProjectProvider = DraftsByProjectFamily();

/// Provider for getting drafts for a project.
///
/// Copied from [draftsByProject].
class DraftsByProjectFamily extends Family<AsyncValue<List<AiCardDraft>>> {
  /// Provider for getting drafts for a project.
  ///
  /// Copied from [draftsByProject].
  const DraftsByProjectFamily();

  /// Provider for getting drafts for a project.
  ///
  /// Copied from [draftsByProject].
  DraftsByProjectProvider call(
    String projectId,
  ) {
    return DraftsByProjectProvider(
      projectId,
    );
  }

  @override
  DraftsByProjectProvider getProviderOverride(
    covariant DraftsByProjectProvider provider,
  ) {
    return call(
      provider.projectId,
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
  String? get name => r'draftsByProjectProvider';
}

/// Provider for getting drafts for a project.
///
/// Copied from [draftsByProject].
class DraftsByProjectProvider
    extends AutoDisposeFutureProvider<List<AiCardDraft>> {
  /// Provider for getting drafts for a project.
  ///
  /// Copied from [draftsByProject].
  DraftsByProjectProvider(
    String projectId,
  ) : this._internal(
          (ref) => draftsByProject(
            ref as DraftsByProjectRef,
            projectId,
          ),
          from: draftsByProjectProvider,
          name: r'draftsByProjectProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$draftsByProjectHash,
          dependencies: DraftsByProjectFamily._dependencies,
          allTransitiveDependencies:
              DraftsByProjectFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  DraftsByProjectProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
  }) : super.internal();

  final String projectId;

  @override
  Override overrideWith(
    FutureOr<List<AiCardDraft>> Function(DraftsByProjectRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DraftsByProjectProvider._internal(
        (ref) => create(ref as DraftsByProjectRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AiCardDraft>> createElement() {
    return _DraftsByProjectProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DraftsByProjectProvider && other.projectId == projectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DraftsByProjectRef on AutoDisposeFutureProviderRef<List<AiCardDraft>> {
  /// The parameter `projectId` of this provider.
  String get projectId;
}

class _DraftsByProjectProviderElement
    extends AutoDisposeFutureProviderElement<List<AiCardDraft>>
    with DraftsByProjectRef {
  _DraftsByProjectProviderElement(super.provider);

  @override
  String get projectId => (origin as DraftsByProjectProvider).projectId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
