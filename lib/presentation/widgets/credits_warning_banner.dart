import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/subscription_providers.dart';
import '../router/app_router.dart';

/// UC124: Visual alert for low AI credits.
///
/// Shows a banner when credits are running low (configurable threshold).
/// Can be placed at the top of relevant screens.
class CreditsWarningBanner extends ConsumerWidget {
  final int warningThreshold;
  final bool showWhenZero;
  final VoidCallback? onTap;

  const CreditsWarningBanner({
    super.key,
    this.warningThreshold = 5,
    this.showWhenZero = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(userSubscriptionProvider('user_id'));

    return subscriptionAsync.when(
      data: (subscription) {
        final credits = subscription.totalAiCredits;

        // Don't show if above threshold
        if (credits > warningThreshold) {
          return const SizedBox.shrink();
        }

        // Don't show zero state if disabled
        if (credits == 0 && !showWhenZero) {
          return const SizedBox.shrink();
        }

        return _buildBanner(context, credits, subscription.isPremium);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(BuildContext context, int credits, bool isPremium) {
    final theme = Theme.of(context);
    final isZero = credits == 0;

    final backgroundColor = isZero
        ? theme.colorScheme.errorContainer
        : Colors.orange.withValues(alpha: 0.2);

    final textColor = isZero
        ? theme.colorScheme.onErrorContainer
        : Colors.orange.shade800;

    final icon = isZero ? Icons.warning_amber : Icons.info_outline;

    final message = isZero
        ? 'Sem creditos IA'
        : 'Apenas $credits credito(s) restante(s)';

    final actionLabel = isZero
        ? (isPremium ? 'Comprar mais' : 'Obter creditos')
        : 'Ver opcoes';

    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap ?? () => context.push(AppRoutes.subscriptionCredits),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                actionLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 18, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// UC124: Animated credits counter with color change.
class AnimatedCreditsCounter extends StatelessWidget {
  final int credits;
  final int warningThreshold;
  final int criticalThreshold;
  final TextStyle? style;

  const AnimatedCreditsCounter({
    super.key,
    required this.credits,
    this.warningThreshold = 5,
    this.criticalThreshold = 2,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color color;
    if (credits == 0) {
      color = theme.colorScheme.error;
    } else if (credits <= criticalThreshold) {
      color = Colors.red;
    } else if (credits <= warningThreshold) {
      color = Colors.orange;
    } else {
      color = theme.colorScheme.primary;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: credits.toDouble(), end: credits.toDouble()),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              '${value.round()}',
              style: (style ?? theme.textTheme.bodyMedium)?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// UC124: Credits progress bar showing remaining vs total.
class CreditsProgressBar extends StatelessWidget {
  final int current;
  final int max;
  final double height;

  const CreditsProgressBar({
    super.key,
    required this.current,
    required this.max,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

    Color progressColor;
    if (progress == 0) {
      progressColor = theme.colorScheme.error;
    } else if (progress < 0.2) {
      progressColor = Colors.red;
    } else if (progress < 0.4) {
      progressColor = Colors.orange;
    } else {
      progressColor = theme.colorScheme.primary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: height,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(progressColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$current de $max creditos',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
