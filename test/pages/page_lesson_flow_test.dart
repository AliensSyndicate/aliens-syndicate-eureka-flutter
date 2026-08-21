import 'dart:io';

import 'package:eureka/app/components/app_button.dart';
import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/enums/learning_mode.dart';
import 'package:eureka/enums/subject_type.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/models/model_lesson.dart';
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
    expect(pager.childrenDelegate.estimatedChildCount, 6);
    expect(
      find.byKey(const ValueKey('lesson-page-indicator-5')),
      findsOneWidget,
    );
    final summaryIndicator = tester.widget<InkWell>(
      find.byKey(const ValueKey('lesson-page-indicator-6')),
    );
    expect(summaryIndicator.onTap, isNull);
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
}
