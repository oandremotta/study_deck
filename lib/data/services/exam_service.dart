import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/exam.dart';

/// UC221-UC226: Exam/Simulation service.
///
/// Handles exam creation, execution, and history.
class ExamService {
  static const String _historyKey = 'exam_history';
  static const String _activeExamKey = 'active_exam';
  static const int _maxHistoryEntries = 50;

  final _uuid = const Uuid();

  /// UC221: Create a new exam from a deck.
  Exam createExam({
    required String userId,
    required String deckId,
    required String deckName,
    required List<String> availableCardIds,
    required int questionCount,
    int? timeLimitMinutes,
    bool shuffle = true,
  }) {
    // Validate question count
    final actualCount = questionCount.clamp(1, availableCardIds.length);

    // Select cards
    List<String> selectedCards;
    if (shuffle) {
      final shuffled = List<String>.from(availableCardIds)..shuffle(Random());
      selectedCards = shuffled.take(actualCount).toList();
    } else {
      selectedCards = availableCardIds.take(actualCount).toList();
    }

    return Exam.create(
      id: _uuid.v4(),
      userId: userId,
      deckId: deckId,
      deckName: deckName,
      questionCount: actualCount,
      timeLimitMinutes: timeLimitMinutes,
      cardIds: selectedCards,
    );
  }

  /// UC222: Start an exam.
  Exam startExam(Exam exam) {
    return exam.start();
  }

  /// UC222: Record answer (without revealing correct answer).
  Exam recordAnswer(Exam exam, String cardId, bool userSaidCorrect) {
    return exam.answerQuestion(cardId, userSaidCorrect);
  }

  /// UC223: Complete exam and calculate results.
  Exam completeExam(Exam exam) {
    return exam.complete();
  }

  /// UC224: Get cards for error review.
  List<String> getErrorCards(Exam exam) {
    return exam.incorrectCardIds;
  }

  /// UC225: Save exam to history.
  Future<void> saveToHistory(Exam exam) async {
    final entry = ExamHistoryEntry.fromExam(exam);
    final sp = await SharedPreferences.getInstance();

    // Load existing history
    final historyJson = sp.getStringList(_historyKey) ?? [];
    final history = historyJson
        .map((json) => _parseHistoryEntry(jsonDecode(json)))
        .toList();

    // Add new entry
    history.insert(0, entry);

    // Limit history size
    if (history.length > _maxHistoryEntries) {
      history.removeRange(_maxHistoryEntries, history.length);
    }

    // Save back
    final updatedJson = history
        .map((e) => jsonEncode(_serializeHistoryEntry(e)))
        .toList();
    await sp.setStringList(_historyKey, updatedJson);
  }

  /// UC225: Get exam history for a deck.
  Future<List<ExamHistoryEntry>> getHistoryForDeck(String deckId) async {
    final sp = await SharedPreferences.getInstance();
    final historyJson = sp.getStringList(_historyKey) ?? [];

    return historyJson
        .map((json) => _parseHistoryEntry(jsonDecode(json)))
        .where((e) => e.deckId == deckId)
        .toList();
  }

  /// UC225: Get all exam history.
  Future<List<ExamHistoryEntry>> getAllHistory() async {
    final sp = await SharedPreferences.getInstance();
    final historyJson = sp.getStringList(_historyKey) ?? [];

    return historyJson
        .map((json) => _parseHistoryEntry(jsonDecode(json)))
        .toList();
  }

  /// UC226: Compare exam with previous.
  Future<ExamComparison> compareWithPrevious(Exam exam) async {
    final history = await getHistoryForDeck(exam.deckId);
    final current = ExamHistoryEntry.fromExam(exam);

    // Find previous exam (if any)
    ExamHistoryEntry? previous;
    if (history.isNotEmpty) {
      previous = history.first;
    }

    return ExamComparison.compare(current, previous);
  }

  /// Save active exam state (for resume).
  Future<void> saveActiveExam(Exam exam) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_activeExamKey, jsonEncode(_serializeExam(exam)));
  }

  /// Load active exam (if any).
  Future<Exam?> loadActiveExam() async {
    final sp = await SharedPreferences.getInstance();
    final json = sp.getString(_activeExamKey);
    if (json == null) return null;

    try {
      return _parseExam(jsonDecode(json));
    } catch (e) {
      await clearActiveExam();
      return null;
    }
  }

  /// Clear active exam.
  Future<void> clearActiveExam() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_activeExamKey);
  }

  // ============ Serialization ============

  Map<String, dynamic> _serializeExam(Exam exam) {
    return {
      'id': exam.id,
      'userId': exam.userId,
      'deckId': exam.deckId,
      'deckName': exam.deckName,
      'questionCount': exam.questionCount,
      'timeLimitMinutes': exam.timeLimitMinutes,
      'status': exam.status.index,
      'currentQuestionIndex': exam.currentQuestionIndex,
      'cardIds': exam.cardIds,
      'answers': exam.answers.map((k, v) => MapEntry(k, {
            'cardId': v.cardId,
            'isCorrect': v.isCorrect,
            'answeredAt': v.answeredAt.millisecondsSinceEpoch,
          })),
      'createdAt': exam.createdAt.millisecondsSinceEpoch,
      'startedAt': exam.startedAt?.millisecondsSinceEpoch,
      'completedAt': exam.completedAt?.millisecondsSinceEpoch,
      'timeSpentSeconds': exam.timeSpentSeconds,
    };
  }

  Exam _parseExam(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      userId: json['userId'],
      deckId: json['deckId'],
      deckName: json['deckName'],
      questionCount: json['questionCount'],
      timeLimitMinutes: json['timeLimitMinutes'],
      status: ExamStatus.values[json['status']],
      currentQuestionIndex: json['currentQuestionIndex'],
      cardIds: List<String>.from(json['cardIds']),
      answers: (json['answers'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          k,
          ExamAnswer(
            cardId: v['cardId'],
            isCorrect: v['isCorrect'],
            answeredAt: DateTime.fromMillisecondsSinceEpoch(v['answeredAt']),
          ),
        ),
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      startedAt: json['startedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['startedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'])
          : null,
      timeSpentSeconds: json['timeSpentSeconds'],
    );
  }

  Map<String, dynamic> _serializeHistoryEntry(ExamHistoryEntry entry) {
    return {
      'examId': entry.examId,
      'deckId': entry.deckId,
      'completedAt': entry.completedAt.millisecondsSinceEpoch,
      'questionCount': entry.questionCount,
      'correctCount': entry.correctCount,
      'scorePercentage': entry.scorePercentage,
      'timeSpentSeconds': entry.timeSpentSeconds,
    };
  }

  ExamHistoryEntry _parseHistoryEntry(Map<String, dynamic> json) {
    return ExamHistoryEntry(
      examId: json['examId'],
      deckId: json['deckId'],
      completedAt: DateTime.fromMillisecondsSinceEpoch(json['completedAt']),
      questionCount: json['questionCount'],
      correctCount: json['correctCount'],
      scorePercentage: json['scorePercentage'],
      timeSpentSeconds: json['timeSpentSeconds'],
    );
  }
}
