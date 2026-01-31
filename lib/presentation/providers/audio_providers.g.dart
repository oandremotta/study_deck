// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$audioServiceHash() => r'b9a9e5c5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5';

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
String _$audioSettingsHash() => r'a8a8e5c5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5';

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
