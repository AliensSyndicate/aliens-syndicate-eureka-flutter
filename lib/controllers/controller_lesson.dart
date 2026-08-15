import '../enums/learning_mode.dart';
import '../models/model_lesson.dart';
import '../models/model_question.dart';
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
       _progressService = progressService,
       _questions = mode == LearningMode.simulation
           ? List.unmodifiable(lesson.questions)
           : List.unmodifiable(
               questionSelectionService.select(
                 lesson.questions,
                 count: QuestionSelectionService.sessionSize,
               ),
             );
  final Lesson lesson;
  final LearningMode mode;
  final AnswerService _answerService;
  final ScoringService _scoringService;
  final ProgressService _progressService;
  final List<Question> _questions;
  final Map<String, String> _answers = {};
  final Map<String, bool> _results = {};
  int currentIndex = 0;
  Question get currentQuestion => _questions[currentIndex];
  List<Question> get visibleQuestions => List.unmodifiable(
    _questions.take((currentIndex + 1).clamp(0, _questions.length)),
  );
  int get totalQuestions => _questions.length;
  bool get isLastQuestion => currentIndex == _questions.length - 1;
  bool get hasSubmittedCurrent => _answers.containsKey(currentQuestion.id);
  int get answeredQuestions => _answers.length;
  double get completionProgress =>
      totalQuestions == 0 ? 0 : answeredQuestions / totalQuestions;
  String? answerFor(Question question) => _answers[question.id];
  bool? resultFor(Question question) => _results[question.id];
  int get correctAnswers => _questions
      .where(
        (question) =>
            _answerService.isCorrect(question, _answers[question.id] ?? ''),
      )
      .length;
  List<String> get reviewTopics => _questions
      .where(
        (question) =>
            !_answerService.isCorrect(question, _answers[question.id] ?? ''),
      )
      .map((question) => question.topicId)
      .toSet()
      .toList();
  int get earnedXp => mode == LearningMode.journey
      ? _scoringService.calculateJourneyXp(correctAnswers: correctAnswers)
      : 0;
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
    if (!correct) {
      await _progressService.recordDifficulty(currentQuestion.subjectId);
    }
    return correct;
  }

  void next() {
    if (!hasSubmittedCurrent) {
      throw StateError('Responda a atividade atual antes de avançar.');
    }
    if (!isLastQuestion) {
      currentIndex++;
    }
  }

  Future<void> complete() async {
    if (mode == LearningMode.journey) {
      await _progressService.completeLesson(lesson.id, earnedXp);
    }
  }
}
