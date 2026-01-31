import 'package:equatable/equatable.dart';

/// UC235-UC240: Onboarding progress entity.
///
/// Tracks user's progress through progressive onboarding.
class OnboardingProgress extends Equatable {
  /// User ID.
  final String userId;

  /// Whether initial welcome was shown.
  final bool welcomeShown;

  /// Whether first deck was created.
  final bool firstDeckCreated;

  /// Whether first card was created.
  final bool firstCardCreated;

  /// Whether first study session was completed.
  final bool firstStudyCompleted;

  /// Whether deck organization was explained.
  final bool organizationExplained;

  /// Number of decks created.
  final int decksCreated;

  /// Number of cards created.
  final int cardsCreated;

  /// Number of study sessions completed.
  final int studySessionsCompleted;

  /// Current onboarding step (0-based).
  final int currentStep;

  /// Whether onboarding is fully complete.
  final bool isComplete;

  /// When the user started onboarding.
  final DateTime startedAt;

  /// When onboarding was completed (null if not complete).
  final DateTime? completedAt;

  /// Hints that have been dismissed.
  final List<String> dismissedHints;

  const OnboardingProgress({
    required this.userId,
    this.welcomeShown = false,
    this.firstDeckCreated = false,
    this.firstCardCreated = false,
    this.firstStudyCompleted = false,
    this.organizationExplained = false,
    this.decksCreated = 0,
    this.cardsCreated = 0,
    this.studySessionsCompleted = 0,
    this.currentStep = 0,
    this.isComplete = false,
    required this.startedAt,
    this.completedAt,
    this.dismissedHints = const [],
  });

  /// Creates initial onboarding progress for a new user.
  factory OnboardingProgress.initial(String userId) {
    return OnboardingProgress(
      userId: userId,
      startedAt: DateTime.now(),
    );
  }

  // ============ Computed Properties ============

  /// UC235: Check if user needs guided deck creation.
  bool get needsGuidedDeckCreation => !firstDeckCreated;

  /// UC236: Check if user needs guided card creation.
  bool get needsGuidedCardCreation => firstDeckCreated && !firstCardCreated;

  /// UC237: Check if should suggest immediate study.
  bool get shouldSuggestStudy =>
      firstDeckCreated && firstCardCreated && !firstStudyCompleted;

  /// UC238: Check if should show organization tips.
  bool get shouldShowOrganizationTips =>
      decksCreated >= 3 && !organizationExplained;

  /// UC240: Calculate completion percentage.
  double get completionPercentage {
    int completed = 0;
    if (welcomeShown) completed++;
    if (firstDeckCreated) completed++;
    if (firstCardCreated) completed++;
    if (firstStudyCompleted) completed++;
    if (organizationExplained) completed++;
    return completed / 5.0;
  }

  /// Get the next suggested action.
  OnboardingAction get nextAction {
    if (!welcomeShown) return OnboardingAction.welcome;
    if (!firstDeckCreated) return OnboardingAction.createDeck;
    if (!firstCardCreated) return OnboardingAction.createCard;
    if (!firstStudyCompleted) return OnboardingAction.study;
    if (!organizationExplained && decksCreated >= 3) {
      return OnboardingAction.organize;
    }
    return OnboardingAction.complete;
  }

  /// Get contextual hint for current state.
  String? get currentHint {
    final action = nextAction;
    if (dismissedHints.contains(action.name)) return null;

    switch (action) {
      case OnboardingAction.welcome:
        return null; // Welcome is shown automatically
      case OnboardingAction.createDeck:
        return 'Comece criando seu primeiro deck para organizar seus flashcards!';
      case OnboardingAction.createCard:
        return 'Adicione cards ao seu deck. Quanto mais específico, melhor a memorização!';
      case OnboardingAction.study:
        return 'Você tem cards prontos para estudar! Que tal uma sessão rápida?';
      case OnboardingAction.organize:
        return 'Dica: Use pastas para organizar seus decks por tema ou projeto.';
      case OnboardingAction.complete:
        return null;
    }
  }

  OnboardingProgress copyWith({
    String? userId,
    bool? welcomeShown,
    bool? firstDeckCreated,
    bool? firstCardCreated,
    bool? firstStudyCompleted,
    bool? organizationExplained,
    int? decksCreated,
    int? cardsCreated,
    int? studySessionsCompleted,
    int? currentStep,
    bool? isComplete,
    DateTime? startedAt,
    DateTime? completedAt,
    List<String>? dismissedHints,
  }) {
    return OnboardingProgress(
      userId: userId ?? this.userId,
      welcomeShown: welcomeShown ?? this.welcomeShown,
      firstDeckCreated: firstDeckCreated ?? this.firstDeckCreated,
      firstCardCreated: firstCardCreated ?? this.firstCardCreated,
      firstStudyCompleted: firstStudyCompleted ?? this.firstStudyCompleted,
      organizationExplained: organizationExplained ?? this.organizationExplained,
      decksCreated: decksCreated ?? this.decksCreated,
      cardsCreated: cardsCreated ?? this.cardsCreated,
      studySessionsCompleted: studySessionsCompleted ?? this.studySessionsCompleted,
      currentStep: currentStep ?? this.currentStep,
      isComplete: isComplete ?? this.isComplete,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      dismissedHints: dismissedHints ?? this.dismissedHints,
    );
  }

  /// Convert to JSON for storage.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'welcomeShown': welcomeShown,
      'firstDeckCreated': firstDeckCreated,
      'firstCardCreated': firstCardCreated,
      'firstStudyCompleted': firstStudyCompleted,
      'organizationExplained': organizationExplained,
      'decksCreated': decksCreated,
      'cardsCreated': cardsCreated,
      'studySessionsCompleted': studySessionsCompleted,
      'currentStep': currentStep,
      'isComplete': isComplete,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'dismissedHints': dismissedHints,
    };
  }

  /// Create from JSON.
  factory OnboardingProgress.fromJson(Map<String, dynamic> json) {
    return OnboardingProgress(
      userId: json['userId'] as String,
      welcomeShown: json['welcomeShown'] as bool? ?? false,
      firstDeckCreated: json['firstDeckCreated'] as bool? ?? false,
      firstCardCreated: json['firstCardCreated'] as bool? ?? false,
      firstStudyCompleted: json['firstStudyCompleted'] as bool? ?? false,
      organizationExplained: json['organizationExplained'] as bool? ?? false,
      decksCreated: json['decksCreated'] as int? ?? 0,
      cardsCreated: json['cardsCreated'] as int? ?? 0,
      studySessionsCompleted: json['studySessionsCompleted'] as int? ?? 0,
      currentStep: json['currentStep'] as int? ?? 0,
      isComplete: json['isComplete'] as bool? ?? false,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      dismissedHints: (json['dismissedHints'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        userId,
        welcomeShown,
        firstDeckCreated,
        firstCardCreated,
        firstStudyCompleted,
        organizationExplained,
        decksCreated,
        cardsCreated,
        studySessionsCompleted,
        currentStep,
        isComplete,
        startedAt,
        completedAt,
        dismissedHints,
      ];
}

/// UC235-UC240: Onboarding actions.
enum OnboardingAction {
  welcome,
  createDeck,
  createCard,
  study,
  organize,
  complete,
}

extension OnboardingActionExtension on OnboardingAction {
  String get title {
    switch (this) {
      case OnboardingAction.welcome:
        return 'Bem-vindo';
      case OnboardingAction.createDeck:
        return 'Criar primeiro deck';
      case OnboardingAction.createCard:
        return 'Criar primeiro card';
      case OnboardingAction.study:
        return 'Primeira sessão de estudo';
      case OnboardingAction.organize:
        return 'Organizar decks';
      case OnboardingAction.complete:
        return 'Onboarding completo';
    }
  }

  String get description {
    switch (this) {
      case OnboardingAction.welcome:
        return 'Conheça o Study Deck';
      case OnboardingAction.createDeck:
        return 'Crie um deck para organizar seus flashcards';
      case OnboardingAction.createCard:
        return 'Adicione cards ao seu deck';
      case OnboardingAction.study:
        return 'Faça sua primeira sessão de estudo';
      case OnboardingAction.organize:
        return 'Use pastas para organizar melhor';
      case OnboardingAction.complete:
        return 'Você está pronto para usar o Study Deck!';
    }
  }

  String get icon {
    switch (this) {
      case OnboardingAction.welcome:
        return '👋';
      case OnboardingAction.createDeck:
        return '📚';
      case OnboardingAction.createCard:
        return '📝';
      case OnboardingAction.study:
        return '🎯';
      case OnboardingAction.organize:
        return '📁';
      case OnboardingAction.complete:
        return '🎉';
    }
  }
}
