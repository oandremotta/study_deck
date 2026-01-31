import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// UC202: Text-to-Speech service for generating audio from card content.
///
/// Supports multiple TTS providers:
/// - OpenAI TTS API
/// - Google Cloud TTS (future)
abstract class TtsService {
  /// Generate audio from text.
  Future<Uint8List> generateAudio(String text, {String? voice, double? speed});

  /// Available voices for this provider.
  List<TtsVoice> get availableVoices;

  /// Provider name.
  String get providerName;
}

/// TTS voice configuration.
class TtsVoice {
  final String id;
  final String name;
  final String language;
  final String? gender;

  const TtsVoice({
    required this.id,
    required this.name,
    required this.language,
    this.gender,
  });
}

/// OpenAI TTS implementation.
class OpenAiTtsService extends TtsService {
  final String apiKey;

  /// Available OpenAI TTS voices.
  static const List<TtsVoice> _voices = [
    TtsVoice(id: 'alloy', name: 'Alloy', language: 'en', gender: 'neutral'),
    TtsVoice(id: 'echo', name: 'Echo', language: 'en', gender: 'male'),
    TtsVoice(id: 'fable', name: 'Fable', language: 'en', gender: 'male'),
    TtsVoice(id: 'onyx', name: 'Onyx', language: 'en', gender: 'male'),
    TtsVoice(id: 'nova', name: 'Nova', language: 'en', gender: 'female'),
    TtsVoice(id: 'shimmer', name: 'Shimmer', language: 'en', gender: 'female'),
  ];

  OpenAiTtsService({required this.apiKey});

  @override
  String get providerName => 'OpenAI TTS';

  @override
  List<TtsVoice> get availableVoices => _voices;

  @override
  Future<Uint8List> generateAudio(String text, {String? voice, double? speed}) async {
    final selectedVoice = voice ?? 'nova';
    final selectedSpeed = (speed ?? 1.0).clamp(0.25, 4.0);

    try {
      debugPrint('TtsService: Generating audio for "${text.substring(0, text.length.clamp(0, 50))}..."');

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/audio/speech'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'tts-1',
          'input': text,
          'voice': selectedVoice,
          'speed': selectedSpeed,
          'response_format': 'mp3',
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('TtsService: Audio generated successfully (${response.bodyBytes.length} bytes)');
        return response.bodyBytes;
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Erro TTS: ${error['error']?['message'] ?? response.statusCode}');
      }
    } catch (e) {
      debugPrint('TtsService: Error generating audio: $e');
      rethrow;
    }
  }

  /// Estimate cost for generating audio (per character).
  /// OpenAI TTS-1: $0.015 per 1K characters
  double estimateCost(String text) {
    return (text.length / 1000) * 0.015;
  }
}

/// Google Cloud TTS implementation (placeholder for future).
class GoogleCloudTtsService extends TtsService {
  final String apiKey;

  GoogleCloudTtsService({required this.apiKey});

  @override
  String get providerName => 'Google Cloud TTS';

  @override
  List<TtsVoice> get availableVoices => const [
        TtsVoice(id: 'pt-BR-Standard-A', name: 'Feminino A', language: 'pt-BR', gender: 'female'),
        TtsVoice(id: 'pt-BR-Standard-B', name: 'Masculino B', language: 'pt-BR', gender: 'male'),
        TtsVoice(id: 'pt-BR-Wavenet-A', name: 'Feminino Premium', language: 'pt-BR', gender: 'female'),
        TtsVoice(id: 'pt-BR-Wavenet-B', name: 'Masculino Premium', language: 'pt-BR', gender: 'male'),
      ];

  @override
  Future<Uint8List> generateAudio(String text, {String? voice, double? speed}) async {
    final selectedVoice = voice ?? 'pt-BR-Standard-A';
    final selectedSpeed = (speed ?? 1.0).clamp(0.25, 4.0);

    try {
      final response = await http.post(
        Uri.parse('https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'input': {'text': text},
          'voice': {
            'languageCode': 'pt-BR',
            'name': selectedVoice,
          },
          'audioConfig': {
            'audioEncoding': 'MP3',
            'speakingRate': selectedSpeed,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioContent = data['audioContent'] as String;
        return base64Decode(audioContent);
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Erro TTS: ${error['error']?['message'] ?? response.statusCode}');
      }
    } catch (e) {
      debugPrint('GoogleTtsService: Error generating audio: $e');
      rethrow;
    }
  }
}

/// TTS provider enum.
enum TtsProvider {
  openai,
  googleCloud,
}

extension TtsProviderExtension on TtsProvider {
  String get displayName {
    switch (this) {
      case TtsProvider.openai:
        return 'OpenAI TTS';
      case TtsProvider.googleCloud:
        return 'Google Cloud TTS';
    }
  }

  String get value {
    switch (this) {
      case TtsProvider.openai:
        return 'openai';
      case TtsProvider.googleCloud:
        return 'google_cloud';
    }
  }

  static TtsProvider fromValue(String value) {
    switch (value) {
      case 'google_cloud':
        return TtsProvider.googleCloud;
      case 'openai':
      default:
        return TtsProvider.openai;
    }
  }
}
