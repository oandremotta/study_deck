import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/study_session.dart';
import '../../../domain/entities/user_stats.dart';
import '../../providers/study_providers.dart';
import '../../router/app_router.dart';

/// Screen showing session results after completing a study session.
///
/// Implements UC25 (Finalizar sessao e mostrar resumo).
class SessionSummaryScreen extends ConsumerWidget {
  final String sessionId;

  const SessionSummaryScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionByIdProvider(sessionId));
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: sessionAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e')),
          data: (session) {
            if (session == null) {
              return const Center(child: Text('Sessao nao encontrada'));
            }

            return statsAsync.when(
              loading: () => _buildContent(context, ref, session, null),
              error: (_, __) => _buildContent(context, ref, session, null),
              data: (stats) => _buildContent(context, ref, session, stats),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    StudySession session,
    UserStats? stats,
  ) {
    // UC50 & UC51: Determine celebration level
    final celebrationInfo = _getCelebrationInfo(stats);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // UC50: Enhanced celebration based on achievement
          _CelebrationHeader(
            celebrationInfo: celebrationInfo,
            sessionMode: session.mode.displayName,
          ),

          const SizedBox(height: 32),

          // UC51: Milestone achievement cards
          if (celebrationInfo.milestone != null)
            _MilestoneCard(milestone: celebrationInfo.milestone!),

          if (celebrationInfo.milestone != null) const SizedBox(height: 16),

          // Stats cards
          _buildStatsGrid(context, session, stats),

          const SizedBox(height: 24),

          // XP earned
          _buildXpCard(context, session, stats),

          const SizedBox(height: 24),

          // Streak info
          if (stats != null) _buildStreakCard(context, stats),

          const SizedBox(height: 32),

          // Action buttons
          _buildActionButtons(context, ref, session),
        ],
      ),
    );
  }

  _CelebrationInfo _getCelebrationInfo(UserStats? stats) {
    if (stats == null) {
      return const _CelebrationInfo(
        icon: Icons.celebration,
        title: 'Sessao Concluida!',
        subtitle: 'Continue assim!',
        color: null,
        milestone: null,
      );
    }

    // UC50: Check if daily goal was just met
    if (stats.dailyGoalMet) {
      return _CelebrationInfo(
        icon: Icons.emoji_events,
        title: 'Meta Diaria Alcancada!',
        subtitle: 'Voce completou ${stats.todayCards} cards hoje!',
        color: Colors.amber,
        milestone: _Milestone.dailyGoal,
      );
    }

    // UC51: Check progress milestones
    final progress = stats.dailyCardProgress;
    if (progress >= 75) {
      return const _CelebrationInfo(
        icon: Icons.trending_up,
        title: 'Quase la!',
        subtitle: 'Falta pouco para a meta diaria!',
        color: Colors.orange,
        milestone: _Milestone.progress75,
      );
    } else if (progress >= 50) {
      return const _CelebrationInfo(
        icon: Icons.star_half,
        title: 'Metade do Caminho!',
        subtitle: 'Continue, voce esta indo muito bem!',
        color: Colors.blue,
        milestone: _Milestone.progress50,
      );
    } else if (progress >= 25) {
      return const _CelebrationInfo(
        icon: Icons.rocket_launch,
        title: 'Bom Comeco!',
        subtitle: 'Ja completou 25% da meta!',
        color: Colors.green,
        milestone: _Milestone.progress25,
      );
    }

    return const _CelebrationInfo(
      icon: Icons.celebration,
      title: 'Sessao Concluida!',
      subtitle: 'Continue estudando!',
      color: null,
      milestone: null,
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    StudySession session,
    UserStats? stats,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.style,
            label: 'Cards Revisados',
            value: '${session.reviewedCards}',
            color: context.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.timer,
            label: 'Tempo',
            value: _formatDuration(session.totalTime),
            color: context.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXpCard(
    BuildContext context,
    StudySession session,
    UserStats? stats,
  ) {
    return Card(
      color: context.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Text(
                  '+${session.xpEarned} XP',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            if (stats != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nivel ${stats.level}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    '${stats.xpInCurrentLevel}/${stats.xpForNextLevel} XP',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: stats.levelProgress / 100,
                backgroundColor: context.colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(
                  context.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, UserStats stats) {
    final levelInfo = LevelInfo.forLevel(stats.level);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Streak
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
                      const SizedBox(width: 4),
                      Text(
                        '${stats.currentStreak}',
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'dias seguidos',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: 1,
              height: 40,
              color: context.colorScheme.outlineVariant,
            ),

            // Level title
            Expanded(
              child: Column(
                children: [
                  Text(
                    levelInfo.badgeEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  Text(
                    levelInfo.title,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
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

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    StudySession session,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // UC72: Primary CTA - "Mais 3 minutos" quick session
        FilledButton.icon(
          onPressed: () {
            ref.read(studyNotifierProvider.notifier).clearSession();
            context.pushReplacement(
              '${AppRoutes.study}?mode=turbo${session.deckId != null ? '&deckId=${session.deckId}' : ''}',
            );
          },
          icon: const Icon(Icons.bolt),
          label: const Text('Mais 3 minutos'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),

        const SizedBox(height: 12),

        // Study more with same mode (secondary option)
        OutlinedButton.icon(
          onPressed: () {
            ref.read(studyNotifierProvider.notifier).clearSession();
            context.pushReplacement(
              '${AppRoutes.study}?mode=${session.mode.name}${session.deckId != null ? '&deckId=${session.deckId}' : ''}',
            );
          },
          icon: const Icon(Icons.replay),
          label: Text(
            session.mode == StudyMode.turbo
                ? 'Mais uma sessao rapida'
                : 'Continuar estudando',
          ),
        ),

        const SizedBox(height: 12),

        // Go home
        TextButton(
          onPressed: () {
            ref.read(studyNotifierProvider.notifier).clearSession();
            context.go(AppRoutes.home);
          },
          child: const Text('Voltar ao inicio'),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}

// ==================== UC50 & UC51: Celebration Components ====================

/// Milestone types for progress tracking.
enum _Milestone {
  progress25,
  progress50,
  progress75,
  dailyGoal,
}

/// Info for celebration display.
class _CelebrationInfo {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final _Milestone? milestone;

  const _CelebrationInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    this.milestone,
  });
}

/// UC50: Enhanced celebration header based on achievement.
class _CelebrationHeader extends StatelessWidget {
  final _CelebrationInfo celebrationInfo;
  final String sessionMode;

  const _CelebrationHeader({
    required this.celebrationInfo,
    required this.sessionMode,
  });

  @override
  Widget build(BuildContext context) {
    final color = celebrationInfo.color ?? context.colorScheme.primary;

    return Column(
      children: [
        // Animated celebration icon
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  celebrationInfo.icon,
                  size: 64,
                  color: color,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        // Title with fade in
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Text(
                celebrationInfo.title,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: celebrationInfo.milestone == _Milestone.dailyGoal
                      ? color
                      : null,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          celebrationInfo.subtitle,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          sessionMode,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// UC51: Milestone achievement card.
class _MilestoneCard extends StatelessWidget {
  final _Milestone milestone;

  const _MilestoneCard({required this.milestone});

  @override
  Widget build(BuildContext context) {
    final (message, icon, color) = _getMilestoneDetails();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Card(
              color: color.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
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

  (String, IconData, Color) _getMilestoneDetails() {
    switch (milestone) {
      case _Milestone.dailyGoal:
        return ('Meta diaria conquistada!', Icons.emoji_events, Colors.amber.shade700);
      case _Milestone.progress75:
        return ('75% da meta - quase la!', Icons.trending_up, Colors.orange);
      case _Milestone.progress50:
        return ('50% da meta - continue!', Icons.star_half, Colors.blue);
      case _Milestone.progress25:
        return ('25% da meta - bom inicio!', Icons.rocket_launch, Colors.green);
    }
  }
}
