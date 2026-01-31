import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/community_deck.dart';
import '../../router/app_router.dart';

/// UC179-180: Publish deck to community screen.
///
/// Allows users to:
/// - Select a deck to publish
/// - Add description and tags
/// - Choose category
/// - Submit for moderation
class PublishDeckScreen extends ConsumerStatefulWidget {
  const PublishDeckScreen({super.key});

  @override
  ConsumerState<PublishDeckScreen> createState() => _PublishDeckScreenState();
}

class _PublishDeckScreenState extends ConsumerState<PublishDeckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();

  String? _selectedDeckId;
  DeckCategory _selectedCategory = DeckCategory.other;
  final List<String> _tags = [];
  bool _isLoading = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: Replace with actual decks provider
    final myDecks = [
      {'id': 'd1', 'name': 'Ingles Basico', 'cardCount': 150},
      {'id': 'd2', 'name': 'Biologia Celular', 'cardCount': 80},
      {'id': 'd3', 'name': 'Matematica', 'cardCount': 60},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Deck'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Compartilhe seus decks com a comunidade! Todos os decks passam por moderacao antes de serem publicados.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Selecione o deck',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedDeckId,
                decoration: InputDecoration(
                  hintText: 'Escolha um deck',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: myDecks
                    .map((deck) => DropdownMenuItem(
                          value: deck['id'] as String,
                          child: Text(
                            '${deck['name']} (${deck['cardCount']} cards)',
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDeckId = value;
                    final deck = myDecks.firstWhere((d) => d['id'] == value);
                    _titleController.text = deck['name'] as String;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecione um deck' : null,
              ),
              const SizedBox(height: 24),
              Text(
                'Titulo',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Nome do deck na comunidade',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Digite um titulo';
                  }
                  if (value.trim().length < 5) {
                    return 'Titulo muito curto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Descricao',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Descreva o conteudo do deck',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Digite uma descricao';
                  }
                  if (value.trim().length < 20) {
                    return 'Descricao muito curta (minimo 20 caracteres)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Categoria',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<DeckCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: DeckCategory.values
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Tags',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        hintText: 'Adicionar tag',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: _addTag,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _addTag(_tagController.text),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tags
                      .map((tag) => Chip(
                            label: Text(tag),
                            onDeleted: () => _removeTag(tag),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              Card(
                child: CheckboxListTile(
                  value: _acceptedTerms,
                  onChanged: (value) =>
                      setState(() => _acceptedTerms = value ?? false),
                  title: const Text('Li e aceito os termos de uso'),
                  subtitle: const Text(
                    'O deck sera revisado pela moderacao antes de ser publicado.',
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _acceptedTerms && !_isLoading ? _submitForReview : null,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enviar para revisao'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _addTag(String tag) {
    final trimmed = tag.trim().toLowerCase();
    if (trimmed.isNotEmpty && !_tags.contains(trimmed) && _tags.length < 5) {
      setState(() {
        _tags.add(trimmed);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  Future<void> _submitForReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Submit to community
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Enviado!'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Seu deck foi enviado para revisao.'),
            SizedBox(height: 8),
            Text(
              'Voce recebera uma notificacao quando ele for aprovado ou se precisar de ajustes.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.communityBrowse);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
