import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/enums/question_type.dart';
import 'package:eureka/models/model_question.dart';
import 'package:eureka/services/service_answer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normaliza espaços e caixa da resposta', () {
    final question = seedLessons.first.questions.firstWhere(
      (q) => q.type == QuestionType.multipleChoice,
    );
    expect(AnswerService().isCorrect(question, ' 1/2 '), isTrue);
  });

  test('preserva a explicacao pedagogica especifica da questao', () {
    final question = Question(
      id: 'fraction_feedback_test',
      prompt: 'Qual fração representa metade?',
      type: QuestionType.multipleChoice,
      options: const ['1/2', '1/3', '2/3', '3/3'],
      correctAnswer: '1/2',
      explanation:
          'Metade significa uma de duas partes iguais. Por isso, usamos 1/2.',
      subjectId: 'mathematics',
      topicId: 'fractions',
    );

    expect(question.incorrectFeedback, question.explanation);
  });
}
