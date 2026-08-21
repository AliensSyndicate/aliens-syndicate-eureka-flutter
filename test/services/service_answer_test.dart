import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/enums/question_type.dart';
import 'package:eureka/models/model_question.dart';
import 'package:eureka/models/model_matching_pair.dart';
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

  test('entrada de texto exige uma unica palavra identica com acento', () {
    final question = Question(
      id: 'accent_test',
      prompt: 'Complete a palavra.',
      type: QuestionType.textInput,
      options: const [],
      correctAnswer: 'fração',
      subjectId: 'mathematics',
      topicId: 'fractions',
    );
    final service = AnswerService();

    expect(service.isCorrect(question, 'fração'), isTrue);
    expect(service.isCorrect(question, 'fracao'), isFalse);
    expect(service.isCorrect(question, 'Fração'), isFalse);
    expect(service.isCorrect(question, 'fração correta'), isFalse);
  });

  test('associação só corrige a resposta completa ao verificar', () {
    final question = Question(
      id: 'matching_test',
      prompt: 'Associe.',
      type: QuestionType.matching,
      options: const [],
      correctAnswer: '__matching_done__',
      subjectId: 'mathematics',
      topicId: 'fractions',
      pairs: const [
        MatchingPair(left: 'A', right: '1'),
        MatchingPair(left: 'B', right: '2'),
        MatchingPair(left: 'C', right: '3'),
        MatchingPair(left: 'D', right: '4'),
        MatchingPair(left: 'E', right: '5'),
      ],
    );
    final service = AnswerService();

    expect(
      service.isCorrect(question, '{"A":"1","B":"2","C":"3","D":"4","E":"5"}'),
      isTrue,
    );
    expect(
      service.isCorrect(question, '{"A":"2","B":"1","C":"3","D":"4","E":"5"}'),
      isFalse,
    );
  });
}
