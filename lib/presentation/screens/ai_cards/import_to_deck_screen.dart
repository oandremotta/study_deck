import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/deck.dart';
import '../../providers/ai_card_providers.dart';
import '../../providers/deck_providers.dart';
import '../../router/app_router.dart';

/// Screen for importing approved drafts to a deck (UC138-139, UC176).
class ImportToDeckScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ImportToDeckScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ImportToDeckScreen> createState() => _ImportToDeckScreenState();
}

class _ImportToDeckScreenState extends ConsumerState<ImportToDeckScreen> {
  String? _selectedDeckId;
  bool _createNewDeck = false;
  final _newDeckNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newDeckNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decksAsync = ref.watch(watchDecksProvider);
    final draftsAsync = ref.watch(draftsByProjectProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar para Deck'),
      ),
      body: draftsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (drafts) {
          final approvedDrafts = drafts.where((d) => d.isApproved).toList();
          final approvedCount = approvedDrafts.length;

          if (approvedCount == 0) {
            return _NoApprovedCards();
          }

          // UC176: Check for cards missing pedagogical fields
          final incompleteDrafts = approvedDrafts
              .where((d) => !d.hasPedagogicalFields)
              .toList();
          final needsReviewDrafts = approvedDrafts
              .where((d) => d.needsReview)
              .toList();

          final hasBlockingIssues = incompleteDrafts.isNotEmpty;
          final hasWarnings = needsReviewDrafts.isNotEmpty && !hasBlockingIssues;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          hasBlockingIssues
                              ? Icons.error
                              : hasWarnings
                                  ? Icons.warning_amber
                                  : Icons.check_circle,
                          color: hasBlockingIssues
                              ? Colors.red
                              : hasWarnings
                                  ? Colors.orange
                                  : Colors.green,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$approvedCount cards aprovados',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                hasBlockingIssues
                                    ? '${incompleteDrafts.length} cards incompletos'
                                    : hasWarnings
                                        ? '${needsReviewDrafts.length} cards precisam de revisão'
                                        : 'Prontos para importar',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: hasBlockingIssues
                                      ? Colors.red
                                      : hasWarnings
                                          ? Colors.orange
                                          : context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // UC176: Blocking warning for incomplete cards
                if (hasBlockingIssues) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.block, color: Colors.red.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Importação bloqueada',
                                style: context.textTheme.titleSmall?.copyWith(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${incompleteDrafts.length} card(s) não possuem os campos pedagógicos obrigatórios (resumo e frase-chave).',
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.edit),
                            label: const Text('Voltar e editar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Warning for cards that need review
                if (hasWarnings) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber, color: Colors.orange.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Atenção',
                                style: context.textTheme.titleSmall?.copyWith(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${needsReviewDrafts.length} card(s) foram marcados para revisão porque a IA aplicou fallbacks. Você pode importar mesmo assim ou voltar para revisar.',
                            style: TextStyle(color: Colors.orange.shade900),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Deck selection
                Text(
                  'Selecione o deck destino',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Create new deck option
                RadioListTile<bool>(
                  title: const Text('Criar novo deck'),
                  value: true,
                  groupValue: _createNewDeck,
                  onChanged: (value) {
                    setState(() {
                      _createNewDeck = true;
                      _selectedDeckId = null;
                    });
                  },
                ),

                if (_createNewDeck) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 48, right: 16),
                    child: TextField(
                      controller: _newDeckNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do novo deck',
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Existing decks
                RadioListTile<bool>(
                  title: const Text('Deck existente'),
                  value: false,
                  groupValue: _createNewDeck,
                  onChanged: (value) {
                    setState(() {
                      _createNewDeck = false;
                    });
                  },
                ),

                if (!_createNewDeck)
                  decksAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Text('Erro ao carregar decks: $e'),
                    data: (decks) {
                      if (decks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 48),
                          child: Text(
                            'Nenhum deck encontrado. Crie um novo.',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Column(
                          children: decks
                              .map((deck) => _DeckOption(
                                    deck: deck,
                                    isSelected: _selectedDeckId == deck.id,
                                    onTap: () {
                                      setState(() => _selectedDeckId = deck.id);
                                    },
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 32),

                // Import button
                FilledButton.icon(
                  onPressed: _canImport() && !_isLoading && !hasBlockingIssues ? _import : null,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(hasBlockingIssues ? Icons.block : Icons.download),
                  label: Text(
                    _isLoading
                        ? 'Importando...'
                        : hasBlockingIssues
                            ? 'Importação bloqueada'
                            : 'Importar cards',
                  ),
                ),

                // Help text
                if (!hasBlockingIssues) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Cards serão criados com todos os campos pedagógicos',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  bool _canImport() {
    if (_createNewDeck) {
      return _newDeckNameController.text.trim().isNotEmpty;
    }
    return _selectedDeckId != null;
  }

  Future<void> _import() async {
    setState(() => _isLoading = true);

    try {
      String deckId;

      if (_createNewDeck) {
        // Create new deck
        final deckRepository = ref.read(deckRepositoryProvider);
        final deck = await createDeckDirect(
          deckRepository,
          name: _newDeckNameController.text.trim(),
        );
        deckId = deck.id;
      } else {
        deckId = _selectedDeckId!;
      }

      // Import drafts
      final aiRepository = ref.read(aiCardRepositoryProvider);
      final cardIds = await importDraftsToDeckDirect(
        aiRepository,
        projectId: widget.projectId,
        deckId: deckId,
      );

      if (mounted) {
        context.showSnackBar('${cardIds.length} cards importados');
        // Navigate to deck
        context.go('${AppRouter.deckDetail}/$deckId');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackBar('Erro ao importar: $e');
      }
    }
  }
}

/// No approved cards state.
class _NoApprovedCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum card aprovado',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Aprove pelo menos um card para importar',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }
}

/// Deck option widget.
class _DeckOption extends StatelessWidget {
  final Deck deck;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeckOption({
    required this.deck,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Radio<bool>(
        value: true,
        groupValue: isSelected,
        onChanged: (_) => onTap(),
      ),
      title: Text(deck.name),
      subtitle: Text('${deck.cardCount} cards'),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
