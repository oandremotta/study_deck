import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/card.dart' as entities;
import '../../providers/card_providers.dart';
import '../../providers/deck_providers.dart';
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return _CardTile(card: card, deckId: deckId);
            },
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
    }
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
      case 'delete':
        _showDeleteDialog(context, ref);
        break;
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
