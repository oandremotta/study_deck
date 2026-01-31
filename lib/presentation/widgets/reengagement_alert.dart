import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/reengagement_service.dart';
import '../providers/premium_providers.dart';

/// UC147-150: Reengagement alert banner/card.
///
/// Shows contextual messages to reengage users:
/// - Premium underutilized features
/// - Inactive user reminders
/// - Streak at risk warnings
class ReengagementAlertBanner extends ConsumerWidget {
  final bool isPremium;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  const ReengagementAlertBanner({
    super.key,
    this.isPremium = false,
    this.onAction,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertAsync = ref.watch(reengagementAlertProvider(isPremium));

    return alertAsync.when(
      data: (alert) {
        if (alert == null) return const SizedBox.shrink();
        return _buildAlert(context, ref, alert);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildAlert(BuildContext context, WidgetRef ref, ReengagementAlert alert) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color iconColor;
    IconData icon;

    switch (alert.type) {
      case AlertType.premiumUnderutilized:
        backgroundColor = theme.colorScheme.primaryContainer;
        iconColor = theme.colorScheme.primary;
        icon = Icons.workspace_premium;
        break;
      case AlertType.inactive:
        backgroundColor = Colors.orange.withValues(alpha: 0.2);
        iconColor = Colors.orange;
        icon = Icons.waving_hand;
        break;
      case AlertType.lowEngagement:
        backgroundColor = theme.colorScheme.secondaryContainer;
        iconColor = theme.colorScheme.secondary;
        icon = Icons.trending_up;
        break;
      case AlertType.streakAtRisk:
        backgroundColor = Colors.red.withValues(alpha: 0.2);
        iconColor = Colors.red;
        icon = Icons.local_fire_department;
        break;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alert.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      ref
                          .read(reengagementServiceProvider)
                          .markAlertShown(alert.type);
                      onDismiss?.call();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alert.message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {
                ref
                    .read(reengagementServiceProvider)
                    .markAlertShown(alert.type);
                onAction?.call();
              },
              child: Text(alert.actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// UC129: Time saved display widget.
class TimeSavedWidget extends ConsumerWidget {
  final bool showDetails;

  const TimeSavedWidget({super.key, this.showDetails = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(timeSavedStatsProvider);
    final theme = Theme.of(context);

    return statsAsync.when(
      data: (stats) {
        if (stats.totalMinutes < 1) return const SizedBox.shrink();

        return Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tempo economizado',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            stats.displayText,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (showDetails) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'Cards gerados com IA',
                    value: '${stats.aiCardsGenerated}',
                    icon: Icons.auto_awesome,
                  ),
                  _DetailRow(
                    label: 'Cards estudados',
                    value: '${stats.cardsStudied}',
                    icon: Icons.school,
                  ),
                  _DetailRow(
                    label: 'Sessoes de estudo',
                    value: '${stats.studySessions}',
                    icon: Icons.trending_up,
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
