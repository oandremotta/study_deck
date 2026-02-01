import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/ai_credit.dart';
import '../../../domain/entities/subscription.dart';
import '../../../domain/entities/user_stats.dart';
import '../../providers/ai_credits_providers.dart';
import '../../providers/app_preferences_provider.dart';
import '../../providers/auth_providers.dart';
import '../../providers/home_providers.dart';
import '../../providers/study_providers.dart';
import '../../providers/subscription_providers.dart';
import '../../router/app_router.dart';

/// Main home screen with improved UX (EP10-EP16, UC65, UC66).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isAnonymous = ref.watch(isAnonymousProvider);
    final statsAsync = ref.watch(watchUserStatsProvider);
    final summaryAsync = ref.watch(homeSummaryProvider);
    final layoutMode = ref.watch(layoutModeProvider);

    // Extract due/new cards from summary (defaults to 0 if loading/error)
    final summary = summaryAsync.valueOrNull;
    final dueCards = summary?.totalDueCards ?? 0;
    final newCards = summary?.totalNewCards ?? 0;
    final nextReviewTime = summary?.nextReviewTime;
    final isCompact = layoutMode == LayoutMode.compact;
    final stats = statsAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Deck'),
        actions: [
          // UC60: Layout mode toggle
          IconButton(
            icon: Icon(isCompact ? Icons.view_agenda : Icons.view_compact),
            tooltip: isCompact ? 'Modo completo' : 'Modo compacto',
            onPressed: () => ref.read(layoutModeProvider.notifier).toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => _showAccountMenu(context, ref, isAnonymous),
          ),
        ],
        // UC65: Compact status line in AppBar bottom
        bottom: stats != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(32),
                child: _HeaderStatusLine(stats: stats),
              )
            : null,
      ),
      body: statsAsync.when(
        loading: () => _HomeBody(
          stats: null,
          userName: currentUser?.displayName,
          isAnonymous: isAnonymous,
          dueCards: dueCards,
          newCards: newCards,
          nextReviewTime: nextReviewTime,
          isCompact: isCompact,
        ),
        error: (_, __) => _HomeBody(
          stats: null,
          userName: currentUser?.displayName,
          isAnonymous: isAnonymous,
          dueCards: dueCards,
          newCards: newCards,
          nextReviewTime: nextReviewTime,
          isCompact: isCompact,
        ),
        data: (stats) => _HomeBody(
          stats: stats,
          userName: currentUser?.displayName,
          isAnonymous: isAnonymous,
          dueCards: dueCards,
          newCards: newCards,
          nextReviewTime: nextReviewTime,
          isCompact: isCompact,
        ),
      ),
    );
  }

  void _showAccountMenu(BuildContext context, WidgetRef ref, bool isAnonymous) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Configuracoes'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.settings);
              },
            ),
            const Divider(),
            if (isAnonymous)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Criar conta / Entrar'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.login);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () async {
                  Navigator.pop(context);
                  final authRepo = ref.read(authRepositoryProvider);
                  await authRepo.signOut();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final UserStats? stats;
  final String? userName;
  final bool isAnonymous;
  final int dueCards;
  final int newCards;
  final DateTime? nextReviewTime;
  final bool isCompact;

  const _HomeBody({
    this.stats,
    this.userName,
    required this.isAnonymous,
    this.dueCards = 0,
    this.newCards = 0,
    this.nextReviewTime,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // UC60: Compact vs Expanded layout
    if (isCompact) {
      return _buildCompactLayout(context);
    }
    return _buildExpandedLayout(context);
  }

  /// Compact layout - minimal info, focused on CTA
  Widget _buildCompactLayout(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Simple greeting (no subtitle)
        Text(
          userName != null ? 'Ola, $userName!' : 'Bem-vindo!',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // CTA button (simplified)
        _MainCtaButton(stats: stats, dueCards: dueCards, newCards: newCards),
        const SizedBox(height: 16),

        // Compact progress row (if stats available)
        if (stats != null) _CompactProgressRow(stats: stats!),

        const SizedBox(height: 16),

        // UC201: Plan status shortcut (compact)
        const _PlanStatusCard(),
        const SizedBox(height: 16),

        // Quick actions (2x2 grid)
        _QuickActionsSection(),
      ],
    );
  }

  /// Expanded layout - full metrics and details
  Widget _buildExpandedLayout(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // UC59: Contextual greeting message
        _GreetingSection(
          userName: userName,
          stats: stats,
        ),
        const SizedBox(height: 20),

        // UC44: Main CTA Button - prominent "Estudar agora"
        _MainCtaButton(stats: stats, dueCards: dueCards, newCards: newCards),

        // UC67/UC68: Urgency nudge with next review time (below CTA)
        if (dueCards > 0 || newCards > 0 || nextReviewTime != null) ...[
          const SizedBox(height: 8),
          _UrgencyNudge(
            dueCards: dueCards,
            newCards: newCards,
            nextReviewTime: nextReviewTime,
          ),
        ],

        const SizedBox(height: 20),

        // UC45 & UC46: Progress and Streak section
        if (stats != null) ...[
          _ProgressSection(stats: stats!),
          const SizedBox(height: 20),
        ],

        // Anonymous user warning
        if (isAnonymous) ...[
          _AnonymousWarning(),
          const SizedBox(height: 20),
        ],

        // UC201: Plan status shortcut
        const _PlanStatusCard(),
        const SizedBox(height: 20),

        // Quick actions
        _QuickActionsSection(),
      ],
    );
  }
}

/// UC65: Header status line with streak and daily progress.
class _HeaderStatusLine extends StatelessWidget {
  final UserStats stats;

  const _HeaderStatusLine({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Streak indicator - tappable
          InkWell(
            onTap: () => context.push(AppRoutes.stats),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: stats.currentStreak > 0
                    ? Colors.orange.withValues(alpha: 0.15)
                    : context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 16,
                    color: stats.currentStreak > 0 ? Colors.orange : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${stats.currentStreak} ${stats.currentStreak == 1 ? 'dia' : 'dias'}',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: stats.currentStreak > 0 ? Colors.orange.shade700 : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Daily progress indicator - tappable
          InkWell(
            onTap: () => context.push(AppRoutes.stats),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: stats.dailyGoalMet
                    ? Colors.green.withValues(alpha: 0.15)
                    : context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    stats.dailyGoalMet ? Icons.check_circle : Icons.flag_outlined,
                    size: 16,
                    color: stats.dailyGoalMet ? Colors.green : context.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${stats.todayCards}/${stats.dailyGoalCards} hoje',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: stats.dailyGoalMet ? Colors.green.shade700 : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// UC66: Contextual greeting with dynamic message (priority-based).
class _GreetingSection extends StatelessWidget {
  final String? userName;
  final UserStats? stats;

  const _GreetingSection({
    this.userName,
    this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final message = _getDynamicMessage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userName != null ? 'Ola, $userName!' : 'Bem-vindo!',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        // UC66: Tappable message triggers study flow
        InkWell(
          onTap: () => context.push(AppRoutes.study),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: _isHighPriorityMessage()
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurfaceVariant,
                fontWeight: _isHighPriorityMessage() ? FontWeight.w500 : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// UC66: Priority-based message selection
  String _getDynamicMessage() {
    if (stats == null) {
      return 'Pronto para estudar?';
    }

    final remaining = stats!.dailyGoalCards - stats!.todayCards;
    final progress = stats!.dailyCardProgress;

    // Priority 1: Goal completed today
    if (stats!.dailyGoalMet) {
      return 'Meta do dia concluida!';
    }

    // Priority 2: Few cards remaining (<= 20% of goal)
    if (progress >= 80 && remaining > 0) {
      return 'Faltam so $remaining para fechar hoje';
    }

    // Priority 3: No study today + has streak
    if (stats!.todayCards == 0 && stats!.currentStreak > 0) {
      return '3 minutos agora mantem sua sequencia';
    }

    // Priority 4: No study today + no streak
    if (stats!.todayCards == 0 && stats!.currentStreak == 0) {
      return 'Comece com 3 minutos hoje';
    }

    // Priority 5: Streak at risk
    if (stats!.streakAtRisk && stats!.currentStreak > 0) {
      return 'Sua sequencia de ${stats!.currentStreak} dias esta em risco!';
    }

    // Priority 6: Time-based greetings
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia! Pronto para estudar?';
    } else if (hour < 18) {
      return 'Boa tarde! Vamos revisar?';
    } else {
      return 'Boa noite! Feche o dia com 3 min';
    }
  }

  bool _isHighPriorityMessage() {
    if (stats == null) return false;
    // High priority: goal met, few remaining, or streak at risk
    return stats!.dailyGoalMet ||
        stats!.dailyCardProgress >= 80 ||
        (stats!.streakAtRisk && stats!.currentStreak > 0);
  }
}

/// UC44: Main CTA button with visual prominence.
class _MainCtaButton extends StatelessWidget {
  final UserStats? stats;
  final int dueCards;
  final int newCards;

  const _MainCtaButton({
    this.stats,
    this.dueCards = 0,
    this.newCards = 0,
  });

  String get _subtitle {
    final total = dueCards + newCards;
    if (total == 0) return 'Comece sua sessao de estudo';

    final parts = <String>[];
    if (dueCards > 0) parts.add('$dueCards para revisar');
    if (newCards > 0) parts.add('$newCards novos');
    return parts.join(' + ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: context.colorScheme.primaryContainer,
      child: InkWell(
        onTap: () {
          // UC69: Haptic feedback on tap
          HapticFeedback.mediumImpact();
          context.push(AppRoutes.study);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Play icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estudar agora',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: context.colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// UC45 & UC46: Progress and streak display.
class _ProgressSection extends StatelessWidget {
  final UserStats stats;

  const _ProgressSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Daily progress card - enhanced
        Expanded(
          child: _EnhancedProgressCard(stats: stats),
        ),
        const SizedBox(width: 12),
        // Streak card - enhanced
        Expanded(
          child: _EnhancedStreakCard(
            currentStreak: stats.currentStreak,
            longestStreak: stats.longestStreak,
            isAtRisk: stats.streakAtRisk,
            hasFreeze: stats.hasStreakFreeze,
            studiedToday: stats.todayCards > 0,
          ),
        ),
      ],
    );
  }
}

/// UC60: Compact progress row for minimal layout.
class _CompactProgressRow extends StatelessWidget {
  final UserStats stats;

  const _CompactProgressRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final progress = stats.dailyCardProgress / 100;
    final isComplete = stats.dailyGoalMet;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Progress indicator
            Expanded(
              child: Row(
                children: [
                  Icon(
                    isComplete ? Icons.check_circle : Icons.check_circle_outline,
                    color: isComplete ? Colors.green : context.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${stats.todayCards}/${stats.dailyGoalCards}',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isComplete ? Colors.green : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: context.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          isComplete ? Colors.green : context.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Streak
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: stats.currentStreak > 0 ? Colors.orange : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${stats.currentStreak}',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: stats.currentStreak > 0 ? Colors.orange : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Enhanced daily progress card with emotional microcopy.
class _EnhancedProgressCard extends StatelessWidget {
  final UserStats stats;

  const _EnhancedProgressCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final progress = stats.dailyCardProgress / 100;
    final isComplete = stats.dailyGoalMet;
    final progressColor = isComplete ? Colors.green : context.colorScheme.primary;

    return Card(
      color: isComplete ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isComplete ? Icons.check_circle : Icons.check_circle_outline,
                  color: progressColor,
                  size: 20,
                ),
                const Spacer(),
                if (isComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Concluido!',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Progresso diario',
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            // Big number display
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${stats.todayCards}',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
                Text(
                  ' / ${stats.dailyGoalCards}',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Enhanced progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: context.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
            const SizedBox(height: 6),
            // Emotional microcopy
            Text(
              _getMotivationalMessage(),
              style: context.textTheme.bodySmall?.copyWith(
                color: isComplete ? Colors.green.shade700 : context.colorScheme.onSurfaceVariant,
                fontWeight: isComplete ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMotivationalMessage() {
    final progress = stats.dailyCardProgress;
    final remaining = stats.dailyGoalCards - stats.todayCards;

    if (stats.dailyGoalMet) {
      return 'Parabens! Meta do dia alcancada!';
    }
    if (progress >= 75) {
      return 'Quase la! Faltam apenas $remaining cards.';
    }
    if (progress >= 50) {
      return 'Metade do caminho! Continue assim.';
    }
    if (progress >= 25) {
      return 'Bom comeco! $remaining cards restantes.';
    }
    if (stats.todayCards > 0) {
      return 'Continue! $remaining cards para a meta.';
    }
    return 'Comece agora para alcancar sua meta!';
  }
}

/// UC46: Enhanced streak card with emotional microcopy.
class _EnhancedStreakCard extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final bool isAtRisk;
  final bool hasFreeze;
  final bool studiedToday;

  const _EnhancedStreakCard({
    required this.currentStreak,
    required this.longestStreak,
    required this.isAtRisk,
    required this.hasFreeze,
    required this.studiedToday,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentStreak > 0;
    final fireColor = isActive ? Colors.orange : Colors.grey;

    return Card(
      color: isAtRisk && isActive
          ? Colors.orange.shade50
          : (studiedToday ? Colors.orange.shade50.withValues(alpha: 0.5) : null),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department, color: fireColor, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Sequencia',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (isAtRisk && isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Em risco!',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (hasFreeze)
                  Tooltip(
                    message: 'Protetor de sequencia disponivel',
                    child: Icon(Icons.ac_unit, color: Colors.blue.shade400, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Big streak number with label
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$currentStreak',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.orange : null,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  currentStreak == 1 ? 'dia ativo' : 'dias ativos',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Visual streak indicator (7 days)
            Row(
              children: List.generate(7, (index) {
                final isDay = index < currentStreak.clamp(0, 7);
                return Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(right: index < 6 ? 2 : 0),
                    decoration: BoxDecoration(
                      color: isDay ? Colors.orange : context.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            // Emotional microcopy
            Text(
              _getStreakMessage(),
              style: context.textTheme.bodySmall?.copyWith(
                color: isAtRisk && isActive
                    ? Colors.orange.shade700
                    : context.colorScheme.onSurfaceVariant,
                fontWeight: isAtRisk && isActive ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStreakMessage() {
    if (currentStreak == 0) {
      return 'Comece hoje sua sequencia!';
    }
    if (isAtRisk) {
      return 'Estude hoje para manter!';
    }
    if (studiedToday) {
      if (currentStreak >= 30) {
        return 'Incrivel! 1 mes de dedicacao!';
      }
      if (currentStreak >= 14) {
        return 'Fantastico! 2 semanas seguidas!';
      }
      if (currentStreak >= 7) {
        return 'Uma semana completa!';
      }
      if (currentStreak >= 3) {
        return 'Otimo ritmo! Continue assim!';
      }
      return 'Sequencia em construcao!';
    }
    if (currentStreak >= 7) {
      return 'Recorde: $longestStreak dias';
    }
    return 'Continue para crescer!';
  }
}

/// Anonymous user warning card.
class _AnonymousWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: context.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Seus dados estao salvos apenas neste dispositivo. '
              'Crie uma conta para sincronizar.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// UC67/UC68: Enhanced urgency nudge below CTA button.
/// Shows next review time and pending cards count.
/// Tappable to start review-only session.
class _UrgencyNudge extends StatelessWidget {
  final int dueCards;
  final int newCards;
  final DateTime? nextReviewTime;

  const _UrgencyNudge({
    required this.dueCards,
    required this.newCards,
    this.nextReviewTime,
  });

  @override
  Widget build(BuildContext context) {
    final total = dueCards + newCards;
    final hasNextReview = nextReviewTime != null;

    if (total == 0 && !hasNextReview) return const SizedBox.shrink();

    return InkWell(
      onTap: dueCards > 0
          ? () => context.push('${AppRoutes.study}?mode=reviewsToday')
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            // Primary message: due cards or next review time
            if (dueCards > 0)
              _buildInfoRow(
                context,
                icon: Icons.schedule,
                message: '$dueCards ${dueCards == 1 ? 'revisao pendente' : 'revisoes pendentes'}',
                color: Colors.orange.shade700,
                showArrow: true,
              )
            else if (hasNextReview)
              _buildInfoRow(
                context,
                icon: Icons.access_time,
                message: 'Proxima revisao ${_formatTimeUntil(nextReviewTime!)}',
                color: context.colorScheme.onSurfaceVariant,
                showArrow: false,
              ),

            // Secondary message: new cards if we showed due cards
            if (dueCards > 0 && newCards > 0) ...[
              const SizedBox(height: 4),
              _buildInfoRow(
                context,
                icon: Icons.auto_awesome,
                message: '+ $newCards novos cards',
                color: context.colorScheme.primary.withValues(alpha: 0.8),
                showArrow: false,
                isSecondary: true,
              ),
            ] else if (dueCards == 0 && newCards > 0) ...[
              _buildInfoRow(
                context,
                icon: Icons.auto_awesome,
                message: '$newCards novos cards esperando',
                color: context.colorScheme.primary,
                showArrow: false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String message,
    required Color color,
    required bool showArrow,
    bool isSecondary = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isSecondary ? 12 : 14, color: color),
        const SizedBox(width: 6),
        Text(
          message,
          style: context.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: isSecondary ? FontWeight.normal : FontWeight.w500,
            fontSize: isSecondary ? 11 : null,
          ),
        ),
        if (showArrow) ...[
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward_ios, size: 10, color: color),
        ],
      ],
    );
  }

  /// Formats time until next review in a friendly way.
  String _formatTimeUntil(DateTime nextReview) {
    final now = DateTime.now();
    final diff = nextReview.difference(now);

    if (diff.isNegative) {
      return 'agora';
    }

    if (diff.inMinutes < 1) {
      return 'em menos de 1 min';
    }

    if (diff.inMinutes < 60) {
      return 'em ${diff.inMinutes} min';
    }

    if (diff.inHours < 24) {
      final hours = diff.inHours;
      return 'em ${hours}h';
    }

    final days = diff.inDays;
    if (days == 1) {
      return 'amanha';
    }

    return 'em $days dias';
  }
}

/// UC106: "Minha biblioteca" section with action-oriented shortcuts.
class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minha biblioteca',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.style_outlined,
                label: 'Meus decks',
                onTap: () => context.push(AppRoutes.decks),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.folder_outlined,
                label: 'Assuntos',
                onTap: () => context.push(AppRoutes.folders),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.bar_chart_rounded,
                label: 'Meu progresso',
                onTap: () => context.push(AppRoutes.stats),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.label_outline,
                label: 'Organizar tags',
                onTap: () => context.push(AppRoutes.tags),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // AI Cards generation button
        _AiCardsCard(),
      ],
    );
  }
}

/// UC202, UC207: AI Cards generation card with credit status and limit badge.
class _AiCardsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Get actual userId from auth
    const userId = 'user_id';
    final subscriptionAsync = ref.watch(userSubscriptionProvider(userId));

    return subscriptionAsync.when(
      data: (subscription) => _buildCard(context, subscription),
      loading: () => _buildCard(context, null),
      error: (_, __) => _buildCard(context, null),
    );
  }

  Widget _buildCard(BuildContext context, UserSubscription? subscription) {
    final credits = subscription?.totalAiCredits ?? 0;
    final hasCredits = credits > 0;

    return Card(
      color: hasCredits
          ? context.colorScheme.tertiaryContainer
          : context.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => context.push(AppRoutes.aiCardsHub),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon with optional lock overlay
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: hasCredits
                          ? context.colorScheme.tertiary.withValues(alpha: 0.15)
                          : context.colorScheme.outline.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 28,
                      color: hasCredits
                          ? context.colorScheme.tertiary
                          : context.colorScheme.outline,
                    ),
                  ),
                  // UC202: Lock badge when no credits
                  if (!hasCredits)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: context.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Gerar Cards com IA',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: hasCredits
                                ? context.colorScheme.onTertiaryContainer
                                : context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        // UC202: Badge when no credits
                        if (!hasCredits) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Sem creditos',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Show credit count or upgrade message
                    Text(
                      hasCredits
                          ? '$credits credito${credits == 1 ? '' : 's'} disponivel'
                          : 'Assista anuncio ou faca upgrade',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: hasCredits
                            ? context.colorScheme.onTertiaryContainer
                                .withValues(alpha: 0.8)
                            : context.colorScheme.error,
                        fontWeight: hasCredits ? null : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: hasCredits
                    ? context.colorScheme.onTertiaryContainer
                    : context.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// UC201: Plan status card showing subscription and AI credits.
class _PlanStatusCard extends ConsumerWidget {
  const _PlanStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isPremium = ref.watch(isPremiumUserProvider);
    final balanceAsync = ref.watch(aiCreditBalanceProvider);

    // Visitante
    if (user == null) {
      return _buildVisitorCard(context);
    }

    return balanceAsync.when(
      data: (balance) => _buildCard(context, balance, isPremium),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildVisitorCard(BuildContext context) {
    return Card(
      color: context.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => context.push(AppRoutes.subscriptionCredits),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Plan badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: context.colorScheme.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Visitante',
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Message
              Expanded(
                child: Text(
                  'Crie conta para salvar creditos',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              // CTA
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Entrar',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, AiCreditBalance? balance, bool isPremium) {
    final credits = balance?.available ?? 0;
    final fromAds = balance?.adsWatchedToday ?? 0;

    return Card(
      color: isPremium
          ? context.colorScheme.primaryContainer
          : context.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => context.push(
          isPremium ? AppRoutes.subscriptionSettings : AppRoutes.subscriptionCredits,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Plan badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isPremium
                      ? context.colorScheme.primary
                      : context.colorScheme.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPremium ? Icons.workspace_premium : Icons.person,
                      size: 16,
                      color: isPremium
                          ? Colors.white
                          : context.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPremium ? 'Premium' : 'Gratuito',
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPremium
                            ? Colors.white
                            : context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // AI Credits info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPremium ? Icons.all_inclusive : Icons.auto_awesome,
                          size: 16,
                          color: isPremium
                              ? context.colorScheme.onPrimaryContainer
                              : credits > 0
                                  ? context.colorScheme.tertiary
                                  : context.colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPremium ? 'IA ilimitada' : '$credits creditos IA',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: isPremium
                                ? context.colorScheme.onPrimaryContainer
                                : credits > 0
                                    ? context.colorScheme.onSurfaceVariant
                                    : context.colorScheme.error,
                            fontWeight: credits == 0 && !isPremium ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    ),
                    // Origem dos creditos (apenas para usuarios gratuitos com creditos)
                    if (!isPremium && credits > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          fromAds > 0 ? 'ganhos com anuncios' : 'disponiveis',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    // Microcopy para upgrade (usuarios gratuitos)
                    if (!isPremium && credits == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'assista anuncio ou faca upgrade',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.error.withValues(alpha: 0.8),
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // CTA for free users
              if (!isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Mais',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: context.colorScheme.onPrimaryContainer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
