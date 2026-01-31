import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/card.dart' as domain;
import '../../providers/card_providers.dart';

/// Screen for migrating legacy cards to pedagogical format (UC172).
///
/// Shows cards that are missing summary and/or keyPhrase fields,
/// allowing users to either auto-migrate or manually edit them.
class LegacyMigrationScreen extends ConsumerStatefulWidget {
  final String deckId;

  const LegacyMigrationScreen({
    super.key,
    required this.deckId,
  });

  @override
  ConsumerState<LegacyMigrationScreen> createState() =>
      _LegacyMigrationScreenState();
}

class _LegacyMigrationScreenState extends ConsumerState<LegacyMigrationScreen> {
  bool _isLoading = false;
  final Set<String> _selectedCardIds = {};
  bool _selectAll = false;

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(watchCardsByDeckProvider(widget.deckId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Migrar Cards Antigos'),
        actions: [
          if (_selectedCardIds.isNotEmpty)
            TextButton.icon(
              onPressed: _isLoading ? null : _migrateSelected,
              icon: const Icon(Icons.auto_fix_high),
              label: Text('Migrar ${_selectedCardIds.length}'),
            ),
        ],
      ),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (cards) {
          // Filter legacy cards (without pedagogical fields)
          final legacyCards =
              cards.where((c) => c.needsMigration).toList();

          if (legacyCards.isEmpty) {
            return _NoLegacyCards();
          }

          return Column(
            children: [
              // Info header
              Container(
                padding: const EdgeInsets.all(16),
                color: context.colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${legacyCards.length} cards precisam de migração',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Estes cards não possuem os campos pedagógicos (resumo e frase-chave). Selecione para migrar automaticamente ou edite manualmente.',
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Select all checkbox
              CheckboxListTile(
                value: _selectAll,
                onChanged: (value) {
                  setState(() {
                    _selectAll = value ?? false;
                    if (_selectAll) {
                      _selectedCardIds.addAll(legacyCards.map((c) => c.id));
                    } else {
                      _selectedCardIds.clear();
                    }
                  });
                },
                title: const Text('Selecionar todos'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const Divider(height: 1),

              // Cards list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: legacyCards.length,
                  itemBuilder: (context, index) {
                    final card = legacyCards[index];
                    return _LegacyCardTile(
                      card: card,
                      isSelected: _selectedCardIds.contains(card.id),
                      onSelectionChanged: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCardIds.add(card.id);
                          } else {
                            _selectedCardIds.remove(card.id);
                          }
                          _selectAll =
                              _selectedCardIds.length == legacyCards.length;
                        });
                      },
                      onEdit: () => _editCard(card),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _selectedCardIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _migrateSelected,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_fix_high),
              label: Text(_isLoading
                  ? 'Migrando...'
                  : 'Migrar ${_selectedCardIds.length} cards'),
            )
          : null,
    );
  }

  Future<void> _migrateSelected() async {
    if (_selectedCardIds.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(cardRepositoryProvider);
      int migratedCount = 0;

      // Get all cards to migrate
      final cardsResult =
          await repository.getCardsByDeck(widget.deckId);
      final cards = cardsResult.fold(
        (f) => throw Exception(f.message),
        (cards) => cards,
      );

      for (final cardId in _selectedCardIds) {
        final card = cards.firstWhere((c) => c.id == cardId);

        // Auto-generate pedagogical fields
        final summary = _generateSummary(card);
        final keyPhrase = _generateKeyPhrase(card, summary);

        await updateCardDirect(
          repository,
          id: card.id,
          summary: summary,
          keyPhrase: keyPhrase,
        );
        migratedCount++;
      }

      if (mounted) {
        setState(() {
          _selectedCardIds.clear();
          _selectAll = false;
          _isLoading = false;
        });
        context.showSnackBar('$migratedCount cards migrados com sucesso');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackBar('Erro ao migrar: $e');
      }
    }
  }

  /// Generates a summary from the card's back content.
  String _generateSummary(domain.Card card) {
    final back = card.back;
    if (back.length <= domain.Card.maxSummaryLength) {
      return back;
    }
    // Smart truncate at sentence boundary
    final truncated = back.substring(0, domain.Card.maxSummaryLength - 3);
    final lastPunct = truncated.lastIndexOf(RegExp(r'[.!?]'));
    if (lastPunct > domain.Card.maxSummaryLength * 0.6) {
      return '${truncated.substring(0, lastPunct + 1)}..';
    }
    final lastSpace = truncated.lastIndexOf(' ');
    if (lastSpace > domain.Card.maxSummaryLength * 0.6) {
      return '${truncated.substring(0, lastSpace)}...';
    }
    return '$truncated...';
  }

  /// Generates a key phrase from summary or back content.
  String _generateKeyPhrase(domain.Card card, String summary) {
    // Extract first sentence
    final source = summary;
    final sentenceEnd = source.indexOf(RegExp(r'[.!?]'));

    String keyPhrase;
    if (sentenceEnd > 0 && sentenceEnd <= domain.Card.maxKeyPhraseLength) {
      keyPhrase = source.substring(0, sentenceEnd + 1);
    } else if (source.length <= domain.Card.maxKeyPhraseLength) {
      keyPhrase = source;
    } else {
      keyPhrase = '${source.substring(0, domain.Card.maxKeyPhraseLength - 3)}...';
    }

    // Ensure it's not a question
    if (keyPhrase.endsWith('?')) {
      keyPhrase = '${keyPhrase.substring(0, keyPhrase.length - 1)}.';
    }

    return keyPhrase.trim();
  }

  void _editCard(domain.Card card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _EditLegacyCardSheet(
        card: card,
        onSaved: () {
          setState(() {
            _selectedCardIds.remove(card.id);
          });
        },
      ),
    );
  }
}

/// Empty state when no legacy cards.
class _NoLegacyCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            'Todos os cards estão atualizados!',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Nenhum card precisa de migração',
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

/// Card tile for legacy card.
class _LegacyCardTile extends StatelessWidget {
  final domain.Card card;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onEdit;

  const _LegacyCardTile({
    required this.card,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Checkbox and front
          ListTile(
            leading: Checkbox(
              value: isSelected,
              onChanged: (v) => onSelectionChanged(v ?? false),
            ),
            title: Text(
              card.front,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              card.back,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Editar manualmente',
            ),
          ),

          // Missing fields indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              children: [
                if (card.summary == null || card.summary!.isEmpty)
                  Chip(
                    label: const Text('Sem resumo'),
                    avatar: const Icon(Icons.warning_amber, size: 16),
                    backgroundColor: Colors.orange.shade100,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade900,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                if (card.keyPhrase == null || card.keyPhrase!.isEmpty)
                  Chip(
                    label: const Text('Sem frase-chave'),
                    avatar: const Icon(Icons.warning_amber, size: 16),
                    backgroundColor: Colors.orange.shade100,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade900,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sheet for manually editing a legacy card.
class _EditLegacyCardSheet extends ConsumerStatefulWidget {
  final domain.Card card;
  final VoidCallback onSaved;

  const _EditLegacyCardSheet({
    required this.card,
    required this.onSaved,
  });

  @override
  ConsumerState<_EditLegacyCardSheet> createState() =>
      _EditLegacyCardSheetState();
}

class _EditLegacyCardSheetState extends ConsumerState<_EditLegacyCardSheet> {
  late final TextEditingController _summaryController;
  late final TextEditingController _keyPhraseController;
  bool _isLoading = false;
  String? _summaryError;
  String? _keyPhraseError;

  @override
  void initState() {
    super.initState();
    _summaryController = TextEditingController(
      text: widget.card.summary ?? widget.card.displaySummary,
    );
    _keyPhraseController = TextEditingController(
      text: widget.card.keyPhrase ?? widget.card.displayKeyPhrase,
    );

    _summaryController.addListener(_validate);
    _keyPhraseController.addListener(_validate);
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _keyPhraseController.dispose();
    super.dispose();
  }

  void _validate() {
    final summary = _summaryController.text.trim();
    final keyPhrase = _keyPhraseController.text.trim();
    String? summaryErr;
    String? keyPhraseErr;

    if (summary.isEmpty) {
      summaryErr = 'Resumo é obrigatório';
    } else if (summary.length > domain.Card.maxSummaryLength) {
      summaryErr = 'Máximo ${domain.Card.maxSummaryLength} caracteres';
    }

    if (keyPhrase.isEmpty) {
      keyPhraseErr = 'Frase-chave é obrigatória';
    } else if (keyPhrase.length > domain.Card.maxKeyPhraseLength) {
      keyPhraseErr = 'Máximo ${domain.Card.maxKeyPhraseLength} caracteres';
    } else if (keyPhrase.endsWith('?')) {
      keyPhraseErr = 'Não pode ser uma pergunta';
    }

    if (summaryErr != _summaryError || keyPhraseErr != _keyPhraseError) {
      setState(() {
        _summaryError = summaryErr;
        _keyPhraseError = keyPhraseErr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Migrar Card',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Question (read-only)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pergunta:',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.card.front,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Summary
                      TextField(
                        controller: _summaryController,
                        decoration: InputDecoration(
                          labelText: 'Resumo *',
                          border: const OutlineInputBorder(),
                          helperText: 'Resposta curta (máx ${domain.Card.maxSummaryLength} chars)',
                          counterText:
                              '${_summaryController.text.length}/${domain.Card.maxSummaryLength}',
                          errorText: _summaryError,
                        ),
                        maxLines: 3,
                        maxLength: domain.Card.maxSummaryLength + 20,
                      ),
                      const SizedBox(height: 16),

                      // Key Phrase
                      TextField(
                        controller: _keyPhraseController,
                        decoration: InputDecoration(
                          labelText: 'Frase-chave *',
                          border: const OutlineInputBorder(),
                          helperText:
                              'Frase afirmativa (máx ${domain.Card.maxKeyPhraseLength} chars)',
                          counterText:
                              '${_keyPhraseController.text.length}/${domain.Card.maxKeyPhraseLength}',
                          errorText: _keyPhraseError,
                        ),
                        maxLines: 2,
                        maxLength: domain.Card.maxKeyPhraseLength + 20,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ||
                              _summaryError != null ||
                              _keyPhraseError != null
                          ? null
                          : _save,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Salvar'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    _validate();
    if (_summaryError != null || _keyPhraseError != null) {
      context.showErrorSnackBar('Corrija os erros antes de salvar');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(cardRepositoryProvider);
      await updateCardDirect(
        repository,
        id: widget.card.id,
        summary: _summaryController.text.trim(),
        keyPhrase: _keyPhraseController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        context.showSnackBar('Card migrado com sucesso');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackBar('Erro ao salvar: $e');
      }
    }
  }
}
