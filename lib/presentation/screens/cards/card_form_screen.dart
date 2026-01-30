import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../providers/card_providers.dart';
import '../../widgets/tag_selection_widget.dart';

/// Screen for creating or editing a card.
///
/// Implements UC10 (Create card) and UC11 (Edit card).
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

class _CardFormScreenState extends ConsumerState<CardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  final _hintController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingCard = false;
  List<String> _selectedTagIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadCard();
    }
  }

  Future<void> _loadCard() async {
    setState(() => _isLoadingCard = true);

    final result = await ref.read(cardRepositoryProvider).getCardById(widget.cardId!);

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
          _backController.text = card.back;
          _hintController.text = card.hint ?? '';
          _selectedTagIds = List.from(card.tagIds);
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
    _backController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Card' : 'Novo Card'),
      ),
      body: _isLoadingCard
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _frontController,
                      decoration: const InputDecoration(
                        labelText: 'Frente (pergunta)',
                        hintText: 'Digite a pergunta ou termo',
                        alignLabelWithHint: true,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      autofocus: !widget.isEditing,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Digite o conteudo da frente';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _backController,
                      decoration: const InputDecoration(
                        labelText: 'Verso (resposta)',
                        hintText: 'Digite a resposta ou definicao',
                        alignLabelWithHint: true,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Digite o conteudo do verso';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                    TagSelectionWidget(
                      selectedTagIds: _selectedTagIds,
                      onChanged: (ids) => setState(() => _selectedTagIds = ids),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _isLoading ? null : _saveCard,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(widget.isEditing ? 'Salvar' : 'Criar Card'),
                    ),
                    if (!widget.isEditing) ...[
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _isLoading ? null : _saveAndCreateAnother,
                        child: const Text('Criar e adicionar outro'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final repository = ref.read(cardRepositoryProvider);
    final front = _frontController.text.trim();
    final back = _backController.text.trim();
    final hint = _hintController.text.trim();

    try {
      if (widget.isEditing) {
        await updateCardDirect(
          repository,
          id: widget.cardId!,
          front: front,
          back: back,
          hint: hint.isEmpty ? null : hint,
          tagIds: _selectedTagIds,
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
          back: back,
          hint: hint.isEmpty ? null : hint,
          tagIds: _selectedTagIds,
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final repository = ref.read(cardRepositoryProvider);
    final front = _frontController.text.trim();
    final back = _backController.text.trim();
    final hint = _hintController.text.trim();

    try {
      await createCardDirect(
        repository,
        deckId: widget.deckId,
        front: front,
        back: back,
        hint: hint.isEmpty ? null : hint,
        tagIds: _selectedTagIds,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        context.showSnackBar('Card criado');
        _frontController.clear();
        _backController.clear();
        _hintController.clear();
        setState(() => _selectedTagIds = []);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }
}
