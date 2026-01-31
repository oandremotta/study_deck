import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/ai_project.dart';
import '../../providers/ai_card_providers.dart';
import '../../router/app_router.dart';

/// Screen for creating cards from pasted text (UC132).
class CreateFromTextScreen extends ConsumerStatefulWidget {
  const CreateFromTextScreen({super.key});

  @override
  ConsumerState<CreateFromTextScreen> createState() =>
      _CreateFromTextScreenState();
}

class _CreateFromTextScreenState extends ConsumerState<CreateFromTextScreen> {
  final _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textLength = _textController.text.length;
    final isValid = textLength >= 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerar de Texto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cole ou digite o conteudo',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A IA ira analisar o texto e criar flashcards com os conceitos mais importantes.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Cole seu texto aqui...\n\nExemplo: artigos, resumos, anotacoes de aula, etc.',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                  counterText: '$textLength caracteres',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 8),
            if (textLength > 0 && textLength < 100)
              Text(
                'Minimo de 100 caracteres para gerar cards',
                style: TextStyle(
                  color: context.colorScheme.error,
                  fontSize: 12,
                ),
              ),
            if (textLength > 50000)
              Text(
                'Texto muito longo. Maximo recomendado: 50.000 caracteres',
                style: TextStyle(
                  color: context.colorScheme.error,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isValid && !_isLoading ? _continue : null,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continue() async {
    final text = _textController.text.trim();
    if (text.length < 100) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(aiCardRepositoryProvider);
      final project = await createAiProjectDirect(
        repository,
        sourceType: AiSourceType.text,
        extractedText: text,
      );

      if (mounted) {
        context.pushReplacement(
          '${AppRouter.aiConfig}/${project.id}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackBar('Erro ao criar projeto: $e');
      }
    }
  }
}
