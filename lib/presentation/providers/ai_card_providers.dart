import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/ai_card_repository_impl.dart';
import '../../data/services/ai_generation_service.dart';
import '../../data/services/gemini_proxy_service.dart';
import '../../data/services/openai_generation_service.dart';
import '../../data/services/pdf_service.dart';
import '../../domain/entities/ai_project.dart';
import '../../domain/entities/ai_card_draft.dart';
import '../../domain/repositories/ai_card_repository.dart';
import 'auth_providers.dart';
import 'database_providers.dart';

part 'ai_card_providers.g.dart';

// ============ Configuration ============

/// Firebase Function URL for secure Gemini API access.
const String _geminiProxyUrl =
    'https://us-central1-studydeck-78bde.cloudfunctions.net/generateWithGemini';

// ============ Repository Provider ============

/// Provider for the AI card repository.
@Riverpod(keepAlive: true)
AiCardRepository aiCardRepository(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AiCardRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    getCurrentUserId: () async {
      return authRepo.currentUser?.id;
    },
  );
}

// ============ Service Providers ============

/// Provider for the PDF service.
@Riverpod(keepAlive: true)
PdfService pdfService(Ref ref) {
  return PdfService();
}

/// Provider for AI generation configuration (synchronous).
///
/// Uses Firebase Functions proxy for Gemini (secure, no API key in client).
final aiConfigProvider = Provider<AiConfig>((ref) {
  return const AiConfig(
    provider: AiProvider.gemini,
    geminiProxyUrl: _geminiProxyUrl,
  );
});

/// Configuration for AI generation.
class AiConfig {
  final AiProvider provider;
  final String? geminiProxyUrl;
  final String? openaiApiKey;

  const AiConfig({
    this.provider = AiProvider.gemini,
    this.geminiProxyUrl,
    this.openaiApiKey,
  });

  /// Returns true if the current provider is properly configured.
  bool get isConfigured {
    switch (provider) {
      case AiProvider.gemini:
        return geminiProxyUrl != null && geminiProxyUrl!.isNotEmpty;
      case AiProvider.openai:
        return openaiApiKey != null && openaiApiKey!.isNotEmpty;
    }
  }
}

/// Provider for the AI generation service.
///
/// Uses Firebase Functions proxy for Gemini (secure).
/// NOTE: keepAlive to prevent recreation on every access.
final aiGenerationServiceProvider = Provider<AiGenerationService?>((ref) {
  final config = ref.watch(aiConfigProvider);

  if (!config.isConfigured) return null;

  switch (config.provider) {
    case AiProvider.gemini:
      return GeminiProxyService(functionUrl: config.geminiProxyUrl!);
    case AiProvider.openai:
      return OpenAiGenerationService(apiKey: config.openaiApiKey!);
  }
});

// ============ Stream Providers ============

/// Stream provider for watching all AI projects.
@riverpod
Stream<List<AiProject>> watchAiProjects(Ref ref) {
  return ref.watch(aiCardRepositoryProvider).watchProjects();
}

/// Stream provider for watching drafts for a project.
@riverpod
Stream<List<AiCardDraft>> watchDraftsByProject(Ref ref, String projectId) {
  return ref.watch(aiCardRepositoryProvider).watchDraftsByProject(projectId);
}

// ============ Future Providers ============

/// Provider for getting all AI projects.
@riverpod
Future<List<AiProject>> aiProjects(Ref ref) async {
  final result = await ref.watch(aiCardRepositoryProvider).getProjects();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (projects) => projects,
  );
}

/// Provider for getting a single AI project.
@riverpod
Future<AiProject?> aiProjectById(Ref ref, String id) async {
  final result = await ref.watch(aiCardRepositoryProvider).getProjectById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (project) => project,
  );
}

/// Provider for getting drafts for a project.
@riverpod
Future<List<AiCardDraft>> draftsByProject(Ref ref, String projectId) async {
  final result =
      await ref.watch(aiCardRepositoryProvider).getDraftsByProject(projectId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (drafts) => drafts,
  );
}

// ============ Direct Functions ============

/// Creates a new AI project directly via repository.
Future<AiProject> createAiProjectDirect(
  AiCardRepository repository, {
  required AiSourceType sourceType,
  String? fileName,
  String? pdfStoragePath,
  String? extractedText,
  String? topic,
  AiGenerationConfig config = const AiGenerationConfig(),
}) async {
  final result = await repository.createProject(
    sourceType: sourceType,
    fileName: fileName,
    pdfStoragePath: pdfStoragePath,
    extractedText: extractedText,
    topic: topic,
    config: config,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (project) => project,
  );
}

/// Updates an AI project directly via repository.
Future<AiProject> updateAiProjectDirect(
  AiCardRepository repository, {
  required String id,
  AiProjectStatus? status,
  String? errorMessage,
  String? extractedText,
  int? generatedCardCount,
  int? approvedCardCount,
  String? targetDeckId,
  DateTime? completedAt,
}) async {
  final result = await repository.updateProject(
    id: id,
    status: status,
    errorMessage: errorMessage,
    extractedText: extractedText,
    generatedCardCount: generatedCardCount,
    approvedCardCount: approvedCardCount,
    targetDeckId: targetDeckId,
    completedAt: completedAt,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (project) => project,
  );
}

/// Deletes an AI project directly via repository.
Future<void> deleteAiProjectDirect(
  AiCardRepository repository,
  String id,
) async {
  final result = await repository.deleteProject(id);
  result.fold(
    (failure) => throw Exception(failure.message),
    (_) {},
  );
}

/// Creates drafts directly via repository.
Future<List<AiCardDraft>> createDraftsDirect(
  AiCardRepository repository, {
  required String projectId,
  required List<AiCardDraftInput> drafts,
}) async {
  final result = await repository.createDrafts(
    projectId: projectId,
    drafts: drafts,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (drafts) => drafts,
  );
}

/// Updates a draft directly via repository.
Future<AiCardDraft> updateDraftDirect(
  AiCardRepository repository, {
  required String id,
  String? front,
  String? back,
  String? summary,
  String? keyPhrase,
  String? hint,
  DraftReviewStatus? reviewStatus,
  bool? isPotentialDuplicate,
  String? similarCardId,
  bool? needsReview,
}) async {
  final result = await repository.updateDraft(
    id: id,
    front: front,
    back: back,
    summary: summary,
    keyPhrase: keyPhrase,
    hint: hint,
    reviewStatus: reviewStatus,
    isPotentialDuplicate: isPotentialDuplicate,
    similarCardId: similarCardId,
    needsReview: needsReview,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (draft) => draft,
  );
}

/// Approves all pending drafts directly via repository.
Future<int> approveAllDraftsDirect(
  AiCardRepository repository,
  String projectId,
) async {
  final result = await repository.approveAllPendingDrafts(projectId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (count) => count,
  );
}

/// Imports approved drafts to a deck directly via repository.
Future<List<String>> importDraftsToDeckDirect(
  AiCardRepository repository, {
  required String projectId,
  required String deckId,
}) async {
  final result = await repository.importDraftsToDeck(
    projectId: projectId,
    deckId: deckId,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (cardIds) => cardIds,
  );
}

/// Checks for duplicates directly via repository.
Future<int> checkDuplicatesDirect(
  AiCardRepository repository, {
  required String projectId,
  required String deckId,
}) async {
  final result = await repository.checkForDuplicates(
    projectId: projectId,
    deckId: deckId,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (count) => count,
  );
}

/// Generates cards using the AI service directly.
Future<List<GeneratedCard>> generateCardsDirect(
  AiGenerationService service,
  AiGenerationRequest request,
) async {
  return await service.generateCards(request);
}

/// Generates pedagogical fields (summary & keyPhrase) for a card using AI.
///
/// UC188/UC190: AI generation of pedagogical fields for manual cards.
Future<PedagogicalFields> generatePedagogicalFieldsDirect(
  AiGenerationService service, {
  required String question,
  required String answer,
}) async {
  return await service.generatePedagogicalFields(
    question: question,
    answer: answer,
  );
}
