import '../enums/learning_mode.dart';
import '../models/model_lesson.dart';
import '../models/model_question.dart';
import '../models/model_lesson_session.dart';
import '../models/model_activity_result.dart';
import '../services/service_answer.dart';
import '../services/service_progress.dart';
import '../services/service_question_selection.dart';
import '../services/service_scoring.dart';

class LessonController {
  LessonController({
    required this.lesson,
    required this.mode,
    required AnswerService answerService,
    required ScoringService scoringService,
    required ProgressService progressService,
    required QuestionSelectionService questionSelectionService,
  }) : _answerService = answerService,
       _scoringService = scoringService,
       _progressService = progressService {
    final saved = _progressService.loadLessonSession(lesson.id);
    final pool = mode != LearningMode.journey
        ? lesson.extraQuestions
        : lesson.practiceQuestions;
    final savedById = {for (final question in pool) question.id: question};
    final compatibleSaved =
        saved.activityVersion == lesson.activityVersion &&
        saved.questionIds.isNotEmpty &&
        saved.questionIds.every(savedById.containsKey);
    _questions = List.unmodifiable(
      compatibleSaved
          ? saved.questionIds.map((id) => savedById[id]!)
          : mode != LearningMode.journey
          ? pool
          : questionSelectionService.select(
              pool,
              count: QuestionSelectionService.sessionSize,
            ),
    );
    if (compatibleSaved ||
        (saved.questionIds.isEmpty &&
            saved.answers.isEmpty &&
            saved.results.isEmpty)) {
      _answers.addAll(saved.answers);
      _results.addAll(saved.results);
    }
    if (compatibleSaved) {
      _rewardedQuestionIds.addAll(saved.rewardedQuestionIds);
      if (saved.rewardedQuestionIds.isEmpty) {
        _rewardedQuestionIds.addAll(
          saved.results.entries
              .where((entry) => entry.value)
              .map((entry) => entry.key),
        );
      }
    }
    _completed = compatibleSaved && saved.completed;
    currentPage = saved.currentPage.clamp(0, summaryPage);
  }
  final Lesson lesson;
  final LearningMode mode;
  final AnswerService _answerService;
  final ScoringService _scoringService;
  final ProgressService _progressService;
  late final List<Question> _questions;
  final Map<String, String> _answers = {};
  final Map<String, bool> _results = {};
  final Set<String> _rewardedQuestionIds = {};
  int currentPage = 0;
  bool _completed = false;
  bool get isCompleted => _completed;
  int get contentPageCount =>
      lesson.contentPages.isEmpty ? 1 : lesson.contentPages.length;
  int get firstQuestionPage => contentPageCount;
  bool isContentPage(int page) => page >= 0 && page < contentPageCount;
  int get currentIndex =>
      (currentPage - firstQuestionPage).clamp(0, _questions.length - 1);
  Question get currentQuestion => _questions[currentIndex];
  List<Question> get visibleQuestions => List.unmodifiable(_questions);
  int get totalQuestions => _questions.length;
  bool get isLastQuestion => currentIndex == _questions.length - 1;
  bool get hasSubmittedCurrent => _results.containsKey(currentQuestion.id);
  int get answeredQuestions => _results.length;
  bool get canOpenSummary => answeredQuestions == totalQuestions;
  int get summaryPage => contentPageCount + totalQuestions;
  double get completionProgress =>
      totalQuestions == 0 ? 0 : answeredQuestions / totalQuestions;
  String? answerFor(Question question) => _answers[question.id];
  bool? resultFor(Question question) => _results[question.id];
  int get correctAnswers => _results.values.where((result) => result).length;
  List<String> get reviewTopics => _questions
      .where((question) => _results[question.id] == false)
      .map((question) => question.topicId)
      .toSet()
      .toList();
  int get earnedXp => mode == LearningMode.journey
      ? _scoringService.calculateJourneyXp(
          correctAnswers: _rewardedQuestionIds.length,
        )
      : 0;
  bool hasEarnedXpFor(Question question) =>
      _rewardedQuestionIds.contains(question.id);
  Future<void> selectPage(int page) async {
    currentPage = page.clamp(0, summaryPage);
    await _persist();
  }

  Future<void> saveDraft(Question question, String answer) async {
    if (_results.containsKey(question.id)) return;
    _answers[question.id] = answer;
    await _persist();
  }

  Future<bool> submit(String answer) async {
    if (answer.trim().isEmpty) {
      throw ArgumentError.value(answer, 'answer', 'A resposta é obrigatória.');
    }
    if (hasSubmittedCurrent) {
      throw StateError('A atividade atual já foi respondida.');
    }
    _answers[currentQuestion.id] = answer;
    final correct = _answerService.isCorrect(currentQuestion, answer);
    _results[currentQuestion.id] = correct;
    if (correct && mode == LearningMode.journey) {
      _rewardedQuestionIds.add(currentQuestion.id);
    }
    if (!correct) {
      await _progressService.recordDifficulty(currentQuestion.subjectId);
      await _progressService.recordDifficulty(currentQuestion.topicId);
    }
    await _persist();
    return correct;
  }

  List<int> get incorrectPages => _questions.indexed
      .where((entry) => _results[entry.$2.id] == false)
      .map((entry) => entry.$1 + firstQuestionPage)
      .toList();

  Future<void> _persist() => _progressService.saveLessonSession(
    lesson.id,
    LessonSession(
      currentPage: currentPage,
      answers: Map.unmodifiable(_answers),
      results: Map.unmodifiable(_results),
      questionIds: _questions.map((question) => question.id).toList(),
      rewardedQuestionIds: _rewardedQuestionIds.toList(),
      activityVersion: lesson.activityVersion,
      completed: _completed,
    ),
  );

  Future<void> complete({
    Duration duration = Duration.zero,
    DateTime? now,
  }) async {
    if (_completed) return;
    _completed = true;
    await _persist();
    if (mode == LearningMode.journey) {
      await _progressService.completeLesson(lesson.id, earnedXp);
    }
    final completedAt = now ?? DateTime.now();
    await _progressService.saveActivityResult(
      ActivityResultSnapshot(
        attemptId: '${lesson.id}-${completedAt.microsecondsSinceEpoch}',
        lessonId: lesson.id,
        lessonTitle: lesson.title,
        subjectId: lesson.subject.name,
        activityVersion: lesson.activityVersion,
        questionIds: _questions.map((question) => question.id).toList(),
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        earnedXp: earnedXp,
        duration: duration.isNegative ? Duration.zero : duration,
        reviewTopics: reviewTopics,
        completedAt: completedAt,
      ),
    );
  }

  Future<void> retry() async {
    _answers.clear();
    _results.clear();
    currentPage = _questions.isEmpty ? 0 : firstQuestionPage;
    _completed = false;
    await _persist();
  }
}
