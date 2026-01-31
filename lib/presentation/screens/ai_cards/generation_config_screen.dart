import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/ai_project.dart';
import '../../providers/ai_card_providers.dart';
import '../../providers/subscription_providers.dart';
import '../../router/app_router.dart';

/// Screen for configuring card generation (UC133).
class GenerationConfigScreen extends ConsumerStatefulWidget {
  final String projectId;

  const GenerationConfigScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<GenerationConfigScreen> createState() =>
      _GenerationConfigScreenState();
}

class _GenerationConfigScreenState
    extends ConsumerState<GenerationConfigScreen> {
  int _cardCount = 10;
  String _difficulty = 'medium';
  bool _includeHints = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(aiProjectByIdProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Geracao'),
      ),
      body: projectAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (project) {
          if (project == null) {
            return const Center(child: Text('Projeto nao encontrado'));
          }
          return _buildContent(context, project);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AiProject project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Project info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getSourceIcon(project.sourceType),
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        project.sourceType.displayName,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.displayName,
                    style: context.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Card count
          Text(
            'Quantidade de cards',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            selected: {_cardCount},
            onSelectionChanged: (set) {
              HapticFeedback.selectionClick();
              setState(() => _cardCount = set.first);
            },
            segments: const [
              ButtonSegment(value: 5, label: Text('5')),
              ButtonSegment(value: 10, label: Text('10')),
              ButtonSegment(value: 20, label: Text('20')),
              ButtonSegment(value: 30, label: Text('30')),
            ],
          ),
          const SizedBox(height: 24),

          // Difficulty
          Text(
            'Dificuldade',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            selected: {_difficulty},
            onSelectionChanged: (set) {
              HapticFeedback.selectionClick();
              setState(() => _difficulty = set.first);
            },
            segments: const [
              ButtonSegment(value: 'easy', label: Text('Facil')),
              ButtonSegment(value: 'medium', label: Text('Medio')),
              ButtonSegment(value: 'hard', label: Text('Dificil')),
              ButtonSegment(value: 'mixed', label: Text('Misto')),
            ],
          ),
          const SizedBox(height: 24),

          // Include hints
          SwitchListTile(
            title: const Text('Incluir dicas'),
            subtitle:
                const Text('A IA gerara dicas para ajudar a lembrar as respostas'),
            value: _includeHints,
            onChanged: (value) => setState(() => _includeHints = value),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 32),

          // Cost estimate
          _CostEstimate(
            cardCount: _cardCount,
          ),
          const SizedBox(height: 24),

          // Generate button
          FilledButton.icon(
            onPressed: _isLoading ? null : _startGeneration,
            icon: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isLoading ? 'Preparando...' : 'Gerar $_cardCount cards'),
          ),
        ],
      ),
    );
  }

  IconData _getSourceIcon(AiSourceType type) {
    switch (type) {
      case AiSourceType.pdf:
        return Icons.description_outlined;
      case AiSourceType.text:
        return Icons.text_fields;
      case AiSourceType.topic:
        return Icons.lightbulb_outline;
    }
  }

  Future<void> _startGeneration() async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(aiCardRepositoryProvider);
      final config = AiGenerationConfig(
        cardCount: _cardCount,
        difficulty: _difficulty,
        includeHints: _includeHints,
      );

      await updateAiProjectDirect(
        repository,
        id: widget.projectId,
        status: AiProjectStatus.generating,
      );

      // Navigate to progress screen
      if (mounted) {
        context.pushReplacement(
          '${AppRouter.aiProgress}/${widget.projectId}',
          extra: config,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackBar('Erro ao iniciar geracao: $e');
      }
    }
  }
}

/// UC212: Cost estimate widget showing credits needed and balance.
class _CostEstimate extends ConsumerWidget {
  final int cardCount;

  const _CostEstimate({required this.cardCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // UC212: Show credits cost
    final subscriptionAsync = ref.watch(userSubscriptionProvider('user_id'));

    return subscriptionAsync.when(
      data: (subscription) {
        final creditsNeeded = cardCount; // 1 credit per card
        final creditsAvailable = subscription.totalAiCredits;
        final hasEnough = creditsAvailable >= creditsNeeded;

        return Card(
          color: hasEnough
              ? context.colorScheme.surfaceContainerHighest
              : context.colorScheme.errorContainer.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      hasEnough ? Icons.auto_awesome : Icons.warning_amber,
                      size: 20,
                      color: hasEnough
                          ? context.colorScheme.primary
                          : context.colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Custo: $creditsNeeded credito(s)',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saldo atual:',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '$creditsAvailable creditos',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hasEnough ? Colors.green : context.colorScheme.error,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Apos geracao:',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      hasEnough
                          ? '${creditsAvailable - creditsNeeded} creditos'
                          : 'Insuficiente',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hasEnough
                            ? context.colorScheme.onSurfaceVariant
                            : context.colorScheme.error,
                      ),
                    ),
                  ],
                ),
                if (!hasEnough) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Voce precisa de mais ${creditsNeeded - creditsAvailable} credito(s)',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.subscriptionCredits),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Obter mais creditos'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
