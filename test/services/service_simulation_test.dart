import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/services/service_simulation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('separa tópicos fortes e de revisão', () {
    final questions = seedLessons.expand((lesson) => lesson.questions).toList();
    final answers = {
      for (final question in questions)
        question.id: question.topicId == 'fractions'
            ? question.correctAnswer
            : 'incorreta',
    };
    final result = SimulationService().evaluate(questions, answers);
    expect(result.strongTopics, contains('fractions'));
    expect(result.reviewTopics, containsAll(['genres', 'water']));
  });
}
