import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/card.dart' as entities;
import '../../../domain/entities/study_session.dart';
import '../../providers/card_providers.dart';
import '../../providers/deck_providers.dart';
import '../../providers/study_providers.dart';
import '../../providers/tag_providers.dart';
import '../../router/app_router.dart';

/// Screen showing deck details and its cards.
///
/// Implements card listing and navigation to card operations.
class DeckDetailScreen extends ConsumerWidget {
  final String deckId;

  const DeckDetailScreen({
    super.key,
    required this.deckId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckAsync = ref.watch(deckByIdProvider(deckId));
    final cardsAsync = ref.watch(watchCardsByDeckProvider(deckId));

    return Scaffold(
      appBar: AppBar(
        title: deckAsync.when(
          loading: () => const Text('Carregando...'),
          error: (_, __) => const Text('Erro'),
          data: (deck) => Text(deck?.name ?? 'Deck'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Lixeira',
            onPressed: () => context.push('${AppRoutes.deckTrash}/$deckId'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 8),
                    Text('Editar deck'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload_file_outlined),
                    SizedBox(width: 8),
                    Text('Importar cards'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download_outlined),
                    SizedBox(width: 8),
                    Text('Exportar deck'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'resetProgress',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt),
                    SizedBox(width: 8),
                    Text('Resetar progresso'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: context.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Erro ao carregar cards: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(watchCardsByDeckProvider(deckId)),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (cards) {
          if (cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add_outlined,
                    size: 64,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum card ainda',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione cards para comecar a estudar',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('${AppRoutes.cardForm}?deckId=$deckId'),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar Card'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Study button header
              _StudyHeader(deckId: deckId, cardCount: cards.length),

              // Card list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return _CardTile(card: card, deckId: deckId);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('${AppRoutes.cardForm}?deckId=$deckId'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit':
        context.push('${AppRoutes.deckForm}?id=$deckId');
        break;
      case 'import':
        context.push('${AppRoutes.importCards}?deckId=$deckId');
        break;
      case 'export':
        context.push('${AppRoutes.exportDeck}/$deckId');
        break;
      case 'resetProgress':
        _showResetProgressDialog(context, ref);
        break;
    }
  }

  void _showResetProgressDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar progresso'),
        content: const Text(
          'Isso vai resetar o progresso de estudo de todos os cards deste deck. '
          'Todos os cards voltarao ao estado "novo". Esta acao nao pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              _resetDeckProgress(context, ref);
            },
            child: const Text('Resetar'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetDeckProgress(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(studyRepositoryProvider);
      await resetDeckProgressDirect(repository, deckId);
      ref.invalidate(deckStudyStatsProvider(deckId));
      if (context.mounted) {
        context.showSnackBar('Progresso do deck resetado');
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }
}

class _StudyHeader extends ConsumerWidget {
  final String deckId;
  final int cardCount;

  const _StudyHeader({
    required this.deckId,
    required this.cardCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(deckStudyStatsProvider(deckId));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: context.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        children: [
          // Stats row
          statsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (stats) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  // Mastery progress bar with completion estimate (UC57)
                  _MasteryProgress(
                    masteryPercent: stats.masteryPercent,
                    totalCards: stats.totalCards,
                    newCards: stats.newCards,
                    learningCards: stats.learningCards,
                  ),
                  const SizedBox(height: 12),
                  // Card status chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(
                        label: 'Novos',
                        value: '${stats.newCards}',
                        color: Colors.blue,
                      ),
                      _StatChip(
                        label: 'Aprendendo',
                        value: '${stats.learningCards}',
                        color: Colors.orange,
                      ),
                      _StatChip(
                        label: 'Para revisar',
                        value: '${stats.dueCards}',
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Study button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: cardCount > 0 ? () => _showStudyModeSheet(context, ref) : null,
              icon: const Icon(Icons.play_arrow),
              label: Text(cardCount > 0 ? 'Estudar' : 'Adicione cards para estudar'),
            ),
          ),
        ],
      ),
    );
  }

  void _showStudyModeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _StudyModeSheet(deckId: deckId),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Shows mastery progress with a visual bar (UC31) and completion estimate (UC57).
class _MasteryProgress extends StatelessWidget {
  final double masteryPercent;
  final int totalCards;
  final int newCards;
  final int learningCards;
  final int? avgCardsPerDay;

  const _MasteryProgress({
    required this.masteryPercent,
    required this.totalCards,
    this.newCards = 0,
    this.learningCards = 0,
    this.avgCardsPerDay,
  });

  @override
  Widget build(BuildContext context) {
    final percent = masteryPercent.clamp(0.0, 100.0);
    final color = _getProgressColor(percent);
    final estimatedDays = _calculateEstimatedDays();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  'Dominio',
                  style: context.textTheme.labelMedium,
                ),
              ],
            ),
            Text(
              '${percent.toStringAsFixed(0)}%',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: context.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _getMasteryLabel(percent),
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            // UC57: Completion estimate
            if (estimatedDays != null && percent < 100)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 12,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatEstimate(estimatedDays),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  /// UC57: Calculate estimated days to complete deck mastery.
  int? _calculateEstimatedDays() {
    if (masteryPercent >= 100) return null;

    // Cards remaining to master (new + learning)
    final remainingCards = newCards + learningCards;
    if (remainingCards == 0) return null;

    // Use provided average or estimate ~10 cards/day as default
    final cardsPerDay = avgCardsPerDay ?? 10;
    if (cardsPerDay <= 0) return null;

    // Each card needs ~3-5 reviews on average to be mastered
    final totalReviewsNeeded = remainingCards * 4;
    return (totalReviewsNeeded / cardsPerDay).ceil();
  }

  String _formatEstimate(int days) {
    if (days <= 1) return '~1 dia';
    if (days < 7) return '~$days dias';
    if (days < 30) {
      final weeks = (days / 7).round();
      return '~$weeks sem${weeks == 1 ? 'ana' : 'anas'}';
    }
    final months = (days / 30).round();
    return '~$months ${months == 1 ? 'mes' : 'meses'}';
  }

  Color _getProgressColor(double percent) {
    if (percent >= 80) return Colors.green;
    if (percent >= 50) return Colors.orange;
    if (percent >= 25) return Colors.amber;
    return Colors.blue;
  }

  String _getMasteryLabel(double percent) {
    if (percent >= 90) return 'Excelente! Voce domina este deck.';
    if (percent >= 70) return 'Muito bom! Continue praticando.';
    if (percent >= 50) return 'Bom progresso! Mantenha o ritmo.';
    if (percent >= 25) return 'Continuando a aprender...';
    return 'Comecando a jornada!';
  }
}

class _StudyModeSheet extends ConsumerWidget {
  final String deckId;

  const _StudyModeSheet({required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Escolha o modo de estudo',
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Study modes
            _StudyModeOption(
              icon: Icons.auto_awesome,
              title: 'Estudar agora',
              description: 'Fila inteligente com revisoes e novos cards',
              onTap: () => _startStudy(context, ref, StudyMode.studyNow),
            ),
            _StudyModeOption(
              icon: Icons.replay,
              title: 'Revisoes de hoje',
              description: 'Apenas cards que precisam ser revisados',
              onTap: () => _startStudy(context, ref, StudyMode.reviewsToday),
            ),
            _StudyModeOption(
              icon: Icons.shuffle,
              title: 'Modo aleatorio',
              description: 'Cards embaralhados, sem algoritmo SRS',
              onTap: () => _startStudy(context, ref, StudyMode.shuffle),
            ),
            _StudyModeOption(
              icon: Icons.bolt,
              title: 'Modo Turbo',
              description: 'Sessao rapida de ~12 cards em 3 minutos',
              onTap: () => _startStudy(context, ref, StudyMode.turbo),
            ),
            _StudyModeOption(
              icon: Icons.error_outline,
              title: 'Apenas erros',
              description: 'Revisar cards que voce errou recentemente',
              onTap: () => _startStudy(context, ref, StudyMode.errorsOnly),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _startStudy(BuildContext context, WidgetRef ref, StudyMode mode) async {
    Navigator.pop(context);

    // Start session
    final session = await ref.read(studyNotifierProvider.notifier).startSession(
      deckId: deckId,
      mode: mode,
    );

    if (session != null && context.mounted) {
      context.push('${AppRoutes.study}?deckId=$deckId&mode=${mode.name}');
    } else if (context.mounted) {
      context.showSnackBar('Nenhum card disponivel para este modo');
    }
  }
}

class _StudyModeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _StudyModeOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: context.colorScheme.primary),
        title: Text(title),
        subtitle: Text(description, style: context.textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _CardTile extends ConsumerWidget {
  final entities.Card card;
  final String deckId;

  const _CardTile({
    required this.card,
    required this.deckId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('${AppRoutes.cardForm}?deckId=$deckId&id=${card.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      card.front,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleCardMenu(context, ref, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'mastered',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline),
                            SizedBox(width: 8),
                            Text('Marcar dominado'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'reset',
                        child: Row(
                          children: [
                            Icon(Icons.restart_alt),
                            SizedBox(width: 8),
                            Text('Resetar progresso'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outlined),
                            SizedBox(width: 8),
                            Text('Excluir'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                card.back,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (card.hasTags) ...[
                const SizedBox(height: 8),
                _buildTagChips(context, ref),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagChips(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsForCardProvider(card.tagIds));

    return tagsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (tags) {
        if (tags.isEmpty) return const SizedBox.shrink();

        return Wrap(
          spacing: 4,
          children: tags.take(3).map((tag) {
            final color = _hexToColor(tag.color);
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tag.name,
                style: context.textTheme.labelSmall?.copyWith(
                  color: color,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  void _handleCardMenu(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit':
        context.push('${AppRoutes.cardForm}?deckId=$deckId&id=${card.id}');
        break;
      case 'mastered':
        _markAsMastered(context, ref);
        break;
      case 'reset':
        _resetProgress(context, ref);
        break;
      case 'delete':
        _showDeleteDialog(context, ref);
        break;
    }
  }

  Future<void> _markAsMastered(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(studyRepositoryProvider);
      await markCardAsMasteredDirect(repository, card.id);
      if (context.mounted) {
        context.showSnackBar('Card marcado como dominado');
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _resetProgress(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(studyRepositoryProvider);
      await resetCardProgressDirect(repository, card.id);
      if (context.mounted) {
        context.showSnackBar('Progresso do card resetado');
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir card'),
        content: const Text(
          'O card sera movido para a lixeira. '
          'Voce podera restaura-lo depois.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCard(context, ref);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCard(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(cardRepositoryProvider);
      await softDeleteCardDirect(repository, card.id);

      if (context.mounted) {
        context.showSnackBar('Card movido para lixeira');
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }
}
