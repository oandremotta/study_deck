import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';

import 'ai_generation_service.dart';

/// OpenAI implementation of [AiGenerationService].
///
/// Uses GPT-4o-mini for cost-effective generation.
class OpenAiGenerationService extends AiGenerationService {
  final String apiKey;

  /// Model to use for generation.
  static const String modelName = 'gpt-4o-mini';

  /// Cost per 1M input tokens (USD).
  static const double inputTokenCost = 0.15;

  /// Cost per 1M output tokens (USD).
  static const double outputTokenCost = 0.60;

  /// Average tokens per character (estimate).
  static const double tokensPerChar = 0.25;

  OpenAiGenerationService({required this.apiKey}) {
    OpenAI.apiKey = apiKey;
  }

  @override
  AiProvider get provider => AiProvider.openai;

  @override
  Future<List<GeneratedCard>> generateCards(AiGenerationRequest request) async {
    try {
      final prompt = buildGenerationPrompt(request);
      debugPrint('OpenAI: Generating ${request.cardCount} cards...');

      final response = await OpenAI.instance.chat.create(
        model: modelName,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'Voce e um assistente especializado em criar flashcards educacionais. '
                'Sempre responda apenas com JSON valido, sem markdown ou explicacoes.',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
        temperature: 0.7,
        maxTokens: 4096,
      );

      final text = response.choices.first.message.content?.first.text;

      if (text == null || text.isEmpty) {
        throw Exception('Resposta vazia da API OpenAI');
      }

      debugPrint('OpenAI response received, parsing...');
      return _parseCardsResponse(text);
    } catch (e) {
      debugPrint('OpenAI generation error: $e');
      if (e is RequestFailedException) {
        throw Exception('Erro na API OpenAI: ${e.message}');
      }
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

      final response = await OpenAI.instance.chat.create(
        model: modelName,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'Voce e um assistente especializado em criar flashcards educacionais. '
                'Sempre responda apenas com JSON valido, sem markdown.',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
        temperature: 0.7,
        maxTokens: 1024,
      );

      final text = response.choices.first.message.content?.first.text;

      if (text == null || text.isEmpty) {
        throw Exception('Resposta vazia da API OpenAI');
      }

      return _parseSingleCardResponse(text);
    } catch (e) {
      debugPrint('OpenAI refine error: $e');
      if (e is RequestFailedException) {
        throw Exception('Erro na API OpenAI: ${e.message}');
      }
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
      debugPrint('OpenAI: Generating pedagogical fields...');

      final response = await OpenAI.instance.chat.create(
        model: modelName,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'Voce e um assistente especializado em educacao e tecnicas de memorizacao. '
                'Sempre responda apenas com JSON valido, sem markdown.',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
        temperature: 0.7,
        maxTokens: 512,
      );

      final text = response.choices.first.message.content?.first.text;

      if (text == null || text.isEmpty) {
        throw Exception('Resposta vazia da API OpenAI');
      }

      debugPrint('OpenAI pedagogical response received, parsing...');
      return _parsePedagogicalFieldsResponse(text, question);
    } catch (e) {
      debugPrint('OpenAI pedagogical generation error: $e');
      if (e is RequestFailedException) {
        throw Exception('Erro na API OpenAI: ${e.message}');
      }
      rethrow;
    }
  }

  /// Builds prompt for generating pedagogical fields (UC188/UC190).
  String _buildPedagogicalFieldsPrompt(String question, String answer) {
    return '''
Dado um card de estudo, gere os campos pedagogicos para facilitar a memorizacao:

CARD:
- Pergunta: "$question"
- Resposta/Explicacao: "$answer"

GERE:
1. summary: Resposta CURTA e direta (maximo 240 caracteres)
2. keyPhrase: Frase-chave de memoria (maximo 120 caracteres) - frase afirmativa simples

REGRAS:
- O summary NAO pode ser igual a pergunta
- O keyPhrase NAO pode terminar com ?
- Mantenha em portugues do Brasil

Retorne APENAS JSON valido:
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

      var summary = (json['summary'] as String? ?? '').trim();
      var keyPhrase = (json['keyPhrase'] as String? ?? '').trim();
      bool needsReview = false;

      // Validate summary
      if (summary.isEmpty) {
        needsReview = true;
        summary = 'Resposta não gerada';
      } else if (summary.length > 240) {
        summary = '${summary.substring(0, 237)}...';
        needsReview = true;
      }

      // Check if summary equals question
      if (summary.toLowerCase().trim() == question.toLowerCase().trim()) {
        needsReview = true;
      }

      // Validate keyPhrase
      if (keyPhrase.isEmpty) {
        needsReview = true;
        keyPhrase = summary.length <= 120 ? summary : '${summary.substring(0, 117)}...';
      } else if (keyPhrase.length > 120) {
        keyPhrase = '${keyPhrase.substring(0, 117)}...';
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

  @override
  double estimateCost(AiGenerationRequest request) {
    // Estimate input tokens
    final inputChars = request.content.length + 500; // prompt overhead
    final inputTokens = inputChars * tokensPerChar;

    // Estimate output tokens (roughly 100 tokens per card)
    final outputTokens = request.cardCount * 100.0;

    final inputCost = (inputTokens / 1000000) * inputTokenCost;
    final outputCost = (outputTokens / 1000000) * outputTokenCost;

    return inputCost + outputCost;
  }

  List<GeneratedCard> _parseCardsResponse(String response) {
    try {
      // Clean up response - remove markdown code blocks if present
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
        return GeneratedCard(
          front: card['front'] as String,
          back: card['back'] as String,
          hint: card['hint'] as String?,
          difficulty: card['difficulty'] as String? ?? 'medium',
          suggestedTags: (card['tags'] as List<dynamic>?)
                  ?.map((t) => t.toString())
                  .toList() ??
              [],
          confidenceScore: 0.85,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error parsing OpenAI response: $e');
      debugPrint('Response was: $response');
      throw Exception('Erro ao processar resposta da IA. Tente novamente.');
    }
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
      return GeneratedCard(
        front: card['front'] as String,
        back: card['back'] as String,
        hint: card['hint'] as String?,
        difficulty: card['difficulty'] as String? ?? 'medium',
        suggestedTags: (card['tags'] as List<dynamic>?)
                ?.map((t) => t.toString())
                .toList() ??
            [],
        confidenceScore: 0.85,
      );
    } catch (e) {
      debugPrint('Error parsing single card response: $e');
      throw Exception('Erro ao processar resposta da IA. Tente novamente.');
    }
  }
}
