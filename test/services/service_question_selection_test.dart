import 'dart:math';

import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/enums/question_type.dart';
import 'package:eureka/models/model_question.dart';
import 'package:eureka/services/service_question_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('evita repetição imediata quando existe alternativa', () {
    final pool = seedLessons.first.questions;
    final result = QuestionSelectionService().select(
      pool,
      count: 1,
      lastQuestionId: pool.first.id,
    );
    expect(result.single.id, isNot(pool.first.id));
  });

  test('sorteia cinco questões únicas sem alterar o banco original', () {
    final pool = List.generate(
      10,
      (index) => Question(
        id: 'question_$index',
        prompt: 'Questão $index',
        type: QuestionType.multipleChoice,
        options: const ['A', 'B', 'C', 'D'],
        correctAnswer: 'A',
        subjectId: 'mathematics',
        topicId: 'topic',
      ),
    );
    final originalIds = pool.map((question) => question.id).toList();

    final result = QuestionSelectionService(
      random: Random(42),
    ).select(pool, count: QuestionSelectionService.sessionSize);

    expect(result, hasLength(5));
    expect(result.map((question) => question.id).toSet(), hasLength(5));
    expect(result.every(pool.contains), isTrue);
    expect(pool.map((question) => question.id), originalIds);
  });
}
