import 'package:eureka/enums/subject_type.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/models/model_lesson.dart';
import 'package:eureka/pages/subject/widgets/widget_subject_lessons_app_bar.dart';
import 'package:eureka/pages/subject/widgets/widget_subject_progress_card.dart';
import 'package:eureka/ui/ui_card.dart';
import 'package:eureka/ui/ui_color.dart';
import 'package:eureka/ui/ui_size.dart';
import 'package:eureka/ui/ui_spacing.dart';
import 'package:eureka/ui/ui_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

void main() {
  testWidgets('usa a cor e o progresso geral da matéria no cabeçalho', (
    tester,
  ) async {
    var backPressed = false;
    var reportPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: SubjectLessonsAppBar(
            title: 'Matemática',
            color: UiColor.mathematics,
            subject: SubjectType.mathematics,
            schoolYear: 5,
            xp: 100,
            onBack: () => backPressed = true,
            onReport: () => reportPressed = true,
          ),
        ),
      ),
    );

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, UiColor.mathematics);
    expect(appBar.systemOverlayStyle?.statusBarColor, Colors.transparent);
    expect(appBar.toolbarHeight, UiSize.subjectAppBarHeight);
    final background = tester.widget<Ink>(
      find.byKey(const ValueKey('subject-app-bar-background')),
    );
    final backgroundDecoration = background.decoration! as BoxDecoration;
    final backgroundGradient = backgroundDecoration.gradient! as LinearGradient;
    expect(backgroundGradient.colors.first, UiColor.mathematics);
    expect(backgroundGradient.colors[2], isNot(UiColor.mathematics));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('subject-header-planet'))).dy,
      0,
    );
    expect(find.byKey(const ValueKey('subject-progress-card')), findsNothing);
    expect(find.text('Matemática'), findsOneWidget);
    final schoolYear = tester.widget<Text>(
      find.text('5º ano do Ensino Fundamental'),
    );
    expect(schoolYear.style?.fontSize, UiText.p.fontSize);
    expect(schoolYear.style?.color, UiColor.textPrimary);
    expect(schoolYear.maxLines, 1);
    expect(schoolYear.softWrap, isFalse);
    final xpText = tester.widget<Text>(find.text('100 XP'));
    expect(xpText.style?.color, UiColor.xp);
    expect(find.byKey(const ValueKey('subject-xp-card')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('subject-xp-card'))).width,
      lessThan(tester.getSize(find.byType(AppBar)).width),
    );
    expect(
      tester.getTopLeft(find.text('100 XP')).dy,
      greaterThan(
        tester.getBottomLeft(find.text('5º ano do Ensino Fundamental')).dy,
      ),
    );
    final headerBottom = tester.getBottomLeft(find.byType(AppBar)).dy;
    final xpCardBottom = tester
        .getBottomLeft(find.byKey(const ValueKey('subject-xp-card')))
        .dy;
    expect(headerBottom - xpCardBottom, UiSpacing.headerBottomGap);
    expect(find.text(AppStrings.completeAllLessons), findsNothing);
    expect(find.byType(HugeIcon), findsNWidgets(2));
    await tester.tap(find.byTooltip(AppStrings.back));
    await tester.tap(find.byTooltip(AppStrings.reportError));
    expect(backPressed, isTrue);
    expect(reportPressed, isTrue);
  });

  testWidgets('acomoda o card e a última aula sem overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: SubjectLessonsAppBar(
            title: 'Matemática',
            color: UiColor.mathematics,
            subject: SubjectType.mathematics,
            schoolYear: 5,
            xp: 20,
            lastCompletedLesson: const Lesson(
              id: 'lesson_1',
              title: 'Números naturais',
              summary: '',
              subject: SubjectType.mathematics,
              questions: [],
            ),
            onBack: _noop,
            onReport: _noop,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('subject-progress-card')), findsNothing);
    final headerBottom = tester.getBottomLeft(find.byType(AppBar)).dy;
    final xpCardBottom = tester
        .getBottomLeft(find.byKey(const ValueKey('subject-xp-card')))
        .dy;
    expect(headerBottom - xpCardBottom, UiSpacing.headerBottomGap);
    expect(find.text('Números naturais'), findsOneWidget);
  });

  testWidgets('card de progresso pode ficar no conteúdo da tela', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(20),
            child: SubjectProgressCard(
              completed: 2,
              total: 5,
              color: UiColor.mathematics,
            ),
          ),
        ),
      ),
    );

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, .4);
    expect(progress.color, UiColor.mathematics);
    expect(
      tester.getSize(find.byKey(const ValueKey('subject-progress-bar'))).height,
      UiCard.progressTagHeight,
    );
    expect(
      tester.getCenter(find.text('2/5')),
      tester.getCenter(find.byKey(const ValueKey('subject-progress-bar'))),
    );
    expect(find.text(AppStrings.completeAllLessons), findsOneWidget);
    final card = tester.widget<Container>(
      find.byKey(const ValueKey('subject-progress-card')),
    );
    final decoration = card.decoration! as BoxDecoration;
    expect(decoration.border, isNotNull);
    expect(decoration.border!.top.color, UiColor.outline);
    expect(decoration.border!.top.width, UiCard.borderWidth);
  });
}

void _noop() {}
