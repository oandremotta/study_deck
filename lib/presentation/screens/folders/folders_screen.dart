import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/folder.dart';
import '../../providers/deck_providers.dart';
import '../../providers/folder_providers.dart';
import '../../router/app_router.dart';

/// Screen displaying all folders (Assuntos).
///
/// Implements UC04, UC05, UC06 (Folder CRUD), UC108 (Navigate to folders).
class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(watchFoldersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assuntos'),
      ),
      body: foldersAsync.when(
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
              Text('Erro ao carregar pastas: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(watchFoldersProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (folders) {
          return _FoldersListView(folders: folders);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.folderForm),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// UC112: List view that includes folders and "Sem assunto" section.
class _FoldersListView extends ConsumerWidget {
  final List<Folder> folders;

  const _FoldersListView({required this.folders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unorganizedDecksAsync = ref.watch(watchDecksByFolderProvider(null));

    return unorganizedDecksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildList(context, 0),
      data: (unorganizedDecks) => _buildList(context, unorganizedDecks.length),
    );
  }

  Widget _buildList(BuildContext context, int unorganizedCount) {
    // If no folders and no unorganized decks, show empty state
    if (folders.isEmpty && unorganizedCount == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 64,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum assunto ainda',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie assuntos para organizar seus decks',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Build list with "Sem assunto" at the top if there are unorganized decks
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: folders.length + (unorganizedCount > 0 ? 1 : 0),
      itemBuilder: (context, index) {
        // First item: "Sem assunto" if there are unorganized decks
        if (unorganizedCount > 0 && index == 0) {
          return _UnorganizedDecksTile(deckCount: unorganizedCount);
        }

        // Adjust index for folders if "Sem assunto" is shown
        final folderIndex = unorganizedCount > 0 ? index - 1 : index;
        final folder = folders[folderIndex];
        return _FolderTile(folder: folder);
      },
    );
  }
}

/// UC112: Tile for decks without a folder ("Sem assunto").
class _UnorganizedDecksTile extends StatelessWidget {
  final int deckCount;

  const _UnorganizedDecksTile({required this.deckCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.folder_off_outlined,
          color: context.colorScheme.onSurfaceVariant,
        ),
        title: const Text('Sem assunto'),
        subtitle: Text(
          '$deckCount ${deckCount == 1 ? 'deck' : 'decks'}',
        ),
        onTap: () {
          // Navigate to decks without folder
          context.push('${AppRoutes.decks}?folderName=${Uri.encodeComponent('Sem assunto')}');
        },
      ),
    );
  }
}

class _FolderTile extends ConsumerWidget {
  final Folder folder;

  const _FolderTile({required this.folder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.folder_rounded,
          color: context.colorScheme.primary,
        ),
        title: Text(folder.name),
        subtitle: Text(
          '${folder.deckCount} ${folder.deckCount == 1 ? 'deck' : 'decks'}',
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
        onTap: () {
          // UC107/UC108: Navigate to folder's decks
          context.push(
            '${AppRoutes.decks}?folderId=${folder.id}&folderName=${Uri.encodeComponent(folder.name)}',
          );
        },
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit':
        context.push('${AppRoutes.folderForm}?id=${folder.id}');
        break;
      case 'delete':
        _showDeleteDialog(context, ref);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    if (folder.hasDecks) {
      // UC113: Folder has decks - ask what to do
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Excluir assunto'),
          content: Text(
            'O assunto "${folder.name}" contem ${folder.deckCount} deck(s). '
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
                _deleteFolder(context, ref, DeleteFolderAction.moveDecksToRoot);
              },
              child: const Text('Mover para "Sem assunto"'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteFolder(context, ref, DeleteFolderAction.deleteDecks);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Excluir decks juntos'),
            ),
          ],
        ),
      );
    } else {
      // Simple delete confirmation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Excluir assunto'),
          content: Text('Deseja excluir o assunto "${folder.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteFolder(context, ref, DeleteFolderAction.moveDecksToRoot);
              },
              child: const Text('Excluir'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _deleteFolder(
    BuildContext context,
    WidgetRef ref,
    DeleteFolderAction action,
  ) async {
    try {
      final repository = ref.read(folderRepositoryProvider);
      await deleteFolderDirect(repository, folder.id, action);

      if (context.mounted) {
        context.showSnackBar('Pasta excluida');
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }
}
