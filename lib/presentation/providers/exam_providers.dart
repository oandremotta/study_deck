import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/exam_service.dart';
import '../../domain/entities/exam.dart';

// ============ Service Provider ============

/// Provider for exam service.
final examServiceProvider = Provider<ExamService>((ref) {
  return ExamService();
});

// ============ Active Exam Provider ============

/// Provider for the active exam state.
class ExamNotifier extends StateNotifier<Exam?> {
  final ExamService _service;

  ExamNotifier(this._service) : super(null) {
    _loadActiveExam();
  }

  Future<void> _loadActiveExam() async {
    state = await _service.loadActiveExam();
  }

  /// UC221: Create a new exam.
  Future<Exam> createExam({
    required String userId,
    required String deckId,
    required String deckName,
    required List<String> cardIds,
    required int questionCount,
    int? timeLimitMinutes,
  }) async {
    final exam = _service.createExam(
      userId: userId,
      deckId: deckId,
      deckName: deckName,
      availableCardIds: cardIds,
      questionCount: questionCount,
      timeLimitMinutes: timeLimitMinutes,
    );
    state = exam;
    await _service.saveActiveExam(exam);
    return exam;
  }

  /// UC222: Start the exam.
  Future<void> startExam() async {
    if (state == null) return;
    state = _service.startExam(state!);
    await _service.saveActiveExam(state!);
  }

  /// UC222: Record answer.
  Future<void> recordAnswer(String cardId, bool isCorrect) async {
    if (state == null) return;
    state = _service.recordAnswer(state!, cardId, isCorrect);
    await _service.saveActiveExam(state!);
  }

  /// Update time spent.
  void updateTime(int seconds) {
    if (state == null) return;
    state = state!.updateTime(seconds);
  }

  /// UC223: Complete the exam.
  Future<ExamComparison> completeExam() async {
    if (state == null) {
      throw StateError('No active exam');
    }

    state = _service.completeExam(state!);
    await _service.saveToHistory(state!);
    final comparison = await _service.compareWithPrevious(state!);
    await _service.clearActiveExam();

    return comparison;
  }

  /// Abandon exam.
  Future<void> abandonExam() async {
    state = null;
    await _service.clearActiveExam();
  }

  /// UC224: Get error card IDs for review.
  List<String> getErrorCards() {
    if (state == null) return [];
    return _service.getErrorCards(state!);
  }
}

/// Provider for exam notifier.
final examNotifierProvider = StateNotifierProvider<ExamNotifier, Exam?>((ref) {
  final service = ref.watch(examServiceProvider);
  return ExamNotifier(service);
});

// ============ History Providers ============

/// Provider for exam history of a specific deck.
final examHistoryByDeckProvider =
    FutureProvider.family<List<ExamHistoryEntry>, String>((ref, deckId) async {
  final service = ref.watch(examServiceProvider);
  return service.getHistoryForDeck(deckId);
});

/// Provider for all exam history.
final allExamHistoryProvider =
    FutureProvider<List<ExamHistoryEntry>>((ref) async {
  final service = ref.watch(examServiceProvider);
  return service.getAllHistory();
});

// ============ Direct Functions ============

/// UC221: Create exam directly.
Future<Exam> createExamDirect(
  ExamService service, {
  required String userId,
  required String deckId,
  required String deckName,
  required List<String> cardIds,
  required int questionCount,
  int? timeLimitMinutes,
}) async {
  return service.createExam(
    userId: userId,
    deckId: deckId,
    deckName: deckName,
    availableCardIds: cardIds,
    questionCount: questionCount,
    timeLimitMinutes: timeLimitMinutes,
  );
}

/// UC225: Get exam history directly.
Future<List<ExamHistoryEntry>> getExamHistoryDirect(
  ExamService service,
  String deckId,
) async {
  return service.getHistoryForDeck(deckId);
}

/// UC226: Compare exams directly.
Future<ExamComparison> compareExamsDirect(
  ExamService service,
  Exam exam,
) async {
  return service.compareWithPrevious(exam);
}
