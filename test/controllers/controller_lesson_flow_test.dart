import 'dart:io';
import 'dart:math';

import 'package:eureka/controllers/controller_lesson.dart';
import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/enums/learning_mode.dart';
import 'package:eureka/services/service_answer.dart';
import 'package:eureka/services/service_progress.dart';
import 'package:eureka/services/service_question_selection.dart';
import 'package:eureka/services/service_scoring.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDirectory;
  late Box<dynamic> box;
  late LessonController controller;

  setUpAll(() async {
    tempDirectory = Directory.systemTemp.createTempSync('eureka_lesson_flow_');
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<dynamic>('lesson_flow');
  });

  tearDownAll(() async {
    await Hive.close();
    tempDirectory.deleteSync(recursive: true);
  });

  setUp(() async {
    await box.clear();
    controller = LessonController(
      lesson: modelMultipleChoiceLesson,
      mode: LearningMode.journey,
      answerService: AnswerService(),
      scoringService: ScoringService(),
      progressService: ProgressService(box),
      questionSelectionService: QuestionSelectionService(random: Random(42)),
    );
  });

  test('libera uma atividade por vez e preserva a resposta anterior', () async {
    expect(controller.totalQuestions, 5);
    expect(controller.visibleQuestions, hasLength(1));
    expect(controller.completionProgress, 0);

    final first = controller.currentQuestion;
    expect(await controller.submit(first.correctAnswer), isTrue);
    expect(controller.answerFor(first), first.correctAnswer);
    expect(controller.resultFor(first), isTrue);
    expect(controller.completionProgress, .2);
    await expectLater(controller.submit(first.correctAnswer), throwsStateError);

    controller.next();
    expect(controller.visibleQuestions, hasLength(2));
    expect(controller.currentQuestion.id, isNot(first.id));
    expect(controller.answerFor(first), first.correctAnswer);
  });

  test('nao avanca antes de responder a atividade obrigatoria', () {
    expect(controller.next, throwsStateError);
  });

  test('atividade modelo tem cinco questoes com quatro opcoes numeradas', () {
    expect(modelMultipleChoiceLesson.questions, hasLength(5));
    expect(
      modelMultipleChoiceLesson.questions.every(
        (question) =>
            question.options.length == 4 &&
            question.options.asMap().entries.every(
              (entry) => entry.value.startsWith('${entry.key + 1}. '),
            ),
      ),
      isTrue,
    );
  });
}
