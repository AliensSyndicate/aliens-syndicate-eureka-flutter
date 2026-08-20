import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/enums/learning_mode.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/pages/lesson/page_lesson_loading.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_campfire.dart';
import 'package:eureka/ui/ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra a fogueira sem botao ou navegacao visual', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app());

    expect(find.text(AppStrings.lessonLoadingTitle), findsOneWidget);
    expect(find.byType(WidgetLessonCampfire), findsOneWidget);
    expect(find.byKey(const Key('lesson-loading-fire')), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(ButtonStyleButton), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == AppStrings.lessonCampfireIllustration,
      ),
      findsOneWidget,
    );

    semantics.dispose();
  });

  testWidgets('anima a chama quando movimento esta habilitado', (tester) async {
    await tester.pumpWidget(_app(disableAnimations: false));

    final firstPainter = _painter(tester);
    await tester.pump(const Duration(milliseconds: 300));
    final secondPainter = _painter(tester);

    expect(secondPainter.progress, isNot(firstPainter.progress));
  });

  testWidgets('mantem a chama parada quando animacoes estao desabilitadas', (
    tester,
  ) async {
    await tester.pumpWidget(_app(disableAnimations: true));

    final firstPainter = _painter(tester);
    await tester.pump(const Duration(milliseconds: 300));
    final secondPainter = _painter(tester);

    expect(secondPainter.progress, firstPainter.progress);
  });

  testWidgets('preserva o layout em tela estreita com texto ampliado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(textScaler: const TextScaler.linear(2)));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('lesson-loading-fire')), findsOneWidget);
  });
}

Widget _app({
  bool disableAnimations = true,
  TextScaler textScaler = TextScaler.noScaling,
}) => MaterialApp(
  theme: UiTheme.dark,
  home: MediaQuery(
    data: MediaQueryData(
      disableAnimations: disableAnimations,
      textScaler: textScaler,
    ),
    child: PageLessonLoading(
      lesson: modelMultipleChoiceLesson,
      mode: LearningMode.explore,
    ),
  ),
);

LessonCampfirePainter _painter(WidgetTester tester) =>
    tester
            .widget<CustomPaint>(find.byKey(const Key('lesson-loading-fire')))
            .painter
        as LessonCampfirePainter;
