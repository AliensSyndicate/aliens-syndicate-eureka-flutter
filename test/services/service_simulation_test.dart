import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/services/service_simulation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

import 'package:eureka/models/model_simulation.dart';

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

  test('calcula erros, brancos, tempo e desempenho por matéria', () {
    final lessons = seedLessons.take(2).toList();
    final questions = SimulationService(
      random: Random(4),
    ).buildQuestions(lessons, count: 4);
    expect(questions, isNotEmpty);
    final startedAt = DateTime(2026, 8, 22, 10);
    final answers = <String, String>{
      questions.first.question.id: questions.first.question.correctAnswer,
    };
    final session = SimulationSession(
      id: 'test',
      startedAt: startedAt,
      endTime: startedAt.add(const Duration(minutes: 20)),
      questions: questions,
      answers: answers,
    );

    final result = SimulationService().evaluateSession(
      session,
      finishedAt: startedAt.add(const Duration(minutes: 7)),
    );

    expect(result.correctAnswers, 1);
    expect(result.unansweredQuestions, questions.length - 1);
    expect(result.incorrectAnswers, 0);
    expect(result.durationUsed, const Duration(minutes: 7));
    expect(result.bySubject, isNotEmpty);
  });

  test('seleção usa somente questões próprias de simulado e sem repetição', () {
    final selected = SimulationService(
      random: Random(7),
    ).buildQuestions(seedLessons, count: 20);

    expect(
      selected.map((item) => item.question.id).toSet(),
      hasLength(selected.length),
    );
    expect(
      selected.every(
        (item) =>
            item.question.usage.name == 'simulatorExplore' ||
            item.question.usage.name == 'practice',
      ),
      isTrue,
    );
  });
}
