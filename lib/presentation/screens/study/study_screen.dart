import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/either.dart';
import '../../../domain/entities/card.dart' as entities;
import '../../../domain/entities/study_session.dart';
import '../../providers/study_providers.dart';
import '../../router/app_router.dart';
import '../../widgets/fullscreen_image_viewer.dart';

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
  bool _showExplanation = false; // UC182: Expandable explanation
  DateTime? _cardStartTime;
  final List<String> _reinsertQueue = []; // Cards to repeat (UC28)
  bool _isLoadingQueue = true;
  String? _loadError;
  bool _isFinishing = false; // Prevent multiple finishSession calls
  ReviewResult? _lastResult; // UC185/UC186: Track last result for feedback

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    debugPrint('StudyScreen: _loadQueue started, deckId=${widget.deckId}, mode=${widget.mode}');
    try {
      final result = await ref.read(studyRepositoryProvider).getStudyQueue(
        deckId: widget.deckId,
        mode: widget.mode,
        limit: widget.mode == StudyMode.turbo ? 12 : null,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('StudyScreen: getStudyQueue TIMEOUT');
          throw Exception('Timeout ao carregar cards');
        },
      );

      debugPrint('StudyScreen: getStudyQueue completed');

      if (!mounted) {
        debugPrint('StudyScreen: widget not mounted, returning');
        return;
      }

      switch (result) {
        case Left(value: final failure):
          debugPrint('StudyScreen: getStudyQueue failed: ${failure.message}');
          setState(() {
            _isLoadingQueue = false;
            _loadError = failure.message;
          });
          return;

        case Right(value: final cards):
          debugPrint('StudyScreen: getStudyQueue success, ${cards.length} cards');
          if (cards.isEmpty) {
            context.showSnackBar('Nenhum card para estudar!');
            context.pop();
            return;
          }

          // Start a study session
          debugPrint('StudyScreen: starting study session...');
          final session = await ref.read(studyNotifierProvider.notifier).startSession(
            deckId: widget.deckId,
            mode: widget.mode,
          );
          debugPrint('StudyScreen: session started: ${session?.id}');

          if (!mounted) return;

          setState(() {
            _queue = cards;
            _cardStartTime = DateTime.now();
            _isLoadingQueue = false;
          });
      }
    } catch (e) {
      debugPrint('StudyScreen: _loadQueue exception: $e');
      if (mounted) {
        setState(() {
          _isLoadingQueue = false;
          _loadError = e.toString();
        });
      }
    }
  }

  entities.Card? get _currentCard {
    if (_currentIndex >= _queue.length) return null;
    return _queue[_currentIndex];
  }

  void _showAnswerCard() {
    setState(() {
      _showAnswer = true;
      _showExplanation = false; // UC182: Start with collapsed explanation
    });
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
      _lastResult = result; // UC185: Track for feedback
      _currentIndex++;
      _showAnswer = false;
      _showExplanation = false;
      _cardStartTime = DateTime.now();
    });

    // Check if session is complete
    if (_currentIndex >= _queue.length) {
      _finishSession();
    }
  }

  Future<void> _finishSession() async {
    // Prevent multiple calls
    if (_isFinishing) {
      debugPrint('_finishSession: already finishing, skipping');
      return;
    }
    _isFinishing = true;
    debugPrint('_finishSession: starting...');
    try {
      final session = await ref.read(studyNotifierProvider.notifier).completeSession();
      debugPrint('_finishSession: completeSession returned session=${session?.id}');
      if (session != null && mounted) {
        context.pushReplacement(
          '${AppRoutes.sessionSummary}?sessionId=${session.id}',
        );
      } else if (mounted) {
        // Fallback: go back if session couldn't be completed
        debugPrint('_finishSession: session is null, going back to home');
        context.showSnackBar('Sessao finalizada');
        context.go(AppRoutes.home);
      }
    } catch (e) {
      debugPrint('_finishSession: error: $e');
      if (mounted) {
        context.showErrorSnackBar('Erro ao finalizar: $e');
        context.go(AppRoutes.home);
      }
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
      body: _buildBody(card),
    );
  }

  Widget _buildBody(entities.Card? card) {
    debugPrint('_buildBody: loading=$_isLoadingQueue, error=$_loadError, queueLen=${_queue.length}, index=$_currentIndex, card=${card?.id}');

    // Show error if queue loading failed
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erro ao carregar cards:\n$_loadError', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Voltar'),
            ),
          ],
        ),
      );
    }

    // Show loading while queue is loading
    if (_isLoadingQueue) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando cards...'),
          ],
        ),
      );
    }

    // If queue loaded but no card, all cards were reviewed - finish session
    if (card == null && _queue.isNotEmpty) {
      debugPrint('All cards reviewed, finishing session...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _finishSession();
      });
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Finalizando sessao...'),
          ],
        ),
      );
    }

    // Empty queue - shouldn't happen, go back
    if (card == null) {
      debugPrint('No cards available, going back...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.showSnackBar('Nenhum card disponivel');
          context.pop();
        }
      });
      return const Center(child: CircularProgressIndicator());
    }

    // Get session for progress bar - only watch when we need it
    final session = ref.watch(studyNotifierProvider).valueOrNull;

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
  }

  Widget _buildProgressBar(StudySession? session) {
    final progress = _queue.isEmpty ? 0.0 : _currentIndex / _queue.length;
    final remaining = _queue.length - _currentIndex;
    final current = _currentIndex + 1;
    final total = _queue.length;

    // Mensagem de progresso mais humana
    String progressMessage;
    if (remaining == 0) {
      progressMessage = 'Último card!';
    } else if (remaining <= 3) {
      progressMessage = 'Quase lá! Faltam $remaining';
    } else {
      progressMessage = 'Card $current de $total';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progressMessage,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (session != null)
                Row(
                  children: [
                    _buildStatChip(
                      Icons.check_circle,
                      '${session.correctCount}',
                      const Color(0xFF43A047),
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.help_outline,
                      '${session.almostCount}',
                      const Color(0xFFFB8C00),
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.cancel,
                      '${session.wrongCount}',
                      const Color(0xFFE53935),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: context.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(context.colorScheme.primary),
            ),
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
      onTap: _showAnswer
          ? null
          : () {
              // UC69: Haptic feedback on card tap
              HapticFeedback.selectionClick();
              _showAnswerCard();
            },
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // UC180: Question with full focus
                  // UC117/UC125: Front side - image or text
                  if (card.imageAsFront && card.hasImage) ...[
                    // Image as front (UC125)
                    _buildCardImage(card),
                  ] else ...[
                    // Text as front (no image here - image goes on back when !imageAsFront)
                    Text(
                      card.front,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  if (_showAnswer) ...[
                    const SizedBox(height: 24),
                    Divider(color: context.colorScheme.outlineVariant),
                    const SizedBox(height: 24),

                    // If imageAsFront, show front text here as part of answer
                    if (card.imageAsFront) ...[
                      Text(
                        card.front,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // If NOT imageAsFront and has image, show image on back/answer side
                    if (!card.imageAsFront && card.hasImage) ...[
                      _buildCardImage(card),
                      const SizedBox(height: 16),
                    ],

                    // UC181: Reveal answer in layers - Summary first (RN12)
                    _buildSummarySection(card),

                    const SizedBox(height: 16),

                    // UC183: Key phrase as memory anchor (RN13)
                    _buildKeyPhraseSection(card),

                    // UC182: Expandable explanation (RN14)
                    if (card.hasExplanation) ...[
                      const SizedBox(height: 16),
                      _buildExplanationSection(card),
                    ],

                    // Hint if available
                    if (card.hint != null && card.hint!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildHintSection(card),
                    ],

                    // UC194: Quality indicator for legacy cards
                    if (card.needsMigration) ...[
                      const SizedBox(height: 16),
                      _buildLegacyCardBanner(),
                    ],
                  ] else ...[
                    const SizedBox(height: 48),
                    Icon(
                      Icons.touch_app_outlined,
                      size: 32,
                      color: context.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toque para revelar',
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
      ),
    );
  }

  /// UC181/RN12: Summary section - shown first when revealing answer.
  Widget _buildSummarySection(entities.Card card) {
    // UC193/UC194: Show quality indicator for legacy cards
    final isLegacy = card.needsMigration;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.summarize_outlined,
                size: 18,
                color: context.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumo',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isLegacy) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Card legado - resumo gerado automaticamente',
                  child: Icon(
                    Icons.auto_fix_high,
                    size: 14,
                    color: context.colorScheme.outline,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            card.displaySummary,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// UC183/RN13: Key phrase as memory anchor.
  Widget _buildKeyPhraseSection(entities.Card card) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colorScheme.tertiaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.key,
            size: 18,
            color: context.colorScheme.tertiary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              card.displayKeyPhrase,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// UC182/RN14: Expandable explanation section.
  Widget _buildExplanationSection(entities.Card card) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _showExplanation = !_showExplanation);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: context.colorScheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showExplanation ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _showExplanation ? 'Ocultar explicação' : 'Ver explicação completa',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showExplanation) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              card.back,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// UC194: Banner for legacy cards that need migration.
  Widget _buildLegacyCardBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Card legado - edite para adicionar resumo e frase-chave',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hint section widget.
  Widget _buildHintSection(entities.Card card) {
    return Container(
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
    );
  }

  /// Builds card image with tap-to-fullscreen (UC117/UC118).
  Widget _buildCardImage(entities.Card card) {
    final imageUrl = card.displayImageUrl;
    if (imageUrl == null) return const SizedBox.shrink();

    final heroTag = 'study_image_${card.id}';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        FullscreenImageViewer.show(
          context,
          imageUrl: imageUrl,
          heroTag: heroTag,
        );
      },
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 200,
              maxWidth: double.infinity,
            ),
            child: kIsWeb
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: context.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: context.colorScheme.onErrorContainer,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Erro ao carregar',
                              style: TextStyle(
                                color: context.colorScheme.onErrorContainer,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: context.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: context.colorScheme.onErrorContainer,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Erro ao carregar',
                              style: TextStyle(
                                color: context.colorScheme.onErrorContainer,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // UC184: Guided self-assessment prompt
            Text(
              'Tente lembrar a resposta antes de revelar',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                // UC69: Haptic feedback on reveal
                HapticFeedback.selectionClick();
                _showAnswerCard();
              },
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Revelar Resposta'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // UC184: Self-assessment guidance
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Compare sua resposta com o resumo acima. Você lembrou?',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildAnswerButton(
                  ReviewResult.wrong,
                  'Não lembrei',
                  const Color(0xFFE53935), // Red 600
                  Icons.close,
                  feedback: 'Volta em breve',
                  metacognition: 'Não reconheci',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnswerButton(
                  ReviewResult.almost,
                  'Lembrei parcial',
                  const Color(0xFFFB8C00), // Orange 600
                  Icons.remove,
                  feedback: 'Vamos reforçar',
                  metacognition: 'Sabia parte',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnswerButton(
                  ReviewResult.correct,
                  'Lembrei fácil',
                  const Color(0xFF43A047), // Green 600
                  Icons.check,
                  feedback: 'Conceito firme!',
                  metacognition: 'Sabia tudo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(
    ReviewResult result,
    String label,
    Color color,
    IconData icon, {
    String? feedback,
    String? metacognition, // UC184: Self-assessment hint
  }) {
    return ElevatedButton(
      onPressed: () {
        // UC69: Haptic feedback based on result
        switch (result) {
          case ReviewResult.correct:
            HapticFeedback.lightImpact();
            break;
          case ReviewResult.almost:
            HapticFeedback.mediumImpact();
            break;
          case ReviewResult.wrong:
            HapticFeedback.heavyImpact();
            break;
        }
        _recordAnswer(result);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          // UC184: Metacognition hint
          if (metacognition != null) ...[
            Text(
              metacognition,
              style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
          Text(
            '+${result.xpValue} XP',
            style: const TextStyle(fontSize: 11),
          ),
          if (feedback != null) ...[
            const SizedBox(height: 2),
            Text(
              feedback,
              style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
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
