import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/card.dart' as entities;
import '../../../domain/entities/study_session.dart';
import '../../providers/study_providers.dart';
import '../../router/app_router.dart';

/// Main study screen for reviewing flashcards.
///
/// Implements UC21-UC28 (Study features).
class StudyScreen extends ConsumerStatefulWidget {
  final String? deckId;
  final StudyMode mode;

  const StudyScreen({
    super.key,
    this.deckId,
    required this.mode,
  });

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  List<entities.Card> _queue = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  DateTime? _cardStartTime;
  final List<String> _reinsertQueue = []; // Cards to repeat (UC28)

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    final result = await ref.read(studyRepositoryProvider).getStudyQueue(
      deckId: widget.deckId,
      mode: widget.mode,
      limit: widget.mode == StudyMode.turbo ? 12 : null,
    );

    result.fold(
      (failure) {
        if (mounted) {
          context.showErrorSnackBar('Erro ao carregar cards: ${failure.message}');
          context.pop();
        }
      },
      (cards) {
        if (cards.isEmpty) {
          if (mounted) {
            context.showSnackBar('Nenhum card para estudar!');
            context.pop();
          }
          return;
        }
        setState(() {
          _queue = cards;
          _cardStartTime = DateTime.now();
        });
      },
    );
  }

  entities.Card? get _currentCard {
    if (_currentIndex >= _queue.length) return null;
    return _queue[_currentIndex];
  }

  void _showAnswerCard() {
    setState(() => _showAnswer = true);
  }

  Future<void> _recordAnswer(ReviewResult result) async {
    final card = _currentCard;
    if (card == null) return;

    final responseTime = DateTime.now().difference(_cardStartTime ?? DateTime.now());

    // Record the review
    await ref.read(studyNotifierProvider.notifier).recordReview(
      cardId: card.id,
      result: result,
      responseTime: responseTime,
    );

    // UC28: If wrong, reinsert at end (max 3 times per card)
    if (result == ReviewResult.wrong) {
      final reinsertCount = _reinsertQueue.where((id) => id == card.id).length;
      if (reinsertCount < 3) {
        _reinsertQueue.add(card.id);
        _queue.add(card);
      }
    }

    // Move to next card
    setState(() {
      _currentIndex++;
      _showAnswer = false;
      _cardStartTime = DateTime.now();
    });

    // Check if session is complete
    if (_currentIndex >= _queue.length) {
      _finishSession();
    }
  }

  Future<void> _finishSession() async {
    final session = await ref.read(studyNotifierProvider.notifier).completeSession();
    if (session != null && mounted) {
      context.pushReplacement(
        '${AppRoutes.sessionSummary}/${session.id}',
      );
    }
  }

  Future<void> _pauseSession() async {
    await ref.read(studyNotifierProvider.notifier).pauseSession();
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(studyNotifierProvider);
    final card = _currentCard;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(),
        ),
        title: Text(widget.mode.displayName),
        actions: [
          if (widget.mode == StudyMode.turbo)
            _buildTurboTimer(),
        ],
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (session) {
          if (card == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Progress bar
              _buildProgressBar(session),

              // Card content
              Expanded(
                child: _buildCardContent(card),
              ),

              // Action buttons
              _buildActionButtons(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(StudySession? session) {
    final progress = _queue.isEmpty ? 0.0 : _currentIndex / _queue.length;
    final remaining = _queue.length - _currentIndex;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentIndex + 1} / ${_queue.length}',
                style: context.textTheme.bodySmall,
              ),
              if (session != null)
                Row(
                  children: [
                    _buildStatChip(
                      Icons.check_circle,
                      '${session.correctCount}',
                      Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.help_outline,
                      '${session.almostCount}',
                      Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.cancel,
                      '${session.wrongCount}',
                      Colors.red,
                    ),
                  ],
                ),
              Text(
                '$remaining restantes',
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: context.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(context.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCardContent(entities.Card card) {
    return GestureDetector(
      onTap: _showAnswer ? null : _showAnswerCard,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Front (question)
                Text(
                  card.front,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (_showAnswer) ...[
                  const SizedBox(height: 24),
                  Divider(color: context.colorScheme.outlineVariant),
                  const SizedBox(height: 24),

                  // Back (answer)
                  Text(
                    card.back,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Hint if available
                  if (card.hint != null && card.hint!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: context.colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              card.hint!,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ] else ...[
                  const SizedBox(height: 48),
                  Text(
                    'Toque para ver a resposta',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!_showAnswer) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _showAnswerCard,
          icon: const Icon(Icons.visibility),
          label: const Text('Ver Resposta'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildAnswerButton(
              ReviewResult.wrong,
              'Errei',
              Colors.red,
              Icons.close,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildAnswerButton(
              ReviewResult.almost,
              'Quase',
              Colors.amber,
              Icons.remove,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildAnswerButton(
              ReviewResult.correct,
              'Acertei',
              Colors.green,
              Icons.check,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(
    ReviewResult result,
    String label,
    Color color,
    IconData icon,
  ) {
    return ElevatedButton(
      onPressed: () => _recordAnswer(result),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            '+${result.xpValue} XP',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTurboTimer() {
    // Simple turbo mode indicator
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bolt,
            size: 16,
            color: context.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'TURBO',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da sessao?'),
        content: const Text(
          'Seu progresso sera salvo e voce podera continuar depois.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar estudando'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _pauseSession();
            },
            child: const Text('Pausar e sair'),
          ),
        ],
      ),
    );
  }
}
