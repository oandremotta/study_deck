import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/folder.dart';
import '../../providers/folder_providers.dart';
import '../../router/app_router.dart';

/// Screen displaying all folders.
///
/// Implements UC04, UC05, UC06 (Folder CRUD).
class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(watchFoldersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pastas'),
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
          if (folders.isEmpty) {
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
                    'Nenhuma pasta ainda',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crie pastas para organizar seus decks',
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
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return _FolderTile(folder: folder);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.folderForm),
        child: const Icon(Icons.add),
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
          // TODO: Navigate to folder decks
          context.showSnackBar('Abrir pasta - em breve!');
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
      // UC06: Folder has decks - ask what to do
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Excluir pasta'),
          content: Text(
            'A pasta "${folder.name}" contem ${folder.deckCount} deck(s). '
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
              child: const Text('Mover para "Sem pasta"'),
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
          title: const Text('Excluir pasta'),
          content: Text('Deseja excluir a pasta "${folder.name}"?'),
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
