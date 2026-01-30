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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Celebration icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.celebration,
              size: 64,
              color: context.colorScheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            'Sessao Concluida!',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            session.mode.displayName,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 32),

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
        // Study more button
        FilledButton.icon(
          onPressed: () {
            ref.read(studyNotifierProvider.notifier).clearSession();
            context.pushReplacement(
              '${AppRoutes.study}?mode=${session.mode.name}${session.deckId != null ? '&deckId=${session.deckId}' : ''}',
            );
          },
          icon: const Icon(Icons.replay),
          label: const Text('Estudar mais'),
        ),

        const SizedBox(height: 12),

        // Turbo mode suggestion
        if (session.mode != StudyMode.turbo)
          OutlinedButton.icon(
            onPressed: () {
              ref.read(studyNotifierProvider.notifier).clearSession();
              context.pushReplacement(
                '${AppRoutes.study}?mode=turbo${session.deckId != null ? '&deckId=${session.deckId}' : ''}',
              );
            },
            icon: const Icon(Icons.bolt),
            label: const Text('Modo Turbo (3 min)'),
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
