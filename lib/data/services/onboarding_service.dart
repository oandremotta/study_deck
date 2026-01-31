import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/onboarding_progress.dart';

/// UC235-UC240: Onboarding service for progressive onboarding.
///
/// Handles:
/// - Tracking onboarding progress (UC235)
/// - Guided first deck creation (UC236)
/// - Guided first card creation (UC237)
/// - Immediate study suggestion (UC238)
/// - Organization tips (UC239)
/// - Progress tracking (UC240)
class OnboardingService {
  static const String _progressKey = 'onboarding_progress';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Get current onboarding progress.
  Future<OnboardingProgress?> getProgress(String userId) async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString('${_progressKey}_$userId');

      if (json == null) return null;

      return OnboardingProgress.fromJson(jsonDecode(json));
    } catch (e) {
      debugPrint('OnboardingService: Error getting progress: $e');
      return null;
    }
  }

  /// Initialize onboarding for new user.
  Future<OnboardingProgress> initializeProgress(String userId) async {
    final progress = OnboardingProgress.initial(userId);
    await _saveProgress(progress);
    debugPrint('OnboardingService: Initialized progress for $userId');
    return progress;
  }

  /// UC235: Mark welcome as shown.
  Future<OnboardingProgress> markWelcomeShown(String userId) async {
    var progress = await getProgress(userId);
    progress ??= await initializeProgress(userId);

    final updated = progress.copyWith(
      welcomeShown: true,
      currentStep: 1,
    );

    await _saveProgress(updated);
    debugPrint('OnboardingService: Welcome shown for $userId');
    return updated;
  }

  /// UC236: Mark first deck created.
  Future<OnboardingProgress> markFirstDeckCreated(String userId) async {
    var progress = await getProgress(userId);
    progress ??= await initializeProgress(userId);

    final updated = progress.copyWith(
      firstDeckCreated: true,
      decksCreated: progress.decksCreated + 1,
      currentStep: progress.firstDeckCreated ? progress.currentStep : 2,
    );

    await _saveProgress(updated);
    debugPrint('OnboardingService: First deck created for $userId');
    return updated;
  }

  /// Track deck creation (after first).
  Future<OnboardingProgress> trackDeckCreated(String userId) async {
    var progress = await getProgress(userId);
    progress ??= await initializeProgress(userId);

    final updated = progress.copyWith(
      firstDeckCreated: true,
      decksCreated: progress.decksCreated + 1,
    );

    await _saveProgress(updated);
    return updated;
  }

  /// UC237: Mark first card created.
  Future<OnboardingProgress> markFirstCardCreated(String userId) async {
    var progress = await getProgress(userId);
    progress ??= await initializeProgress(userId);

    final updated = progress.copyWith(
      firstCardCreated: true,
      cardsCreated: progress.cardsCreated + 1,
      currentStep: progress.firstCardCreated ? progress.currentStep : 3,
    );

    await _saveProgress(updated);
    debugPrint('OnboardingService: First card created for $userId');
    return updated;
  }

  /// Track card creation (after first).
  Future<OnboardingProgress> trackCardCreated(String userId) async {
    var progress = await getProgress(userId);
    progress ??= await initializeProgress(userId);

    final updated = progress.copyWith(
      firstCardCreated: true,
      cardsCreated: progress.cardsCreated + 1,
    );

    await _saveProgress(updated);
    return updated;
  }

  /// UC238: Mark first study session completed.
  Future<OnboardingProgress> markFirstStudyCompleted(String userId) async {
    var progress = await getProgress(userId);
    progress ??= await initializeProgress(userId);

    final updated = progress.copyWith(
      firstStudyCompleted: true,
      studySessionsCompleted: progress.studySessionsCompleted + 1,
      currentStep: progress.firstStudyCompleted ? progress.currentStep : 4,
    );

    await _saveProgress(updated);
    debugPrint('OnboardingService: First study completed for $userId');

    // Check if onboarding is now complete
    await _checkCompletion(updated);

    return updated;
  }

  /// Track study session (after first).
  Future<OnboardingProgress> trackStudyCompleted(String userId) async {
    var progress = await getProgress(userId);
    progress ??= await initializeProgress(userId);

    final updated = progress.copyWith(
      firstStudyCompleted: true,
      studySessionsCompleted: progress.studySessionsCompleted + 1,
    );

    await _saveProgress(updated);
    return updated;
  }

  /// UC239: Mark organization explained.
  Future<OnboardingProgress> markOrganizationExplained(String userId) async {
    var progress = await getProgress(userId);
    progress ??= await initializeProgress(userId);

    final updated = progress.copyWith(
      organizationExplained: true,
      currentStep: 5,
    );

    await _saveProgress(updated);
    debugPrint('OnboardingService: Organization explained for $userId');

    // Check if onboarding is now complete
    await _checkCompletion(updated);

    return updated;
  }

  /// UC240: Dismiss a hint.
  Future<OnboardingProgress> dismissHint(String userId, String hintId) async {
    var progress = await getProgress(userId);
    progress ??= await initializeProgress(userId);

    if (progress.dismissedHints.contains(hintId)) return progress;

    final updated = progress.copyWith(
      dismissedHints: [...progress.dismissedHints, hintId],
    );

    await _saveProgress(updated);
    debugPrint('OnboardingService: Hint $hintId dismissed for $userId');
    return updated;
  }

  /// Get guided deck creation tips.
  List<GuidedTip> getDeckCreationTips() {
    return [
      GuidedTip(
        id: 'deck_name',
        title: 'Nome do Deck',
        description:
            'Escolha um nome descritivo, como "Vocabulário de Espanhol" ou "Anatomia - Sistema Nervoso".',
        icon: '📚',
      ),
      GuidedTip(
        id: 'deck_description',
        title: 'Descrição',
        description:
            'Adicione uma descrição para lembrar o objetivo do deck.',
        icon: '📝',
      ),
      GuidedTip(
        id: 'deck_folder',
        title: 'Organização',
        description:
            'Você pode organizar decks em pastas depois de criar alguns.',
        icon: '📁',
      ),
    ];
  }

  /// Get guided card creation tips.
  List<GuidedTip> getCardCreationTips() {
    return [
      GuidedTip(
        id: 'card_front',
        title: 'Frente do Card',
        description:
            'Escreva a pergunta ou conceito. Seja específico e conciso.',
        icon: '❓',
      ),
      GuidedTip(
        id: 'card_back',
        title: 'Verso do Card',
        description:
            'Escreva a resposta completa. Inclua exemplos se ajudar.',
        icon: '✅',
      ),
      GuidedTip(
        id: 'card_summary',
        title: 'Resumo',
        description:
            'Uma resposta curta (até 240 caracteres) para revisão rápida.',
        icon: '📋',
      ),
      GuidedTip(
        id: 'card_key_phrase',
        title: 'Frase-Chave',
        description:
            'Uma âncora de memória (até 120 caracteres) para lembrar mais fácil.',
        icon: '🔑',
      ),
    ];
  }

  /// Get study session tips.
  List<GuidedTip> getStudyTips() {
    return [
      GuidedTip(
        id: 'study_rating',
        title: 'Avalie sua Resposta',
        description:
            'Seja honesto na avaliação. Isso ajuda o algoritmo a otimizar suas revisões.',
        icon: '⭐',
      ),
      GuidedTip(
        id: 'study_consistency',
        title: 'Consistência',
        description:
            'Estudar um pouco todo dia é melhor que muito de vez em quando.',
        icon: '📅',
      ),
      GuidedTip(
        id: 'study_focus',
        title: 'Foco',
        description:
            'Evite distrações durante o estudo para melhor memorização.',
        icon: '🎯',
      ),
    ];
  }

  /// Check if user should see study suggestion.
  Future<bool> shouldSuggestStudy(String userId) async {
    final progress = await getProgress(userId);
    return progress?.shouldSuggestStudy ?? false;
  }

  /// Check if user should see organization tips.
  Future<bool> shouldShowOrganizationTips(String userId) async {
    final progress = await getProgress(userId);
    return progress?.shouldShowOrganizationTips ?? false;
  }

  /// Mark onboarding as complete.
  Future<OnboardingProgress> markComplete(String userId) async {
    var progress = await getProgress(userId);
    progress ??= await initializeProgress(userId);

    final updated = progress.copyWith(
      isComplete: true,
      completedAt: DateTime.now(),
    );

    await _saveProgress(updated);
    debugPrint('OnboardingService: Onboarding complete for $userId');
    return updated;
  }

  /// Reset onboarding (for testing).
  Future<void> resetProgress(String userId) async {
    final prefs = await _preferences;
    await prefs.remove('${_progressKey}_$userId');
    debugPrint('OnboardingService: Progress reset for $userId');
  }

  // ============ Private Methods ============

  Future<void> _saveProgress(OnboardingProgress progress) async {
    final prefs = await _preferences;
    await prefs.setString(
      '${_progressKey}_${progress.userId}',
      jsonEncode(progress.toJson()),
    );
  }

  Future<void> _checkCompletion(OnboardingProgress progress) async {
    // Onboarding is complete when all main steps are done
    if (progress.welcomeShown &&
        progress.firstDeckCreated &&
        progress.firstCardCreated &&
        progress.firstStudyCompleted) {
      // Organization is optional, complete after study
      if (!progress.isComplete) {
        await markComplete(progress.userId);
      }
    }
  }
}

/// A guided tip for onboarding.
class GuidedTip {
  final String id;
  final String title;
  final String description;
  final String icon;

  const GuidedTip({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}
