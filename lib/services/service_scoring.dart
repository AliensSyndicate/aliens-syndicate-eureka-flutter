/// Centraliza a pontuação para impedir XP fora da jornada principal.
class ScoringService {
  static const int xpPerCorrectJourneyAnswer = 10;
  int calculateJourneyXp({required int correctAnswers}) =>
      correctAnswers * xpPerCorrectJourneyAnswer;
}
