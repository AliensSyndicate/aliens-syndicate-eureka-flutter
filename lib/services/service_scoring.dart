/// Centraliza a pontuação para impedir XP fora da jornada principal.
class ScoringService {
  static const int xpPerCorrectJourneyAnswer = 20;
  static const int activitiesPerJourneyLesson = 5;
  static const int maximumJourneyLessonXp =
      xpPerCorrectJourneyAnswer * activitiesPerJourneyLesson;

  int calculateJourneyXp({required int correctAnswers}) =>
      correctAnswers * xpPerCorrectJourneyAnswer;

  int maximumJourneyXpForQuestionCount(int availableQuestions) =>
      calculateJourneyXp(
        correctAnswers: availableQuestions.clamp(0, activitiesPerJourneyLesson),
      );

  int calculateJourneyXpFromResults(Iterable<bool> results) =>
      calculateJourneyXp(
        correctAnswers: results.where((isCorrect) => isCorrect).length,
      );
}
