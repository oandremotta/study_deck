import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

/// UC201-UC205: Audio service for TTS playback and pronunciation recording.
///
/// Provides:
/// - TTS audio playback (UC201, UC202)
/// - Pronunciation recording (UC203)
/// - Audio comparison (UC204)
/// - Playback settings (UC205)
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  AudioRecorder? _recorder;

  // Playback state
  bool _isPlaying = false;
  bool _isRecording = false;
  double _playbackSpeed = 1.0;

  // Stream controllers for state updates
  final _playbackStateController = StreamController<AudioPlaybackState>.broadcast();
  final _recordingStateController = StreamController<AudioRecordingState>.broadcast();

  /// Stream of playback state changes.
  Stream<AudioPlaybackState> get playbackState => _playbackStateController.stream;

  /// Stream of recording state changes.
  Stream<AudioRecordingState> get recordingState => _recordingStateController.stream;

  /// Whether audio is currently playing.
  bool get isPlaying => _isPlaying;

  /// Whether audio is currently being recorded.
  bool get isRecording => _isRecording;

  /// Current playback speed.
  double get playbackSpeed => _playbackSpeed;

  AudioService() {
    _initPlayer();
  }

  void _initPlayer() {
    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      _playbackStateController.add(AudioPlaybackState(
        isPlaying: _isPlaying,
        speed: _playbackSpeed,
      ));
    });
  }

  /// UC201/UC202: Play TTS audio from URL.
  Future<void> playFromUrl(String url) async {
    try {
      await _player.stop();
      await _player.setPlaybackRate(_playbackSpeed);
      await _player.play(UrlSource(url));
      debugPrint('AudioService: Playing audio from $url');
    } catch (e) {
      debugPrint('AudioService: Error playing audio: $e');
      rethrow;
    }
  }

  /// UC201: Play audio from bytes (for cached/local audio).
  Future<void> playFromBytes(Uint8List bytes) async {
    try {
      await _player.stop();
      await _player.setPlaybackRate(_playbackSpeed);
      await _player.play(BytesSource(bytes));
    } catch (e) {
      debugPrint('AudioService: Error playing audio bytes: $e');
      rethrow;
    }
  }

  /// Stop current playback.
  Future<void> stop() async {
    await _player.stop();
  }

  /// Pause current playback.
  Future<void> pause() async {
    await _player.pause();
  }

  /// Resume paused playback.
  Future<void> resume() async {
    await _player.resume();
  }

  /// UC205: Set playback speed (0.5x to 2.0x).
  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed.clamp(0.5, 2.0);
    await _player.setPlaybackRate(_playbackSpeed);
    _playbackStateController.add(AudioPlaybackState(
      isPlaying: _isPlaying,
      speed: _playbackSpeed,
    ));
  }

  /// UC203: Start recording pronunciation.
  Future<void> startRecording() async {
    if (kIsWeb) {
      debugPrint('AudioService: Recording not supported on web');
      throw UnsupportedError('Recording not supported on web platform');
    }

    _recorder ??= AudioRecorder();

    if (await _recorder!.hasPermission()) {
      await _recorder!.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: '', // Will use temporary path
      );
      _isRecording = true;
      _recordingStateController.add(AudioRecordingState(
        isRecording: true,
        duration: Duration.zero,
      ));
      debugPrint('AudioService: Recording started');
    } else {
      throw Exception('Permissão de microfone negada');
    }
  }

  /// UC203: Stop recording and return the audio path.
  Future<String?> stopRecording() async {
    if (_recorder == null || !_isRecording) return null;

    final path = await _recorder!.stop();
    _isRecording = false;
    _recordingStateController.add(AudioRecordingState(
      isRecording: false,
      duration: Duration.zero,
    ));
    debugPrint('AudioService: Recording stopped, saved to $path');
    return path;
  }

  /// UC203: Cancel recording without saving.
  Future<void> cancelRecording() async {
    if (_recorder == null || !_isRecording) return;

    await _recorder!.stop();
    _isRecording = false;
    _recordingStateController.add(AudioRecordingState(
      isRecording: false,
      duration: Duration.zero,
    ));
  }

  /// UC204: Get audio duration for comparison display.
  Future<Duration?> getAudioDuration(String url) async {
    // Note: Duration detection may not work for all audio formats/sources
    try {
      await _player.setSource(UrlSource(url));
      final duration = await _player.getDuration();
      return duration;
    } catch (e) {
      debugPrint('AudioService: Error getting duration: $e');
      return null;
    }
  }

  /// Dispose resources.
  void dispose() {
    _player.dispose();
    _recorder?.dispose();
    _playbackStateController.close();
    _recordingStateController.close();
  }
}

/// State of audio playback.
class AudioPlaybackState {
  final bool isPlaying;
  final double speed;
  final Duration? position;
  final Duration? duration;

  const AudioPlaybackState({
    required this.isPlaying,
    this.speed = 1.0,
    this.position,
    this.duration,
  });
}

/// State of audio recording.
class AudioRecordingState {
  final bool isRecording;
  final Duration duration;
  final double? amplitude;

  const AudioRecordingState({
    required this.isRecording,
    required this.duration,
    this.amplitude,
  });
}

/// UC205: Audio settings for the app.
class AudioSettings {
  /// Default playback speed.
  final double defaultSpeed;

  /// Auto-play TTS when revealing answer.
  final bool autoPlayOnReveal;

  /// Play pronunciation after TTS.
  final bool playPronunciationAfterTts;

  const AudioSettings({
    this.defaultSpeed = 1.0,
    this.autoPlayOnReveal = false,
    this.playPronunciationAfterTts = false,
  });

  AudioSettings copyWith({
    double? defaultSpeed,
    bool? autoPlayOnReveal,
    bool? playPronunciationAfterTts,
  }) {
    return AudioSettings(
      defaultSpeed: defaultSpeed ?? this.defaultSpeed,
      autoPlayOnReveal: autoPlayOnReveal ?? this.autoPlayOnReveal,
      playPronunciationAfterTts: playPronunciationAfterTts ?? this.playPronunciationAfterTts,
    );
  }
}
