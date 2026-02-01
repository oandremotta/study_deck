import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/ai_credit.dart';
import '../../providers/ai_credits_providers.dart';
import '../../providers/auth_providers.dart';

/// UC183-UC195: Tela de creditos IA.
///
/// Comportamento diferente para:
/// - Visitante: mostra opcao de assistir anuncio
/// - Logado Free: mostra saldo, historico, opcoes de compra
/// - Premium: mostra status premium
class AiCreditsScreen extends ConsumerWidget {
  const AiCreditsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    // UC184, UC190: Visitante nao ve saldo nem planos
    if (user == null) {
      return _VisitorCreditsView(theme: theme);
    }

    // Usuario logado
    final isPremium = ref.watch(isPremiumUserProvider);
    if (isPremium) {
      return _PremiumCreditsView(theme: theme);
    }

    return _LoggedUserCreditsView(theme: theme);
  }
}

/// UC184: Tela de creditos para visitante.
///
/// - Nao mostra saldo
/// - Nao mostra historico
/// - Nao mostra pacotes
/// - Mostra opcao de assistir anuncio ou criar conta
class _VisitorCreditsView extends ConsumerWidget {
  final ThemeData theme;

  const _VisitorCreditsView({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTemporaryCredit = ref.watch(hasTemporaryCreditProvider);
    final canWatchAd = ref.watch(canWatchAdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creditos IA'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icone
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

              // Titulo
              Text(
                'Entre para acompanhar seus creditos',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Descricao
              Text(
                'Assista anuncios para gerar 1 card por vez.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Status do credito temporario
              hasTemporaryCredit.when(
                data: (hasCredit) {
                  if (hasCredit) {
                    return _TemporaryCreditBanner(theme: theme);
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Botao criar conta (principal)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.person_add),
                  label: const Text(
                    'Criar Conta',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botao assistir anuncio
              canWatchAd.when(
                data: (canWatch) {
                  if (!canWatch) {
                    return Text(
                      'Voce ja tem 1 credito disponivel',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  }
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => _watchAdAsVisitor(context, ref),
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text(
                        'Assistir Anuncio (+1 geracao)',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _watchAdAsVisitor(BuildContext context, WidgetRef ref) async {
    // TODO: Integrar com Google AdMob rewarded ad
    // Por enquanto, simula assistir anuncio
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Assistindo Anuncio'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Simulando anuncio...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await grantTemporaryCreditAfterAd(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Credito temporario concedido! Use agora.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }
}

/// Banner mostrando que visitante tem credito temporario.
class _TemporaryCreditBanner extends StatelessWidget {
  final ThemeData theme;

  const _TemporaryCreditBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voce tem 1 geracao disponivel!',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  'Use agora - expira em 5 minutos',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// UC191: Tela de creditos para usuario logado (free).
///
/// - Mostra saldo
/// - Mostra consumo
/// - Mostra opcoes de compra
/// - Mostra opcao de assistir anuncio
class _LoggedUserCreditsView extends ConsumerWidget {
  final ThemeData theme;

  const _LoggedUserCreditsView({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(aiCreditBalanceProvider);
    final canWatchAd = ref.watch(canWatchAdProvider);
    final packages = ref.watch(creditPackagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creditos IA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium),
            onPressed: () => context.push('/subscription/paywall'),
            tooltip: 'Ver Premium',
          ),
        ],
      ),
      body: balanceAsync.when(
        data: (balance) {
          if (balance == null) {
            return const Center(child: Text('Erro ao carregar saldo'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card de saldo
                _BalanceCard(balance: balance, theme: theme),
                const SizedBox(height: 24),

                // Estatisticas
                _StatsRow(balance: balance, theme: theme),
                const SizedBox(height: 24),

                // Opcao de assistir anuncio
                canWatchAd.when(
                  data: (canWatch) => _AdSection(
                    canWatch: canWatch,
                    balance: balance,
                    theme: theme,
                    onWatchAd: () => _watchAdAsUser(context, ref),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
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
                const SizedBox(height: 12),
                ...packages.map((package) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CreditPackageCard(
                        package: package,
                        theme: theme,
                        onBuy: () => _buyPackage(context, ref, package),
                      ),
                    )),

                const SizedBox(height: 24),

                // Ver Premium
                _PremiumBanner(theme: theme),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Future<void> _watchAdAsUser(BuildContext context, WidgetRef ref) async {
    // TODO: Integrar com Google AdMob rewarded ad
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Assistindo Anuncio'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Simulando anuncio...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await addCreditFromAd(ref);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('+1 credito adicionado!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _buyPackage(
      BuildContext context, WidgetRef ref, AiCreditPackage package) async {
    // TODO: Integrar com Stripe
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compra de ${package.name} em breve!'),
      ),
    );
  }
}

/// Card mostrando saldo de creditos.
class _BalanceCard extends StatelessWidget {
  final AiCreditBalance balance;
  final ThemeData theme;

  const _BalanceCard({required this.balance, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Creditos Disponiveis',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${balance.available}',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              balance.available == 1 ? 'credito' : 'creditos',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha de estatisticas.
class _StatsRow extends StatelessWidget {
  final AiCreditBalance balance;
  final ThemeData theme;

  const _StatsRow({required this.balance, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Usados hoje',
            value: '${balance.usedToday}',
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Este mes',
            value: '${balance.usedThisMonth}',
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Total',
            value: '${balance.totalUsed}',
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _StatCard({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Secao de assistir anuncio.
class _AdSection extends StatelessWidget {
  final bool canWatch;
  final AiCreditBalance balance;
  final ThemeData theme;
  final VoidCallback onWatchAd;

  const _AdSection({
    required this.canWatch,
    required this.balance,
    required this.theme,
    required this.onWatchAd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ganhe Creditos Gratis',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Assista um anuncio e ganhe 1 credito.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anuncios hoje: ${balance.adsWatchedToday}/5',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canWatch ? onWatchAd : null,
                icon: const Icon(Icons.play_arrow),
                label: Text(canWatch ? 'Assistir Anuncio' : 'Limite atingido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de pacote de creditos.
class _CreditPackageCard extends StatelessWidget {
  final AiCreditPackage package;
  final ThemeData theme;
  final VoidCallback onBuy;

  const _CreditPackageCard({
    required this.package,
    required this.theme,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: package.isPopular
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onBuy,
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${package.credits}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
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
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'POPULAR',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      'R\$ ${package.pricePerCredit.toStringAsFixed(2)}/credito',
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
      ),
    );
  }
}

/// Banner para ver Premium.
class _PremiumBanner extends StatelessWidget {
  final ThemeData theme;

  const _PremiumBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
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
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange.shade700],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seja Premium',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'IA ilimitada + todos os recursos',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tela para usuario Premium.
class _PremiumCreditsView extends StatelessWidget {
  final ThemeData theme;

  const _PremiumCreditsView({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creditos IA'),
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
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange.shade700],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Voce e Premium!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'IA liberada - bom estudo!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aproveite todos os recursos sem limites.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
