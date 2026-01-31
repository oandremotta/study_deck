import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/ai_project.dart';
import '../../providers/ai_card_providers.dart';
import '../../router/app_router.dart';

/// Screen showing AI generation history (UC141).
class AiHistoryScreen extends ConsumerWidget {
  const AiHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(watchAiProjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historico'),
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (projects) {
          if (projects.isEmpty) {
            return _EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return _ProjectCard(project: project);
            },
          );
        },
      ),
    );
  }
}

/// Empty state widget.
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum projeto ainda',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Seus projetos de geracao aparecerão aqui',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Project card widget.
class _ProjectCard extends ConsumerWidget {
  final AiProject project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToProject(context),
        onLongPress: () => _showOptions(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getStatusIcon(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.displayName,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${project.sourceType.displayName} - ${project.status.displayName}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _getActionButton(context),
                ],
              ),
              const SizedBox(height: 12),
              // Stats row
              Row(
                children: [
                  _StatItem(
                    icon: Icons.auto_awesome,
                    label: '${project.generatedCardCount} gerados',
                  ),
                  const SizedBox(width: 16),
                  _StatItem(
                    icon: Icons.check_circle_outline,
                    label: '${project.approvedCardCount} aprovados',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Date
              Text(
                _formatDate(project.createdAt),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getStatusIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (project.status) {
      case AiProjectStatus.created:
      case AiProjectStatus.extracting:
      case AiProjectStatus.generating:
        icon = Icons.hourglass_top;
        color = context.colorScheme.primary;
        break;
      case AiProjectStatus.review:
        icon = Icons.rate_review;
        color = context.colorScheme.tertiary;
        break;
      case AiProjectStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case AiProjectStatus.failed:
        icon = Icons.error;
        color = context.colorScheme.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _getActionButton(BuildContext context) {
    switch (project.status) {
      case AiProjectStatus.review:
        return FilledButton.tonal(
          onPressed: () =>
              context.push('${AppRouter.aiReview}/${project.id}'),
          child: const Text('Revisar'),
        );
      case AiProjectStatus.failed:
        return OutlinedButton(
          onPressed: () =>
              context.push('${AppRouter.aiConfig}/${project.id}'),
          child: const Text('Retry'),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _navigateToProject(BuildContext context) {
    switch (project.status) {
      case AiProjectStatus.review:
        context.push('${AppRouter.aiReview}/${project.id}');
        break;
      case AiProjectStatus.generating:
      case AiProjectStatus.extracting:
        context.push('${AppRouter.aiProgress}/${project.id}');
        break;
      default:
        break;
    }
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Excluir projeto'),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await _confirmDelete(context);
                if (confirmed && context.mounted) {
                  try {
                    final repository = ref.read(aiCardRepositoryProvider);
                    await deleteAiProjectDirect(repository, project.id);
                    if (context.mounted) {
                      context.showSnackBar('Projeto excluido');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      context.showErrorSnackBar('Erro ao excluir: $e');
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Excluir projeto?'),
            content: const Text(
              'Esta acao nao pode ser desfeita. Todos os rascunhos serao excluidos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colorScheme.error,
                ),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hoje';
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} dias atras';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Stat item widget.
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: context.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
