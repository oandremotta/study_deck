import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

/// UC111-113-116: Upgrade prompt dialog shown at conversion triggers.
///
/// Supports different trigger contexts:
/// - UC111: Deck limit reached
/// - UC113: AI credits exhausted
/// - UC116: Streak lost (offer protection)
class UpgradePromptDialog extends StatelessWidget {
  final UpgradeTrigger trigger;
  final VoidCallback? onDismiss;
  final VoidCallback? onAlternative;
  final String? alternativeLabel;

  const UpgradePromptDialog({
    super.key,
    required this.trigger,
    this.onDismiss,
    this.onAlternative,
    this.alternativeLabel,
  });

  /// Show the upgrade prompt dialog.
  static Future<UpgradeAction?> show(
    BuildContext context, {
    required UpgradeTrigger trigger,
    VoidCallback? onAlternative,
    String? alternativeLabel,
  }) {
    return showDialog<UpgradeAction>(
      context: context,
      barrierDismissible: true,
      builder: (context) => UpgradePromptDialog(
        trigger: trigger,
        onAlternative: onAlternative,
        alternativeLabel: alternativeLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getConfig();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: config.iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                config.icon,
                size: 48,
                color: config.iconColor,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              config.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              config.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Benefits list
            ...config.benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),

            // Primary action - Upgrade
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop(UpgradeAction.upgrade);
                context.push(AppRoutes.subscriptionPaywall);
              },
              icon: const Icon(Icons.workspace_premium),
              label: const Text('Ver planos Premium'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),

            // Alternative action (if provided)
            if (onAlternative != null || config.defaultAlternative != null) ...[
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(UpgradeAction.alternative);
                  if (onAlternative != null) {
                    onAlternative!();
                  } else if (config.defaultAlternative != null) {
                    config.defaultAlternative!(context);
                  }
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: Text(alternativeLabel ?? config.alternativeLabel ?? 'Outra opcao'),
              ),
              const SizedBox(height: 8),
            ],

            // Dismiss
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(UpgradeAction.dismiss);
                onDismiss?.call();
              },
              child: const Text('Agora nao'),
            ),
          ],
        ),
      ),
    );
  }

  _UpgradeConfig _getConfig() {
    switch (trigger) {
      case UpgradeTrigger.deckLimit:
        return _UpgradeConfig(
          icon: Icons.folder_off,
          iconColor: Colors.orange,
          title: 'Limite de decks atingido',
          description: 'Voce atingiu o limite de decks do plano gratuito.',
          benefits: [
            'Decks ilimitados',
            'Cards ilimitados por deck',
            'Backup na nuvem',
            'Creditos IA mensais',
          ],
          alternativeLabel: 'Excluir um deck antigo',
          defaultAlternative: (ctx) => ctx.pop(),
        );

      case UpgradeTrigger.cardLimit:
        return _UpgradeConfig(
          icon: Icons.credit_card_off,
          iconColor: Colors.orange,
          title: 'Limite de cards atingido',
          description: 'Voce atingiu o limite de cards neste deck.',
          benefits: [
            'Cards ilimitados',
            'Decks ilimitados',
            'Importacao de arquivos',
          ],
          alternativeLabel: 'Excluir cards antigos',
          defaultAlternative: (ctx) => ctx.pop(),
        );

      case UpgradeTrigger.aiCreditsExhausted:
        return _UpgradeConfig(
          icon: Icons.auto_awesome_outlined,
          iconColor: Colors.purple,
          title: 'Creditos IA esgotados',
          description: 'Seus creditos de IA acabaram. Gere mais cards automaticamente!',
          benefits: [
            '50 creditos IA/mes',
            'Geracao ilimitada de cards',
            'Cards com dicas automaticas',
          ],
          alternativeLabel: 'Assistir anuncio (+1 credito)',
          defaultAlternative: (ctx) => ctx.push(AppRoutes.subscriptionCredits),
        );

      case UpgradeTrigger.streakLost:
        return _UpgradeConfig(
          icon: Icons.local_fire_department,
          iconColor: Colors.red,
          title: 'Sequencia perdida!',
          description: 'Sua sequencia de estudos foi interrompida. Proteja suas conquistas!',
          benefits: [
            'Protecao de sequencia',
            '1 "passe livre" por semana',
            'Lembretes personalizados',
          ],
          alternativeLabel: 'Continuar sem protecao',
          defaultAlternative: null,
        );

      case UpgradeTrigger.backupLimit:
        return _UpgradeConfig(
          icon: Icons.cloud_off,
          iconColor: Colors.blue,
          title: 'Backup na nuvem',
          description: 'Seus dados estao apenas neste dispositivo. Proteja seu progresso!',
          benefits: [
            'Backup automatico',
            'Sincronizacao entre dispositivos',
            'Restauracao facil',
          ],
          alternativeLabel: 'Exportar localmente',
          defaultAlternative: null,
        );
    }
  }
}

/// Configuration for upgrade prompts.
class _UpgradeConfig {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<String> benefits;
  final String? alternativeLabel;
  final void Function(BuildContext)? defaultAlternative;

  const _UpgradeConfig({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.benefits,
    this.alternativeLabel,
    this.defaultAlternative,
  });
}

/// Triggers for showing upgrade prompts.
enum UpgradeTrigger {
  deckLimit,         // UC111
  cardLimit,         // Similar to deck limit
  aiCreditsExhausted, // UC113
  streakLost,        // UC116
  backupLimit,       // Cloud backup upsell
}

/// User actions on upgrade prompt.
enum UpgradeAction {
  upgrade,      // Go to plans
  alternative,  // Use alternative option
  dismiss,      // Close without action
}
