import 'dart:io';

import 'package:eureka/app/components/app_button.dart';
import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/enums/learning_mode.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/pages/lesson/page_lesson.dart';
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

  tearDownAll(() async {
    await Hive.close();
    tempDirectory.deleteSync(recursive: true);
  });

  testWidgets('mostra descricao e libera uma atividade por vez', (
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

    expect(find.text(modelMultipleChoiceLesson.summary), findsOneWidget);
    expect(find.byType(QuestionOption), findsNothing);
    expect(find.bySemanticsLabel(AppStrings.startActivity), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(AppStrings.startActivity));
    await tester.pumpAndSettle();

    var pager = tester.widget<PageView>(find.byType(PageView));
    expect(pager.childrenDelegate.estimatedChildCount, 2);
    expect(pager.controller?.page, closeTo(1, .01));
    expect(find.text(AppStrings.activityPosition(1, 5)), findsOneWidget);
    expect(find.text(AppStrings.activityPosition(2, 5)), findsNothing);
    expect(find.byType(QuestionOption), findsNWidgets(4));

    final currentQuestion = modelMultipleChoiceLesson.questions.singleWhere(
      (question) => find.text(question.prompt).evaluate().isNotEmpty,
    );
    final correctOption = tester.widget<QuestionOption>(
      find.ancestor(
        of: find.text(currentQuestion.correctAnswer),
        matching: find.byType(QuestionOption),
      ),
    );
    correctOption.onTap!();
    await tester.pump();
    final confirm = tester.widget<AppButton>(
      find.byKey(const ValueKey('lesson-bottom-action')),
    );
    expect(confirm.isEnabled, isTrue);
    confirm.onPressed!();
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.nextQuestion.toUpperCase()), findsOneWidget);

    await tester.tap(find.text(AppStrings.nextQuestion.toUpperCase()));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.activityPosition(2, 5)), findsOneWidget);
    pager = tester.widget<PageView>(find.byType(PageView));
    expect(pager.childrenDelegate.estimatedChildCount, 3);
    expect(pager.controller?.page, closeTo(2, .01));

    await tester.drag(find.byType(PageView), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.activityPosition(1, 5)), findsOneWidget);
    expect(find.byType(QuestionOption), findsNWidgets(4));
    expect(
      find.text(AppStrings.returnToCurrentActivity.toUpperCase()),
      findsOneWidget,
    );

    final optionInkWells = tester.widgetList<InkWell>(
      find.descendant(
        of: find.byType(QuestionOption),
        matching: find.byType(InkWell),
      ),
    );
    expect(optionInkWells.every((item) => item.onTap == null), isTrue);

    await tester.drag(find.byType(PageView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.text(modelMultipleChoiceLesson.summary), findsOneWidget);
    expect(pager.controller?.page, closeTo(0, .01));

    final returnAction = tester.widget<AppButton>(
      find.byKey(const ValueKey('lesson-bottom-action')),
    );
    returnAction.onPressed!();
    await tester.pumpAndSettle();
    expect(pager.controller?.page, closeTo(2, .01));
  });
}
