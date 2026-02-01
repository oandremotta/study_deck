import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/sync_status.dart';
import '../../providers/sync_providers.dart';
import '../../router/app_router.dart';

/// UC276, UC278, UC279, UC280: Sync settings screen.
class SyncSettingsScreen extends ConsumerStatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  ConsumerState<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends ConsumerState<SyncSettingsScreen> {
  bool _autoSync = true;
  bool _syncOnWifiOnly = false;
  bool _syncStudyProgress = true;
  bool _isLoading = false;

  // TODO: Get from auth provider
  final String _userId = 'user_id';
  // TODO: Get from subscription provider
  final bool _isPremium = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final syncStatusAsync = ref.watch(syncStatusProvider(_userId));
    final offlineChangesAsync = ref.watch(offlineChangesProvider(_userId));
    final conflictsAsync = ref.watch(syncConflictsProvider(_userId));
    final limits = getBackupLimitsDirect(
      ref.read(syncServiceProvider),
      _isPremium,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronização'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sync status
            syncStatusAsync.when(
              data: (status) => _SyncStatusSection(
                status: status,
                onSync: _performSync,
                isLoading: _isLoading,
              ),
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

            // Conflicts
            conflictsAsync.when(
              data: (conflicts) => conflicts.isNotEmpty
                  ? Card(
                      color: theme.colorScheme.errorContainer,
                      child: ListTile(
                        leading: Icon(
                          Icons.warning,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        title: Text(
                          '${conflicts.length} conflito(s) detectado(s)',
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(AppRoutes.syncConflicts),
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            if (conflictsAsync.valueOrNull?.isNotEmpty == true)
              const SizedBox(height: 16),

            // Sync settings
            Text(
              'Configurações',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Sincronização automática'),
                    subtitle: Text(
                      _isPremium
                          ? 'Sincronizar automaticamente em segundo plano'
                          : 'Disponível apenas para Premium',
                    ),
                    value: _autoSync && _isPremium,
                    onChanged: _isPremium
                        ? (v) => setState(() => _autoSync = v)
                        : null,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Sincronizar apenas em Wi-Fi'),
                    subtitle: const Text('Economize dados móveis'),
                    value: _syncOnWifiOnly,
                    onChanged: (v) => setState(() => _syncOnWifiOnly = v),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Sincronizar progresso de estudo'),
                    subtitle: const Text('Incluir estatísticas e XP'),
                    value: _syncStudyProgress,
                    onChanged: (v) => setState(() => _syncStudyProgress = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Offline changes
            Text(
              'Alterações Offline',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            offlineChangesAsync.when(
              data: (changes) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pending_actions,
                            color: changes.isNotEmpty
                                ? Colors.orange
                                : Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              changes.isEmpty
                                  ? 'Nenhuma alteração pendente'
                                  : '${changes.length} alteração(ões) pendente(s)',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (changes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Estas alterações serão sincronizadas quando você estiver online.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...changes.take(5).map((change) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    _getChangeIcon(change.changeType),
                                    size: 16,
                                    color: theme.colorScheme.outline,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${change.entityType.displayName} ${change.changeType.name}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        if (changes.length > 5)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '+${changes.length - 5} mais...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
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

            // Limits
            Text(
              'Limites do Plano',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _LimitRow(
                      label: 'Backups mantidos',
                      value: '${limits.maxBackupsKept}',
                      premiumValue: '30',
                      isPremium: _isPremium,
                    ),
                    const Divider(height: 24),
                    _LimitRow(
                      label: 'Retenção de backup',
                      value: '${limits.backupRetentionDays} dias',
                      premiumValue: '90 dias',
                      isPremium: _isPremium,
                    ),
                    const Divider(height: 24),
                    _LimitRow(
                      label: 'Backup automático',
                      value: limits.autoBackup ? 'Sim' : 'Não',
                      premiumValue: 'Sim',
                      isPremium: _isPremium,
                    ),
                  ],
                ),
              ),
            ),
            if (!_isPremium) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.subscriptionPaywall),
                icon: const Icon(Icons.workspace_premium),
                label: const Text('Fazer Upgrade'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getChangeIcon(OfflineChangeType type) {
    switch (type) {
      case OfflineChangeType.create:
        return Icons.add;
      case OfflineChangeType.update:
        return Icons.edit;
      case OfflineChangeType.delete:
        return Icons.delete;
    }
  }

  Future<void> _performSync() async {
    setState(() => _isLoading = true);

    try {
      final service = ref.read(syncServiceProvider);
      await syncDirect(
        service,
        _userId,
        localData: {}, // TODO: Collect actual data
        fetchRemote: () async => {},
        pushToRemote: (_) async {},
        applyLocal: (_) async {},
      );

      ref.invalidate(syncStatusProvider(_userId));
      ref.invalidate(offlineChangesProvider(_userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sincronização concluída'),
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

class _SyncStatusSection extends StatelessWidget {
  final SyncStatus status;
  final VoidCallback onSync;
  final bool isLoading;

  const _SyncStatusSection({
    required this.status,
    required this.onSync,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: _getStatusColor(status.state, theme),
              child: Icon(
                _getStatusIcon(status.state),
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              status.state.displayName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              status.lastSyncDisplay,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (status.pendingChanges > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${status.pendingChanges} alterações pendentes',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: isLoading ? null : onSync,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(isLoading ? 'Sincronizando...' : 'Sincronizar Agora'),
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

class _LimitRow extends StatelessWidget {
  final String label;
  final String value;
  final String premiumValue;
  final bool isPremium;

  const _LimitRow({
    required this.label,
    required this.value,
    required this.premiumValue,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isPremium ? theme.colorScheme.primary : null,
          ),
        ),
        if (!isPremium) ...[
          const SizedBox(width: 8),
          Text(
            '→ $premiumValue',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}
