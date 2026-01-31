import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'ai_generation_service.dart';

/// Google Gemini implementation of [AiGenerationService].
///
/// Uses direct HTTP calls matching the working curl format.
class GeminiGenerationService extends AiGenerationService {
  final String apiKey;

  /// Model to use for generation.
  static const String modelName = 'gemini-2.5-flash-lite';

  /// Base URL for Gemini API.
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  /// Cost per 1M input tokens (USD).
  static const double inputTokenCost = 0.075;

  /// Cost per 1M output tokens (USD).
  static const double outputTokenCost = 0.30;

  /// Average tokens per character (estimate).
  static const double tokensPerChar = 0.25;

  GeminiGenerationService({required this.apiKey}) {
    debugPrint('Initializing Gemini with model: $modelName');
  }

  @override
  AiProvider get provider => AiProvider.gemini;

  @override
  Future<List<GeneratedCard>> generateCards(AiGenerationRequest request) async {
    try {
      final prompt = buildGenerationPrompt(request);
      debugPrint(
          'Gemini: Generating ${request.cardCount} cards with model $modelName...');

      final text = await _callGeminiApi(prompt);

      if (text.isEmpty) {
        throw Exception('Resposta vazia da API Gemini');
      }

      debugPrint('Gemini response received, parsing...');
      return _parseCardsResponse(text);
    } catch (e) {
      debugPrint('Gemini generation error: $e');
      rethrow;
    }
  }

  @override
  Future<GeneratedCard> refineCard({
    required String originalFront,
    required String originalBack,
    required String feedback,
  }) async {
    try {
      final prompt = buildRefinePrompt(
        originalFront: originalFront,
        originalBack: originalBack,
        feedback: feedback,
      );

      final text = await _callGeminiApi(prompt);

      if (text.isEmpty) {
        throw Exception('Resposta vazia da API Gemini');
      }

      return _parseSingleCardResponse(text);
    } catch (e) {
      debugPrint('Gemini refine error: $e');
      rethrow;
    }
  }

  @override
  Future<PedagogicalFields> generatePedagogicalFields({
    required String question,
    required String answer,
  }) async {
    try {
      final prompt = _buildPedagogicalFieldsPrompt(question, answer);
      debugPrint('Gemini: Generating pedagogical fields...');

      final text = await _callGeminiApi(prompt);

      if (text.isEmpty) {
        throw Exception('Resposta vazia da API Gemini');
      }

      debugPrint('Gemini pedagogical response received, parsing...');
      return _parsePedagogicalFieldsResponse(text, question);
    } catch (e) {
      debugPrint('Gemini pedagogical generation error: $e');
      rethrow;
    }
  }

  /// Builds prompt for generating pedagogical fields (UC188/UC190).
  String _buildPedagogicalFieldsPrompt(String question, String answer) {
    return '''
Voce e um especialista em educacao e tecnicas de memorizacao.
Dado um card de estudo, gere os campos pedagogicos para facilitar a memorizacao:

CARD:
- Pergunta: "$question"
- Resposta/Explicacao: "$answer"

GERE:
1. summary: Resposta CURTA e direta (maximo 240 caracteres) - sera mostrada primeiro ao estudar
2. keyPhrase: Frase-chave de memoria (maximo 120 caracteres) - uma frase afirmativa simples que ancora o conceito

REGRAS IMPORTANTES:
- O summary NAO pode ser igual a pergunta
- O summary deve ser uma resposta direta e concisa, nao uma reformulacao da pergunta
- O keyPhrase DEVE ser uma frase afirmativa (NAO uma pergunta, NAO terminar com ?)
- O keyPhrase deve capturar a essencia do conceito em uma frase memoravel
- Mantenha a linguagem em portugues do Brasil

Retorne APENAS um JSON valido (sem markdown, sem explicacoes):
{
  "summary": "resposta curta max 240 chars",
  "keyPhrase": "frase-chave max 120 chars"
}''';
  }

  /// Parse pedagogical fields response with normalization.
  PedagogicalFields _parsePedagogicalFieldsResponse(String response, String question) {
    try {
      var jsonStr = response.trim();
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.substring(7);
      } else if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.substring(3);
      }
      if (jsonStr.endsWith('```')) {
        jsonStr = jsonStr.substring(0, jsonStr.length - 3);
      }
      jsonStr = jsonStr.trim();

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      var summary = _cleanText(json['summary'] as String? ?? '');
      var keyPhrase = _cleanText(json['keyPhrase'] as String? ?? '');
      bool needsReview = false;

      // Validate and truncate summary
      if (summary.isEmpty) {
        needsReview = true;
        summary = 'Resposta não gerada';
      } else if (summary.length > 240) {
        summary = _smartTruncate(summary, 240);
        needsReview = true;
      }

      // Check if summary is too similar to question
      if (_isSimilarText(summary, question)) {
        needsReview = true;
      }

      // Validate and truncate keyPhrase
      if (keyPhrase.isEmpty) {
        needsReview = true;
        keyPhrase = _extractFirstSentence(summary, maxLength: 120);
      } else if (keyPhrase.length > 120) {
        keyPhrase = _smartTruncate(keyPhrase, 120);
        needsReview = true;
      }

      // Ensure keyPhrase is not a question
      if (keyPhrase.endsWith('?')) {
        keyPhrase = '${keyPhrase.substring(0, keyPhrase.length - 1)}.';
        needsReview = true;
      }

      return PedagogicalFields(
        summary: summary,
        keyPhrase: keyPhrase,
        confidenceScore: needsReview ? 0.6 : 0.85,
        needsReview: needsReview,
      );
    } catch (e) {
      debugPrint('Error parsing pedagogical fields response: $e');
      debugPrint('Response was: $response');
      throw Exception('Erro ao processar resposta da IA. Tente novamente.');
    }
  }

  /// Call Gemini API directly via HTTP (matching working curl format).
  Future<String> _callGeminiApi(String prompt) async {
    final url = '$_baseUrl/models/$modelName:generateContent?key=$apiKey';

    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'response_mime_type': 'application/json',
      }
    });

    debugPrint('Calling Gemini API: $url');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    debugPrint('Response status: ${response.statusCode}');

    if (response.statusCode != 200) {
      debugPrint('Response body: ${response.body}');
      final error = jsonDecode(response.body);
      final message = error['error']?['message'] ?? 'Unknown error';
      throw Exception('Erro na API Gemini: $message');
    }

    final json = jsonDecode(response.body);
    final candidates = json['candidates'] as List<dynamic>?;

    if (candidates == null || candidates.isEmpty) {
      throw Exception('Nenhuma resposta gerada');
    }

    final content = candidates[0]['content'];
    final parts = content['parts'] as List<dynamic>?;

    if (parts == null || parts.isEmpty) {
      throw Exception('Resposta vazia');
    }

    return parts[0]['text'] as String;
  }

  @override
  double estimateCost(AiGenerationRequest request) {
    final inputChars = request.content.length + 500;
    final inputTokens = inputChars * tokensPerChar;
    final outputTokens = request.cardCount * 100.0;

    final inputCost = (inputTokens / 1000000) * inputTokenCost;
    final outputCost = (outputTokens / 1000000) * outputTokenCost;

    return inputCost + outputCost;
  }

  /// Parse cards response and normalize with fallbacks (UC168).
  List<GeneratedCard> _parseCardsResponse(String response) {
    try {
      var jsonStr = response.trim();
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.substring(7);
      } else if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.substring(3);
      }
      if (jsonStr.endsWith('```')) {
        jsonStr = jsonStr.substring(0, jsonStr.length - 3);
      }
      jsonStr = jsonStr.trim();

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final cardsList = json['cards'] as List<dynamic>;

      return cardsList.map((cardJson) {
        final card = cardJson as Map<String, dynamic>;
        return _normalizeCard(card);
      }).toList();
    } catch (e) {
      debugPrint('Error parsing Gemini response: $e');
      debugPrint('Response was: $response');
      throw Exception('Erro ao processar resposta da IA. Tente novamente.');
    }
  }

  /// Normalize a single card with fallbacks (UC168).
  GeneratedCard _normalizeCard(Map<String, dynamic> card) {
    bool needsReview = false;

    // Get raw values (support both old and new format)
    String question = (card['question'] ?? card['front'] ?? '') as String;
    String? summary = card['summary'] as String?;
    String? keyPhrase = card['keyPhrase'] as String?;
    String? explanation = (card['explanation'] ?? card['back']) as String?;
    String? hint = card['hint'] as String?;

    // Clean and normalize text
    question = _cleanText(question);
    summary = summary != null ? _cleanText(summary) : null;
    keyPhrase = keyPhrase != null ? _cleanText(keyPhrase) : null;
    explanation = explanation != null ? _cleanText(explanation) : null;

    // Apply fallbacks for summary (UC168)
    if (summary == null || summary.isEmpty) {
      needsReview = true;
      if (explanation != null && explanation.isNotEmpty) {
        // Extract first sentence from explanation
        summary = _extractFirstSentence(explanation, maxLength: 240);
      } else if (keyPhrase != null && keyPhrase.isNotEmpty) {
        summary = keyPhrase;
      } else {
        summary = 'Resposta não gerada';
      }
      debugPrint('Applied fallback for summary: $summary');
    }

    // Truncate summary if too long (with smart cut at punctuation)
    if (summary.length > 240) {
      summary = _smartTruncate(summary, 240);
      needsReview = true;
    }

    // Apply fallbacks for keyPhrase (UC168)
    if (keyPhrase == null || keyPhrase.isEmpty) {
      needsReview = true;
      // Derive from summary
      keyPhrase = _extractFirstSentence(summary, maxLength: 120);
      debugPrint('Applied fallback for keyPhrase: $keyPhrase');
    }

    // Truncate keyPhrase if too long
    if (keyPhrase.length > 120) {
      keyPhrase = _smartTruncate(keyPhrase, 120);
      needsReview = true;
    }

    // Ensure keyPhrase is not a question
    if (keyPhrase.endsWith('?')) {
      keyPhrase = '${keyPhrase.substring(0, keyPhrase.length - 1)}.';
      needsReview = true;
    }

    // Check for low quality indicators
    if (_isSimilarText(summary, question)) {
      needsReview = true;
      debugPrint('Summary too similar to question, marking for review');
    }

    if (summary.length < 10 || keyPhrase.length < 10) {
      needsReview = true;
      debugPrint('Card too short, marking for review');
    }

    // For backward compatibility, use summary as back if explanation is empty
    final back = (explanation != null && explanation.isNotEmpty)
        ? explanation
        : summary;

    return GeneratedCard(
      front: question,
      back: back,
      summary: summary,
      keyPhrase: keyPhrase,
      hint: hint,
      difficulty: card['difficulty'] as String? ?? 'medium',
      suggestedTags: (card['tags'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          [],
      confidenceScore: needsReview ? 0.6 : 0.85,
      needsReview: needsReview,
    );
  }

  /// Clean text by removing excess whitespace and common prefixes.
  String _cleanText(String text) {
    var cleaned = text.trim();
    // Remove common AI prefixes
    final prefixes = [
      'Resposta:',
      'Explicação:',
      'Resumo:',
      'Frase-chave:',
      'Answer:',
      'R:',
    ];
    for (final prefix in prefixes) {
      if (cleaned.toLowerCase().startsWith(prefix.toLowerCase())) {
        cleaned = cleaned.substring(prefix.length).trim();
      }
    }
    // Remove excessive whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    return cleaned;
  }

  /// Extract first sentence from text with max length.
  String _extractFirstSentence(String text, {required int maxLength}) {
    // Find first sentence end
    final sentenceEnd = RegExp(r'[.!?]');
    final match = sentenceEnd.firstMatch(text);

    String sentence;
    if (match != null && match.end <= maxLength) {
      sentence = text.substring(0, match.end);
    } else if (text.length <= maxLength) {
      sentence = text;
    } else {
      sentence = _smartTruncate(text, maxLength);
    }

    return sentence.trim();
  }

  /// Truncate text smartly at last punctuation or space.
  String _smartTruncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;

    // Try to cut at last punctuation
    final truncated = text.substring(0, maxLength - 3);
    final lastPunctuation = truncated.lastIndexOf(RegExp(r'[.!?,;:]'));

    if (lastPunctuation > maxLength * 0.6) {
      return '${truncated.substring(0, lastPunctuation + 1)}..';
    }

    // Cut at last space
    final lastSpace = truncated.lastIndexOf(' ');
    if (lastSpace > maxLength * 0.6) {
      return '${truncated.substring(0, lastSpace)}...';
    }

    return '$truncated...';
  }

  /// Check if two texts are too similar (normalized comparison).
  bool _isSimilarText(String a, String b) {
    final normalizedA = a.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
    final normalizedB = b.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
    return normalizedA == normalizedB;
  }

  GeneratedCard _parseSingleCardResponse(String response) {
    try {
      var jsonStr = response.trim();
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.substring(7);
      } else if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.substring(3);
      }
      if (jsonStr.endsWith('```')) {
        jsonStr = jsonStr.substring(0, jsonStr.length - 3);
      }
      jsonStr = jsonStr.trim();

      final card = jsonDecode(jsonStr) as Map<String, dynamic>;
      return _normalizeCard(card);
    } catch (e) {
      debugPrint('Error parsing single card response: $e');
      throw Exception('Erro ao processar resposta da IA. Tente novamente.');
    }
  }
}
