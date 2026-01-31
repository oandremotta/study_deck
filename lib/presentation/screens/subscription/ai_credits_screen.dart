import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/subscription.dart';
import '../../providers/ads_providers.dart';
import '../../providers/subscription_providers.dart';

/// UC211-214, UC264, UC265: AI credits panel and purchase screen.
///
/// Supports:
/// - UC211: Credits panel with current balance
/// - UC212: Earn credits by watching ads
/// - UC213: Usage information
/// - UC214: Low balance alerts
/// - UC264: Purchase credit packages
/// - UC265: Credit consumption info
class AiCreditsScreen extends ConsumerStatefulWidget {
  const AiCreditsScreen({super.key});

  @override
  ConsumerState<AiCreditsScreen> createState() => _AiCreditsScreenState();
}

class _AiCreditsScreenState extends ConsumerState<AiCreditsScreen> {
  AiCreditPackage? _selectedPackage;
  bool _isLoading = false;
  bool _isLoadingAd = false;

  // TODO: Get from auth provider
  final String _userId = 'user_id';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(userSubscriptionProvider(_userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créditos de IA'),
      ),
      body: subscriptionAsync.when(
        data: (subscription) => _buildContent(context, subscription, theme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    UserSubscription subscription,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current credits
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    '${subscription.totalAiCredits}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'créditos disponíveis',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Assinatura: ${subscription.aiCreditsRemaining} | '
                    'Comprados: ${subscription.aiCreditsPurchased}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // UC214: Low balance alert
          if (subscription.totalAiCredits <= 5 &&
              subscription.totalAiCredits > 0) ...[
            _LowBalanceAlert(credits: subscription.totalAiCredits),
            const SizedBox(height: 16),
          ],

          // UC211: Earn credits section
          _EarnCreditsSection(
            subscription: subscription,
            isLoading: _isLoadingAd,
            onWatchAd: _watchAd,
          ),
          const SizedBox(height: 24),

          // What are credits
          Text(
            'O que são créditos de IA?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créditos são usados para gerar flashcards automaticamente com IA. '
            'Cada card gerado consome 1 crédito.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          // UC213: Usage info
          _UsageInfoCard(subscription: subscription),
          const SizedBox(height: 24),

          // Packages
          Text(
            'Pacotes de Créditos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ...AiCreditPackage.values.map(
            (package) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PackageCard(
                package: package,
                isSelected: _selectedPackage == package,
                onTap: () => setState(() => _selectedPackage = package),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Purchase button
          FilledButton(
            onPressed: _selectedPackage == null || _isLoading
                ? null
                : _purchaseCredits,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _selectedPackage != null
                        ? 'Comprar por ${_selectedPackage!.priceDisplay}'
                        : 'Selecione um pacote',
                  ),
          ),
          const SizedBox(height: 16),

          // Info
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
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Créditos comprados não expiram e são acumulados com os da assinatura.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _watchAd() async {
    setState(() => _isLoadingAd = true);

    try {
      final adsService = ref.read(adsServiceProvider);
      final adSenseService = ref.read(adSenseServiceProvider);
      final subscriptionService = ref.read(subscriptionServiceProvider);
      final subscription = await subscriptionService.getSubscription(_userId);

      final result = await watchAdForCreditsDirect(
        adsService,
        subscriptionService,
        _userId,
        isPremium: subscription.isPremium,
        adSenseService: adSenseService,
      );

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voce ganhou ${result.creditsEarned} credito(s)!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(userSubscriptionProvider(_userId));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Erro ao assistir anuncio'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAd = false);
      }
    }
  }

  Future<void> _purchaseCredits() async {
    if (_selectedPackage == null) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(subscriptionServiceProvider);
      await purchaseAiCreditsDirect(
        service,
        _userId,
        _selectedPackage!,
        transactionId: 'credits_${DateTime.now().millisecondsSinceEpoch}',
      );

      ref.invalidate(userSubscriptionProvider(_userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_selectedPackage!.credits} créditos adicionados!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
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

class _PackageCard extends StatelessWidget {
  final AiCreditPackage package;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBestValue = package == AiCreditPackage.large;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Row(
          children: [
            Radio<AiCreditPackage>(
              value: package,
              groupValue: isSelected ? package : null,
              onChanged: (_) => onTap(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        package.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isBestValue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'MELHOR VALOR',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'R\$ ${(package.pricePerCredit / 100).toStringAsFixed(2)} por crédito',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              package.priceDisplay,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// UC214: Low balance alert widget.
class _LowBalanceAlert extends StatelessWidget {
  final int credits;

  const _LowBalanceAlert({required this.credits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.orange.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo baixo',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  Text(
                    'Voce tem apenas $credits credito(s) restante(s)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade700,
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
}

/// UC211: Earn credits section with ads option.
class _EarnCreditsSection extends StatelessWidget {
  final UserSubscription subscription;
  final bool isLoading;
  final VoidCallback onWatchAd;

  const _EarnCreditsSection({
    required this.subscription,
    required this.isLoading,
    required this.onWatchAd,
  });

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
                  Icons.card_giftcard,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ganhe creditos gratis',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Assista anuncios para ganhar creditos de IA gratuitamente.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subscription.isPremium
                  ? 'Ate 5 anuncios por dia (Premium)'
                  : 'Ate 3 anuncios por dia',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: isLoading ? null : onWatchAd,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_circle_outline),
              label: Text(
                isLoading ? 'Carregando...' : 'Assistir anuncio (+1 credito)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// UC213: Usage info card.
class _UsageInfoCard extends StatelessWidget {
  final UserSubscription subscription;

  const _UsageInfoCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalhes dos creditos',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Creditos da assinatura',
            value: '${subscription.aiCreditsRemaining}',
            icon: Icons.calendar_month,
          ),
          const SizedBox(height: 4),
          _InfoRow(
            label: 'Creditos comprados',
            value: '${subscription.aiCreditsPurchased}',
            icon: Icons.shopping_cart,
          ),
          const SizedBox(height: 4),
          _InfoRow(
            label: 'Total disponivel',
            value: '${subscription.totalAiCredits}',
            icon: Icons.auto_awesome,
            isBold: true,
          ),
          if (subscription.isPremium) ...[
            const Divider(height: 16),
            _InfoRow(
              label: 'Renovacao mensal',
              value: '${subscription.features.aiCreditsPerMonth} creditos',
              icon: Icons.refresh,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isBold;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: isBold ? FontWeight.bold : null,
            color: isBold ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
