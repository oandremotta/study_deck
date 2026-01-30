import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/deck.dart';
import '../../../domain/repositories/deck_repository.dart';
import '../../providers/deck_providers.dart';
import '../../router/app_router.dart';

/// Screen displaying decks in a folder (or root).
///
/// Implements UC07, UC08, UC09 (Deck CRUD).
class DecksScreen extends ConsumerWidget {
  final String? folderId;
  final String? folderName;

  const DecksScreen({
    super.key,
    this.folderId,
    this.folderName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(watchDecksByFolderProvider(folderId));

    return Scaffold(
      appBar: AppBar(
        title: Text(folderName ?? 'Meus Decks'),
      ),
      body: decksAsync.when(
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
              Text('Erro ao carregar decks: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(watchDecksByFolderProvider(folderId)),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (decks) {
          if (decks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.style_outlined,
                    size: 64,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum deck ainda',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crie decks para organizar seus flashcards',
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
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return _DeckTile(deck: deck);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          '${AppRoutes.deckForm}${folderId != null ? '?folderId=$folderId' : ''}',
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DeckTile extends ConsumerWidget {
  final Deck deck;

  const _DeckTile({required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.style_rounded,
            color: context.colorScheme.primary,
          ),
        ),
        title: Text(deck.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (deck.description != null && deck.description!.isNotEmpty)
              Text(
                deck.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall,
              ),
            Text(
              '${deck.cardCount} ${deck.cardCount == 1 ? 'card' : 'cards'}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, ref, value),
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
        onTap: () => context.push('${AppRoutes.deckDetail}/${deck.id}'),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit':
        context.push('${AppRoutes.deckForm}?id=${deck.id}');
        break;
      case 'delete':
        _showDeleteDialog(context, ref);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    if (deck.hasCards) {
      // UC09: Deck has cards - ask what to do
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Excluir deck'),
          content: Text(
            'O deck "${deck.name}" contem ${deck.cardCount} card(s). '
            'O que deseja fazer com eles?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteDeck(context, ref, DeleteDeckAction.archiveCards);
              },
              child: const Text('Arquivar cards'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteDeck(context, ref, DeleteDeckAction.deleteCards);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Excluir cards juntos'),
            ),
          ],
        ),
      );
    } else {
      // Simple delete confirmation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Excluir deck'),
          content: Text('Deseja excluir o deck "${deck.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteDeck(context, ref, DeleteDeckAction.deleteCards);
              },
              child: const Text('Excluir'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _deleteDeck(
    BuildContext context,
    WidgetRef ref,
    DeleteDeckAction action,
  ) async {
    try {
      final repository = ref.read(deckRepositoryProvider);
      await deleteDeckDirect(repository, deck.id, action);

      if (context.mounted) {
        context.showSnackBar('Deck excluido');
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }
}
