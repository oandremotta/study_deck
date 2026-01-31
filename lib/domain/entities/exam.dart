import 'package:equatable/equatable.dart';

/// UC221-UC226: Exam/Simulation entity.
///
/// Represents a test/exam session for a deck.
class Exam extends Equatable {
  /// Unique identifier (UUID).
  final String id;

  /// User ID.
  final String userId;

  /// Deck ID being tested.
  final String deckId;

  /// Deck name (for display).
  final String deckName;

  /// Number of questions in this exam.
  final int questionCount;

  /// Time limit in minutes (null = no limit).
  final int? timeLimitMinutes;

  /// Exam status.
  final ExamStatus status;

  /// Current question index (0-based).
  final int currentQuestionIndex;

  /// List of card IDs in exam order.
  final List<String> cardIds;

  /// User answers (cardId -> ExamAnswer).
  final Map<String, ExamAnswer> answers;

  /// When the exam was created.
  final DateTime createdAt;

  /// When the exam was started.
  final DateTime? startedAt;

  /// When the exam was completed.
  final DateTime? completedAt;

  /// Time spent in seconds.
  final int timeSpentSeconds;

  const Exam({
    required this.id,
    required this.userId,
    required this.deckId,
    required this.deckName,
    required this.questionCount,
    this.timeLimitMinutes,
    required this.status,
    this.currentQuestionIndex = 0,
    required this.cardIds,
    this.answers = const {},
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.timeSpentSeconds = 0,
  });

  /// Create a new exam.
  factory Exam.create({
    required String id,
    required String userId,
    required String deckId,
    required String deckName,
    required int questionCount,
    int? timeLimitMinutes,
    required List<String> cardIds,
  }) {
    return Exam(
      id: id,
      userId: userId,
      deckId: deckId,
      deckName: deckName,
      questionCount: questionCount,
      timeLimitMinutes: timeLimitMinutes,
      status: ExamStatus.created,
      cardIds: cardIds,
      createdAt: DateTime.now(),
    );
  }

  // ============ Computed Properties ============

  /// Number of questions answered.
  int get answeredCount => answers.length;

  /// Number of correct answers.
  int get correctCount => answers.values.where((a) => a.isCorrect).length;

  /// Number of incorrect answers.
  int get incorrectCount => answers.values.where((a) => !a.isCorrect).length;

  /// Score as percentage (0-100).
  double get scorePercentage =>
      answeredCount > 0 ? (correctCount / answeredCount) * 100 : 0;

  /// Whether exam is in progress.
  bool get isInProgress => status == ExamStatus.inProgress;

  /// Whether exam is completed.
  bool get isCompleted => status == ExamStatus.completed;

  /// Whether there's a next question.
  bool get hasNextQuestion => currentQuestionIndex < cardIds.length - 1;

  /// Current card ID.
  String? get currentCardId =>
      currentQuestionIndex < cardIds.length ? cardIds[currentQuestionIndex] : null;

  /// Time remaining in seconds (null if no limit).
  int? get timeRemainingSeconds {
    if (timeLimitMinutes == null) return null;
    final limitSeconds = timeLimitMinutes! * 60;
    return (limitSeconds - timeSpentSeconds).clamp(0, limitSeconds);
  }

  /// Whether time has expired.
  bool get isTimeExpired =>
      timeLimitMinutes != null && timeSpentSeconds >= timeLimitMinutes! * 60;

  /// List of incorrect card IDs for review.
  List<String> get incorrectCardIds =>
      answers.entries.where((e) => !e.value.isCorrect).map((e) => e.key).toList();

  // ============ State Updates ============

  Exam start() {
    return copyWith(
      status: ExamStatus.inProgress,
      startedAt: DateTime.now(),
    );
  }

  Exam answerQuestion(String cardId, bool isCorrect) {
    final newAnswers = Map<String, ExamAnswer>.from(answers);
    newAnswers[cardId] = ExamAnswer(
      cardId: cardId,
      isCorrect: isCorrect,
      answeredAt: DateTime.now(),
    );

    return copyWith(
      answers: newAnswers,
      currentQuestionIndex: currentQuestionIndex + 1,
    );
  }

  Exam updateTime(int seconds) {
    return copyWith(timeSpentSeconds: seconds);
  }

  Exam complete() {
    return copyWith(
      status: ExamStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  Exam copyWith({
    String? id,
    String? userId,
    String? deckId,
    String? deckName,
    int? questionCount,
    int? timeLimitMinutes,
    ExamStatus? status,
    int? currentQuestionIndex,
    List<String>? cardIds,
    Map<String, ExamAnswer>? answers,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    int? timeSpentSeconds,
  }) {
    return Exam(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deckId: deckId ?? this.deckId,
      deckName: deckName ?? this.deckName,
      questionCount: questionCount ?? this.questionCount,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      status: status ?? this.status,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      cardIds: cardIds ?? this.cardIds,
      answers: answers ?? this.answers,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        deckId,
        deckName,
        questionCount,
        timeLimitMinutes,
        status,
        currentQuestionIndex,
        cardIds,
        answers,
        createdAt,
        startedAt,
        completedAt,
        timeSpentSeconds,
      ];
}

/// Exam status.
enum ExamStatus {
  created,
  inProgress,
  completed,
  abandoned,
}

extension ExamStatusExtension on ExamStatus {
  String get displayName {
    switch (this) {
      case ExamStatus.created:
        return 'Criado';
      case ExamStatus.inProgress:
        return 'Em andamento';
      case ExamStatus.completed:
        return 'Concluído';
      case ExamStatus.abandoned:
        return 'Abandonado';
    }
  }
}

/// UC222: Individual exam answer.
class ExamAnswer extends Equatable {
  final String cardId;
  final bool isCorrect;
  final DateTime answeredAt;

  const ExamAnswer({
    required this.cardId,
    required this.isCorrect,
    required this.answeredAt,
  });

  @override
  List<Object?> get props => [cardId, isCorrect, answeredAt];
}

/// UC225/UC226: Exam history entry for comparison.
class ExamHistoryEntry extends Equatable {
  final String examId;
  final String deckId;
  final DateTime completedAt;
  final int questionCount;
  final int correctCount;
  final double scorePercentage;
  final int timeSpentSeconds;

  const ExamHistoryEntry({
    required this.examId,
    required this.deckId,
    required this.completedAt,
    required this.questionCount,
    required this.correctCount,
    required this.scorePercentage,
    required this.timeSpentSeconds,
  });

  factory ExamHistoryEntry.fromExam(Exam exam) {
    return ExamHistoryEntry(
      examId: exam.id,
      deckId: exam.deckId,
      completedAt: exam.completedAt ?? DateTime.now(),
      questionCount: exam.questionCount,
      correctCount: exam.correctCount,
      scorePercentage: exam.scorePercentage,
      timeSpentSeconds: exam.timeSpentSeconds,
    );
  }

  /// Format time as MM:SS.
  String get formattedTime {
    final minutes = timeSpentSeconds ~/ 60;
    final seconds = timeSpentSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        examId,
        deckId,
        completedAt,
        questionCount,
        correctCount,
        scorePercentage,
        timeSpentSeconds,
      ];
}

/// UC226: Exam comparison result.
class ExamComparison {
  final ExamHistoryEntry current;
  final ExamHistoryEntry? previous;
  final double scoreDifference;
  final int timeDifference;
  final ComparisonTrend trend;

  const ExamComparison({
    required this.current,
    this.previous,
    required this.scoreDifference,
    required this.timeDifference,
    required this.trend,
  });

  factory ExamComparison.compare(ExamHistoryEntry current, ExamHistoryEntry? previous) {
    if (previous == null) {
      return ExamComparison(
        current: current,
        previous: null,
        scoreDifference: 0,
        timeDifference: 0,
        trend: ComparisonTrend.first,
      );
    }

    final scoreDiff = current.scorePercentage - previous.scorePercentage;
    final timeDiff = current.timeSpentSeconds - previous.timeSpentSeconds;

    ComparisonTrend trend;
    if (scoreDiff > 5) {
      trend = ComparisonTrend.improving;
    } else if (scoreDiff < -5) {
      trend = ComparisonTrend.declining;
    } else {
      trend = ComparisonTrend.stable;
    }

    return ExamComparison(
      current: current,
      previous: previous,
      scoreDifference: scoreDiff,
      timeDifference: timeDiff,
      trend: trend,
    );
  }

  String get trendMessage {
    switch (trend) {
      case ComparisonTrend.first:
        return 'Primeiro simulado deste deck';
      case ComparisonTrend.improving:
        return 'Melhorou ${scoreDifference.toStringAsFixed(1)}% desde o último';
      case ComparisonTrend.stable:
        return 'Performance estável';
      case ComparisonTrend.declining:
        return 'Reduziu ${scoreDifference.abs().toStringAsFixed(1)}% desde o último';
    }
  }
}

enum ComparisonTrend {
  first,
  improving,
  stable,
  declining,
}
