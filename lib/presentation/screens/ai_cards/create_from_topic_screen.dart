import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/ai_project.dart';
import '../../providers/ai_card_providers.dart';
import '../../router/app_router.dart';

/// Screen for creating cards from a topic (UC131).
class CreateFromTopicScreen extends ConsumerStatefulWidget {
  const CreateFromTopicScreen({super.key});

  @override
  ConsumerState<CreateFromTopicScreen> createState() =>
      _CreateFromTopicScreenState();
}

class _CreateFromTopicScreenState extends ConsumerState<CreateFromTopicScreen> {
  final _topicController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topicLength = _topicController.text.trim().length;
    final isValid = topicLength >= 3 && topicLength <= 200;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerar por Assunto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Qual assunto voce quer estudar?',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A IA ira gerar flashcards sobre o assunto escolhido.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _topicController,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Assunto',
                hintText: 'Ex: Revolucao Francesa, Fotossintese, etc.',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (isValid && !_isLoading) _continue();
              },
            ),
            const SizedBox(height: 8),
            if (topicLength > 0 && topicLength < 3)
              Text(
                'Digite pelo menos 3 caracteres',
                style: TextStyle(
                  color: context.colorScheme.error,
                  fontSize: 12,
                ),
              ),
            const Spacer(),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: context.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dicas',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Seja especifico: "Guerra Fria" e melhor que "Historia"'),
                    _buildTip('Inclua contexto: "Verbos irregulares em ingles"'),
                    _buildTip('Combine topicos: "Matematica financeira para concursos"'),
                  ],
                ),
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

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _continue() async {
    final topic = _topicController.text.trim();
    if (topic.length < 3) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(aiCardRepositoryProvider);
      final project = await createAiProjectDirect(
        repository,
        sourceType: AiSourceType.topic,
        topic: topic,
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
