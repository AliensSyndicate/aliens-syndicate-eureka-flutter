import 'dart:io';
import 'dart:math';
import 'package:eureka/controllers/controller_lesson.dart';
import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/enums/learning_mode.dart';
import 'package:eureka/enums/question_type.dart';
import 'package:eureka/enums/subject_type.dart';
import 'package:eureka/models/model_lesson.dart';
import 'package:eureka/models/model_question.dart';
import 'package:eureka/models/content/model_content_page.dart';
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

  test(
    'libera o resumo apenas depois de verificar todas as atividades',
    () async {
      await controller.selectPage(controller.summaryPage);
      expect(controller.currentPage, controller.totalQuestions);
      expect(controller.canOpenSummary, isFalse);

      for (var page = 1; page <= controller.totalQuestions; page++) {
        await controller.selectPage(page);
        final question = controller.currentQuestion;
        await controller.saveDraft(question, question.correctAnswer);
        await controller.submit(question.correctAnswer);
      }

      expect(controller.canOpenSummary, isTrue);
      await controller.selectPage(controller.summaryPage);
      expect(controller.currentPage, controller.summaryPage);
    },
  );

  test(
    'tentar novamente limpa resultados e volta a primeira atividade',
    () async {
      await controller.selectPage(1);
      final question = controller.currentQuestion;
      await controller.saveDraft(question, question.correctAnswer);
      await controller.submit(question.correctAnswer);

      await controller.retry();

      expect(controller.currentPage, 1);
      expect(controller.answeredQuestions, 0);
      expect(controller.answerFor(question), isNull);
      expect(controller.resultFor(question), isNull);
      expect(controller.canOpenSummary, isFalse);
    },
  );

  test('jornada usa práticas e modos externos usam somente extras', () {
    final questions = [
      for (var index = 0; index < 8; index++)
        Question(
          id: 'runtime_$index',
          prompt: 'Questão $index',
          type: QuestionType.multipleChoice,
          options: const ['A', 'B', 'C', 'D'],
          correctAnswer: 'A',
          subjectId: 'mathematics',
          topicId: 'fractions',
          usage: index < 5
              ? QuestionUsage.practice
              : QuestionUsage.simulatorExplore,
        ),
    ];
    final lesson = Lesson(
      id: 'runtime_usage',
      title: 'Uso das questões',
      summary: 'Resumo',
      subject: SubjectType.mathematics,
      questions: questions,
    );
    LessonController build(LearningMode mode) => LessonController(
      lesson: lesson,
      mode: mode,
      answerService: AnswerService(),
      scoringService: ScoringService(),
      progressService: ProgressService(box),
      questionSelectionService: QuestionSelectionService(random: Random(1)),
    );

    expect(build(LearningMode.journey).visibleQuestions, hasLength(5));
    expect(build(LearningMode.explore).visibleQuestions, hasLength(3));
    expect(build(LearningMode.simulation).visibleQuestions, hasLength(3));
  });

  test('páginas estruturadas aparecem antes da primeira questão', () {
    final lesson = Lesson(
      id: 'structured_pages',
      title: 'Aula estruturada',
      summary: 'Fallback',
      subject: SubjectType.science,
      contentPages: const [
        ContentPage(page: 1, type: 'hook', title: 'Gancho', text: 'Observe.'),
        ContentPage(
          page: 2,
          type: 'explanation',
          title: 'Explicação',
          text: 'Entenda.',
        ),
      ],
      questions: [
        for (var index = 0; index < 5; index++)
          Question(
            id: 'structured_$index',
            prompt: 'Questão $index',
            type: QuestionType.multipleChoice,
            options: const ['A', 'B', 'C', 'D'],
            correctAnswer: 'A',
            subjectId: 'science',
            topicId: 'water',
          ),
      ],
    );
    final structured = LessonController(
      lesson: lesson,
      mode: LearningMode.journey,
      answerService: AnswerService(),
      scoringService: ScoringService(),
      progressService: ProgressService(box),
      questionSelectionService: QuestionSelectionService(random: Random(1)),
    );

    expect(structured.contentPageCount, 2);
    expect(structured.firstQuestionPage, 2);
    expect(structured.summaryPage, 7);
  });
}
