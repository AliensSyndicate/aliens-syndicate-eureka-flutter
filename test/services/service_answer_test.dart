import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/enums/question_type.dart';
import 'package:eureka/services/service_answer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normaliza espaços e caixa da resposta', () {
    final question = seedLessons.first.questions.firstWhere(
      (q) => q.type == QuestionType.multipleChoice,
    );
    expect(AnswerService().isCorrect(question, ' 1/2 '), isTrue);
  });
}
