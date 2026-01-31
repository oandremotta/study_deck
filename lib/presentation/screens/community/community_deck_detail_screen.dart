import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/community_deck.dart';
import '../../router/app_router.dart';

/// UC176-178: Community deck detail screen.
///
/// Shows:
/// - Deck information
/// - Card preview
/// - Download option
/// - Ratings and reviews
/// - Report functionality
class CommunityDeckDetailScreen extends ConsumerWidget {
  final String deckId;

  const CommunityDeckDetailScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // TODO: Replace with actual provider
    final deck = CommunityDeck(
      id: deckId,
      originalDeckId: 'd1',
      creatorId: 'a1',
      creatorName: 'Maria Santos',
      name: 'Ingles Basico',
      description:
          'Este deck contem vocabulario essencial para iniciantes em ingles. Inclui palavras do dia a dia, frases comuns e expressoes uteis para conversacao basica.',
      category: DeckCategory.languages.name,
      cardCount: 150,
      importCount: 1250,
      helpfulCount: 80,
      notHelpfulCount: 9,
      reviewStatus: DeckReviewStatus.approved,
      tags: ['ingles', 'vocabulario', 'iniciante'],
      publishedAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    );

    final categoryEnum = DeckCategory.values.firstWhere(
      (c) => c.name == deck.category,
      orElse: () => DeckCategory.other,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Deck'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Share deck
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') {
                _showReportDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag),
                    SizedBox(width: 8),
                    Text('Reportar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DeckHeader(deck: deck, category: categoryEnum),
            const Divider(),
            _DeckStats(deck: deck),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descricao',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deck.description ?? 'Sem descricao',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (deck.tags.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: deck.tags
                          .map((tag) => Chip(label: Text(tag)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(),
            _CardPreview(deckId: deckId),
            const Divider(),
            _HelpfulnessSection(deck: deck),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => _showDownloadDialog(context, deck),
            icon: const Icon(Icons.download),
            label: const Text('Baixar para meus decks'),
          ),
        ),
      ),
    );
  }

  void _showDownloadDialog(BuildContext context, CommunityDeck deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Baixar Deck'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deseja baixar "${deck.name}"?'),
            const SizedBox(height: 16),
            Text(
              'O deck sera copiado para sua biblioteca pessoal.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Download deck
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deck baixado com sucesso!')),
              );
              context.go(AppRoutes.home);
            },
            child: const Text('Baixar'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    ReportReason? selectedReason;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Reportar Deck'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Por que voce esta reportando este deck?'),
              const SizedBox(height: 16),
              ...ReportReason.values.map((reason) => RadioListTile<ReportReason>(
                    title: Text(reason.displayName),
                    value: reason,
                    groupValue: selectedReason,
                    onChanged: (value) => setState(() => selectedReason = value),
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: selectedReason != null
                  ? () {
                      Navigator.pop(context);
                      // TODO: Submit report
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Denuncia enviada. Obrigado!'),
                        ),
                      );
                    }
                  : null,
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeckHeader extends StatelessWidget {
  final CommunityDeck deck;
  final DeckCategory category;

  const _DeckHeader({required this.deck, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deck.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'por ${deck.creatorName}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category.displayName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(DeckCategory category) {
    switch (category) {
      case DeckCategory.languages:
        return Colors.blue;
      case DeckCategory.science:
        return Colors.green;
      case DeckCategory.math:
        return Colors.purple;
      case DeckCategory.history:
        return Colors.brown;
      case DeckCategory.geography:
        return Colors.teal;
      case DeckCategory.arts:
        return Colors.pink;
      case DeckCategory.technology:
        return Colors.indigo;
      case DeckCategory.health:
        return Colors.red;
      case DeckCategory.business:
        return Colors.orange;
      case DeckCategory.exams:
        return Colors.deepPurple;
      case DeckCategory.other:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(DeckCategory category) {
    switch (category) {
      case DeckCategory.languages:
        return Icons.translate;
      case DeckCategory.science:
        return Icons.science;
      case DeckCategory.math:
        return Icons.calculate;
      case DeckCategory.history:
        return Icons.history_edu;
      case DeckCategory.geography:
        return Icons.public;
      case DeckCategory.arts:
        return Icons.palette;
      case DeckCategory.technology:
        return Icons.computer;
      case DeckCategory.health:
        return Icons.medical_services;
      case DeckCategory.business:
        return Icons.business;
      case DeckCategory.exams:
        return Icons.quiz;
      case DeckCategory.other:
        return Icons.folder;
    }
  }
}

class _DeckStats extends StatelessWidget {
  final CommunityDeck deck;

  const _DeckStats({required this.deck});

  @override
  Widget build(BuildContext context) {
    final totalVotes = deck.helpfulCount + deck.notHelpfulCount;
    final helpfulPercent = totalVotes > 0
        ? ((deck.helpfulCount / totalVotes) * 100).round()
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            icon: Icons.style,
            value: '${deck.cardCount}',
            label: 'Cards',
          ),
          _StatItem(
            icon: Icons.download,
            value: '${deck.importCount}',
            label: 'Downloads',
          ),
          _StatItem(
            icon: Icons.thumb_up,
            value: '$helpfulPercent%',
            label: 'Util ($totalVotes votos)',
            iconColor: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: iconColor ?? theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
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
    );
  }
}

class _CardPreview extends StatelessWidget {
  final String deckId;

  const _CardPreview({required this.deckId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: Replace with actual preview cards
    final previewCards = [
      {'front': 'Hello', 'back': 'Ola'},
      {'front': 'Thank you', 'back': 'Obrigado'},
      {'front': 'Good morning', 'back': 'Bom dia'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview dos cards',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...previewCards.map((card) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(card['front']!),
                  subtitle: Text(
                    card['back']!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: const Icon(Icons.swap_horiz),
                ),
              )),
          const SizedBox(height: 8),
          Text(
            'E mais 147 cards...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpfulnessSection extends StatelessWidget {
  final CommunityDeck deck;

  const _HelpfulnessSection({required this.deck});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalVotes = deck.helpfulCount + deck.notHelpfulCount;
    final helpfulPercent = totalVotes > 0
        ? ((deck.helpfulCount / totalVotes) * 100).round()
        : 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Este deck foi util?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Mark as helpful
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Obrigado pelo feedback!')),
                    );
                  },
                  icon: const Icon(Icons.thumb_up, color: Colors.green),
                  label: Text('Sim (${deck.helpfulCount})'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Mark as not helpful
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Obrigado pelo feedback!')),
                    );
                  },
                  icon: const Icon(Icons.thumb_down, color: Colors.red),
                  label: Text('Nao (${deck.notHelpfulCount})'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: totalVotes > 0 ? deck.helpfulCount / totalVotes : 0.5,
            backgroundColor: Colors.red.withValues(alpha: 0.2),
            color: Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '$helpfulPercent% acharam util ($totalVotes votos)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
