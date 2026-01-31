import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';

/// UC168-170: Educator dashboard overview.
///
/// Shows:
/// - All classrooms summary
/// - Overall statistics
/// - Recent activity across all classes
/// - Quick actions
class EducatorDashboardScreen extends ConsumerWidget {
  const EducatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Educador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeCard(),
            const SizedBox(height: 24),
            _QuickActions(),
            const SizedBox(height: 24),
            Text(
              'Resumo geral',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _OverviewStats(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Minhas turmas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.classroomList),
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ClassroomsList(),
            const SizedBox(height: 24),
            Text(
              'Atividade recente',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _RecentActivityList(),
            const SizedBox(height: 24),
            Text(
              'Alunos que precisam de atencao',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _StudentsNeedingAttention(),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Bom dia';
    } else if (hour < 18) {
      greeting = 'Boa tarde';
    } else {
      greeting = 'Boa noite';
    }

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, Professor!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seus alunos estudaram 245 cards hoje.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.school,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.add_circle,
            label: 'Nova turma',
            onTap: () {
              // TODO: Create classroom
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.folder_copy,
            label: 'Atribuir deck',
            onTap: () {
              // TODO: Assign deck
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.analytics,
            label: 'Relatorios',
            onTap: () {
              // TODO: View reports
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.class_,
            value: '3',
            label: 'Turmas',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.people,
            value: '75',
            label: 'Alunos',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.folder,
            value: '12',
            label: 'Decks',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
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

class _ClassroomsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: Replace with actual data
    final classrooms = [
      {'name': 'Biologia 3A', 'students': 25, 'progress': 0.72},
      {'name': 'Quimica 2B', 'students': 28, 'progress': 0.58},
      {'name': 'Fisica 1C', 'students': 22, 'progress': 0.45},
    ];

    return Column(
      children: classrooms.map((classroom) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.class_,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(classroom['name'] as String),
            subtitle: Row(
              children: [
                Text('${classroom['students']} alunos'),
                const SizedBox(width: 16),
                Expanded(
                  child: LinearProgressIndicator(
                    value: classroom['progress'] as double,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${((classroom['progress'] as double) * 100).round()}%',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to classroom detail
            },
          ),
        );
      }).toList(),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: Replace with actual data
    final activities = [
      {
        'student': 'Ana Silva',
        'action': 'completou 15 cards',
        'classroom': 'Biologia 3A',
        'time': 'ha 5 min',
      },
      {
        'student': 'Bruno Costa',
        'action': 'iniciou nova sessao',
        'classroom': 'Quimica 2B',
        'time': 'ha 12 min',
      },
      {
        'student': 'Carla Santos',
        'action': 'atingiu 7 dias de sequencia',
        'classroom': 'Fisica 1C',
        'time': 'ha 30 min',
      },
    ];

    return Card(
      child: Column(
        children: activities.map((activity) {
          return ListTile(
            leading: CircleAvatar(
              child: Text((activity['student'] as String)[0]),
            ),
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: activity['student'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' ${activity['action']}'),
                ],
              ),
            ),
            subtitle: Text(activity['classroom'] as String),
            trailing: Text(
              activity['time'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StudentsNeedingAttention extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: Replace with actual data
    final students = [
      {
        'name': 'Pedro Lima',
        'issue': 'Inativo ha 5 dias',
        'classroom': 'Biologia 3A',
        'type': 'inactive',
      },
      {
        'name': 'Julia Ferreira',
        'issue': 'Precisao baixa (45%)',
        'classroom': 'Quimica 2B',
        'type': 'struggling',
      },
    ];

    if (students.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              const Text('Todos os alunos estao no caminho certo!'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: students.map((student) {
        final isInactive = student['type'] == 'inactive';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isInactive
              ? Colors.orange.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
          child: ListTile(
            leading: Icon(
              isInactive ? Icons.schedule : Icons.trending_down,
              color: isInactive ? Colors.orange : Colors.red,
            ),
            title: Text(student['name'] as String),
            subtitle: Text(student['issue'] as String),
            trailing: FilledButton.tonal(
              onPressed: () {
                // TODO: Navigate to student or send message
              },
              child: const Text('Ver'),
            ),
          ),
        );
      }).toList(),
    );
  }
}
