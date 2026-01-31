import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/audio_service.dart';
import '../../data/services/tts_service.dart';
import 'ai_card_providers.dart';

part 'audio_providers.g.dart';

// ============ Configuration Keys ============

const String _audioSpeedKey = 'audio_speed';
const String _autoPlayOnRevealKey = 'auto_play_on_reveal';
const String _ttsVoiceKey = 'tts_voice';

// ============ Service Providers ============

/// Provider for the audio playback/recording service.
@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// Provider for TTS service based on configuration.
@riverpod
TtsService? ttsService(Ref ref) {
  final configAsync = ref.watch(aiConfigNotifierProvider);

  return configAsync.when(
    data: (config) {
      // Use OpenAI API key for TTS if available
      if (config.openaiApiKey != null && config.openaiApiKey!.isNotEmpty) {
        return OpenAiTtsService(apiKey: config.openaiApiKey!);
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
}

// ============ Audio Settings ============

/// Audio settings state.
class AudioSettingsState {
  final double defaultSpeed;
  final bool autoPlayOnReveal;
  final String? preferredVoice;

  const AudioSettingsState({
    this.defaultSpeed = 1.0,
    this.autoPlayOnReveal = false,
    this.preferredVoice,
  });

  AudioSettingsState copyWith({
    double? defaultSpeed,
    bool? autoPlayOnReveal,
    String? preferredVoice,
  }) {
    return AudioSettingsState(
      defaultSpeed: defaultSpeed ?? this.defaultSpeed,
      autoPlayOnReveal: autoPlayOnReveal ?? this.autoPlayOnReveal,
      preferredVoice: preferredVoice ?? this.preferredVoice,
    );
  }
}

/// Provider for loading audio settings.
@riverpod
Future<AudioSettingsState> audioSettings(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return AudioSettingsState(
    defaultSpeed: prefs.getDouble(_audioSpeedKey) ?? 1.0,
    autoPlayOnReveal: prefs.getBool(_autoPlayOnRevealKey) ?? false,
    preferredVoice: prefs.getString(_ttsVoiceKey),
  );
}

/// Save audio speed setting.
Future<void> saveAudioSpeed(double speed) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble(_audioSpeedKey, speed);
}

/// Save auto-play setting.
Future<void> saveAutoPlayOnReveal(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_autoPlayOnRevealKey, value);
}

/// Save preferred TTS voice.
Future<void> saveTtsVoice(String voiceId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_ttsVoiceKey, voiceId);
}

// ============ Audio Player State ============

/// State for current audio playback.
class AudioPlayerState {
  final bool isPlaying;
  final bool isLoading;
  final String? currentCardId;
  final AudioType? currentType;
  final String? error;

  const AudioPlayerState({
    this.isPlaying = false,
    this.isLoading = false,
    this.currentCardId,
    this.currentType,
    this.error,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    String? currentCardId,
    AudioType? currentType,
    String? error,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      currentCardId: currentCardId ?? this.currentCardId,
      currentType: currentType ?? this.currentType,
      error: error,
    );
  }
}

enum AudioType {
  tts,
  pronunciation,
}

/// StateNotifier for audio playback.
class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final AudioService _audioService;

  AudioPlayerNotifier(this._audioService) : super(const AudioPlayerState());

  /// Play TTS audio for a card.
  Future<void> playTts(String cardId, String audioUrl) async {
    state = state.copyWith(
      isLoading: true,
      currentCardId: cardId,
      currentType: AudioType.tts,
      error: null,
    );

    try {
      await _audioService.playFromUrl(audioUrl);
      state = state.copyWith(isPlaying: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isPlaying: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Play pronunciation audio for a card.
  Future<void> playPronunciation(String cardId, String audioUrl) async {
    state = state.copyWith(
      isLoading: true,
      currentCardId: cardId,
      currentType: AudioType.pronunciation,
      error: null,
    );

    try {
      await _audioService.playFromUrl(audioUrl);
      state = state.copyWith(isPlaying: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isPlaying: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Stop playback.
  Future<void> stop() async {
    await _audioService.stop();
    state = const AudioPlayerState();
  }

  /// Toggle playback.
  Future<void> toggle(String cardId, String audioUrl, AudioType type) async {
    if (state.isPlaying && state.currentCardId == cardId && state.currentType == type) {
      await stop();
    } else {
      if (type == AudioType.tts) {
        await playTts(cardId, audioUrl);
      } else {
        await playPronunciation(cardId, audioUrl);
      }
    }
  }
}

/// Provider for audio player notifier.
final audioPlayerNotifierProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return AudioPlayerNotifier(audioService);
});

// ============ TTS Generation ============

/// Generate TTS audio for card content.
Future<Uint8List?> generateTtsAudioDirect(
  TtsService service,
  String text, {
  String? voice,
  double? speed,
}) async {
  try {
    return await service.generateAudio(text, voice: voice, speed: speed);
  } catch (e) {
    return null;
  }
}
