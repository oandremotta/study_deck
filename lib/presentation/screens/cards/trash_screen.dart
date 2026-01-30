import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/card.dart' as entities;
import '../../providers/card_providers.dart';

/// Screen showing deleted cards (trash) for a deck.
///
/// Implements UC13 (Restore deleted card).
class TrashScreen extends ConsumerWidget {
  final String deckId;

  const TrashScreen({
    super.key,
    required this.deckId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedCardsAsync = ref.watch(watchDeletedCardsByDeckProvider(deckId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lixeira'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Esvaziar lixeira',
            onPressed: () => _showEmptyTrashDialog(context, ref),
          ),
        ],
      ),
      body: deletedCardsAsync.when(
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
              Text('Erro ao carregar lixeira: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(watchDeletedCardsByDeckProvider(deckId)),
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
                    Icons.delete_outline,
                    size: 64,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lixeira vazia',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cards excluidos aparecerao aqui',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
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
              return _DeletedCardTile(card: card, deckId: deckId);
            },
          );
        },
      ),
    );
  }

  void _showEmptyTrashDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Esvaziar lixeira'),
        content: const Text(
          'Todos os cards na lixeira serao excluidos permanentemente. '
          'Esta acao nao pode ser desfeita.',
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
              // TODO: Implement empty trash
              context.showSnackBar('Funcao em desenvolvimento');
            },
            child: const Text('Esvaziar'),
          ),
        ],
      ),
    );
  }
}

class _DeletedCardTile extends ConsumerWidget {
  final entities.Card card;
  final String deckId;

  const _DeletedCardTile({
    required this.card,
    required this.deckId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restore),
                      tooltip: 'Restaurar',
                      onPressed: () => _restoreCard(context, ref),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_forever,
                        color: context.colorScheme.error,
                      ),
                      tooltip: 'Excluir permanentemente',
                      onPressed: () => _showPermanentDeleteDialog(context, ref),
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
            if (card.deletedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Excluido em: ${_formatDate(card.deletedAt!)}',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _restoreCard(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(cardRepositoryProvider);
      await restoreCardDirect(repository, card.id);

      if (context.mounted) {
        context.showSnackBar('Card restaurado');
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _showPermanentDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir permanentemente'),
        content: const Text(
          'Este card sera excluido permanentemente. '
          'Esta acao nao pode ser desfeita.',
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
              _permanentlyDeleteCard(context, ref);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _permanentlyDeleteCard(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(cardRepositoryProvider);
      await permanentlyDeleteCardDirect(repository, card.id);

      if (context.mounted) {
        context.showSnackBar('Card excluido permanentemente');
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }
}
