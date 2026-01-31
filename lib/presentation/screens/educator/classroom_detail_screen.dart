import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/classroom.dart';
import '../../router/app_router.dart';

/// UC163-165: Classroom detail screen for educators.
///
/// Shows:
/// - Classroom info and invite code
/// - Student list with progress
/// - Assigned decks
/// - Class statistics
class ClassroomDetailScreen extends ConsumerStatefulWidget {
  final String classroomId;

  const ClassroomDetailScreen({super.key, required this.classroomId});

  @override
  ConsumerState<ClassroomDetailScreen> createState() =>
      _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState extends ConsumerState<ClassroomDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual provider
    final classroom = Classroom(
      id: widget.classroomId,
      name: 'Biologia 3A',
      description: 'Turma do 3o ano',
      educatorId: 'educator1',
      inviteCode: 'ABC123',
      studentIds: ['s1', 's2', 's3'],
      assignedDeckIds: ['d1', 'd2'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(classroom.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context, classroom),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Alunos'),
            Tab(text: 'Decks'),
            Tab(text: 'Estatisticas'),
          ],
        ),
      ),
      body: Column(
        children: [
          _InviteCodeCard(
            inviteCode: classroom.inviteCode ?? 'N/A',
            onShare: () => _shareInviteCode(classroom.inviteCode ?? ''),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _StudentsTab(classroomId: widget.classroomId),
                _DecksTab(classroomId: widget.classroomId),
                _StatsTab(classroomId: widget.classroomId),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptions(context),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }

  void _shareInviteCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Codigo copiado!')),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Atribuir deck'),
              onTap: () {
                Navigator.pop(context);
                _showAssignDeckDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Convidar alunos'),
              onTap: () {
                Navigator.pop(context);
                _showInviteDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDeckDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atribuir Deck'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Selecione um deck para atribuir a turma.'),
            SizedBox(height: 16),
            // TODO: Add deck selection list
            Text('(Lista de decks aqui)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Assign deck
              Navigator.pop(context);
            },
            child: const Text('Atribuir'),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convidar Alunos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Compartilhe o codigo de convite:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const SelectableText(
                'ABC123',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: 'ABC123'));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Codigo copiado!')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copiar'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context, Classroom classroom) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar turma'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Edit classroom
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Gerar novo codigo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Regenerate code
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Arquivar turma'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Archive classroom
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Excluir turma',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir turma?'),
        content: const Text(
          'Esta acao nao pode ser desfeita. Todos os dados de progresso serao perdidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Delete classroom
              context.go(AppRoutes.classroomList);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _InviteCodeCard extends StatelessWidget {
  final String inviteCode;
  final VoidCallback onShare;

  const _InviteCodeCard({
    required this.inviteCode,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.qr_code, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Codigo de convite',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    inviteCode,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: onShare,
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class for displaying student info in list.
class _StudentDisplayInfo {
  final String id;
  final String name;
  final int cardsStudied;
  final int totalCards;
  final double accuracy;
  final int streak;
  final DateTime? lastStudy;

  const _StudentDisplayInfo({
    required this.id,
    required this.name,
    required this.cardsStudied,
    required this.totalCards,
    required this.accuracy,
    required this.streak,
    this.lastStudy,
  });
}

class _StudentsTab extends ConsumerWidget {
  final String classroomId;

  const _StudentsTab({required this.classroomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // TODO: Replace with actual provider - for now using display helper
    final students = <_StudentDisplayInfo>[
      _StudentDisplayInfo(
        id: 'student1',
        name: 'Ana Silva',
        cardsStudied: 150,
        totalCards: 200,
        accuracy: 0.85,
        streak: 7,
        lastStudy: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      _StudentDisplayInfo(
        id: 'student2',
        name: 'Bruno Costa',
        cardsStudied: 80,
        totalCards: 200,
        accuracy: 0.72,
        streak: 3,
        lastStudy: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum aluno ainda',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Compartilhe o codigo de convite',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return _StudentCard(
          student: student,
          onTap: () => context.push(
            '${AppRoutes.studentProgress}/${student.id}',
          ),
        );
      },
    );
  }
}

class _StudentCard extends StatelessWidget {
  final _StudentDisplayInfo student;
  final VoidCallback onTap;

  const _StudentCard({
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = student.totalCards > 0
        ? student.cardsStudied / student.totalCards
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(student.name[0]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${student.streak} dias de sequencia',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _AccuracyBadge(accuracy: student.accuracy),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${student.cardsStudied}/${student.totalCards} cards',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccuracyBadge extends StatelessWidget {
  final double accuracy;

  const _AccuracyBadge({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (accuracy * 100).round();

    Color color;
    if (accuracy >= 0.8) {
      color = Colors.green;
    } else if (accuracy >= 0.6) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$percent%',
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DecksTab extends ConsumerWidget {
  final String classroomId;

  const _DecksTab({required this.classroomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // TODO: Replace with actual deck data
    final decks = [
      {'name': 'Celulas', 'cards': 50, 'progress': 0.65},
      {'name': 'Genetica', 'cards': 80, 'progress': 0.40},
      {'name': 'Ecologia', 'cards': 45, 'progress': 0.20},
    ];

    if (decks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum deck atribuido',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: decks.length,
      itemBuilder: (context, index) {
        final deck = decks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.folder,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(deck['name'] as String),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${deck['cards']} cards'),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: deck['progress'] as double,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                // TODO: Remove deck from classroom
              },
            ),
          ),
        );
      },
    );
  }
}

class _StatsTab extends ConsumerWidget {
  final String classroomId;

  const _StatsTab({required this.classroomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visao geral',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people,
                  label: 'Alunos',
                  value: '25',
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.school,
                  label: 'Cards estudados',
                  value: '2.5k',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  label: 'Precisao media',
                  value: '78%',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  label: 'Streak medio',
                  value: '5 dias',
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Atividade semanal',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _BarChartColumn(label: 'Seg', value: 0.6),
                _BarChartColumn(label: 'Ter', value: 0.8),
                _BarChartColumn(label: 'Qua', value: 0.5),
                _BarChartColumn(label: 'Qui', value: 0.9),
                _BarChartColumn(label: 'Sex', value: 0.7),
                _BarChartColumn(label: 'Sab', value: 0.3),
                _BarChartColumn(label: 'Dom', value: 0.2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
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

class _BarChartColumn extends StatelessWidget {
  final String label;
  final double value;

  const _BarChartColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 100 * value,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
