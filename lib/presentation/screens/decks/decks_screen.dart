import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/deck.dart';
import '../../../domain/entities/folder.dart';
import '../../../domain/repositories/deck_repository.dart';
import '../../providers/deck_providers.dart';
import '../../providers/folder_providers.dart';
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
            // UC110: Move deck to folder
            const PopupMenuItem(
              value: 'move',
              child: Row(
                children: [
                  Icon(Icons.drive_file_move_outlined),
                  SizedBox(width: 8),
                  Text('Mover para assunto'),
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
      case 'move':
        _showMoveToFolderDialog(context, ref);
        break;
      case 'delete':
        _showDeleteDialog(context, ref);
        break;
    }
  }

  /// UC110: Show dialog to move deck to another folder.
  void _showMoveToFolderDialog(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.read(watchFoldersProvider);

    foldersAsync.when(
      loading: () => context.showSnackBar('Carregando assuntos...'),
      error: (_, __) => context.showErrorSnackBar('Erro ao carregar assuntos'),
      data: (folders) {
        showModalBottomSheet(
          context: context,
          builder: (context) => _MoveToFolderSheet(
            deck: deck,
            folders: folders,
            currentFolderId: deck.folderId,
          ),
        );
      },
    );
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

/// UC110: Bottom sheet for moving a deck to a folder.
class _MoveToFolderSheet extends ConsumerWidget {
  final Deck deck;
  final List<Folder> folders;
  final String? currentFolderId;

  const _MoveToFolderSheet({
    required this.deck,
    required this.folders,
    this.currentFolderId,
  });

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
              'Mover "${deck.name}" para:',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // "Sem assunto" option (UC112)
            ListTile(
              leading: Icon(
                Icons.folder_off_outlined,
                color: currentFolderId == null
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurfaceVariant,
              ),
              title: const Text('Sem assunto'),
              trailing: currentFolderId == null
                  ? Icon(Icons.check, color: context.colorScheme.primary)
                  : null,
              onTap: currentFolderId == null
                  ? null
                  : () => _moveDeck(context, ref, null),
            ),

            const Divider(),

            // Folder list
            if (folders.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Nenhum assunto criado ainda',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...folders.map((folder) => ListTile(
                    leading: Icon(
                      Icons.folder_rounded,
                      color: folder.id == currentFolderId
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(folder.name),
                    subtitle: Text('${folder.deckCount} decks'),
                    trailing: folder.id == currentFolderId
                        ? Icon(Icons.check, color: context.colorScheme.primary)
                        : null,
                    onTap: folder.id == currentFolderId
                        ? null
                        : () => _moveDeck(context, ref, folder.id),
                  )),

            const SizedBox(height: 8),

            // Create new folder option
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push(AppRoutes.folderForm);
              },
              icon: const Icon(Icons.add),
              label: const Text('Criar novo assunto'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _moveDeck(
    BuildContext context,
    WidgetRef ref,
    String? newFolderId,
  ) async {
    Navigator.pop(context);

    try {
      final repository = ref.read(deckRepositoryProvider);
      await moveDeckToFolderDirect(repository, deck.id, newFolderId);

      // Invalidate providers to refresh data
      ref.invalidate(watchFoldersProvider);
      ref.invalidate(watchDecksByFolderProvider(currentFolderId));
      ref.invalidate(watchDecksByFolderProvider(newFolderId));

      if (context.mounted) {
        final folderName = newFolderId == null
            ? 'Sem assunto'
            : folders.firstWhere((f) => f.id == newFolderId).name;
        context.showSnackBar('Deck movido para "$folderName"');
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }
}
