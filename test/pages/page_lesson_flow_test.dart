import 'dart:io';

import 'package:eureka/app/components/app_button.dart';
import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/enums/learning_mode.dart';
import 'package:eureka/enums/question_type.dart';
import 'package:eureka/enums/subject_type.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/models/content/model_content_page.dart';
import 'package:eureka/models/model_lesson.dart';
import 'package:eureka/models/model_question.dart';
import 'package:eureka/pages/lesson/page_lesson.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_feedback_card.dart';
import 'package:eureka/pages/lesson/widgets/widget_question_option.dart';
import 'package:eureka/ui/ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDirectory;
  setUpAll(() async {
    tempDirectory = Directory.systemTemp.createTempSync('eureka_page_lesson_');
    Hive.init(tempDirectory.path);
    await Hive.openBox<dynamic>('eureka');
  });
  testWidgets('permite navegar livremente e so corrige ao verificar', (
    tester,
  ) async {
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: PageLesson(
          lesson: modelMultipleChoiceLesson,
          mode: LearningMode.journey,
        ),
      ),
    );

    final pager = tester.widget<PageView>(find.byType(PageView));
    expect(pager.scrollDirection, Axis.horizontal);
    expect(pager.childrenDelegate.estimatedChildCount, 7);
    expect(
      find.byKey(const ValueKey('lesson-page-indicator-5')),
      findsOneWidget,
    );
    final summaryIndicator = tester.widget<InkWell>(
      find.byKey(const ValueKey('lesson-page-indicator-6')),
    );
    expect(summaryIndicator.onTap, isNotNull);
    expect(find.text(modelMultipleChoiceLesson.summary), findsOneWidget);
    expect(find.text(AppStrings.startActivity), findsNothing);

    tester
        .widget<InkWell>(find.byKey(const ValueKey('lesson-page-indicator-4')))
        .onTap!();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(pager.controller?.page, closeTo(4, .01));
    expect(find.byType(QuestionOption), findsNWidgets(4));

    final verify = tester.widget<AppButton>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppButton && widget.label == AppStrings.checkAnswer,
      ),
    );
    expect(verify.isEnabled, isFalse);

    final option = tester.widget<QuestionOption>(
      find.byType(QuestionOption).first,
    );
    option.onTap!();
    await tester.pump();
    expect(find.text(AppStrings.correctFeedback), findsNothing);
    final enabledVerify = tester.widget<AppButton>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppButton && widget.label == AppStrings.checkAnswer,
      ),
    );
    expect(enabledVerify.isEnabled, isTrue);

    tester
        .widget<InkWell>(find.byKey(const ValueKey('lesson-page-indicator-0')))
        .onTap!();
    await tester.pumpAndSettle();
    expect(find.text(modelMultipleChoiceLesson.summary), findsOneWidget);
    tester
        .widget<InkWell>(find.byKey(const ValueKey('lesson-page-indicator-4')))
        .onTap!();
    await tester.pumpAndSettle();
    expect(find.byType(QuestionOption), findsNWidgets(4));
  });

  testWidgets('permite rolagem vertical quando o conteudo for longo', (
    tester,
  ) async {
    final longContent = List.filled(
      16,
      'Frações representam partes iguais de um todo.',
    ).join('\n\n');
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: PageLesson(
          lesson: Lesson(
            id: 'vertical_scroll_test',
            title: 'Frações na prática',
            summary: longContent,
            subject: SubjectType.mathematics,
            questions: const [],
          ),
          mode: LearningMode.journey,
        ),
      ),
    );

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey('lesson-description-page')),
    );
    expect(scrollView.scrollDirection, Axis.vertical);
    final indicator = find.byKey(const ValueKey('lesson-page-indicator-0'));
    final initialIndicatorTop = tester.getTopLeft(indicator).dy;
    final initialTop = tester.getTopLeft(find.text(longContent)).dy;
    await tester.drag(
      find.byKey(const ValueKey('lesson-description-page')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text(longContent)).dy, lessThan(initialTop));
    expect(tester.getTopLeft(indicator).dy, initialIndicatorTop);
  });

  testWidgets(
    'renderiza paginas estruturadas antes das cinco praticas com labels corretos',
    (tester) async {
      final lesson = _structuredLesson();
      await tester.pumpWidget(
        MaterialApp(
          theme: UiTheme.dark,
          home: PageLesson(lesson: lesson, mode: LearningMode.journey),
        ),
      );

      final pager = tester.widget<PageView>(find.byType(PageView));
      expect(pager.childrenDelegate.estimatedChildCount, 8);
      expect(find.text('Gancho da água'), findsOneWidget);
      expect(find.text('1 de 8 - Gancho da água'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('lesson-page-indicator-7')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('lesson-page-indicator-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('lesson-page-indicator-1')),
        findsOneWidget,
      );

      tester
          .widget<InkWell>(
            find.byKey(const ValueKey('lesson-page-indicator-1')),
          )
          .onTap!();
      await tester.pumpAndSettle();
      expect(find.text('Descoberta'), findsOneWidget);
      expect(find.text('2 de 8 - Descoberta'), findsOneWidget);

      tester
          .widget<InkWell>(
            find.byKey(const ValueKey('lesson-page-indicator-2')),
          )
          .onTap!();
      await tester.pumpAndSettle();
      expect(find.text('Prática 0'), findsOneWidget);
      expect(find.text('3 de 8 - Escolha uma resposta'), findsOneWidget);
    },
  );

  testWidgets('mantem summary legado como unica pagina de conteudo', (
    tester,
  ) async {
    final lesson = Lesson(
      id: 'legacy_summary_widget',
      title: 'Conteúdo legado',
      summary: 'Este resumo continua disponível.',
      subject: SubjectType.history,
      questions: [_question('legacy_practice', QuestionUsage.practice)],
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: PageLesson(lesson: lesson, mode: LearningMode.journey),
      ),
    );

    expect(find.text('Este resumo continua disponível.'), findsOneWidget);
    expect(find.text('1 de 3 - ${AppStrings.lessonContent}'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('lesson-page-indicator-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('lesson-page-indicator-1')),
      findsOneWidget,
    );
  });

  for (final answer in ['A', 'B']) {
    final correct = answer == 'A';
    testWidgets(
      'troca Verificar por feedback inline ${correct ? 'correto' : 'errado'}',
      (tester) async {
        final question = Question(
          id: 'feedback_${answer.toLowerCase()}',
          prompt: 'Quanto é 2 + 2?',
          type: QuestionType.multipleChoice,
          options: const ['A', 'B', 'C', 'D'],
          correctAnswer: 'A',
          subjectId: 'mathematics',
          topicId: 'addition',
          explanation: 'Dois mais dois formam quatro unidades.',
        );
        final lesson = Lesson(
          id: 'feedback_lesson_${answer.toLowerCase()}',
          title: 'Adição',
          summary: 'Some as parcelas.',
          subject: SubjectType.mathematics,
          questions: [question],
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: UiTheme.dark,
            home: PageLesson(lesson: lesson, mode: LearningMode.journey),
          ),
        );
        tester
            .widget<InkWell>(
              find.byKey(const ValueKey('lesson-page-indicator-1')),
            )
            .onTap!();
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(ValueKey('lesson-option-${question.id}-$answer')),
        );
        await tester.pump();
        await tester.tap(find.byKey(ValueKey('verify-${question.id}')));
        await tester.pumpAndSettle();

        expect(find.byType(LessonFeedbackCard), findsOneWidget);
        expect(find.byKey(ValueKey('verify-${question.id}')), findsNothing);
        expect(
          find.text(
            correct ? AppStrings.correctTitle : AppStrings.incorrectTitle,
          ),
          findsOneWidget,
        );
        expect(
          find.text(AppStrings.correctAnswer),
          correct ? findsNothing : findsOneWidget,
        );
        expect(
          find.text('Dois mais dois formam quatro unidades.'),
          correct ? findsNothing : findsOneWidget,
        );
        expect(
          find.text(AppStrings.earnedXpGain(20)),
          correct ? findsOneWidget : findsNothing,
        );
      },
    );
  }

  for (final mode in [LearningMode.explore, LearningMode.simulation]) {
    testWidgets('$mode mostra somente as tres questoes extras', (tester) async {
      final lesson = _structuredLesson();
      await tester.pumpWidget(
        MaterialApp(
          theme: UiTheme.dark,
          home: PageLesson(lesson: lesson, mode: mode),
        ),
      );

      final pager = tester.widget<PageView>(find.byType(PageView));
      expect(pager.childrenDelegate.estimatedChildCount, 6);
      expect(
        find.byKey(const ValueKey('lesson-page-indicator-5')),
        findsOneWidget,
      );
      tester
          .widget<InkWell>(
            find.byKey(const ValueKey('lesson-page-indicator-2')),
          )
          .onTap!();
      await tester.pumpAndSettle();

      expect(find.text('Extra 0'), findsOneWidget);
      expect(find.text('Prática 0'), findsNothing);
      expect(find.text(AppStrings.noXpOutsideJourney), findsNothing);
    });
  }
}

Lesson _structuredLesson() => Lesson(
  id: 'structured_widget',
  title: 'Ciclo da água',
  summary: 'Resumo legado que não deve substituir páginas.',
  subject: SubjectType.science,
  contentPages: const [
    ContentPage(
      page: 1,
      type: 'hook',
      title: 'Gancho da água',
      text: 'Para onde vai a água da poça?',
    ),
    ContentPage(
      page: 2,
      type: 'discovery',
      title: 'Descoberta',
      text: 'O calor transforma a água.',
      keyConcept: 'A água muda de estado.',
    ),
  ],
  questions: [
    for (var index = 0; index < 5; index++)
      _question('practice_$index', QuestionUsage.practice),
    for (var index = 0; index < 3; index++)
      _question('extra_$index', QuestionUsage.simulatorExplore),
  ],
);

Question _question(String id, QuestionUsage usage) => Question(
  id: id,
  prompt: usage == QuestionUsage.practice
      ? 'Prática ${id.split('_').last}'
      : 'Extra ${id.split('_').last}',
  type: QuestionType.multipleChoice,
  options: const ['A', 'B', 'C', 'D'],
  correctAnswer: 'A',
  subjectId: 'science',
  topicId: 'water_cycle',
  usage: usage,
);
