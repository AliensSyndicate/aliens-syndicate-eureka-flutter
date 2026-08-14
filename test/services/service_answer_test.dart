import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/services/service_answer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normaliza espaços e caixa da resposta', () {
    final question = seedLessons.first.questions.first;
    expect(AnswerService().isCorrect(question, ' 1/2 '), isTrue);
  });
}
