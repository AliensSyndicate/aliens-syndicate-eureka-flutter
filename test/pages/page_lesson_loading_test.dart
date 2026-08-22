import 'dart:async';

import 'package:eureka/app/navigation/navigation_router.dart';
import 'package:eureka/controllers/controller_lesson_preparation.dart';
import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/enums/learning_mode.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/models/model_lesson.dart';
import 'package:eureka/pages/lesson/page_lesson_loading.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_campfire.dart';
import 'package:eureka/ui/ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('mostra a fogueira sem botao ou navegacao visual', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app());

    expect(find.text(AppStrings.lessonLoadingTitle), findsOneWidget);
    expect(find.byKey(const Key('lesson-loading-wallpaper')), findsOneWidget);
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

    await tester.pump(const Duration(seconds: 3));
    semantics.dispose();
  });

  testWidgets('anima a chama quando movimento esta habilitado', (tester) async {
    await tester.pumpWidget(_app(disableAnimations: false));

    final firstPainter = _painter(tester);
    await tester.pump(const Duration(milliseconds: 300));
    final secondPainter = _painter(tester);

    expect(secondPainter.progress, isNot(firstPainter.progress));
    await tester.pump(const Duration(milliseconds: 2700));
  });

  testWidgets('mantem a chama parada quando animacoes estao desabilitadas', (
    tester,
  ) async {
    await tester.pumpWidget(_app(disableAnimations: true));

    final firstPainter = _painter(tester);
    await tester.pump(const Duration(milliseconds: 300));
    final secondPainter = _painter(tester);

    expect(secondPainter.progress, firstPainter.progress);
    await tester.pump(const Duration(milliseconds: 2700));
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
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('abre a aula assim que a atividade fica pronta', (tester) async {
    var calls = 0;
    final controller = LessonPreparationController(
      loadActivity: (lesson) async {
        calls++;
        return modelMultipleChoiceLesson;
      },
    );
    final router = _router(controller);

    await tester.pumpWidget(
      MaterialApp.router(theme: UiTheme.dark, routerConfig: router),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Aula preparada'), findsOneWidget);
    expect(find.text(modelMultipleChoiceLesson.id), findsOneWidget);
    expect(find.text(LearningMode.explore.name), findsOneWidget);
    expect(calls, 1);
  });

  testWidgets('mantem o carregamento somente enquanto a atividade nao chega', (
    tester,
  ) async {
    final completer = Completer<Lesson>();
    final router = _router(
      LessonPreparationController(loadActivity: (_) => completer.future),
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: UiTheme.dark, routerConfig: router),
    );
    expect(find.byKey(const Key('lesson-loading-wallpaper')), findsOneWidget);

    completer.complete(modelMultipleChoiceLesson);
    await tester.pump();
    await tester.pump();

    expect(find.text('Aula preparada'), findsOneWidget);
  });

  testWidgets('mostra indisponibilidade assim que a preparacao falha', (
    tester,
  ) async {
    final controller = LessonPreparationController(
      loadActivity: (lesson) async => Lesson(
        id: lesson.id,
        title: lesson.title,
        summary: lesson.summary,
        subject: lesson.subject,
        questions: const [],
      ),
    );
    final router = _router(controller);

    await tester.pumpWidget(
      MaterialApp.router(theme: UiTheme.dark, routerConfig: router),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppStrings.contentUnavailable), findsOneWidget);
    expect(find.text('Aula preparada'), findsNothing);
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
      controller: LessonPreparationController(
        loadActivity: (_) => Completer<Lesson>().future,
      ),
    ),
  ),
);

GoRouter _router(LessonPreparationController controller) => GoRouter(
  initialLocation: '/loading',
  routes: [
    GoRoute(
      path: '/loading',
      builder: (context, state) => PageLessonLoading(
        lesson: modelMultipleChoiceLesson,
        mode: LearningMode.explore,
        controller: controller,
      ),
    ),
    GoRoute(
      path: '/lesson',
      name: AppRoute.lesson,
      builder: (context, state) {
        final arguments = state.extra! as LessonRouteArguments;
        return Scaffold(
          body: Column(
            children: [
              const Text('Aula preparada'),
              Text(arguments.lesson.id),
              Text(arguments.mode.name),
            ],
          ),
        );
      },
    ),
  ],
);

LessonCampfirePainter _painter(WidgetTester tester) =>
    tester
            .widget<CustomPaint>(find.byKey(const Key('lesson-loading-fire')))
            .painter
        as LessonCampfirePainter;
