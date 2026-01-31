import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/sync_status.dart';
import '../../providers/sync_providers.dart';

/// UC277: Conflict resolution screen.
class ConflictResolutionScreen extends ConsumerStatefulWidget {
  const ConflictResolutionScreen({super.key});

  @override
  ConsumerState<ConflictResolutionScreen> createState() =>
      _ConflictResolutionScreenState();
}

class _ConflictResolutionScreenState
    extends ConsumerState<ConflictResolutionScreen> {
  bool _isLoading = false;

  // TODO: Get from auth provider
  final String _userId = 'user_id';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final conflictsAsync = ref.watch(syncConflictsProvider(_userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolver Conflitos'),
        actions: [
          conflictsAsync.maybeWhen(
            data: (conflicts) => conflicts.isNotEmpty
                ? PopupMenuButton<ConflictResolution>(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: ConflictResolution.keepLocal,
                        child: Text('Manter todos locais'),
                      ),
                      const PopupMenuItem(
                        value: ConflictResolution.keepRemote,
                        child: Text('Manter todos remotos'),
                      ),
                    ],
                    onSelected: (resolution) =>
                        _resolveAllConflicts(resolution),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: conflictsAsync.when(
        data: (conflicts) => conflicts.isEmpty
            ? _buildEmptyState(theme)
            : _buildConflictsList(theme, conflicts),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum conflito',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Todos os dados estão sincronizados',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictsList(ThemeData theme, List<SyncConflict> conflicts) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          child: Row(
            children: [
              Icon(
                Icons.warning,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${conflicts.length} conflito(s) encontrado(s)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Info
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Resolva cada conflito escolhendo qual versão manter. '
            'Você também pode manter ambas as versões.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: conflicts.length,
            itemBuilder: (context, index) {
              final conflict = conflicts[index];
              return _ConflictCard(
                conflict: conflict,
                onResolve: (resolution) =>
                    _resolveConflict(conflict.id, resolution),
                isLoading: _isLoading,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _resolveConflict(
    String conflictId,
    ConflictResolution resolution,
  ) async {
    setState(() => _isLoading = true);

    try {
      final service = ref.read(syncServiceProvider);
      await resolveConflictDirect(service, _userId, conflictId, resolution);

      ref.invalidate(syncConflictsProvider(_userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conflito resolvido: ${resolution.displayName}'),
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

  Future<void> _resolveAllConflicts(ConflictResolution resolution) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolver todos os conflitos'),
        content: Text(
          'Tem certeza que deseja aplicar "${resolution.displayName}" '
          'a todos os conflitos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(syncServiceProvider);
      await resolveAllConflictsDirect(service, _userId, resolution);

      ref.invalidate(syncConflictsProvider(_userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos os conflitos resolvidos'),
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
}

class _ConflictCard extends StatelessWidget {
  final SyncConflict conflict;
  final Function(ConflictResolution) onResolve;
  final bool isLoading;

  const _ConflictCard({
    required this.conflict,
    required this.onResolve,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.errorContainer,
                  child: Icon(
                    _getEntityIcon(conflict.entityType),
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conflict.entityName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${conflict.entityType.displayName} • ${conflict.conflictType.displayName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                conflict.conflictType.description,
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),

            // Timestamps
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Versão local',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        _formatDate(conflict.localModifiedAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Versão remota',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        _formatDate(conflict.remoteModifiedAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => onResolve(ConflictResolution.keepLocal),
                  icon: const Icon(Icons.phone_android, size: 18),
                  label: const Text('Manter local'),
                ),
                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => onResolve(ConflictResolution.keepRemote),
                  icon: const Icon(Icons.cloud, size: 18),
                  label: const Text('Manter remoto'),
                ),
                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => onResolve(ConflictResolution.keepBoth),
                  icon: const Icon(Icons.copy_all, size: 18),
                  label: const Text('Manter ambos'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEntityIcon(SyncEntityType type) {
    switch (type) {
      case SyncEntityType.deck:
        return Icons.style;
      case SyncEntityType.card:
        return Icons.credit_card;
      case SyncEntityType.folder:
        return Icons.folder;
      case SyncEntityType.tag:
        return Icons.label;
      case SyncEntityType.studyProgress:
        return Icons.trending_up;
      case SyncEntityType.settings:
        return Icons.settings;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
