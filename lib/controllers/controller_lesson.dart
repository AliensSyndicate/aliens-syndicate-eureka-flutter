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
  int currentIndex = 0;
  Question get currentQuestion => _questions[currentIndex];
  int get totalQuestions => _questions.length;
  bool get isLastQuestion => currentIndex == _questions.length - 1;
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
    _answers[currentQuestion.id] = answer;
    final correct = _answerService.isCorrect(currentQuestion, answer);
    if (!correct) {
      await _progressService.recordDifficulty(currentQuestion.subjectId);
    }
    return correct;
  }

  void next() {
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
