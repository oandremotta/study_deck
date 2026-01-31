import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/subscription.dart';
import '../../providers/subscription_providers.dart';
import '../../router/app_router.dart';

/// UC260, UC261: Subscription management screen.
class SubscriptionSettingsScreen extends ConsumerStatefulWidget {
  const SubscriptionSettingsScreen({super.key});

  @override
  ConsumerState<SubscriptionSettingsScreen> createState() =>
      _SubscriptionSettingsScreenState();
}

class _SubscriptionSettingsScreenState
    extends ConsumerState<SubscriptionSettingsScreen> {
  bool _isLoading = false;

  // TODO: Get from auth provider
  final String _userId = 'user_id';

  @override
  Widget build(BuildContext context) {
    final subscriptionAsync = ref.watch(userSubscriptionProvider(_userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assinatura'),
      ),
      body: subscriptionAsync.when(
        data: (subscription) => _buildContent(context, subscription),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserSubscription subscription) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current plan card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: subscription.isPremium
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          subscription.isPremium
                              ? Icons.workspace_premium
                              : Icons.person,
                          color: subscription.isPremium
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscription.plan.displayName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              subscription.status.displayName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _getStatusColor(subscription.status, theme),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (subscription.isPremium) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: 'Próxima cobrança',
                      value: subscription.endDate != null
                          ? _formatDate(subscription.endDate!)
                          : 'N/A',
                    ),
                    _InfoRow(
                      label: 'Valor',
                      value: '${subscription.plan.priceDisplay}${subscription.plan.periodDisplay}',
                    ),
                    _InfoRow(
                      label: 'Renovação automática',
                      value: subscription.autoRenew ? 'Ativada' : 'Desativada',
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // AI Credits
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Créditos de IA',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${subscription.totalAiCredits}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créditos da assinatura: ${subscription.aiCreditsRemaining}\n'
                    'Créditos comprados: ${subscription.aiCreditsPurchased}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.subscriptionCredits),
                    icon: const Icon(Icons.add),
                    label: const Text('Comprar Créditos'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          if (!subscription.isPremium) ...[
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.subscriptionPlans),
              icon: const Icon(Icons.upgrade),
              label: const Text('Fazer Upgrade'),
            ),
            const SizedBox(height: 12),
          ],

          if (subscription.isPremium) ...[
            // Toggle auto-renewal
            ListTile(
              leading: const Icon(Icons.autorenew),
              title: const Text('Renovação Automática'),
              subtitle: Text(
                subscription.autoRenew
                    ? 'Sua assinatura será renovada automaticamente'
                    : 'Sua assinatura expira em ${subscription.daysRemaining} dias',
              ),
              trailing: Switch(
                value: subscription.autoRenew,
                onChanged: _isLoading ? null : (v) => _toggleAutoRenew(v),
              ),
            ),
            const Divider(),

            // Cancel subscription
            ListTile(
              leading: Icon(Icons.cancel, color: theme.colorScheme.error),
              title: Text(
                'Cancelar Assinatura',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              subtitle: const Text('Você manterá o acesso até o fim do período'),
              onTap: _isLoading ? null : _showCancelDialog,
            ),
          ],

          const SizedBox(height: 24),

          // Restore purchases
          TextButton.icon(
            onPressed: _isLoading ? null : _restorePurchases,
            icon: const Icon(Icons.restore),
            label: const Text('Restaurar Compras'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SubscriptionStatus status, ThemeData theme) {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.expired:
      case SubscriptionStatus.cancelled:
        return theme.colorScheme.error;
      case SubscriptionStatus.paused:
      case SubscriptionStatus.pendingPayment:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _toggleAutoRenew(bool value) async {
    setState(() => _isLoading = true);

    try {
      final service = ref.read(subscriptionServiceProvider);
      await toggleAutoRenewDirect(service, _userId, autoRenew: value);
      ref.invalidate(userSubscriptionProvider(_userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Renovação automática ativada'
                  : 'Renovação automática desativada',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showCancelDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Assinatura'),
        content: const Text(
          'Tem certeza que deseja cancelar sua assinatura?\n\n'
          'Você continuará tendo acesso aos recursos Premium até o fim do período atual.',
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
            child: const Text('Cancelar Assinatura'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cancelSubscription();
    }
  }

  Future<void> _cancelSubscription() async {
    setState(() => _isLoading = true);

    try {
      final service = ref.read(subscriptionServiceProvider);
      await cancelSubscriptionDirect(service, _userId);
      ref.invalidate(userSubscriptionProvider(_userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assinatura cancelada'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    try {
      // In a real app, this would fetch purchases from the app store
      // For now, show a message that no purchases were found
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma compra encontrada para restaurar'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
