import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/ai_card_draft.dart';
import '../../providers/ai_card_providers.dart';
import '../../router/app_router.dart';

/// Filter options for draft list.
enum _DraftFilter { all, pending, needsReview, approved }

/// Screen for reviewing AI-generated card drafts (UC135-137).
class ReviewDraftsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ReviewDraftsScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ReviewDraftsScreen> createState() => _ReviewDraftsScreenState();
}

class _ReviewDraftsScreenState extends ConsumerState<ReviewDraftsScreen> {
  bool _isLoading = false;
  _DraftFilter _filter = _DraftFilter.all;

  @override
  Widget build(BuildContext context) {
    final draftsAsync = ref.watch(watchDraftsByProjectProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisar Cards'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _approveAll,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Aprovar todos'),
          ),
        ],
      ),
      body: draftsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (drafts) {
          if (drafts.isEmpty) {
            return _EmptyState();
          }

          final pendingCount =
              drafts.where((d) => d.reviewStatus == DraftReviewStatus.pending).length;
          final approvedCount = drafts.where((d) => d.isApproved).length;
          final rejectedCount =
              drafts.where((d) => d.reviewStatus == DraftReviewStatus.rejected).length;
          final needsReviewCount = drafts.where((d) => d.needsReview).length;

          // Apply filter
          final filteredDrafts = _applyFilter(drafts);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDrafts.length + 2, // +2 for header and filter
            itemBuilder: (context, index) {
              // Header with stats
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatChip(
                            label: 'Pendentes',
                            count: pendingCount,
                            color: context.colorScheme.primary,
                          ),
                          _StatChip(
                            label: 'Aprovados',
                            count: approvedCount,
                            color: Colors.green,
                          ),
                          _StatChip(
                            label: 'Rejeitados',
                            count: rejectedCount,
                            color: context.colorScheme.error,
                          ),
                          if (needsReviewCount > 0)
                            _StatChip(
                              label: 'Revisar',
                              count: needsReviewCount,
                              color: Colors.orange,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Filter chips
              if (index == 1) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Todos',
                          selected: _filter == _DraftFilter.all,
                          onSelected: () => setState(() => _filter = _DraftFilter.all),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Pendentes',
                          selected: _filter == _DraftFilter.pending,
                          onSelected: () => setState(() => _filter = _DraftFilter.pending),
                        ),
                        const SizedBox(width: 8),
                        if (needsReviewCount > 0) ...[
                          _FilterChip(
                            label: 'Precisa revisar',
                            selected: _filter == _DraftFilter.needsReview,
                            onSelected: () => setState(() => _filter = _DraftFilter.needsReview),
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                        ],
                        _FilterChip(
                          label: 'Aprovados',
                          selected: _filter == _DraftFilter.approved,
                          onSelected: () => setState(() => _filter = _DraftFilter.approved),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final draft = filteredDrafts[index - 2];
              return _DraftCard(
                draft: draft,
                onApprove: () => _approveDraft(draft),
                onReject: () => _rejectDraft(draft),
                onEdit: () => _editDraft(draft),
              );
            },
          );
        },
      ),
      floatingActionButton: draftsAsync.maybeWhen(
        data: (drafts) {
          final approvedCount = drafts.where((d) => d.isApproved).length;
          if (approvedCount == 0) return null;
          return FloatingActionButton.extended(
            onPressed: _isLoading ? null : _goToImport,
            icon: const Icon(Icons.download),
            label: Text('Importar $approvedCount'),
          );
        },
        orElse: () => null,
      ),
    );
  }

  Future<void> _approveAll() async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(aiCardRepositoryProvider);
      final count = await approveAllDraftsDirect(repository, widget.projectId);

      if (mounted) {
        context.showSnackBar('$count cards aprovados');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Erro ao aprovar: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _approveDraft(AiCardDraft draft) async {
    HapticFeedback.lightImpact();
    try {
      final repository = ref.read(aiCardRepositoryProvider);
      await updateDraftDirect(
        repository,
        id: draft.id,
        reviewStatus: DraftReviewStatus.approved,
      );
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Erro ao aprovar: $e');
      }
    }
  }

  Future<void> _rejectDraft(AiCardDraft draft) async {
    HapticFeedback.lightImpact();
    try {
      final repository = ref.read(aiCardRepositoryProvider);
      await updateDraftDirect(
        repository,
        id: draft.id,
        reviewStatus: DraftReviewStatus.rejected,
      );
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Erro ao rejeitar: $e');
      }
    }
  }

  void _editDraft(AiCardDraft draft) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _EditDraftSheet(draft: draft),
    );
  }

  void _goToImport() {
    context.push('${AppRouter.aiImport}/${widget.projectId}');
  }

  List<AiCardDraft> _applyFilter(List<AiCardDraft> drafts) {
    switch (_filter) {
      case _DraftFilter.all:
        return drafts;
      case _DraftFilter.pending:
        return drafts.where((d) => d.isPending).toList();
      case _DraftFilter.needsReview:
        return drafts.where((d) => d.needsReview).toList();
      case _DraftFilter.approved:
        return drafts.where((d) => d.isApproved).toList();
    }
  }
}

/// Stats chip widget.
class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: context.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Filter chip widget.
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: color?.withValues(alpha: 0.2),
      checkmarkColor: color,
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
            Icons.inbox_outlined,
            size: 64,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum card gerado',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go(AppRouter.aiCardsHub),
            child: const Text('Voltar ao inicio'),
          ),
        ],
      ),
    );
  }
}

/// Single draft card widget with pedagogical fields display.
class _DraftCard extends StatelessWidget {
  final AiCardDraft draft;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onEdit;

  const _DraftCard({
    required this.draft,
    required this.onApprove,
    required this.onReject,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = draft.isApproved;
    final isRejected = draft.isRejected;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isRejected
          ? Colors.red.shade50
          : isApproved
              ? Colors.green.shade50
              : draft.needsReview
                  ? Colors.orange.shade50
                  : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status badges
          Row(
            children: [
              if (isApproved || isRejected)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    color: isApproved ? Colors.green : Colors.red,
                    child: Text(
                      isApproved ? 'APROVADO' : 'REJEITADO',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (draft.needsReview && !isApproved && !isRejected)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    color: Colors.orange,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'PRECISA REVISAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Question (front)
                Text(
                  'Pergunta:',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  draft.front,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),

                // Summary
                Row(
                  children: [
                    Text(
                      'Resumo:',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${draft.displaySummary.length}/${AiCardDraft.maxSummaryLength}',
                      style: TextStyle(
                        fontSize: 10,
                        color: draft.displaySummary.length > AiCardDraft.maxSummaryLength
                            ? Colors.red
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    draft.displaySummary,
                    style: TextStyle(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Key Phrase
                Row(
                  children: [
                    Text(
                      'Frase-chave:',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${draft.displayKeyPhrase.length}/${AiCardDraft.maxKeyPhraseLength}',
                      style: TextStyle(
                        fontSize: 10,
                        color: draft.displayKeyPhrase.length > AiCardDraft.maxKeyPhraseLength
                            ? Colors.red
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.colorScheme.secondary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    draft.displayKeyPhrase,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: context.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),

                // Explanation (if different from summary)
                if (draft.back.isNotEmpty && draft.back != draft.summary) ...[
                  const SizedBox(height: 12),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      'Ver explicação completa',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          draft.back,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Hint
                if (draft.hint != null && draft.hint!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '💡 Dica: ${draft.hint}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Actions
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                if (!isRejected)
                  TextButton(
                    onPressed: onReject,
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Rejeitar'),
                  ),
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Editar'),
                ),
                if (!isApproved)
                  FilledButton(
                    onPressed: onApprove,
                    child: const Text('Aprovar'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Edit draft bottom sheet with pedagogical fields.
class _EditDraftSheet extends ConsumerStatefulWidget {
  final AiCardDraft draft;

  const _EditDraftSheet({required this.draft});

  @override
  ConsumerState<_EditDraftSheet> createState() => _EditDraftSheetState();
}

class _EditDraftSheetState extends ConsumerState<_EditDraftSheet> {
  late final TextEditingController _frontController;
  late final TextEditingController _summaryController;
  late final TextEditingController _keyPhraseController;
  late final TextEditingController _backController;
  late final TextEditingController _hintController;
  bool _isLoading = false;
  String? _summaryError;
  String? _keyPhraseError;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(text: widget.draft.front);
    _summaryController = TextEditingController(text: widget.draft.summary ?? widget.draft.displaySummary);
    _keyPhraseController = TextEditingController(text: widget.draft.keyPhrase ?? widget.draft.displayKeyPhrase);
    _backController = TextEditingController(text: widget.draft.back);
    _hintController = TextEditingController(text: widget.draft.hint ?? '');

    // Add listeners for validation
    _summaryController.addListener(_validateSummary);
    _keyPhraseController.addListener(_validateKeyPhrase);
    _frontController.addListener(_validateSummary); // Re-validate summary when front changes
  }

  @override
  void dispose() {
    _frontController.dispose();
    _summaryController.dispose();
    _keyPhraseController.dispose();
    _backController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  void _validateSummary() {
    final summary = _summaryController.text.trim();
    final front = _frontController.text.trim();
    String? error;

    if (summary.isEmpty) {
      error = 'Resumo é obrigatório';
    } else if (summary.length > AiCardDraft.maxSummaryLength) {
      error = 'Máximo ${AiCardDraft.maxSummaryLength} caracteres';
    } else if (_normalizeText(summary) == _normalizeText(front)) {
      error = 'Resumo não pode ser igual à pergunta';
    }

    if (error != _summaryError) {
      setState(() => _summaryError = error);
    }
  }

  void _validateKeyPhrase() {
    final keyPhrase = _keyPhraseController.text.trim();
    String? error;

    if (keyPhrase.isEmpty) {
      error = 'Frase-chave é obrigatória';
    } else if (keyPhrase.length > AiCardDraft.maxKeyPhraseLength) {
      error = 'Máximo ${AiCardDraft.maxKeyPhraseLength} caracteres';
    } else if (keyPhrase.endsWith('?')) {
      error = 'Não pode ser uma pergunta';
    }

    if (error != _keyPhraseError) {
      setState(() => _keyPhraseError = error);
    }
  }

  String _normalizeText(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
                    'Editar Card',
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

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question
                      TextField(
                        controller: _frontController,
                        decoration: const InputDecoration(
                          labelText: 'Pergunta *',
                          border: OutlineInputBorder(),
                          helperText: 'A pergunta que será exibida',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Summary with counter
                      TextField(
                        controller: _summaryController,
                        decoration: InputDecoration(
                          labelText: 'Resumo *',
                          border: const OutlineInputBorder(),
                          helperText: 'Resposta curta (máx ${AiCardDraft.maxSummaryLength} chars)',
                          counterText: '${_summaryController.text.length}/${AiCardDraft.maxSummaryLength}',
                          errorText: _summaryError,
                        ),
                        maxLines: 3,
                        maxLength: AiCardDraft.maxSummaryLength + 20, // Allow slight overflow for editing
                      ),
                      const SizedBox(height: 16),

                      // Key Phrase with counter
                      TextField(
                        controller: _keyPhraseController,
                        decoration: InputDecoration(
                          labelText: 'Frase-chave *',
                          border: const OutlineInputBorder(),
                          helperText: 'Frase afirmativa memorável (máx ${AiCardDraft.maxKeyPhraseLength} chars)',
                          counterText: '${_keyPhraseController.text.length}/${AiCardDraft.maxKeyPhraseLength}',
                          errorText: _keyPhraseError,
                        ),
                        maxLines: 2,
                        maxLength: AiCardDraft.maxKeyPhraseLength + 20,
                      ),
                      const SizedBox(height: 16),

                      // Explanation (optional)
                      ExpansionTile(
                        title: const Text('Explicação completa (opcional)'),
                        tilePadding: EdgeInsets.zero,
                        children: [
                          TextField(
                            controller: _backController,
                            decoration: const InputDecoration(
                              hintText: 'Explicação detalhada...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 5,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Hint
                      TextField(
                        controller: _hintController,
                        decoration: const InputDecoration(
                          labelText: 'Dica (opcional)',
                          border: OutlineInputBorder(),
                          helperText: 'Ajuda a lembrar sem revelar',
                        ),
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
                      onPressed: _isLoading || _summaryError != null || _keyPhraseError != null
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
    // Validate before saving
    _validateSummary();
    _validateKeyPhrase();

    final front = _frontController.text.trim();
    final summary = _summaryController.text.trim();
    final keyPhrase = _keyPhraseController.text.trim();
    final back = _backController.text.trim();
    final hint = _hintController.text.trim();

    if (front.isEmpty) {
      context.showErrorSnackBar('Pergunta é obrigatória');
      return;
    }

    if (_summaryError != null || _keyPhraseError != null) {
      context.showErrorSnackBar('Corrija os erros antes de salvar');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(aiCardRepositoryProvider);
      await updateDraftDirect(
        repository,
        id: widget.draft.id,
        front: front,
        back: back.isEmpty ? summary : back, // Use summary as back if no explanation
        summary: summary,
        keyPhrase: keyPhrase,
        hint: hint.isEmpty ? null : hint,
        reviewStatus: DraftReviewStatus.edited,
        needsReview: false, // Editing clears the needsReview flag
      );

      if (mounted) {
        Navigator.pop(context);
        context.showSnackBar('Card atualizado');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackBar('Erro ao salvar: $e');
      }
    }
  }
}
