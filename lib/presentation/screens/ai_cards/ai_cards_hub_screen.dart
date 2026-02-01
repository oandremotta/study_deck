import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/ai_project.dart';
import '../../../domain/entities/subscription.dart';
import '../../providers/ads_providers.dart';
import '../../providers/ai_card_providers.dart';
import '../../providers/subscription_providers.dart';
import '../../router/app_router.dart';

/// Hub screen for AI card generation (UC127).
///
/// Provides access to:
/// - Generate from PDF
/// - Generate from text
/// - Generate by topic
/// - Generation history
class AiCardsHubScreen extends ConsumerWidget {
  const AiCardsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(watchAiProjectsProvider);
    // UC204-207: Watch subscription for credits
    final subscriptionAsync = ref.watch(userSubscriptionProvider('user_id'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards IA'),
      ),
      body: Builder(
        builder: (context) {
          final subscription = subscriptionAsync.valueOrNull ??
              UserSubscription.free('user_id');
          final hasCredits = subscription.totalAiCredits > 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Credits status card (UC211)
                _CreditsStatusCard(subscription: subscription),
                const SizedBox(height: 16),

                // UC207: No credits - show ad option
                if (!hasCredits) ...[
                  _NoCreditsWarning(),
                  const SizedBox(height: 16),
                ],

                // Generation options
                Text(
                  'Gerar Cards',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _GenerationOptions(canGenerate: hasCredits),
                const SizedBox(height: 24),

                // Recent projects
                Text(
                  'Projetos Recentes',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                projectsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Text('Erro ao carregar projetos: $e'),
                  data: (projects) => projects.isEmpty
                      ? _EmptyProjects()
                      : _ProjectsList(projects: projects.take(5).toList()),
                ),

                // View all history button
                if (projectsAsync.valueOrNull?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.push(AppRouter.aiHistory),
                      icon: const Icon(Icons.history),
                      label: const Text('Ver todo o historico'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// UC211: Credits status card.
class _CreditsStatusCard extends StatelessWidget {
  final UserSubscription subscription;

  const _CreditsStatusCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final credits = subscription.totalAiCredits;
    final isPremium = subscription.isPremium;

    return Card(
      color: isPremium
          ? context.colorScheme.primaryContainer
          : context.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPremium
                    ? context.colorScheme.primary
                    : context.colorScheme.outline.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: isPremium
                    ? context.colorScheme.onPrimary
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$credits',
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isPremium
                              ? context.colorScheme.onPrimaryContainer
                              : null,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'creditos IA',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: isPremium
                              ? context.colorScheme.onPrimaryContainer
                              : context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPremium
                        ? 'Premium - ${subscription.features.aiCreditsPerMonth} creditos/mes'
                        : 'Plano Gratuito',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isPremium
                          ? context.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.8)
                          : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (!isPremium)
              TextButton(
                onPressed: () => context.push(AppRoutes.subscriptionPaywall),
                child: const Text('Upgrade'),
              ),
          ],
        ),
      ),
    );
  }
}

/// UC207: Warning when no credits available with alternatives.
class _NoCreditsWarning extends ConsumerStatefulWidget {
  const _NoCreditsWarning();

  @override
  ConsumerState<_NoCreditsWarning> createState() => _NoCreditsWarningState();
}

class _NoCreditsWarningState extends ConsumerState<_NoCreditsWarning> {
  bool _isLoadingAd = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.credit_card_off,
                  color: context.colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sem creditos IA',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Voce precisa de creditos para gerar cards com IA. Escolha uma opcao:',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.subscriptionPaywall),
                  icon: const Icon(Icons.workspace_premium, size: 18),
                  label: const Text('Fazer upgrade'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.subscriptionCredits),
                  icon: const Icon(Icons.shopping_cart, size: 18),
                  label: const Text('Comprar creditos'),
                ),
                OutlinedButton.icon(
                  onPressed: _isLoadingAd ? null : _watchAd,
                  icon: _isLoadingAd
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_circle_outline, size: 18),
                  label: Text(_isLoadingAd ? 'Carregando...' : 'Assistir anuncio'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _watchAd() async {
    setState(() => _isLoadingAd = true);

    try {
      final adsService = ref.read(adsServiceProvider);
      final subscriptionService = ref.read(subscriptionServiceProvider);

      // Get subscription to check if premium
      final subscription = await subscriptionService.getSubscription('user_id');

      final result = await watchAdForCreditsDirect(
        adsService,
        subscriptionService,
        'user_id',
        isPremium: subscription.isPremium,
      );

      if (!mounted) return;

      if (result.success) {
        context.showSnackBar(
          'Voce ganhou ${result.creditsEarned} credito(s) IA!',
        );
        // Refresh subscription to update credits
        ref.invalidate(userSubscriptionProvider('user_id'));
      } else {
        context.showErrorSnackBar(result.errorMessage ?? 'Erro ao assistir anuncio');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Erro: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAd = false);
      }
    }
  }
}

/// Generation options cards.
class _GenerationOptions extends StatelessWidget {
  final bool canGenerate;

  const _GenerationOptions({required this.canGenerate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OptionCard(
          icon: Icons.description_outlined,
          title: 'A partir de PDF',
          subtitle: 'Extraia texto de um PDF e gere cards',
          onTap: canGenerate ? () => context.push(AppRouter.aiFromPdf) : null,
        ),
        const SizedBox(height: 8),
        _OptionCard(
          icon: Icons.text_fields,
          title: 'A partir de texto',
          subtitle: 'Cole ou digite o conteudo para gerar cards',
          onTap: canGenerate ? () => context.push(AppRouter.aiFromText) : null,
        ),
        const SizedBox(height: 8),
        _OptionCard(
          icon: Icons.lightbulb_outline,
          title: 'Por assunto',
          subtitle: 'Informe um tema e deixe a IA criar os cards',
          onTap: canGenerate ? () => context.push(AppRouter.aiFromTopic) : null,
        ),
      ],
    );
  }
}

/// Single option card.
class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty state for no projects.
class _EmptyProjects extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 48,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhum projeto ainda',
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Selecione uma opcao acima para comecar',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List of recent projects.
class _ProjectsList extends StatelessWidget {
  final List<AiProject> projects;

  const _ProjectsList({required this.projects});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: projects.map((project) => _ProjectCard(project: project)).toList(),
    );
  }
}

/// Single project card.
class _ProjectCard extends StatelessWidget {
  final AiProject project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _getStatusIcon(context),
        title: Text(
          project.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${project.sourceType.displayName} - ${project.status.displayName}',
        ),
        trailing: project.hasReviewableDrafts
            ? TextButton(
                onPressed: () =>
                    context.push('${AppRouter.aiReview}/${project.id}'),
                child: const Text('Revisar'),
              )
            : null,
        onTap: () => _navigateToProject(context),
      ),
    );
  }

  Widget _getStatusIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (project.status) {
      case AiProjectStatus.created:
      case AiProjectStatus.extracting:
      case AiProjectStatus.generating:
        icon = Icons.hourglass_top;
        color = context.colorScheme.primary;
        break;
      case AiProjectStatus.review:
        icon = Icons.rate_review;
        color = context.colorScheme.tertiary;
        break;
      case AiProjectStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case AiProjectStatus.failed:
        icon = Icons.error;
        color = context.colorScheme.error;
        break;
    }

    return Icon(icon, color: color);
  }

  void _navigateToProject(BuildContext context) {
    if (project.status == AiProjectStatus.review) {
      context.push('${AppRouter.aiReview}/${project.id}');
    } else if (project.status == AiProjectStatus.generating ||
        project.status == AiProjectStatus.extracting) {
      context.push('${AppRouter.aiProgress}/${project.id}');
    }
  }
}
