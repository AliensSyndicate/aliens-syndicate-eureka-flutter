import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_activity.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_description.dart';
import 'package:eureka/pages/lesson/widgets/widget_question_option.dart';
import 'package:eureka/ui/ui_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('descricao reutilizavel mostra titulo resumo e destaque', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LessonDescription(
            title: 'Título',
            description: 'Descrição da lição',
            primaryColor: UiColor.science,
          ),
        ),
      ),
    );

    expect(find.text('Título'), findsOneWidget);
    expect(find.text('Descrição da lição'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Título')).style?.color,
      UiColor.science,
    );
  });

  testWidgets('atividade ativa emite selecao e respondida fica bloqueada', (
    tester,
  ) async {
    final question = modelMultipleChoiceLesson.questions.first;
    String? selected;

    Widget activity(LessonActivityStatus status) => MaterialApp(
      home: Scaffold(
        body: LessonActivity(
          question: question,
          position: 1,
          total: 5,
          primaryColor: UiColor.science,
          status: status,
          interactionEnabled: status == LessonActivityStatus.active,
          currentAnswer: selected ?? '',
          submittedAnswer: question.correctAnswer,
          onOptionSelected: (value) => selected = value,
          onTextChanged: (_) {},
        ),
      ),
    );

    await tester.pumpWidget(activity(LessonActivityStatus.active));
    tester.widget<QuestionOption>(find.byType(QuestionOption).first).onTap!();
    expect(selected, question.options.first);

    await tester.pumpWidget(activity(LessonActivityStatus.answeredCorrect));
    await tester.pump();

    final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));
    expect(inkWells.every((item) => item.onTap == null), isTrue);
  });
}
