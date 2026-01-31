import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/card.dart' as domain;
import '../../../domain/entities/card_template.dart';
import '../../providers/ai_card_providers.dart';
import '../../providers/card_providers.dart';
import '../../providers/image_providers.dart';
import '../../widgets/tag_selection_widget.dart';

/// Screen for creating or editing a card with pedagogical format.
///
/// Implements UC10 (Create card), UC11 (Edit card), UC115 (Add image),
/// UC116 (Remove image), UC125 (Image as front), UC173 (Pedagogical fields),
/// UC170 (Validation), UC174 (Preview).
class CardFormScreen extends ConsumerStatefulWidget {
  final String deckId;
  final String? cardId;

  const CardFormScreen({
    super.key,
    required this.deckId,
    this.cardId,
  });

  bool get isEditing => cardId != null;

  @override
  ConsumerState<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends ConsumerState<CardFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _frontController = TextEditingController();
  final _summaryController = TextEditingController();
  final _keyPhraseController = TextEditingController();
  final _backController = TextEditingController();
  final _hintController = TextEditingController();

  late TabController _tabController;
  bool _isLoading = false;
  bool _isLoadingCard = false;
  bool _isGeneratingAi = false; // UC188: AI generation loading state
  List<String> _selectedTagIds = [];
  bool _imageAsFront = false;
  bool _showExplanation = false;

  // UC195: Template selection state
  CardTemplateType? _selectedTemplate;
  bool _showTemplateSelector = true;
  TemplateSuggestion? _templateSuggestion;

  // Validation state
  String? _frontError;
  String? _summaryError;
  String? _keyPhraseError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.isEditing) {
      _loadCard();
      _showTemplateSelector = false; // Hide template selector when editing
    }
    // Add listeners for real-time validation
    _frontController.addListener(_validateForm);
    _summaryController.addListener(_validateForm);
    _keyPhraseController.addListener(_validateForm);
    // UC200: Add listener for template suggestion
    _frontController.addListener(_updateTemplateSuggestion);
  }

  /// UC200: Update template suggestion based on question content.
  void _updateTemplateSuggestion() {
    final content = _frontController.text.trim();
    if (content.length >= 10 && _selectedTemplate == null) {
      final suggestion = suggestTemplate(content);
      if (suggestion.confidence >= 0.7) {
        setState(() => _templateSuggestion = suggestion);
      }
    }
  }

  /// UC195: Select a template and update field placeholders.
  void _selectTemplate(CardTemplateType template) {
    setState(() {
      _selectedTemplate = template;
      _showTemplateSelector = false;
      _templateSuggestion = null;
    });
  }

  /// Clear template selection.
  void _clearTemplate() {
    setState(() {
      _selectedTemplate = null;
      _showTemplateSelector = true;
    });
  }

  /// UC195: Build template selector grid.
  Widget _buildTemplateSelector() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard_customize,
                  size: 20,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Escolha um modelo (opcional)',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CardTemplateType.values.map((template) {
                return _TemplateOptionChip(
                  template: template,
                  onTap: () => _selectTemplate(template),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _showTemplateSelector = false),
              child: const Text('Pular - criar sem modelo'),
            ),
          ],
        ),
      ),
    );
  }

  /// UC195: Show selected template as a chip with clear option.
  Widget _buildSelectedTemplateChip() {
    if (_selectedTemplate == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            _getTemplateIcon(_selectedTemplate!),
            size: 18,
            color: context.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Modelo: ${_selectedTemplate!.displayName}',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: context.colorScheme.primary,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _clearTemplate,
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Trocar'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }

  /// UC200: Show template suggestion based on content.
  Widget _buildTemplateSuggestion() {
    if (_templateSuggestion == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 20,
            color: context.colorScheme.tertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sugestão: ${_templateSuggestion!.suggestedTemplate.displayName}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.onTertiaryContainer,
                  ),
                ),
                Text(
                  _templateSuggestion!.reason,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _selectTemplate(_templateSuggestion!.suggestedTemplate),
            child: const Text('Usar'),
          ),
        ],
      ),
    );
  }

  /// Get icon for template type.
  IconData _getTemplateIcon(CardTemplateType template) {
    switch (template) {
      case CardTemplateType.definition:
        return Icons.menu_book;
      case CardTemplateType.qAndA:
        return Icons.question_answer;
      case CardTemplateType.cloze:
        return Icons.text_fields;
      case CardTemplateType.trueFalse:
        return Icons.check_circle_outline;
    }
  }

  /// UC196-199: Build template validation warning/suggestion.
  Widget _buildTemplateValidation() {
    if (_selectedTemplate == null) return const SizedBox.shrink();

    final question = _frontController.text.trim();
    if (question.isEmpty) return const SizedBox.shrink();

    final validation = TemplateValidation.validate(_selectedTemplate!, question);

    if (validation.warning == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: validation.isValid
              ? context.colorScheme.tertiaryContainer.withValues(alpha: 0.5)
              : context.colorScheme.errorContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              validation.isValid ? Icons.lightbulb_outline : Icons.warning_amber,
              size: 16,
              color: validation.isValid
                  ? context.colorScheme.tertiary
                  : context.colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    validation.warning!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: validation.isValid
                          ? context.colorScheme.onTertiaryContainer
                          : context.colorScheme.onErrorContainer,
                    ),
                  ),
                  if (validation.suggestion != null) ...[
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () {
                        _frontController.text = validation.suggestion!;
                        _validateForm();
                      },
                      child: Text(
                        'Sugestão: "${validation.suggestion}"',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadCard() async {
    setState(() => _isLoadingCard = true);

    final result =
        await ref.read(cardRepositoryProvider).getCardById(widget.cardId!);

    result.fold(
      (failure) {
        if (mounted) {
          context.showErrorSnackBar('Erro ao carregar card: ${failure.message}');
          context.pop();
        }
      },
      (card) {
        if (card != null && mounted) {
          _frontController.text = card.front;
          _summaryController.text = card.summary ?? '';
          _keyPhraseController.text = card.keyPhrase ?? '';
          _backController.text = card.back;
          _hintController.text = card.hint ?? '';
          _selectedTagIds = List.from(card.tagIds);
          _imageAsFront = card.imageAsFront;
          _showExplanation = card.back.isNotEmpty &&
              (card.summary == null || card.back != card.summary);

          // Initialize image provider with existing URL
          if (card.imageUrl != null) {
            ref.read(cardImageNotifierProvider.notifier).initWithUrl(card.imageUrl);
          }
        }
      },
    );

    if (mounted) {
      setState(() => _isLoadingCard = false);
    }
  }

  @override
  void dispose() {
    _frontController.dispose();
    _summaryController.dispose();
    _keyPhraseController.dispose();
    _backController.dispose();
    _hintController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      final imageState = ref.read(cardImageNotifierProvider);

      // RN11: Pergunta validation
      final front = _frontController.text.trim();
      if (!_imageAsFront || !imageState.hasImage) {
        if (front.isEmpty) {
          _frontError = 'Pergunta é obrigatória';
        } else if (front.length < 8) {
          _frontError = 'Pergunta deve ter no mínimo 8 caracteres';
        } else if (front == '???' || front == '?') {
          _frontError = 'Pergunta inválida';
        } else {
          _frontError = null;
        }
      } else {
        _frontError = null;
      }

      // RN06: Summary validation
      final summary = _summaryController.text.trim();
      if (summary.isEmpty) {
        _summaryError = 'Resumo é obrigatório';
      } else if (summary.length > domain.Card.maxSummaryLength) {
        _summaryError =
            'Resumo deve ter no máximo ${domain.Card.maxSummaryLength} caracteres';
      } else if (_normalizeText(summary) == _normalizeText(front)) {
        _summaryError = 'Resumo não pode ser igual à pergunta';
      } else {
        _summaryError = null;
      }

      // RN07: KeyPhrase validation
      final keyPhrase = _keyPhraseController.text.trim();
      if (keyPhrase.isEmpty) {
        _keyPhraseError = 'Frase-chave é obrigatória';
      } else if (keyPhrase.length > domain.Card.maxKeyPhraseLength) {
        _keyPhraseError =
            'Frase-chave deve ter no máximo ${domain.Card.maxKeyPhraseLength} caracteres';
      } else if (keyPhrase.endsWith('?')) {
        _keyPhraseError = 'Frase-chave não pode ser uma pergunta';
      } else {
        _keyPhraseError = null;
      }
    });
  }

  String _normalizeText(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool get _isFormValid {
    return _frontError == null &&
        _summaryError == null &&
        _keyPhraseError == null &&
        _summaryController.text.trim().isNotEmpty &&
        _keyPhraseController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(cardImageNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Card' : 'Novo Card'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Editor'),
            Tab(text: 'Prévia'),
          ],
        ),
      ),
      body: _isLoadingCard
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEditorTab(imageState),
                _buildPreviewTab(),
              ],
            ),
    );
  }

  Widget _buildEditorTab(CardImageState imageState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // UC195: Template Selection (only for new cards)
            if (!widget.isEditing && _showTemplateSelector)
              _buildTemplateSelector(),
            if (!widget.isEditing && _selectedTemplate != null)
              _buildSelectedTemplateChip(),
            if (_templateSuggestion != null && _selectedTemplate == null)
              _buildTemplateSuggestion(),

            // Image Section (UC115)
            _ImageSection(
              imageState: imageState,
              imageAsFront: _imageAsFront,
              onImageAsFrontChanged: (value) {
                setState(() => _imageAsFront = value);
                _validateForm();
              },
              onPickFromGallery: () async {
                await ref
                    .read(cardImageNotifierProvider.notifier)
                    .pickFromGallery();
                if (ref.read(cardImageNotifierProvider).hasImage &&
                    !_imageAsFront) {
                  setState(() => _imageAsFront = true);
                }
                _validateForm();
              },
              onPickFromCamera: () async {
                await ref
                    .read(cardImageNotifierProvider.notifier)
                    .pickFromCamera();
                if (ref.read(cardImageNotifierProvider).hasImage &&
                    !_imageAsFront) {
                  setState(() => _imageAsFront = true);
                }
                _validateForm();
              },
              onRemoveImage: () {
                ref.read(cardImageNotifierProvider.notifier).removeImage(
                      cardId: widget.cardId,
                    );
                setState(() => _imageAsFront = false);
                _validateForm();
              },
            ),
            const SizedBox(height: 16),

            // Pergunta field (Question)
            _buildFieldWithCounter(
              controller: _frontController,
              label: 'Pergunta',
              hint: _selectedTemplate?.questionPlaceholder ?? 'O que você quer lembrar?',
              error: _frontError,
              maxLines: 3,
              autofocus: !widget.isEditing,
              isOptional: _imageAsFront && imageState.hasImage,
            ),
            // UC196-199: Template validation warning
            if (_selectedTemplate != null) _buildTemplateValidation(),
            const SizedBox(height: 16),

            // UC188/UC190: "Gerar com IA" button
            _buildAiGenerationButton(),
            const SizedBox(height: 16),

            // Resumo field (Summary) - Required
            _buildFieldWithCounter(
              controller: _summaryController,
              label: 'Resumo',
              hint: _selectedTemplate?.summaryPlaceholder ?? 'Resposta curta (para memorizar rápido)',
              error: _summaryError,
              maxLength: domain.Card.maxSummaryLength,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Frase-chave field (Key Phrase) - Required
            _buildFieldWithCounter(
              controller: _keyPhraseController,
              label: 'Frase-chave',
              hint: _selectedTemplate?.keyPhrasePlaceholder ?? 'Em uma frase (âncora de memória)',
              error: _keyPhraseError,
              maxLength: domain.Card.maxKeyPhraseLength,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Explicação completa (Explanation) - Optional, collapsible
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => setState(() => _showExplanation = !_showExplanation),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            _showExplanation
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Explicação completa (opcional)',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showExplanation)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: TextFormField(
                        controller: _backController,
                        decoration: const InputDecoration(
                          hintText: 'Detalhes adicionais para aprofundamento',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 5,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dica field (Hint) - Optional
            TextFormField(
              controller: _hintController,
              decoration: const InputDecoration(
                labelText: 'Dica (opcional)',
                hintText: 'Uma dica para lembrar a resposta',
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Tags
            TagSelectionWidget(
              selectedTagIds: _selectedTagIds,
              onChanged: (ids) => setState(() => _selectedTagIds = ids),
            ),
            const SizedBox(height: 32),

            // Save button
            FilledButton(
              onPressed: _isFormValid && !_isLoading && !imageState.isUploading
                  ? _saveCard
                  : null,
              child: _isLoading || imageState.isUploading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        if (imageState.isUploading) ...[
                          const SizedBox(width: 12),
                          const Text('Enviando imagem...'),
                        ],
                      ],
                    )
                  : Text(widget.isEditing ? 'Atualizar card' : 'Salvar card'),
            ),

            if (!widget.isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed:
                    _isFormValid && !_isLoading && !imageState.isUploading
                        ? _saveAndCreateAnother
                        : null,
                child: const Text('Criar e adicionar outro'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFieldWithCounter({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? error,
    int? maxLength,
    int maxLines = 1,
    bool autofocus = false,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isOptional)
              Text(
                ' *',
                style: TextStyle(color: context.colorScheme.error),
              ),
            const Spacer(),
            if (maxLength != null)
              Text(
                '${controller.text.length}/$maxLength',
                style: context.textTheme.bodySmall?.copyWith(
                  color: controller.text.length > maxLength
                      ? context.colorScheme.error
                      : context.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            alignLabelWithHint: true,
            border: const OutlineInputBorder(),
            errorText: error,
          ),
          textCapitalization: TextCapitalization.sentences,
          maxLines: maxLines,
          autofocus: autofocus,
        ),
      ],
    );
  }

  /// UC188/UC190: Button to generate pedagogical fields using AI.
  Widget _buildAiGenerationButton() {
    final aiService = ref.watch(aiGenerationServiceProvider);
    final hasContent = _frontController.text.trim().length >= 8 ||
        _backController.text.trim().isNotEmpty;

    // Don't show if both summary and keyPhrase are already filled
    final hasPedagogicalFields = _summaryController.text.trim().isNotEmpty &&
        _keyPhraseController.text.trim().isNotEmpty;

    if (hasPedagogicalFields && !_isGeneratingAi) {
      return const SizedBox.shrink();
    }

    return Card(
      color: context.colorScheme.secondaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: context.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Gerar com IA',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Preencha a pergunta e/ou explicação e deixe a IA gerar o resumo e frase-chave automaticamente.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            if (aiService == null) ...[
              // UC189: No API key configured
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 16,
                      color: context.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Configure sua chave de API nas configurações para usar IA.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              FilledButton.tonalIcon(
                onPressed: hasContent && !_isGeneratingAi
                    ? _generatePedagogicalFields
                    : null,
                icon: _isGeneratingAi
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.colorScheme.onSecondaryContainer,
                        ),
                      )
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(
                  _isGeneratingAi ? 'Gerando...' : 'Gerar resumo e frase-chave',
                ),
              ),
              if (!hasContent) ...[
                const SizedBox(height: 4),
                Text(
                  'Digite a pergunta (min. 8 caracteres) ou explicação primeiro.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// UC188/UC190: Generate pedagogical fields using AI.
  Future<void> _generatePedagogicalFields() async {
    final aiService = ref.read(aiGenerationServiceProvider);
    if (aiService == null) return;

    final question = _frontController.text.trim();
    final answer = _backController.text.trim();

    // Need at least question or answer
    if (question.length < 8 && answer.isEmpty) {
      context.showErrorSnackBar(
        'Digite a pergunta (min. 8 caracteres) ou explicação primeiro.',
      );
      return;
    }

    setState(() => _isGeneratingAi = true);

    try {
      // UC191: Track AI usage (could be implemented with a counter/quota system)
      final fields = await generatePedagogicalFieldsDirect(
        aiService,
        question: question.isNotEmpty ? question : 'Explique: $answer',
        answer: answer.isNotEmpty ? answer : question,
      );

      if (mounted) {
        setState(() {
          _summaryController.text = fields.summary;
          _keyPhraseController.text = fields.keyPhrase;
          _isGeneratingAi = false;
        });
        _validateForm();

        if (fields.needsReview) {
          context.showSnackBar(
            'Campos gerados! Revise o conteúdo antes de salvar.',
          );
        } else {
          context.showSnackBar('Campos gerados com sucesso!');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingAi = false);
        context.showErrorSnackBar(
          'Erro ao gerar: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    }
  }

  Widget _buildPreviewTab() {
    final front = _frontController.text.trim();
    final summary = _summaryController.text.trim();
    final keyPhrase = _keyPhraseController.text.trim();
    final explanation = _backController.text.trim();
    final hint = _hintController.text.trim();
    final imageState = ref.watch(cardImageNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info card
          Card(
            color: context.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Prévia de como o card aparecerá no estudo',
                      style: TextStyle(
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Card preview - Question side
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PERGUNTA',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_imageAsFront && imageState.hasImage) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _buildImagePreview(imageState),
                      ),
                    ),
                    if (front.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        front,
                        style: context.textTheme.bodyLarge,
                      ),
                    ],
                  ] else ...[
                    Text(
                      front.isEmpty ? '(Pergunta vazia)' : front,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: front.isEmpty
                            ? context.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                  ],
                  if (hint.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hint,
                              style: context.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Card preview - Answer side
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RESPOSTA',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Summary
                  Text(
                    summary.isEmpty ? '(Resumo vazio)' : summary,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: summary.isEmpty
                          ? context.colorScheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Key Phrase
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.key,
                          size: 16,
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            keyPhrase.isEmpty ? '(Frase-chave vazia)' : keyPhrase,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: keyPhrase.isEmpty
                                  ? context.colorScheme.onSurfaceVariant
                                  : context.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Explanation (if present)
                  if (explanation.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: const Text('Ver explicação completa'),
                      tilePadding: EdgeInsets.zero,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            explanation,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(CardImageState imageState) {
    if (imageState.imageBytes != null) {
      return Image.memory(
        imageState.imageBytes!,
        fit: BoxFit.cover,
      );
    } else if (imageState.imageUrl != null) {
      if (kIsWeb) {
        return Image.network(
          imageState.imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: context.colorScheme.surfaceContainerHighest,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: context.colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.error_outline),
          ),
        );
      } else {
        return CachedNetworkImage(
          imageUrl: imageState.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: context.colorScheme.surfaceContainerHighest,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: context.colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.error_outline),
          ),
        );
      }
    }
    return Container(
      color: context.colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.image_outlined),
    );
  }

  Future<void> _saveCard() async {
    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    final repository = ref.read(cardRepositoryProvider);
    final imageNotifier = ref.read(cardImageNotifierProvider.notifier);
    final imageState = ref.read(cardImageNotifierProvider);

    final front = _frontController.text.trim();
    final summary = _summaryController.text.trim();
    final keyPhrase = _keyPhraseController.text.trim();
    final back = _backController.text.trim();
    final hint = _hintController.text.trim();

    // Use back as summary fallback for backward compatibility
    final finalBack = back.isNotEmpty ? back : summary;

    try {
      String? imageUrl = imageState.imageUrl;

      // Upload image if there's a new one selected
      if (imageState.selectedImage != null || imageState.imageBytes != null) {
        final cardId =
            widget.cardId ?? DateTime.now().millisecondsSinceEpoch.toString();
        imageUrl = await imageNotifier.uploadImage(cardId);
      }

      if (widget.isEditing) {
        await updateCardDirect(
          repository,
          id: widget.cardId!,
          front: front,
          back: finalBack,
          summary: summary,
          keyPhrase: keyPhrase,
          hint: hint.isEmpty ? null : hint,
          tagIds: _selectedTagIds,
          imageUrl: imageUrl,
          imageAsFront: _imageAsFront,
        );

        if (mounted) {
          context.showSnackBar('Card atualizado');
          context.pop();
        }
      } else {
        await createCardDirect(
          repository,
          deckId: widget.deckId,
          front: front,
          back: finalBack,
          summary: summary,
          keyPhrase: keyPhrase,
          hint: hint.isEmpty ? null : hint,
          tagIds: _selectedTagIds,
          imageUrl: imageUrl,
          imageAsFront: _imageAsFront,
        );

        if (mounted) {
          context.showSnackBar('Card criado');
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _saveAndCreateAnother() async {
    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    final repository = ref.read(cardRepositoryProvider);
    final imageNotifier = ref.read(cardImageNotifierProvider.notifier);
    final imageState = ref.read(cardImageNotifierProvider);

    final front = _frontController.text.trim();
    final summary = _summaryController.text.trim();
    final keyPhrase = _keyPhraseController.text.trim();
    final back = _backController.text.trim();
    final hint = _hintController.text.trim();

    // Use back as summary fallback for backward compatibility
    final finalBack = back.isNotEmpty ? back : summary;

    try {
      String? imageUrl;

      // Upload image if there's one selected
      if (imageState.selectedImage != null || imageState.imageBytes != null) {
        final cardId = DateTime.now().millisecondsSinceEpoch.toString();
        imageUrl = await imageNotifier.uploadImage(cardId);
      }

      await createCardDirect(
        repository,
        deckId: widget.deckId,
        front: front,
        back: finalBack,
        summary: summary,
        keyPhrase: keyPhrase,
        hint: hint.isEmpty ? null : hint,
        tagIds: _selectedTagIds,
        imageUrl: imageUrl,
        imageAsFront: _imageAsFront,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        context.showSnackBar('Card criado');
        _frontController.clear();
        _summaryController.clear();
        _keyPhraseController.clear();
        _backController.clear();
        _hintController.clear();
        imageNotifier.clear();
        setState(() {
          _selectedTagIds = [];
          _imageAsFront = false;
          _showExplanation = false;
          _frontError = null;
          _summaryError = null;
          _keyPhraseError = null;
        });
        // Reset to editor tab
        _tabController.animateTo(0);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }
}

/// Widget for image selection and preview (UC115, UC116, UC125).
class _ImageSection extends StatelessWidget {
  final CardImageState imageState;
  final bool imageAsFront;
  final ValueChanged<bool> onImageAsFrontChanged;
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;
  final VoidCallback onRemoveImage;

  const _ImageSection({
    required this.imageState,
    required this.imageAsFront,
    required this.onImageAsFrontChanged,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.image_outlined,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Imagem',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (imageState.hasImage)
                  TextButton.icon(
                    onPressed: onRemoveImage,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Remover'),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colorScheme.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Image preview or selection buttons
            if (imageState.hasImage)
              _ImagePreview(imageState: imageState)
            else
              _ImagePickerButtons(
                onPickFromGallery: onPickFromGallery,
                onPickFromCamera: onPickFromCamera,
              ),

            // Image as front toggle (UC125)
            if (imageState.hasImage) ...[
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Usar imagem como frente'),
                subtitle: const Text('A imagem será a pergunta do card'),
                value: imageAsFront,
                onChanged: onImageAsFrontChanged,
                contentPadding: EdgeInsets.zero,
              ),
            ],

            // Error message
            if (imageState.error != null) ...[
              const SizedBox(height: 8),
              Text(
                imageState.error!,
                style: TextStyle(
                  color: context.colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Image preview widget.
class _ImagePreview extends StatelessWidget {
  final CardImageState imageState;

  const _ImagePreview({required this.imageState});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            if (imageState.imageBytes != null)
              Image.memory(
                imageState.imageBytes!,
                fit: BoxFit.cover,
              )
            else if (imageState.imageUrl != null)
              kIsWeb
                  ? Image.network(
                      imageState.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: context.colorScheme.surfaceContainerHighest,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: context.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.error_outline),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: imageState.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: context.colorScheme.surfaceContainerHighest,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: context.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.error_outline),
                      ),
                    ),

            // Upload progress overlay
            if (imageState.isUploading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        'Enviando...',
                        style: TextStyle(color: Colors.white),
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
}

/// Buttons for picking image from gallery or camera.
class _ImagePickerButtons extends StatelessWidget {
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;

  const _ImagePickerButtons({
    required this.onPickFromGallery,
    required this.onPickFromCamera,
  });

  @override
  Widget build(BuildContext context) {
    // On web, only show gallery button (no camera access)
    if (kIsWeb) {
      return OutlinedButton.icon(
        onPressed: onPickFromGallery,
        icon: const Icon(Icons.photo_library_outlined),
        label: const Text('Selecionar imagem'),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPickFromGallery,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Galeria'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPickFromCamera,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Câmera'),
          ),
        ),
      ],
    );
  }
}

/// UC195-UC199: Template option chip for selection grid.
class _TemplateOptionChip extends StatelessWidget {
  final CardTemplateType template;
  final VoidCallback onTap;

  const _TemplateOptionChip({
    required this.template,
    required this.onTap,
  });

  IconData get _icon {
    switch (template) {
      case CardTemplateType.definition:
        return Icons.menu_book;
      case CardTemplateType.qAndA:
        return Icons.question_answer;
      case CardTemplateType.cloze:
        return Icons.text_fields;
      case CardTemplateType.trueFalse:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _icon,
                size: 24,
                color: context.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                template.displayName,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                template.description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
