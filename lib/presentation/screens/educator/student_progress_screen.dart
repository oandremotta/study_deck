import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UC166-167: Individual student progress screen.
///
/// Shows detailed progress for a single student:
/// - Overall statistics
/// - Deck-by-deck progress
/// - Study history
/// - Areas needing improvement
class StudentProgressScreen extends ConsumerWidget {
  final String studentId;

  const StudentProgressScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // TODO: Replace with actual provider - using display helper
    final student = _StudentDisplayData(
      id: studentId,
      name: 'Ana Silva',
      cardsStudied: 150,
      totalCards: 200,
      accuracy: 0.85,
      streak: 7,
      lastStudy: DateTime.now().subtract(const Duration(hours: 2)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(student.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () => _showMessageDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StudentHeader(student: student),
            const SizedBox(height: 24),
            _OverviewStats(student: student),
            const SizedBox(height: 24),
            Text(
              'Progresso por deck',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _DeckProgressList(studentId: studentId),
            const SizedBox(height: 24),
            Text(
              'Areas para melhorar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _ImprovementAreas(studentId: studentId),
            const SizedBox(height: 24),
            Text(
              'Atividade recente',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _RecentActivity(studentId: studentId),
          ],
        ),
      ),
    );
  }

  void _showMessageDialog(BuildContext context) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar mensagem'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            labelText: 'Mensagem',
            hintText: 'Digite sua mensagem...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Send message
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mensagem enviada!')),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

/// Helper class for displaying student data.
class _StudentDisplayData {
  final String id;
  final String name;
  final int cardsStudied;
  final int totalCards;
  final double accuracy;
  final int streak;
  final DateTime? lastStudy;

  const _StudentDisplayData({
    required this.id,
    required this.name,
    required this.cardsStudied,
    required this.totalCards,
    required this.accuracy,
    required this.streak,
    this.lastStudy,
  });
}

class _StudentHeader extends StatelessWidget {
  final _StudentDisplayData student;

  const _StudentHeader({required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              child: Text(
                student.name[0],
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${student.streak} dias de sequencia',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ultimo estudo: ha 2 horas',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
}

class _OverviewStats extends StatelessWidget {
  final _StudentDisplayData student;

  const _OverviewStats({required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracyPercent = (student.accuracy * 100).round();
    final progressPercent = student.totalCards > 0
        ? ((student.cardsStudied / student.totalCards) * 100).round()
        : 0;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.check_circle,
            label: 'Precisao',
            value: '$accuracyPercent%',
            color: _getAccuracyColor(student.accuracy),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.school,
            label: 'Progresso',
            value: '$progressPercent%',
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.style,
            label: 'Cards',
            value: '${student.cardsStudied}',
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return Colors.green;
    if (accuracy >= 0.6) return Colors.orange;
    return Colors.red;
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
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

class _DeckProgressList extends StatelessWidget {
  final String studentId;

  const _DeckProgressList({required this.studentId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: Replace with actual data
    final deckProgress = [
      {'name': 'Celulas', 'studied': 45, 'total': 50, 'accuracy': 0.92},
      {'name': 'Genetica', 'studied': 60, 'total': 80, 'accuracy': 0.78},
      {'name': 'Ecologia', 'studied': 15, 'total': 45, 'accuracy': 0.65},
    ];

    return Column(
      children: deckProgress.map((deck) {
        final progress = (deck['studied'] as int) / (deck['total'] as int);
        final accuracy = deck['accuracy'] as double;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      deck['name'] as String,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getAccuracyColor(accuracy).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(accuracy * 100).round()}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getAccuracyColor(accuracy),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${deck['studied']}/${deck['total']}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return Colors.green;
    if (accuracy >= 0.6) return Colors.orange;
    return Colors.red;
  }
}

class _ImprovementAreas extends StatelessWidget {
  final String studentId;

  const _ImprovementAreas({required this.studentId});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual data
    final areas = [
      {'topic': 'Divisao celular', 'accuracy': 0.45, 'reviews': 8},
      {'topic': 'Hereditariedade', 'accuracy': 0.52, 'reviews': 12},
      {'topic': 'Cadeias alimentares', 'accuracy': 0.58, 'reviews': 6},
    ];

    if (areas.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              const Text('Nenhuma area precisa de atencao especial'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: areas.map((area) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.orange.withValues(alpha: 0.1),
          child: ListTile(
            leading: const Icon(Icons.warning_amber, color: Colors.orange),
            title: Text(area['topic'] as String),
            subtitle: Text(
              '${((area['accuracy'] as double) * 100).round()}% de acertos em ${area['reviews']} revisoes',
            ),
            trailing: FilledButton.tonal(
              onPressed: () {
                // TODO: Recommend extra practice
              },
              child: const Text('Praticar'),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final String studentId;

  const _RecentActivity({required this.studentId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: Replace with actual data
    final activities = [
      {
        'date': 'Hoje, 14:30',
        'deck': 'Celulas',
        'cards': 15,
        'accuracy': 0.87,
      },
      {
        'date': 'Hoje, 10:15',
        'deck': 'Genetica',
        'cards': 20,
        'accuracy': 0.75,
      },
      {
        'date': 'Ontem, 16:45',
        'deck': 'Ecologia',
        'cards': 10,
        'accuracy': 0.60,
      },
    ];

    return Column(
      children: activities.map((activity) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.school,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(activity['deck'] as String),
            subtitle: Text(
              '${activity['cards']} cards - ${((activity['accuracy'] as double) * 100).round()}% acertos',
            ),
            trailing: Text(
              activity['date'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
