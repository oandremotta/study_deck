import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../providers/deck_providers.dart';

/// Screen for creating or editing a deck.
///
/// Implements UC07 (Create deck) and UC08 (Edit deck).
class DeckFormScreen extends ConsumerStatefulWidget {
  final String? deckId;
  final String? folderId;

  const DeckFormScreen({
    super.key,
    this.deckId,
    this.folderId,
  });

  bool get isEditing => deckId != null;

  @override
  ConsumerState<DeckFormScreen> createState() => _DeckFormScreenState();
}

class _DeckFormScreenState extends ConsumerState<DeckFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingDeck = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadDeck();
    }
  }

  Future<void> _loadDeck() async {
    setState(() => _isLoadingDeck = true);

    final result = await ref.read(deckRepositoryProvider).getDeckById(widget.deckId!);

    result.fold(
      (failure) {
        if (mounted) {
          context.showErrorSnackBar('Erro ao carregar deck: ${failure.message}');
          context.pop();
        }
      },
      (deck) {
        if (deck != null && mounted) {
          _nameController.text = deck.name;
          _descriptionController.text = deck.description ?? '';
        }
      },
    );

    if (mounted) {
      setState(() => _isLoadingDeck = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Deck' : 'Novo Deck'),
      ),
      body: _isLoadingDeck
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do deck',
                        hintText: 'Ex: Vocabulario Ingles',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      autofocus: !widget.isEditing,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Digite o nome do deck';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descricao (opcional)',
                        hintText: 'Descreva o conteudo do deck',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _isLoading ? null : _saveDeck,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(widget.isEditing ? 'Salvar' : 'Criar Deck'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveDeck() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(deckRepositoryProvider);
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();

      if (widget.isEditing) {
        await updateDeckDirect(
          repository,
          id: widget.deckId!,
          name: name,
          description: description.isEmpty ? null : description,
        );
      } else {
        await createDeckDirect(
          repository,
          name: name,
          description: description.isEmpty ? null : description,
          folderId: widget.folderId,
        );
      }

      if (mounted) {
        context.showSnackBar(
          widget.isEditing ? 'Deck atualizado' : 'Deck criado',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
