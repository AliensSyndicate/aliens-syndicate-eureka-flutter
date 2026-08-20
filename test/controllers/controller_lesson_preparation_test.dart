import 'package:eureka/controllers/controller_lesson_preparation.dart';
import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/models/model_lesson.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prepara uma atividade completa para a jornada', () async {
    var calls = 0;
    final controller = LessonPreparationController(
      loadActivity: (lesson) async {
        calls++;
        return modelMultipleChoiceLesson;
      },
    );

    final result = await controller.prepare(_emptyLesson('journey'));

    expect(result, same(modelMultipleChoiceLesson));
    expect(calls, 1);
  });

  test('retorna indisponivel quando nenhuma atividade tem perguntas', () async {
    final controller = LessonPreparationController(
      loadActivity: (lesson) async => lesson,
    );

    final result = await controller.prepare(_emptyLesson('empty'));

    expect(result, isNull);
  });
}

Lesson _emptyLesson(String id) => Lesson(
  id: id,
  title: 'Frações',
  summary: 'Resumo',
  subject: modelMultipleChoiceLesson.subject,
  questions: const [],
);
