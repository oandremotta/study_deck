import 'package:flutter/material.dart';

import '../../domain/entities/subscription.dart';

/// UC143: Celebration dialog shown after successful premium upgrade.
///
/// Reinforces the user's decision with:
/// - Celebratory animation
/// - List of unlocked features
/// - Encouragement to use new features
class PremiumCelebrationDialog extends StatefulWidget {
  final SubscriptionPlan plan;
  final VoidCallback? onDismiss;

  const PremiumCelebrationDialog({
    super.key,
    required this.plan,
    this.onDismiss,
  });

  /// Show the celebration dialog.
  static Future<void> show(BuildContext context, {required SubscriptionPlan plan}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PremiumCelebrationDialog(plan: plan),
    );
  }

  @override
  State<PremiumCelebrationDialog> createState() => _PremiumCelebrationDialogState();
}

class _PremiumCelebrationDialogState extends State<PremiumCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final features = PlanFeatures.forPlan(widget.plan);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Celebration icon with animation
                    _AnimatedIcon(),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Parabens!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Voce agora e Premium!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Unlocked features
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recursos desbloqueados:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _UnlockedFeature(
                            icon: Icons.folder_copy,
                            text: 'Decks ilimitados',
                          ),
                          _UnlockedFeature(
                            icon: Icons.style,
                            text: 'Cards ilimitados',
                          ),
                          _UnlockedFeature(
                            icon: Icons.auto_awesome,
                            text: '${features.aiCreditsPerMonth} creditos IA/mes',
                          ),
                          _UnlockedFeature(
                            icon: Icons.cloud_upload,
                            text: 'Backup na nuvem',
                          ),
                          _UnlockedFeature(
                            icon: Icons.volume_up,
                            text: 'Audio e TTS',
                          ),
                          _UnlockedFeature(
                            icon: Icons.block,
                            text: 'Sem anuncios',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // CTA button
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onDismiss?.call();
                      },
                      icon: const Icon(Icons.rocket_launch),
                      label: const Text('Comecar a usar!'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedIcon extends StatefulWidget {
  @override
  State<_AnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.1),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 20 + (_controller.value * 10),
                  spreadRadius: 5 + (_controller.value * 5),
                ),
              ],
            ),
            child: Icon(
              Icons.workspace_premium,
              size: 48,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        );
      },
    );
  }
}

class _UnlockedFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _UnlockedFeature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Icon(
            Icons.check_circle,
            size: 18,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
