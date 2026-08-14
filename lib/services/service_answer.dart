import '../models/model_question.dart';

/// Avalia respostas de forma consistente em todos os modos de estudo.
class AnswerService {
  bool isCorrect(Question question, String answer) =>
      answer.trim().toLowerCase() ==
      question.correctAnswer.trim().toLowerCase();
}
