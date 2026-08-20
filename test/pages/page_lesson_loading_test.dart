import 'dart:async';

import 'package:eureka/controllers/controller_lesson_preparation.dart';
import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/enums/learning_mode.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/models/model_lesson.dart';
import 'package:eureka/pages/lesson/page_lesson_loading.dart';
import 'package:eureka/ui/ui_color.dart';
import 'package:eureka/ui/ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('mostra o preparo com semantica enquanto carrega', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final completer = Completer<Lesson>();
    final controller = _controller((lesson) => completer.future);

    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: PageLessonLoading(
          lesson: modelMultipleChoiceLesson,
          mode: LearningMode.journey,
          controller: controller,
        ),
      ),
    );

    expect(find.text(AppStrings.preparingActivity), findsOneWidget);
    expect(find.text(modelMultipleChoiceLesson.title), findsOneWidget);
    final liveRegion = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.liveRegion == true,
      ),
    );
    expect(liveRegion.properties.label, AppStrings.preparingActivity);
    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(
      indicator.color,
      UiColor.forSubject(modelMultipleChoiceLesson.subject),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    completer.complete(modelMultipleChoiceLesson);
    await tester.pump();
    semantics.dispose();
  });

  testWidgets('substitui o preparo pela aula pronta', (tester) async {
    final completer = Completer<Lesson>();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => PageLessonLoading(
            lesson: modelMultipleChoiceLesson,
            mode: LearningMode.explore,
            controller: _controller((lesson) => completer.future),
          ),
        ),
        GoRoute(
          path: '/lesson',
          name: 'lesson',
          builder: (context, state) =>
              const Scaffold(body: Text('Aula pronta')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: UiTheme.dark, routerConfig: router),
    );
    expect(find.text(AppStrings.preparingActivity), findsOneWidget);

    completer.complete(modelMultipleChoiceLesson);
    await tester.pumpAndSettle();

    expect(find.text('Aula pronta'), findsOneWidget);
    expect(find.text(AppStrings.preparingActivity), findsNothing);
  });
}

LessonPreparationController _controller(
  Future<Lesson> Function(Lesson lesson) loadActivity,
) => LessonPreparationController(loadActivity: loadActivity);
