import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/services/ai_credits_service.dart';
import '../../../data/services/stripe_web_service.dart';
import '../../../domain/entities/ai_credit.dart';
import '../../providers/ads_providers.dart' as ads;
import '../../providers/ai_credits_providers.dart';
import '../../providers/auth_providers.dart';

/// UC184, UC185, UC192: Tela de creditos de IA.
///
/// UC184: Painel de creditos para usuario logado
/// UC185: Informacoes para visitantes
/// UC192: Opcoes antes do paywall
class AiCreditsScreen extends ConsumerStatefulWidget {
  const AiCreditsScreen({super.key});

  @override
  ConsumerState<AiCreditsScreen> createState() => _AiCreditsScreenState();
}

class _AiCreditsScreenState extends ConsumerState<AiCreditsScreen> {
  AiCreditPackage? _selectedPackage;
  bool _isLoading = false;
  bool _isLoadingAd = false;
  bool _justEarnedCredit = false; // Para destacar proximo passo

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final isPremium = ref.watch(isPremiumUserProvider);

    // UC185: Visitante - tela simplificada
    if (user == null) {
      return _buildVisitorScreen(context, theme);
    }

    // UC184: Usuario logado
    final balanceAsync = ref.watch(aiCreditBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creditos de IA'),
        actions: [
          if (isPremium)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Premium',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: balanceAsync.when(
        data: (balance) {
          final actualBalance = balance ?? const AiCreditBalance();
          return _buildLoggedUserContent(context, actualBalance, isPremium, theme);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  /// UC185: Tela para visitante (nao logado).
  Widget _buildVisitorScreen(BuildContext context, ThemeData theme) {
    final hasTemporaryCredit = ref.watch(hasTemporaryCreditProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creditos de IA'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gere Cards com IA',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crie flashcards automaticamente a partir de qualquer texto',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Status do credito temporario
            hasTemporaryCredit.when(
              data: (hasCredit) => Card(
                color: hasCredit
                    ? Colors.green.withValues(alpha: 0.1)
                    : theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: hasCredit
                              ? Colors.green.withValues(alpha: 0.2)
                              : theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          hasCredit ? Icons.check_circle : Icons.hourglass_empty,
                          color: hasCredit ? Colors.green : theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasCredit ? '1 Geracao Disponivel' : 'Sem Creditos',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: hasCredit ? Colors.green.shade700 : null,
                              ),
                            ),
                            Text(
                              hasCredit
                                  ? 'Use agora para gerar um card com IA'
                                  : 'Assista um anuncio para ganhar 1 geracao',
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
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Opcoes para visitante
            Text(
              'Como obter creditos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Opcao 1: Assistir anuncio
            _VisitorOptionCard(
              icon: Icons.play_circle_outline,
              title: 'Assistir Anuncio',
              description: 'Ganhe 1 geracao gratuita',
              buttonText: _isLoadingAd ? 'Carregando...' : 'Assistir Agora',
              isPrimary: true,
              isLoading: _isLoadingAd,
              onPressed: _isLoadingAd ? null : _watchAdAsVisitor,
            ),
            const SizedBox(height: 12),

            // Opcao 2: Criar conta - com gatilho de perda
            _VisitorOptionCard(
              icon: Icons.person_add,
              title: 'Criar Conta Gratis',
              description: 'Entre para nao perder seus cards e creditos',
              buttonText: 'Entrar / Criar Conta',
              isPrimary: false,
              onPressed: () => context.push('/login'),
              highlight: _justEarnedCredit, // Destacar apos ganhar credito
            ),
            const SizedBox(height: 32),

            // Info sobre creditos
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
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Como funciona',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoItem(
                    text: 'Cada anuncio te da 1 geracao de IA',
                    theme: theme,
                  ),
                  _InfoItem(
                    text: 'Creditos de visitante sao de uso unico',
                    theme: theme,
                  ),
                  _InfoItem(
                    text: 'Crie uma conta para acumular creditos',
                    theme: theme,
                  ),
                  _InfoItem(
                    text: 'Premium tem IA ilimitada!',
                    theme: theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// UC184: Conteudo para usuario logado.
  Widget _buildLoggedUserContent(
    BuildContext context,
    AiCreditBalance balance,
    bool isPremium,
    ThemeData theme,
  ) {
    final canWatchAd = ref.watch(canWatchAdProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card de saldo
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    isPremium ? Icons.all_inclusive : Icons.auto_awesome,
                    size: 48,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 12),
                  if (isPremium)
                    Text(
                      'Ilimitado',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    )
                  else
                    Text(
                      '${balance.available}',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  Text(
                    isPremium ? 'creditos de IA' : 'creditos disponiveis',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (!isPremium && balance.adsWatchedToday > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Anuncios assistidos hoje: ${balance.adsWatchedToday}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Proximo passo apos ganhar credito
          if (_justEarnedCredit && balance.available > 0) ...[
            _NextStepCard(
              onTap: () => context.push('/ai-cards'),
              onDismiss: () => setState(() => _justEarnedCredit = false),
            ),
            const SizedBox(height: 16),
          ],

          // UC214: Alerta de saldo baixo
          if (!isPremium && balance.available <= 5 && balance.available > 0 && !_justEarnedCredit) ...[
            _LowBalanceAlert(credits: balance.available),
            const SizedBox(height: 16),
          ],

          // Secao de ganhar creditos (se nao for premium)
          if (!isPremium) ...[
            canWatchAd.when(
              data: (canWatch) => _EarnCreditsSection(
                canWatchAd: canWatch,
                isLoading: _isLoadingAd,
                onWatchAd: _watchAdAsLoggedUser,
                adsWatchedToday: balance.adsWatchedToday,
                dailyLimit: AiCreditsService.dailyAdLimit,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Pacotes de creditos
            Text(
              'Comprar Creditos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Creditos comprados nao expiram',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            ...AiCreditsService.creditPackages.map(
              (package) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PackageCard(
                  package: package,
                  isSelected: _selectedPackage?.id == package.id,
                  onTap: () => setState(() => _selectedPackage = package),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botao de compra
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
                          ? 'Comprar por R\$ ${_selectedPackage!.price.toStringAsFixed(2).replaceAll('.', ',')}'
                          : 'Selecione um pacote',
                    ),
            ),
            const SizedBox(height: 24),

            // Link para premium
            Card(
              child: InkWell(
                onTap: () => context.push('/subscription/paywall'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.workspace_premium,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quer IA ilimitada?',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Assine o Premium e gere quantos cards quiser',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            // Premium user info
            Card(
              color: Colors.green.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voce e Premium!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            'Aproveite a geracao ilimitada de cards com IA',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Como funciona
          _HowItWorksSection(theme: theme),
        ],
      ),
    );
  }

  Future<void> _watchAdAsVisitor() async {
    setState(() => _isLoadingAd = true);

    try {
      // Usar AdsService real em mobile, simulacao em web
      final adCompleted = await _showRealOrSimulatedAd();

      if (adCompleted) {
        await grantTemporaryCreditAfterAd(ref);
        setState(() => _justEarnedCredit = true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text(
                    '🎉',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '+1 geracao de IA recebida! Use agora.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
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

  Future<void> _watchAdAsLoggedUser() async {
    setState(() => _isLoadingAd = true);

    try {
      // Usar AdsService real em mobile, simulacao em web
      final adCompleted = await _showRealOrSimulatedAd();

      if (adCompleted) {
        await addCreditFromAd(ref);
        ref.invalidate(aiCreditBalanceProvider);
        setState(() => _justEarnedCredit = true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text(
                    '🎉',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '+1 credito de IA recebido!',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Usar agora',
                textColor: Colors.white,
                onPressed: () {
                  context.push('/ai-cards');
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
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

  /// Mostra anuncio real em mobile ou simulado em web.
  Future<bool> _showRealOrSimulatedAd() async {
    if (kIsWeb) {
      // Web: usar simulacao (AdSense nao implementado)
      return await _showAdSimulation();
    }

    // Mobile: usar AdMob
    final adsService = ref.read(ads.adsServiceProvider);

    // Carregar anuncio se necessario
    if (!adsService.isAdReady) {
      final loaded = await adsService.loadRewardedAd();
      if (!loaded) {
        // Se falhou ao carregar, usar simulacao como fallback
        return await _showAdSimulation();
      }
    }

    // Mostrar anuncio real
    final credits = await adsService.showRewardedAd();
    return credits > 0;
  }

  Future<bool> _showAdSimulation() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const _AdSimulationDialog(),
        ) ??
        false;
  }

  Future<void> _purchaseCredits() async {
    if (_selectedPackage == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voce precisa estar logado para comprar creditos'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if Stripe is configured for this package
      final stripePackage =
          StripeWebService.creditPackages[_selectedPackage!.id];

      if (stripePackage == null || !stripePackage.hasValidPriceId) {
        // Stripe not configured yet - show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Pagamentos ainda nao estao disponiveis. Tente novamente em breve.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Create Stripe Checkout session
      final stripeService = StripeWebService();
      final baseUrl = kIsWeb
          ? Uri.base.origin
          : 'https://studydeck-78bde.web.app';

      final checkoutUrl = await stripeService.createCreditPackageCheckout(
        packageId: _selectedPackage!.id,
        userId: user.id,
        userEmail: user.email,
        successUrl: '$baseUrl/subscription/credits?payment=success',
        cancelUrl: '$baseUrl/subscription/credits?payment=canceled',
      );

      if (checkoutUrl == null) {
        throw Exception('Erro ao criar sessao de pagamento');
      }

      // Open Stripe Checkout
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Redirecionando para pagamento... Os creditos serao adicionados apos a confirmacao.',
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        throw Exception('Nao foi possivel abrir a pagina de pagamento');
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _VisitorOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final bool isPrimary;
  final bool isLoading;
  final bool highlight;
  final VoidCallback? onPressed;

  const _VisitorOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.isPrimary,
    this.isLoading = false,
    this.highlight = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: highlight ? Colors.amber.withValues(alpha: 0.15) : null,
      shape: highlight
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.amber.shade600, width: 2),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: highlight
                        ? Colors.amber.withValues(alpha: 0.3)
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    color: highlight ? Colors.amber.shade800 : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (highlight) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade600,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'RECOMENDADO',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: highlight
                              ? Colors.amber.shade800
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: highlight ? FontWeight.w500 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: isPrimary
                  ? FilledButton(
                      onPressed: onPressed,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(buttonText),
                    )
                  : highlight
                      ? FilledButton.tonal(
                          onPressed: onPressed,
                          child: Text(buttonText),
                        )
                      : OutlinedButton(
                          onPressed: onPressed,
                          child: Text(buttonText),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String text;
  final ThemeData theme;

  const _InfoItem({required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
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
            Radio<String>(
              value: package.id,
              groupValue: isSelected ? package.id : null,
              onChanged: (_) => onTap(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        package.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (package.isPopular) ...[
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
                            'POPULAR',
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
                    'R\$ ${package.pricePerCredit.toStringAsFixed(2).replaceAll('.', ',')} por credito',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'R\$ ${package.price.toStringAsFixed(2).replaceAll('.', ',')}',
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

/// Card destacado para proximo passo apos ganhar credito.
class _NextStepCard extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NextStepCard({
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.green.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade400, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.green,
                  size: 28,
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
                          'Proximo passo',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('👉', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    Text(
                      'Use seu credito para gerar cards com IA',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.green.shade400,
                ),
                onPressed: onDismiss,
                tooltip: 'Fechar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _EarnCreditsSection extends StatelessWidget {
  final bool canWatchAd;
  final bool isLoading;
  final VoidCallback onWatchAd;
  final int adsWatchedToday;
  final int dailyLimit;

  const _EarnCreditsSection({
    required this.canWatchAd,
    required this.isLoading,
    required this.onWatchAd,
    required this.adsWatchedToday,
    required this.dailyLimit,
  });

  bool get isLimitReached => adsWatchedToday >= dailyLimit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: isLimitReached
          ? theme.colorScheme.surfaceContainerHighest
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isLimitReached ? Icons.check_circle : Icons.card_giftcard,
                  color: isLimitReached
                      ? Colors.green
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isLimitReached
                        ? 'Maximo de anuncios assistidos hoje!'
                        : 'Ganhe creditos gratis',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLimitReached ? Colors.green.shade700 : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLimitReached) ...[
              // Mensagem amigavel quando limite atingido
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voce ganhou $adsWatchedToday credito${adsWatchedToday > 1 ? 's' : ''} hoje!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Volte amanha para mais anuncios gratuitos.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Sugestao de upgrade
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ou faca upgrade para IA ilimitada!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Secao normal quando pode assistir
              Text(
                'Assista anuncios para ganhar creditos de IA gratuitamente.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              // Progress indicator
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: adsWatchedToday / dailyLimit,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        color: theme.colorScheme.primary,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$adsWatchedToday/$dailyLimit',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: canWatchAd && !isLoading ? onWatchAd : null,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_circle_outline),
                  label: Text(
                    isLoading
                        ? 'Carregando...'
                        : 'Assistir anuncio (+1 credito)',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  final ThemeData theme;

  const _HowItWorksSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Como funciona',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _HowItWorksItem(
            icon: Icons.auto_awesome,
            text: 'Cada geracao de card com IA consome 1 credito',
            theme: theme,
          ),
          _HowItWorksItem(
            icon: Icons.play_circle_outline,
            text: 'Assista anuncios para ganhar creditos gratis',
            theme: theme,
          ),
          _HowItWorksItem(
            icon: Icons.shopping_cart,
            text: 'Creditos comprados nunca expiram',
            theme: theme,
          ),
          _HowItWorksItem(
            icon: Icons.workspace_premium,
            text: 'Premium tem IA ilimitada sem anuncios',
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _HowItWorksItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final ThemeData theme;

  const _HowItWorksItem({
    required this.icon,
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog simulando exibicao de anuncio.
class _AdSimulationDialog extends StatefulWidget {
  const _AdSimulationDialog();

  @override
  State<_AdSimulationDialog> createState() => _AdSimulationDialogState();
}

class _AdSimulationDialogState extends State<_AdSimulationDialog> {
  int _countdown = 3;
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 3; i >= 0; i--) {
      if (!mounted) return;
      setState(() => _countdown = i);
      if (i > 0) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    if (mounted) {
      setState(() => _canClose = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Anuncio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Simulacao de Anuncio',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!_canClose)
            Text(
              'Aguarde $_countdown segundos...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Text(
              'Anuncio concluido!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
      actions: [
        if (_canClose)
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Concluir'),
          )
        else
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
      ],
    );
  }
}
