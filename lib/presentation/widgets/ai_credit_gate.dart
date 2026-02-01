import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/ads_providers.dart' as ads;
import '../providers/ai_credits_providers.dart';
import '../providers/auth_providers.dart';

/// UC183, UC192: Widget que verifica creditos antes de usar IA.
///
/// Mostra dialogs apropriados conforme estado do usuario:
/// - Visitante sem credito: opcao de login ou assistir anuncio
/// - Logado sem credito: opcao de anuncio, comprar ou premium
/// - Com credito: executa acao
class AiCreditGate {
  /// Verifica se pode usar IA e executa acao se permitido.
  ///
  /// Retorna true se a acao foi executada, false se foi bloqueada.
  static Future<bool> checkAndExecute(
    BuildContext context,
    WidgetRef ref, {
    required Future<void> Function() onAllowed,
  }) async {
    final user = ref.read(currentUserProvider);
    final isPremium = ref.read(isPremiumUserProvider);
    final service = ref.read(aiCreditsServiceProvider);

    // Premium sempre pode
    if (isPremium) {
      await onAllowed();
      return true;
    }

    if (user == null) {
      // UC183: Visitante
      final hasTemp = await service.hasTemporaryCredit();
      if (hasTemp) {
        // Consumir credito e executar
        final consumed = await consumeTemporaryCredit(ref);
        if (consumed) {
          await onAllowed();
          return true;
        }
      }

      // Mostrar opcoes para visitante
      if (context.mounted) {
        return await _showVisitorDialog(context, ref, onAllowed);
      }
      return false;
    } else {
      // Usuario logado
      final balance = await service.getBalance(user.id);
      if (balance.available > 0) {
        // Consumir credito e executar
        final consumed = await consumeUserCredit(ref);
        if (consumed) {
          await onAllowed();
          return true;
        }
      }

      // UC192: Mostrar opcoes antes do paywall
      if (context.mounted) {
        return await _showLoggedUserDialog(context, ref, onAllowed);
      }
      return false;
    }
  }

  /// UC183: Dialog para visitante sem credito.
  static Future<bool> _showVisitorDialog(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() onAllowed,
  ) async {
    final result = await showModalBottomSheet<_VisitorAction>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _VisitorOptionsSheet(),
    );

    if (result == null) return false;

    switch (result) {
      case _VisitorAction.login:
        if (context.mounted) {
          context.push('/login');
        }
        return false;

      case _VisitorAction.watchAd:
        // Mostrar anuncio real ou simulado
        if (context.mounted) {
          final adCompleted = await _showRealOrSimulatedAd(context, ref);
          if (adCompleted) {
            await grantTemporaryCreditAfterAd(ref);
            // Consumir imediatamente e executar
            final consumed = await consumeTemporaryCredit(ref);
            if (consumed) {
              await onAllowed();
              return true;
            }
          }
        }
        return false;
    }
  }

  /// UC192: Dialog para usuario logado sem credito.
  static Future<bool> _showLoggedUserDialog(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() onAllowed,
  ) async {
    final service = ref.read(aiCreditsServiceProvider);
    final user = ref.read(currentUserProvider);
    final canWatch = user != null ? await service.canUserWatchAd(user.id) : false;

    if (!context.mounted) return false;

    final result = await showModalBottomSheet<_LoggedUserAction>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _LoggedUserOptionsSheet(canWatchAd: canWatch),
    );

    if (result == null) return false;

    switch (result) {
      case _LoggedUserAction.watchAd:
        if (context.mounted) {
          final adCompleted = await _showRealOrSimulatedAd(context, ref);
          if (adCompleted) {
            try {
              await addCreditFromAd(ref);
              // Consumir imediatamente e executar
              final consumed = await consumeUserCredit(ref);
              if (consumed) {
                await onAllowed();
                return true;
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                );
              }
            }
          }
        }
        return false;

      case _LoggedUserAction.buyCredits:
        if (context.mounted) {
          context.push('/subscription/credits');
        }
        return false;

      case _LoggedUserAction.seePremium:
        if (context.mounted) {
          context.push('/subscription/paywall');
        }
        return false;
    }
  }

  /// Mostra anuncio real em mobile ou simulado em web.
  static Future<bool> _showRealOrSimulatedAd(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (kIsWeb) {
      // Web: usar simulacao (AdSense nao implementado)
      return await _showAdSimulation(context);
    }

    // Mobile: usar AdMob
    final adsService = ref.read(ads.adsServiceProvider);

    // Carregar anuncio se necessario
    if (!adsService.isAdReady) {
      final loaded = await adsService.loadRewardedAd();
      if (!loaded) {
        // Se falhou ao carregar, usar simulacao como fallback
        return await _showAdSimulation(context);
      }
    }

    // Mostrar anuncio real
    final credits = await adsService.showRewardedAd();
    return credits > 0;
  }

  /// Simula exibicao de anuncio.
  static Future<bool> _showAdSimulation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const _AdSimulationDialog(),
        ) ??
        false;
  }
}

enum _VisitorAction { login, watchAd }

enum _LoggedUserAction { watchAd, buyCredits, seePremium }

/// UC183: Bottom sheet de opcoes para visitante.
class _VisitorOptionsSheet extends StatelessWidget {
  const _VisitorOptionsSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Icon(
            Icons.auto_awesome,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Gerar Cards com IA',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Entre ou assista um anuncio para gerar 1 card agora',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Botao criar conta (principal)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: () => Navigator.pop(context, _VisitorAction.login),
              icon: const Icon(Icons.person_add),
              label: const Text('Criar Conta / Entrar'),
            ),
          ),
          const SizedBox(height: 12),

          // Botao assistir anuncio
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, _VisitorAction.watchAd),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Assistir Anuncio (+1 geracao)'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// UC192: Bottom sheet de opcoes para usuario logado sem creditos.
class _LoggedUserOptionsSheet extends StatelessWidget {
  final bool canWatchAd;

  const _LoggedUserOptionsSheet({required this.canWatchAd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Icon(
            Icons.auto_awesome,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Sem Creditos',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha como deseja obter creditos para usar a IA',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Botao assistir anuncio
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: canWatchAd
                  ? () => Navigator.pop(context, _LoggedUserAction.watchAd)
                  : null,
              icon: const Icon(Icons.play_circle_outline),
              label: Text(canWatchAd
                  ? 'Assistir Anuncio (+1 credito)'
                  : 'Limite de anuncios atingido'),
            ),
          ),
          const SizedBox(height: 12),

          // Botao comprar creditos
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, _LoggedUserAction.buyCredits),
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Comprar Creditos'),
            ),
          ),
          const SizedBox(height: 12),

          // Botao ver premium
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context, _LoggedUserAction.seePremium),
              icon: const Icon(Icons.workspace_premium),
              label: const Text('Ver Premium (IA ilimitada)'),
            ),
          ),
          const SizedBox(height: 16),
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

/// UC185: Dialog pos-geracao para visitante.
///
/// Incentiva criacao de conta apos primeira experiencia positiva com IA.
class PostGenerationDialog extends StatelessWidget {
  const PostGenerationDialog({super.key});

  static Future<void> showIfVisitor(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user != null) return; // Apenas para visitantes

    await showDialog(
      context: context,
      builder: (context) => const PostGenerationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 28),
          const SizedBox(width: 8),
          const Text('Card Gerado!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Crie uma conta para salvar seus cards e ganhar mais creditos.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Continuar como visitante'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            context.push('/login');
          },
          child: const Text('Criar Conta'),
        ),
      ],
    );
  }
}
