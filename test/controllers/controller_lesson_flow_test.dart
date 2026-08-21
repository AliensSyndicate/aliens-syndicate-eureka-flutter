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
  LessonController createController() => LessonController(
    lesson: modelMultipleChoiceLesson,
    mode: LearningMode.journey,
    answerService: AnswerService(),
    scoringService: ScoringService(),
    progressService: ProgressService(box),
    questionSelectionService: QuestionSelectionService(random: Random(42)),
  );
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
    controller = createController();
  });

  test(
    'disponibiliza todas as atividades e permite pular livremente',
    () async {
      expect(controller.visibleQuestions, hasLength(5));
      await controller.selectPage(4);
      expect(controller.currentPage, 4);
      expect(controller.answeredQuestions, 0);
      await controller.selectPage(0);
      expect(controller.currentPage, 0);
    },
  );

  test('persiste pagina, rascunho e resultado por atividade', () async {
    await controller.selectPage(4);
    final question = controller.currentQuestion;
    await controller.saveDraft(question, question.correctAnswer);
    expect(controller.resultFor(question), isNull);
    expect(await controller.submit(question.correctAnswer), isTrue);
    final restored = createController();
    expect(restored.currentPage, 4);
    expect(restored.answerFor(question), question.correctAnswer);
    expect(restored.resultFor(question), isTrue);
  });

  test('erro conta como respondido sem bloquear outra pagina', () async {
    await controller.selectPage(2);
    final question = controller.currentQuestion;
    final wrong = question.options.firstWhere(
      (e) => e != question.correctAnswer,
    );
    await controller.saveDraft(question, wrong);
    expect(await controller.submit(wrong), isFalse);
    expect(controller.answeredQuestions, 1);
    expect(controller.incorrectPages, [2]);
    await controller.selectPage(5);
    expect(controller.currentPage, 5);
  });
}
