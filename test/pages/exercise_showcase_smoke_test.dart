import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/enums/question_type.dart';
import 'package:eureka/models/model_question.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_activity.dart';
import 'package:eureka/ui/ui_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final questions = seedLessons
      .firstWhere((lesson) => lesson.id == 'fractions_intro')
      .questions;

  Future<void> pump(
    WidgetTester tester,
    Question question, {
    required bool current,
    String answer = '',
  }) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LessonActivity(
              question: question,
              position: 1,
              total: questions.length,
              primaryColor: UiColor.mathematics,
              status: current
                  ? LessonActivityStatus.active
                  : LessonActivityStatus.answeredCorrect,
              interactionEnabled: current,
              currentAnswer: answer,
              submittedAnswer: current ? null : answer,
              textController: current ? TextEditingController() : null,
              onOptionSelected: (_) {},
              onTextChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  test('a lição de frações traz exatamente um exercício de cada tipo', () {
    final types = questions.map((question) => question.type).toList();
    expect(types.toSet(), QuestionType.values.toSet());
    expect(types, hasLength(QuestionType.values.length));
  });

  for (final question in questions) {
    testWidgets('renderiza ${question.type.name} (${question.id}) ativa', (
      tester,
    ) async {
      await pump(tester, question, current: true);
      expect(find.text(question.prompt), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renderiza ${question.type.name} (${question.id}) respondida', (
      tester,
    ) async {
      final answer = switch (question.type) {
        QuestionType.matching || QuestionType.memory => question.correctAnswer,
        QuestionType.essay => 'Uma fração é uma parte de um todo inteiro.',
        _ => question.correctAnswer,
      };
      await pump(tester, question, current: false, answer: answer);
      expect(tester.takeException(), isNull);
    });
  }
}
