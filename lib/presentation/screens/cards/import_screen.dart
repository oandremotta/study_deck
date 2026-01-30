import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/card.dart' as entities;
import '../../providers/card_providers.dart';

/// Screen for importing cards from CSV or text.
///
/// Implements UC16 (Import CSV) and UC17 (Import by pasting text).
class ImportScreen extends ConsumerStatefulWidget {
  final String deckId;

  const ImportScreen({
    super.key,
    required this.deckId,
  });

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _textController = TextEditingController();
  String _separator = ';';
  bool _isLoading = false;
  List<_ParsedCard> _parsedCards = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Cards'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Colar Texto'),
            Tab(text: 'Arquivo CSV'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTextImportTab(),
          _buildCsvImportTab(),
        ],
      ),
    );
  }

  Widget _buildTextImportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cole o texto com seus cards abaixo.',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Formato: Uma linha por card, com frente e verso separados pelo delimitador escolhido.',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Separador:', style: context.textTheme.bodyMedium),
              const SizedBox(width: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: ';', label: Text('; (ponto e virgula)')),
                  ButtonSegment(value: '\t', label: Text('Tab')),
                  ButtonSegment(value: ',', label: Text(', (virgula)')),
                ],
                selected: {_separator},
                onSelectionChanged: (selection) {
                  setState(() {
                    _separator = selection.first;
                    _parseText();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: 'Texto',
              hintText: 'Exemplo:\nPalavra${_separator}Traducao\nHello${_separator}Ola',
              alignLabelWithHint: true,
            ),
            maxLines: 10,
            onChanged: (_) => _parseText(),
          ),
          const SizedBox(height: 16),
          if (_parsedCards.isNotEmpty) ...[
            Text(
              'Pre-visualizacao (${_parsedCards.length} cards):',
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _parsedCards.length,
                itemBuilder: (context, index) {
                  final card = _parsedCards[index];
                  return ListTile(
                    dense: true,
                    leading: Text(
                      '${index + 1}',
                      style: context.textTheme.bodySmall,
                    ),
                    title: Text(
                      card.front,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      card.back,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: card.isValid
                        ? Icon(Icons.check, color: context.colorScheme.primary)
                        : Icon(Icons.error, color: context.colorScheme.error),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: _isLoading || _parsedCards.isEmpty ? null : _importCards,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Importar ${_parsedCards.where((c) => c.isValid).length} Cards'),
          ),
        ],
      ),
    );
  }

  Widget _buildCsvImportTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.upload_file_outlined,
            size: 64,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Importar arquivo CSV',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Selecione um arquivo CSV com duas colunas:\nfrente e verso',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement file picker
              context.showSnackBar('Funcao em desenvolvimento');
            },
            icon: const Icon(Icons.folder_open),
            label: const Text('Selecionar Arquivo'),
          ),
        ],
      ),
    );
  }

  void _parseText() {
    final text = _textController.text;
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty);

    setState(() {
      _parsedCards = lines.map((line) {
        final parts = line.split(_separator);
        if (parts.length >= 2) {
          return _ParsedCard(
            front: parts[0].trim(),
            back: parts[1].trim(),
            isValid: parts[0].trim().isNotEmpty && parts[1].trim().isNotEmpty,
          );
        }
        return _ParsedCard(front: line, back: '', isValid: false);
      }).toList();
    });
  }

  Future<void> _importCards() async {
    final validCards = _parsedCards.where((c) => c.isValid).toList();
    if (validCards.isEmpty) return;

    setState(() => _isLoading = true);

    final notifier = ref.read(cardNotifierProvider.notifier);
    final cards = validCards
        .map((c) => entities.Card.create(
              id: '',
              deckId: widget.deckId,
              front: c.front,
              back: c.back,
            ))
        .toList();

    final result = await notifier.createCards(cards);

    if (mounted) {
      setState(() => _isLoading = false);

      if (result != null) {
        context.showSnackBar('${result.length} cards importados');
        context.pop();
      } else {
        context.showErrorSnackBar('Erro ao importar cards');
      }
    }
  }
}

class _ParsedCard {
  final String front;
  final String back;
  final bool isValid;

  _ParsedCard({
    required this.front,
    required this.back,
    required this.isValid,
  });
}
