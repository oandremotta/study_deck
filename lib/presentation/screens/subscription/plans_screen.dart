import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/subscription.dart';
import '../../providers/auth_providers.dart';
import '../../providers/revenuecat_providers.dart';
import '../../router/app_router.dart';

/// UC258, UC190, UC191: Plans comparison screen.
///
/// UC190: Planos ocultos para visitante
/// UC191: Planos liberados apenas após login
class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    // UC190: Se não está logado, mostrar tela de login obrigatório
    if (user == null) {
      return _buildLoginRequiredScreen(context, theme);
    }

    // Check premium status (mobile only)
    final isPremium = kIsWeb ? false : ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha seu Plano'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Desbloqueie todo o potencial',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha o plano ideal para seus estudos',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Plans
            _PlanCard(
              plan: SubscriptionPlan.free,
              isCurrentPlan: !isPremium,
              onSelect: () {},
            ),
            const SizedBox(height: 16),
            _PlanCard(
              plan: SubscriptionPlan.premiumMonthly,
              isCurrentPlan: isPremium,
              onSelect: () {
                context.push(AppRoutes.subscriptionPaywall);
              },
            ),
            const SizedBox(height: 16),
            _PlanCard(
              plan: SubscriptionPlan.premiumAnnual,
              isCurrentPlan: isPremium,
              isRecommended: true,
              onSelect: () {
                context.push(AppRoutes.subscriptionPaywall);
              },
            ),
            const SizedBox(height: 32),

            // Features comparison
            Text(
              'Comparação de Recursos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _FeaturesComparisonTable(),
          ],
        ),
      ),
    );
  }

  /// UC190: Tela para usuário não logado - planos ocultos
  Widget _buildLoginRequiredScreen(BuildContext context, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planos'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Crie uma conta para ver os planos',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Entre ou crie uma conta para desbloquear todos os recursos premium.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    context.push('/login');
                  },
                  icon: const Icon(Icons.login),
                  label: const Text(
                    'Entrar ou Criar Conta',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isCurrentPlan;
  final bool isRecommended;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.plan,
    required this.isCurrentPlan,
    this.isRecommended = false,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final features = PlanFeatures.forPlan(plan);

    return Card(
      elevation: isRecommended ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isRecommended
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isRecommended)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'RECOMENDADO',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isRecommended) const SizedBox(height: 8),
                      Text(
                        plan.displayName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.priceDisplay,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (plan.periodDisplay.isNotEmpty)
                      Text(
                        plan.periodDisplay,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              plan.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Key features
            _FeatureItem(
              text: features.unlimitedDecks
                  ? 'Decks ilimitados'
                  : 'Até ${features.maxDecks} decks',
              included: true,
            ),
            _FeatureItem(
              text: features.unlimitedCards
                  ? 'Cards ilimitados'
                  : 'Até ${features.maxCardsPerDeck} cards/deck',
              included: true,
            ),
            _FeatureItem(
              text: '${features.aiCreditsPerMonth} créditos IA/mês',
              included: true,
            ),
            _FeatureItem(
              text: 'Backup na nuvem',
              included: features.cloudBackup,
            ),
            _FeatureItem(
              text: 'Áudio e TTS',
              included: features.audioFeatures,
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: isCurrentPlan
                  ? OutlinedButton(
                      onPressed: null,
                      child: const Text('Plano Atual'),
                    )
                  : FilledButton(
                      onPressed: onSelect,
                      child: Text(plan.isPremium ? 'Assinar' : 'Selecionar'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  final bool included;

  const _FeatureItem({required this.text, required this.included});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: included
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: included
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesComparisonTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final freeFeatures = PlanFeatures.free;
    final premiumFeatures = PlanFeatures.premium;

    return Table(
      border: TableBorder.all(
        color: theme.colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          children: [
            _TableCell('Recurso', isHeader: true),
            _TableCell('Grátis', isHeader: true),
            _TableCell('Premium', isHeader: true),
          ],
        ),
        _buildRow('Decks', '${freeFeatures.maxDecks}', 'Ilimitado'),
        _buildRow('Cards/Deck', '${freeFeatures.maxCardsPerDeck}', 'Ilimitado'),
        _buildRow('Créditos IA', '${freeFeatures.aiCreditsPerMonth}/mês',
            '${premiumFeatures.aiCreditsPerMonth}/mês'),
        _buildRow('Backup', 'Não', 'Sim'),
        _buildRow('Áudio/TTS', 'Não', 'Sim'),
        _buildRow('Stats Avançadas', 'Não', 'Sim'),
        _buildRow('Sem Anúncios', 'Não', 'Sim'),
      ],
    );
  }

  TableRow _buildRow(String feature, String free, String premium) {
    return TableRow(
      children: [
        _TableCell(feature),
        _TableCell(free),
        _TableCell(premium),
      ],
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;

  const _TableCell(this.text, {this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: isHeader
            ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
            : theme.textTheme.bodyMedium,
        textAlign: isHeader ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}
