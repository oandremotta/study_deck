import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/user_stats.dart';
import '../../providers/study_providers.dart';

/// Stats and progress screen (UC29, UC30, UC32).
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(watchUserStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatisticas'),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) {
          debugPrint('Stats error: $e\n$stack');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: context.colorScheme.error),
                const SizedBox(height: 16),
                const Text('Erro ao carregar estatisticas'),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => ref.invalidate(watchUserStatsProvider),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        },
        data: (stats) => _StatsContent(stats: stats),
      ),
    );
  }
}

class _StatsContent extends ConsumerWidget {
  final UserStats stats;

  const _StatsContent({required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelInfo = LevelInfo.forLevel(stats.level);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Level and XP Card
        _LevelCard(stats: stats, levelInfo: levelInfo),
        const SizedBox(height: 16),

        // Streak Card (with freeze indicator - UC34)
        _StreakCard(stats: stats),
        const SizedBox(height: 16),

        // Weekly Challenges Card (UC33)
        _WeeklyChallengesCard(stats: stats),
        const SizedBox(height: 16),

        // Daily Goals Card
        _DailyGoalsCard(stats: stats),
        const SizedBox(height: 16),

        // Overall Stats Card
        _OverallStatsCard(stats: stats),
      ],
    );
  }
}

/// Card showing level and XP progress (UC32).
class _LevelCard extends StatelessWidget {
  final UserStats stats;
  final LevelInfo levelInfo;

  const _LevelCard({required this.stats, required this.levelInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${stats.level}',
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: context.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        levelInfo.title,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${stats.totalXp} XP total',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // XP Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Proximo nivel',
                      style: context.textTheme.bodySmall,
                    ),
                    Text(
                      '${stats.xpInCurrentLevel}/${stats.xpForNextLevel} XP',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: stats.levelProgress / 100,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card showing streak information.
class _StreakCard extends StatelessWidget {
  final UserStats stats;

  const _StreakCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isActive = stats.streakActiveToday;
    final isAtRisk = stats.streakAtRisk && !isActive;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: isActive
                      ? Colors.orange
                      : isAtRisk
                          ? Colors.yellow.shade700
                          : context.colorScheme.outline,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stats.currentStreak} dias',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isActive
                            ? 'Sequencia mantida hoje!'
                            : isAtRisk
                                ? 'Estude hoje para manter a sequencia!'
                                : 'Comece uma nova sequencia',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: isAtRisk ? Colors.orange : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StreakStat(
                  label: 'Recorde',
                  value: '${stats.longestStreak} dias',
                  icon: Icons.emoji_events,
                ),
                const SizedBox(width: 24),
                _StreakStat(
                  label: 'Ultimo estudo',
                  value: stats.lastStudyDate != null
                      ? _formatDate(stats.lastStudyDate!)
                      : 'Nunca',
                  icon: Icons.calendar_today,
                ),
              ],
            ),
            // UC34: Streak freeze indicator
            if (stats.hasStreakFreeze) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.ac_unit, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${stats.streakFreezes} congelamento${stats.streakFreezes > 1 ? 's' : ''} disponivel${stats.streakFreezes > 1 ? 'is' : ''}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) return 'Hoje';
    if (dateDay == today.subtract(const Duration(days: 1))) return 'Ontem';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Card showing weekly challenges (UC33).
class _WeeklyChallengesCard extends StatelessWidget {
  final UserStats stats;

  const _WeeklyChallengesCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final allComplete = stats.allWeeklyChallengesMet;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag,
                  color: allComplete ? Colors.green : context.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Desafios da semana',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (allComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Completo!',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Cards challenge
            _ChallengeProgress(
              title: 'Estudar ${stats.weeklyCardsGoal} cards',
              current: stats.weeklyCardsStudied,
              goal: stats.weeklyCardsGoal,
              icon: Icons.style,
              isComplete: stats.weeklyCardsChallengeMet,
            ),
            const SizedBox(height: 12),
            // Sessions challenge
            _ChallengeProgress(
              title: 'Completar ${stats.weeklySessionsGoal} sessoes',
              current: stats.weeklySessionsCompleted,
              goal: stats.weeklySessionsGoal,
              icon: Icons.playlist_add_check,
              isComplete: stats.weeklySessionsChallengeMet,
            ),
            const SizedBox(height: 12),
            // Week info
            Text(
              _getWeekInfo(stats.weekStartDate),
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekInfo(DateTime? weekStart) {
    if (weekStart == null) return 'Semana atual';
    final now = DateTime.now();
    final endOfWeek = weekStart.add(const Duration(days: 6));
    final daysLeft = endOfWeek.difference(now).inDays;
    if (daysLeft <= 0) return 'Ultima semana terminou';
    if (daysLeft == 1) return 'Falta 1 dia para resetar';
    return 'Faltam $daysLeft dias para resetar';
  }
}

class _ChallengeProgress extends StatelessWidget {
  final String title;
  final int current;
  final int goal;
  final IconData icon;
  final bool isComplete;

  const _ChallengeProgress({
    required this.title,
    required this.current,
    required this.goal,
    required this.icon,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isComplete
                ? Colors.green.shade100
                : context.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isComplete ? Icons.check : icon,
            size: 20,
            color: isComplete
                ? Colors.green.shade700
                : context.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      decoration: isComplete ? TextDecoration.lineThrough : null,
                      color: isComplete ? context.colorScheme.onSurfaceVariant : null,
                    ),
                  ),
                  Text(
                    '$current/$goal',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isComplete ? Colors.green : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
                backgroundColor: context.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  isComplete ? Colors.green : context.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StreakStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colorScheme.outline),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: context.textTheme.labelSmall),
            Text(value, style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

/// Card showing daily goals with edit option (UC29).
class _DailyGoalsCard extends ConsumerWidget {
  final UserStats stats;

  const _DailyGoalsCard({required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Metas diarias',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showGoalsDialog(context, ref),
                  tooltip: 'Editar metas',
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Cards goal
            _GoalProgress(
              label: 'Cards estudados',
              current: stats.todayCards,
              goal: stats.dailyGoalCards,
              icon: Icons.style,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            // Time goal
            _GoalProgress(
              label: 'Minutos de estudo',
              current: stats.todayMinutes,
              goal: stats.dailyGoalMinutes,
              icon: Icons.timer,
              color: context.colorScheme.secondary,
            ),
            if (stats.dailyGoalMet) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Meta diaria alcancada!',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showGoalsDialog(BuildContext context, WidgetRef ref) {
    int cardsGoal = stats.dailyGoalCards;
    int minutesGoal = stats.dailyGoalMinutes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Definir metas diarias'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cards slider
              Row(
                children: [
                  const Icon(Icons.style, size: 20),
                  const SizedBox(width: 8),
                  Text('Cards: $cardsGoal'),
                ],
              ),
              Slider(
                value: cardsGoal.toDouble(),
                min: 5,
                max: 100,
                divisions: 19,
                label: '$cardsGoal cards',
                onChanged: (v) => setState(() => cardsGoal = v.round()),
              ),
              const SizedBox(height: 16),
              // Minutes slider
              Row(
                children: [
                  const Icon(Icons.timer, size: 20),
                  const SizedBox(width: 8),
                  Text('Minutos: $minutesGoal'),
                ],
              ),
              Slider(
                value: minutesGoal.toDouble(),
                min: 5,
                max: 60,
                divisions: 11,
                label: '$minutesGoal min',
                onChanged: (v) => setState(() => minutesGoal = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await ref
                    .read(userGoalsNotifierProvider.notifier)
                    .updateGoals(cards: cardsGoal, minutes: minutesGoal);
                if (context.mounted) {
                  if (success) {
                    context.showSnackBar('Metas atualizadas!');
                  } else {
                    context.showErrorSnackBar('Erro ao atualizar metas');
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalProgress extends StatelessWidget {
  final String label;
  final int current;
  final int goal;
  final IconData icon;
  final Color color;

  const _GoalProgress({
    required this.label,
    required this.current,
    required this.goal,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final isComplete = current >= goal;

    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: context.textTheme.bodyMedium),
                  Text(
                    '$current / $goal',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isComplete ? Colors.green : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(
                  isComplete ? Colors.green : color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Card showing overall statistics (UC30).
class _OverallStatsCard extends StatelessWidget {
  final UserStats stats;

  const _OverallStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatisticas gerais',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.style,
                    label: 'Cards estudados',
                    value: '${stats.totalCardsStudied}',
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    icon: Icons.playlist_add_check,
                    label: 'Sessoes',
                    value: '${stats.totalSessionsCompleted}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.timer,
                    label: 'Tempo total',
                    value: _formatDuration(stats.totalStudyTime),
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    icon: Icons.speed,
                    label: 'Media/sessao',
                    value: stats.totalSessionsCompleted > 0
                        ? '${(stats.totalCardsStudied / stats.totalSessionsCompleted).round()} cards'
                        : '-',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.colorScheme.outline),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
