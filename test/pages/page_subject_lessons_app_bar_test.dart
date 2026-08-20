import 'package:eureka/enums/subject_type.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/pages/subject/widgets/widget_subject_lessons_app_bar.dart';
import 'package:eureka/ui/ui_card.dart';
import 'package:eureka/ui/ui_color.dart';
import 'package:eureka/ui/ui_size.dart';
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
            completedLessons: 2,
            totalLessons: 5,
            onBack: () => backPressed = true,
            onReport: () => reportPressed = true,
          ),
        ),
      ),
    );

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );

    expect(appBar.backgroundColor, UiColor.mathematics);
    expect(appBar.systemOverlayStyle?.statusBarColor, Colors.transparent);
    expect(appBar.toolbarHeight, UiSize.subjectAppBarHeight);
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
    final background = tester.widget<Ink>(
      find.byKey(const ValueKey('subject-app-bar-background')),
    );
    final backgroundDecoration = background.decoration! as BoxDecoration;
    final backgroundGradient = backgroundDecoration.gradient! as LinearGradient;
    expect(backgroundGradient.colors.first, UiColor.mathematics);
    expect(backgroundGradient.colors[2], isNot(UiColor.mathematics));
    expect(find.byKey(const ValueKey('subject-progress-card')), findsOneWidget);
    expect(find.text('Matemática'), findsOneWidget);
    expect(find.text(AppStrings.completeAllLessons), findsOneWidget);
    expect(find.text('2/5'), findsOneWidget);
    expect(find.text('40%'), findsNothing);
    expect(find.byType(HugeIcon), findsNWidgets(2));
    final screenWidth = tester.getSize(find.byType(Scaffold)).width;
    final progressCard = tester.getRect(
      find.byKey(const ValueKey('subject-progress-card')),
    );
    expect(progressCard.left, screenWidth - progressCard.right);

    await tester.tap(find.byTooltip(AppStrings.back));
    await tester.tap(find.byTooltip(AppStrings.reportError));
    expect(backPressed, isTrue);
    expect(reportPressed, isTrue);
  });
}
