// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$audioServiceHash() => r'010adb07618eeb58ad083f9a779873d496d836ee';

/// Provider for the audio playback/recording service.
///
/// Copied from [audioService].
@ProviderFor(audioService)
final audioServiceProvider = Provider<AudioService>.internal(
  audioService,
  name: r'audioServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$audioServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AudioServiceRef = ProviderRef<AudioService>;
String _$ttsServiceHash() => r'0849baaee56a29fc469ff2a1a53368b38d4d6bd5';

/// Provider for TTS service based on configuration.
///
/// Copied from [ttsService].
@ProviderFor(ttsService)
final ttsServiceProvider = AutoDisposeProvider<TtsService?>.internal(
  ttsService,
  name: r'ttsServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$ttsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TtsServiceRef = AutoDisposeProviderRef<TtsService?>;
String _$audioSettingsHash() => r'abd65ff8a5601d27a9c3c37725925416f4ebdd11';

/// Provider for loading audio settings.
///
/// Copied from [audioSettings].
@ProviderFor(audioSettings)
final audioSettingsProvider =
    AutoDisposeFutureProvider<AudioSettingsState>.internal(
  audioSettings,
  name: r'audioSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$audioSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AudioSettingsRef = AutoDisposeFutureProviderRef<AudioSettingsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
