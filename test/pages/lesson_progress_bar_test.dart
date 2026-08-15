import 'package:eureka/enums/subject_type.dart';
import 'package:eureka/app/components/app_button.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/pages/lesson/page_lesson.dart';
import 'package:eureka/pages/lesson/widgets/widget_progress_bar.dart';
import 'package:eureka/ui/ui_color.dart';
import 'package:eureka/ui/ui_motion.dart';
import 'package:eureka/ui/ui_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe progresso da atividade com cor da materia e 8 px', (
    tester,
  ) async {
    final subjectColor = UiColor.forSubject(SubjectType.mathematics);
    final remainingTime = ValueNotifier(const Duration(minutes: 20));
    addTearDown(remainingTime.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: LessonHeader(
            progress: .4,
            progressColor: subjectColor,
            remainingTime: remainingTime,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    final appBar = tester.widget<AppBar>(find.byType(AppBar));

    expect(appBar.backgroundColor, UiColor.background);
    expect(appBar.systemOverlayStyle?.statusBarColor, UiColor.background);
    expect(indicator.value, .4);
    expect(indicator.minHeight, UiSize.lessonProgressHeight);
    expect(indicator.color, subjectColor);
    expect(indicator.backgroundColor, UiColor.lessonProgressTrack);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);
    expect(find.bySemanticsLabel(AppStrings.lessonProgress), findsOneWidget);
    expect(find.byTooltip(AppStrings.closeActivity), findsOneWidget);

    final closeCenter = tester.getCenter(find.byIcon(Icons.close_rounded));
    final progressCenter = tester.getCenter(
      find.byType(LinearProgressIndicator),
    );
    final percentageCenter = tester.getCenter(find.text('40%'));
    expect(closeCenter.dy, closeTo(progressCenter.dy, 1));
    expect(percentageCenter.dy, closeTo(progressCenter.dy, 1));
    expect(
      tester.getSize(find.byType(IconButton)),
      const Size.square(UiSize.touchTarget),
    );
  });

  testWidgets('anima o progresso em slide ate o novo valor', (tester) async {
    double value = .2;
    late StateSetter update;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return LessonProgressBar(
                value: value,
                progressColor: UiColor.mathematics,
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    update(() => value = .6);
    await tester.pump();
    var indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, .2);

    await tester.pump(UiMotion.lessonProgressDuration ~/ 2);
    indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, inExclusiveRange(.2, .6));

    await tester.pumpAndSettle();
    indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, closeTo(.6, .001));
  });

  testWidgets('permite aplicar a cor da materia ao botao primario', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: AppStrings.startActivity,
            color: UiColor.mathematics,
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(
      button.style?.backgroundColor?.resolve(<WidgetState>{}),
      UiColor.mathematics,
    );
  });

  testWidgets('limita o percentual visual ao intervalo de zero a cem', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LessonProgressBar(
            value: 1.5,
            progressColor: UiColor.mathematics,
          ),
        ),
      ),
    );

    final indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, 1);
    expect(find.bySemanticsLabel(AppStrings.lessonProgress), findsOneWidget);
  });
}
