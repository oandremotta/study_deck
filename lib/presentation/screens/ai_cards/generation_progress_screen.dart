import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/services/ai_generation_service.dart';
import '../../../domain/entities/ai_project.dart';
import '../../../domain/repositories/ai_card_repository.dart';
import '../../providers/ai_card_providers.dart';
import '../../router/app_router.dart';

/// Screen showing generation progress (UC140).
class GenerationProgressScreen extends ConsumerStatefulWidget {
  final String projectId;
  final AiGenerationConfig? config;

  const GenerationProgressScreen({
    super.key,
    required this.projectId,
    this.config,
  });

  @override
  ConsumerState<GenerationProgressScreen> createState() =>
      _GenerationProgressScreenState();
}

class _GenerationProgressScreenState
    extends ConsumerState<GenerationProgressScreen> {
  bool _isGenerating = false;
  String _statusMessage = 'Preparando...';
  int _generatedCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  Future<void> _startGeneration() async {
    setState(() {
      _isGenerating = true;
      _statusMessage = 'Iniciando geracao...';
    });

    try {
      final repository = ref.read(aiCardRepositoryProvider);
      final service = ref.read(aiGenerationServiceProvider);

      if (service == null) {
        throw Exception('Servico de IA nao configurado');
      }

      // Get project
      final projectResult = await repository.getProjectById(widget.projectId);
      final project = projectResult.fold(
        (f) => throw Exception(f.message),
        (p) => p,
      );

      if (project == null) {
        throw Exception('Projeto nao encontrado');
      }

      setState(() => _statusMessage = 'Gerando cards com IA...');

      // Get content to generate from
      final content = project.extractedText ?? project.topic ?? '';
      if (content.isEmpty) {
        throw Exception('Conteudo vazio');
      }

      // Use config from navigation or project
      final config = widget.config ?? project.config;

      // Generate cards
      final request = AiGenerationRequest(
        content: content,
        cardCount: config.cardCount,
        difficulty: config.difficulty,
        includeHints: config.includeHints,
        isTopic: project.sourceType == AiSourceType.topic,
      );

      final generatedCards = await service.generateCards(request);

      setState(() {
        _statusMessage = 'Salvando ${generatedCards.length} cards...';
        _generatedCount = generatedCards.length;
      });

      // Create drafts with pedagogical fields (UC167/UC168)
      final draftInputs = generatedCards.asMap().entries.map((entry) {
        final card = entry.value;
        return AiCardDraftInput(
          front: card.front,
          back: card.back,
          summary: card.summary,
          keyPhrase: card.keyPhrase,
          hint: card.hint,
          suggestedTags: card.suggestedTags,
          difficulty: card.difficulty,
          confidenceScore: card.confidenceScore,
          needsReview: card.needsReview,
        );
      }).toList();

      await createDraftsDirect(
        repository,
        projectId: widget.projectId,
        drafts: draftInputs,
      );

      // Update project status
      await updateAiProjectDirect(
        repository,
        id: widget.projectId,
        status: AiProjectStatus.review,
        generatedCardCount: generatedCards.length,
      );

      setState(() {
        _isGenerating = false;
        _statusMessage = 'Concluido!';
      });

      // Navigate to review
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.pushReplacement('${AppRouter.aiReview}/${widget.projectId}');
        }
      }
    } catch (e) {
      // Update project as failed
      try {
        final repository = ref.read(aiCardRepositoryProvider);
        await updateAiProjectDirect(
          repository,
          id: widget.projectId,
          status: AiProjectStatus.failed,
          errorMessage: e.toString(),
        );
      } catch (_) {}

      if (mounted) {
        setState(() {
          _isGenerating = false;
          _error = e.toString().replaceFirst('Exception: ', '');
          _statusMessage = 'Erro na geracao';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerando Cards'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isGenerating) ...[
                const SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(strokeWidth: 4),
                ),
                const SizedBox(height: 32),
              ] else if (_error != null) ...[
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: context.colorScheme.error,
                ),
                const SizedBox(height: 32),
              ] else ...[
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 32),
              ],
              Text(
                _statusMessage,
                style: context.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (_generatedCount > 0 && _error == null) ...[
                const SizedBox(height: 8),
                Text(
                  '$_generatedCount cards gerados',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: context.colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: context.colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => context.go(AppRouter.aiCardsHub),
                      child: const Text('Voltar'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: _startGeneration,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
