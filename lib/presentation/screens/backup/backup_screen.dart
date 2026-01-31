import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/sync_status.dart';
import '../../providers/sync_providers.dart';
import '../../router/app_router.dart';

/// UC274, UC275: Backup management screen.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _isLoading = false;

  // TODO: Get from auth provider
  final String _userId = 'user_id';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backupsAsync = ref.watch(backupsProvider(_userId));
    final syncStatusAsync = ref.watch(syncStatusProvider(_userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.syncSettings),
            tooltip: 'Configurações de Sync',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sync status card
            syncStatusAsync.when(
              data: (status) => _SyncStatusCard(status: status),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erro: $e'),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Create backup button
            FilledButton.icon(
              onPressed: _isLoading ? null : _createBackup,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.backup),
              label: Text(_isLoading ? 'Criando backup...' : 'Criar Backup Agora'),
            ),
            const SizedBox(height: 24),

            // Backups list
            Row(
              children: [
                Text(
                  'Backups Recentes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ref.invalidate(backupsProvider(_userId));
                  },
                  child: const Text('Atualizar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            backupsAsync.when(
              data: (backups) => backups.isEmpty
                  ? _buildEmptyState(theme)
                  : Column(
                      children: backups
                          .map((backup) => _BackupCard(
                                backup: backup,
                                onRestore: () => _restoreBackup(backup),
                              ))
                          .toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
            ),
            const SizedBox(height: 24),

            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Sobre Backups',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Backups salvam todos os seus decks, cards e progresso\n'
                    '• Usuários Premium têm backup automático diário\n'
                    '• Restaurar um backup substituirá todos os dados atuais',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum backup encontrado',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie seu primeiro backup para proteger seus dados',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);

    try {
      final service = ref.read(syncServiceProvider);
      await createBackupDirect(
        service,
        _userId,
        type: BackupType.manual,
        data: {}, // TODO: Collect actual data from repositories
      );

      ref.invalidate(backupsProvider(_userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup criado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreBackup(BackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Backup'),
        content: Text(
          'Tem certeza que deseja restaurar o backup de '
          '${_formatDate(backup.createdAt)}?\n\n'
          'Isso substituirá todos os seus dados atuais.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(syncServiceProvider);
      await restoreFromBackupDirect(service, _userId, backup.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup restaurado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _SyncStatusCard extends StatelessWidget {
  final SyncStatus status;

  const _SyncStatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: _getStatusColor(status.state, theme).withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getStatusColor(status.state, theme),
              child: Icon(
                _getStatusIcon(status.state),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.state.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    status.lastSyncDisplay,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (status.pendingChanges > 0)
                    Text(
                      '${status.pendingChanges} alterações pendentes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
            ),
            if (status.hasConflicts)
              IconButton(
                icon: Icon(Icons.warning, color: theme.colorScheme.error),
                onPressed: () {
                  context.push(AppRoutes.syncConflicts);
                },
                tooltip: 'Ver conflitos',
              ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(SyncState state) {
    switch (state) {
      case SyncState.idle:
        return Icons.cloud_done;
      case SyncState.syncing:
      case SyncState.backingUp:
      case SyncState.restoring:
        return Icons.sync;
      case SyncState.offline:
        return Icons.cloud_off;
      case SyncState.error:
        return Icons.error;
      case SyncState.conflict:
        return Icons.warning;
    }
  }

  Color _getStatusColor(SyncState state, ThemeData theme) {
    switch (state) {
      case SyncState.idle:
        return Colors.green;
      case SyncState.syncing:
      case SyncState.backingUp:
      case SyncState.restoring:
        return Colors.blue;
      case SyncState.offline:
        return Colors.grey;
      case SyncState.error:
      case SyncState.conflict:
        return theme.colorScheme.error;
    }
  }
}

class _BackupCard extends StatelessWidget {
  final BackupInfo backup;
  final VoidCallback onRestore;

  const _BackupCard({
    required this.backup,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            backup.type == BackupType.automatic
                ? Icons.schedule
                : Icons.backup,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          _formatDate(backup.createdAt),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${backup.type.displayName} • ${backup.sizeDisplay}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${backup.decksCount} decks • ${backup.cardsCount} cards',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.restore),
          onPressed: backup.status == BackupStatus.completed ? onRestore : null,
          tooltip: 'Restaurar',
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
