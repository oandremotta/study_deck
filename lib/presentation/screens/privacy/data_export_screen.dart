import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/privacy_settings.dart';
import '../../providers/privacy_providers.dart';

/// UC269: Data export screen (LGPD data portability).
class DataExportScreen extends ConsumerStatefulWidget {
  const DataExportScreen({super.key});

  @override
  ConsumerState<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends ConsumerState<DataExportScreen> {
  final Set<DataExportType> _selectedTypes = {
    DataExportType.decks,
    DataExportType.cards,
    DataExportType.studyProgress,
  };
  bool _isLoading = false;
  DataExportRequest? _currentRequest;

  // TODO: Get from auth provider
  final String _userId = 'user_id';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar Dados'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.download_for_offline,
                      size: 48,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Seus Dados, Seu Direito',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'De acordo com a LGPD, você pode solicitar uma cópia de todos os seus dados armazenados no Study Deck.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Current request status
            if (_currentRequest != null) ...[
              _RequestStatusCard(request: _currentRequest!),
              const SizedBox(height: 24),
            ],

            // Data selection
            Text(
              'Selecione os dados para exportar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...DataExportType.values.map(
              (type) => CheckboxListTile(
                title: Text(type.displayName),
                subtitle: Text(_getTypeDescription(type)),
                value: _selectedTypes.contains(type),
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selectedTypes.add(type);
                    } else {
                      _selectedTypes.remove(type);
                    }
                  });
                },
              ),
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
                        'Informações',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• O arquivo será gerado em formato JSON\n'
                    '• O link para download expira em 7 dias\n'
                    '• Você receberá uma notificação quando estiver pronto',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Export button
            FilledButton.icon(
              onPressed: _selectedTypes.isEmpty || _isLoading
                  ? null
                  : _requestExport,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(
                _isLoading ? 'Processando...' : 'Solicitar Exportação',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeDescription(DataExportType type) {
    switch (type) {
      case DataExportType.profile:
        return 'Informações do seu perfil';
      case DataExportType.decks:
        return 'Todos os seus baralhos';
      case DataExportType.cards:
        return 'Todos os seus cards';
      case DataExportType.studyProgress:
        return 'Histórico de estudo e revisões';
      case DataExportType.statistics:
        return 'Estatísticas de desempenho';
      case DataExportType.settings:
        return 'Suas preferências e configurações';
    }
  }

  Future<void> _requestExport() async {
    setState(() => _isLoading = true);

    try {
      final service = ref.read(privacyServiceProvider);
      final request = await requestDataExportDirect(
        service,
        _userId,
        includedData: _selectedTypes.toList(),
      );

      setState(() {
        _currentRequest = request;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitação enviada! Você será notificado quando estiver pronto.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _RequestStatusCard extends StatelessWidget {
  final DataExportRequest request;

  const _RequestStatusCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(request.status),
                  color: _getStatusColor(request.status, theme),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Solicitação ${request.status.displayName}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Solicitado em: ${_formatDate(request.requestedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (request.status == DataExportStatus.ready &&
                request.downloadUrl != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Download file
                },
                icon: const Icon(Icons.download),
                label: const Text('Baixar Arquivo'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(DataExportStatus status) {
    switch (status) {
      case DataExportStatus.pending:
        return Icons.hourglass_empty;
      case DataExportStatus.processing:
        return Icons.sync;
      case DataExportStatus.ready:
        return Icons.check_circle;
      case DataExportStatus.failed:
        return Icons.error;
      case DataExportStatus.expired:
        return Icons.timer_off;
    }
  }

  Color _getStatusColor(DataExportStatus status, ThemeData theme) {
    switch (status) {
      case DataExportStatus.pending:
      case DataExportStatus.processing:
        return Colors.orange;
      case DataExportStatus.ready:
        return Colors.green;
      case DataExportStatus.failed:
      case DataExportStatus.expired:
        return theme.colorScheme.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
