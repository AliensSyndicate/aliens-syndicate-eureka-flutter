import '../enums/learning_mode.dart';
import '../models/model_lesson.dart';
import '../models/model_question.dart';
import '../services/service_answer.dart';
import '../services/service_progress.dart';
import '../services/service_scoring.dart';

class LessonController {
  LessonController({
    required this.lesson,
    required this.mode,
    required AnswerService answerService,
    required ScoringService scoringService,
    required ProgressService progressService,
  }) : _answerService = answerService,
       _scoringService = scoringService,
       _progressService = progressService;
  final Lesson lesson;
  final LearningMode mode;
  final AnswerService _answerService;
  final ScoringService _scoringService;
  final ProgressService _progressService;
  final Map<String, String> _answers = {};
  int currentIndex = 0;
  Question get currentQuestion => lesson.questions[currentIndex];
  bool get isLastQuestion => currentIndex == lesson.questions.length - 1;
  int get correctAnswers => lesson.questions
      .where(
        (question) =>
            _answerService.isCorrect(question, _answers[question.id] ?? ''),
      )
      .length;
  List<String> get reviewTopics => lesson.questions
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
  bool submit(String answer) {
    _answers[currentQuestion.id] = answer;
    return _answerService.isCorrect(currentQuestion, answer);
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
