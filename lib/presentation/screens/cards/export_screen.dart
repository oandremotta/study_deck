import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../providers/card_providers.dart';
import '../../providers/deck_providers.dart';

/// Screen for exporting a deck to CSV or text.
///
/// Implements UC18 (Export deck).
class ExportScreen extends ConsumerStatefulWidget {
  final String deckId;

  const ExportScreen({
    super.key,
    required this.deckId,
  });

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String _separator = ';';
  bool _includeHints = false;
  String _exportedText = '';

  @override
  void initState() {
    super.initState();
    _generateExport();
  }

  void _generateExport() {
    final cardsAsync = ref.read(cardsByDeckProvider(widget.deckId));
    cardsAsync.whenData((cards) {
      final buffer = StringBuffer();

      for (final card in cards) {
        buffer.write(card.front);
        buffer.write(_separator);
        buffer.write(card.back);
        if (_includeHints && card.hint != null && card.hint!.isNotEmpty) {
          buffer.write(_separator);
          buffer.write(card.hint);
        }
        buffer.writeln();
      }

      setState(() {
        _exportedText = buffer.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final deckAsync = ref.watch(deckByIdProvider(widget.deckId));
    final cardsAsync = ref.watch(cardsByDeckProvider(widget.deckId));

    return Scaffold(
      appBar: AppBar(
        title: deckAsync.when(
          loading: () => const Text('Exportar Deck'),
          error: (_, __) => const Text('Exportar Deck'),
          data: (deck) => Text('Exportar: ${deck?.name ?? "Deck"}'),
        ),
      ),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Erro ao carregar cards: $error'),
        ),
        data: (cards) {
          if (cards.isEmpty) {
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
                    'Nenhum card para exportar',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Opcoes de exportacao',
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Separador:', style: context.textTheme.bodyMedium),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: ';', label: Text(';')),
                          ButtonSegment(value: '\t', label: Text('Tab')),
                          ButtonSegment(value: ',', label: Text(',')),
                        ],
                        selected: {_separator},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _separator = selection.first;
                          });
                          _generateExport();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Incluir dicas'),
                  value: _includeHints,
                  onChanged: (value) {
                    setState(() {
                      _includeHints = value ?? false;
                    });
                    _generateExport();
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Pre-visualizacao (${cards.length} cards):',
                  style: context.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.colorScheme.outlineVariant,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _exportedText,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar para area de transferencia'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement file save
                    context.showSnackBar('Funcao em desenvolvimento');
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Salvar como arquivo CSV'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _exportedText));
    context.showSnackBar('Copiado para area de transferencia');
  }
}
