import '../enums/question_type.dart';
import '../models/model_question.dart';

/// Avalia respostas de forma consistente em todos os modos de estudo.
class AnswerService {
  /// Mínimo de caracteres aceito em uma resposta dissertativa.
  static const essayMinLength = 20;

  bool isCorrect(Question question, String answer) {
    // Resposta dissertativa não tem gabarito único: valida o esforço mínimo.
    if (question.type == QuestionType.essay) {
      return answer.trim().length >= essayMinLength;
    }
    return answer.trim().toLowerCase() ==
        question.correctAnswer.trim().toLowerCase();
  }
}
