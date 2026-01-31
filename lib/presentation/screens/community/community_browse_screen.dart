import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/community_deck.dart';
import '../../router/app_router.dart';

/// UC172-175: Community deck browsing screen.
///
/// Shows:
/// - Curated community decks by category
/// - Search functionality
/// - Quality indicators
/// - No competitive ranking (UC181)
class CommunityBrowseScreen extends ConsumerStatefulWidget {
  const CommunityBrowseScreen({super.key});

  @override
  ConsumerState<CommunityBrowseScreen> createState() =>
      _CommunityBrowseScreenState();
}

class _CommunityBrowseScreenState extends ConsumerState<CommunityBrowseScreen> {
  final _searchController = TextEditingController();
  DeckCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidade'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () => context.push(AppRoutes.publishDeck),
            tooltip: 'Publicar deck',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar decks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(
                  label: 'Todos',
                  selected: _selectedCategory == null,
                  onSelected: () => setState(() => _selectedCategory = null),
                ),
                ...DeckCategory.values.map((category) => _CategoryChip(
                      label: category.displayName,
                      selected: _selectedCategory == category,
                      onSelected: () =>
                          setState(() => _selectedCategory = category),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _DeckGrid(
              category: _selectedCategory,
              searchQuery: _searchQuery,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _DeckGrid extends ConsumerWidget {
  final DeckCategory? category;
  final String searchQuery;

  const _DeckGrid({
    this.category,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with actual provider
    final decks = _getMockDecks();

    // Filter by category and search
    var filteredDecks = decks.where((deck) {
      if (category != null && deck.category != category!.name) return false;
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return deck.name.toLowerCase().contains(query) ||
            (deck.description?.toLowerCase().contains(query) ?? false);
      }
      return true;
    }).toList();

    if (filteredDecks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum deck encontrado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Tente buscar por outro termo',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredDecks.length,
      itemBuilder: (context, index) {
        final deck = filteredDecks[index];
        return _CommunityDeckCard(
          deck: deck,
          onTap: () => context.push(
            '${AppRoutes.communityDeckDetail}/${deck.id}',
          ),
        );
      },
    );
  }

  List<CommunityDeck> _getMockDecks() {
    return [
      CommunityDeck(
        id: '1',
        originalDeckId: 'd1',
        creatorId: 'a1',
        creatorName: 'Maria Santos',
        name: 'Ingles Basico',
        description: 'Vocabulario essencial para iniciantes',
        category: DeckCategory.languages.name,
        cardCount: 150,
        importCount: 1250,
        helpfulCount: 80,
        notHelpfulCount: 9,
        reviewStatus: DeckReviewStatus.approved,
        publishedAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      CommunityDeck(
        id: '2',
        originalDeckId: 'd2',
        creatorId: 'a2',
        creatorName: 'Carlos Lima',
        name: 'Biologia Celular',
        description: 'Estrutura e funcao das celulas',
        category: DeckCategory.science.name,
        cardCount: 80,
        importCount: 560,
        helpfulCount: 38,
        notHelpfulCount: 4,
        reviewStatus: DeckReviewStatus.approved,
        publishedAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CommunityDeck(
        id: '3',
        originalDeckId: 'd3',
        creatorId: 'a3',
        creatorName: 'Ana Costa',
        name: 'Matematica Financeira',
        description: 'Juros, taxas e investimentos',
        category: DeckCategory.math.name,
        cardCount: 60,
        importCount: 320,
        helpfulCount: 24,
        notHelpfulCount: 4,
        reviewStatus: DeckReviewStatus.approved,
        publishedAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CommunityDeck(
        id: '4',
        originalDeckId: 'd4',
        creatorId: 'a4',
        creatorName: 'Pedro Souza',
        name: 'Historia do Brasil',
        description: 'Principais eventos historicos',
        category: DeckCategory.history.name,
        cardCount: 120,
        importCount: 890,
        helpfulCount: 58,
        notHelpfulCount: 7,
        reviewStatus: DeckReviewStatus.approved,
        publishedAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }
}

class _CommunityDeckCard extends StatelessWidget {
  final CommunityDeck deck;
  final VoidCallback onTap;

  const _CommunityDeckCard({
    required this.deck,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryEnum = DeckCategory.values.firstWhere(
      (c) => c.name == deck.category,
      orElse: () => DeckCategory.other,
    );

    // Calculate helpfulness rating
    final totalVotes = deck.helpfulCount + deck.notHelpfulCount;
    final rating = totalVotes > 0 ? (deck.helpfulCount / totalVotes) * 5 : 0.0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              width: double.infinity,
              color: _getCategoryColor(categoryEnum),
              child: Center(
                child: Icon(
                  _getCategoryIcon(categoryEnum),
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deck.creatorName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.style, size: 14, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${deck.cardCount}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.thumb_up, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          '${deck.helpfulCount}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
