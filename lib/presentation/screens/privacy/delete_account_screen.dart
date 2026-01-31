import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/privacy_settings.dart';
import '../../providers/privacy_providers.dart';

/// UC270: Account deletion screen.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _reasonController = TextEditingController();
  bool _confirmDelete = false;
  bool _isLoading = false;
  AccountDeletionRequest? _pendingRequest;

  // TODO: Get from auth provider
  final String _userId = 'user_id';

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Excluir Conta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning card
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Atenção!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Esta ação é irreversível. Todos os seus dados serão permanentemente excluídos.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pending request status
            if (_pendingRequest != null) ...[
              _DeletionStatusCard(request: _pendingRequest!),
              const SizedBox(height: 24),
            ],

            // What will be deleted
            Text(
              'O que será excluído:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _DeletionItem(
              icon: Icons.folder,
              text: 'Todas as suas pastas',
            ),
            _DeletionItem(
              icon: Icons.style,
              text: 'Todos os seus decks',
            ),
            _DeletionItem(
              icon: Icons.credit_card,
              text: 'Todos os seus cards',
            ),
            _DeletionItem(
              icon: Icons.trending_up,
              text: 'Todo o progresso de estudo',
            ),
            _DeletionItem(
              icon: Icons.settings,
              text: 'Configurações e preferências',
            ),
            _DeletionItem(
              icon: Icons.person,
              text: 'Informações da conta',
            ),
            const SizedBox(height: 24),

            // Reason (optional)
            Text(
              'Por que você está saindo? (opcional)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'Seu feedback nos ajuda a melhorar...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Confirmation checkbox
            CheckboxListTile(
              title: const Text('Eu entendo que esta ação é irreversível'),
              value: _confirmDelete,
              onChanged: (v) => setState(() => _confirmDelete = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),

            // Info about grace period
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Você terá 30 dias para cancelar a exclusão antes que seja processada definitivamente.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Delete button
            FilledButton(
              onPressed: _confirmDelete && !_isLoading
                  ? _requestDeletion
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Solicitar Exclusão da Conta'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestDeletion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Tem certeza absoluta que deseja excluir sua conta?\n\n'
          'Você terá 30 dias para cancelar esta solicitação.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Confirmar Exclusão'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(privacyServiceProvider);
      final request = await requestAccountDeletionDirect(
        service,
        _userId,
        reason: _reasonController.text.isNotEmpty
            ? _reasonController.text
            : null,
      );

      setState(() {
        _pendingRequest = request;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitação de exclusão enviada'),
            backgroundColor: Colors.orange,
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

class _DeletionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DeletionItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}

class _DeletionStatusCard extends StatelessWidget {
  final AccountDeletionRequest request;

  const _DeletionStatusCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.hourglass_bottom,
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Exclusão Pendente',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Solicitado em: ${_formatDate(request.requestedAt)}\n'
              'Processamento em: ${_formatDate(request.scheduledAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (request.status == DeletionStatus.pending) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // TODO: Cancel deletion
                },
                child: const Text('Cancelar Exclusão'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
