import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_activity.dart';
import 'package:eureka/pages/lesson/widgets/exercise_content.dart';
import 'package:eureka/pages/lesson/widgets/widget_question_option.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_page_indicators.dart';
import 'package:eureka/services/service_lesson_narration.dart';
import 'package:eureka/ui/ui_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

void main() {
  testWidgets('descricao reutilizavel mostra titulo resumo e destaque', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExerciseContent(
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

  testWidgets('alinha leitura ao titulo e alterna play e pause', (
    tester,
  ) async {
    final narration = _FakeLessonNarrationController();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      narration.dispose();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseContent(
            title: 'Frações',
            description: 'Uma fração representa partes iguais de um todo.',
            primaryColor: UiColor.mathematics,
            narrationController: narration,
          ),
        ),
      ),
    );

    expect(
      tester
          .widget<HugeIcon>(
            find.descendant(
              of: find.byKey(const ValueKey('lesson-narration-toggle')),
              matching: find.byType(HugeIcon),
            ),
          )
          .icon,
      same(HugeIcons.strokeRoundedVolumeHigh),
    );
    await tester.tap(find.byKey(const ValueKey('lesson-narration-toggle')));
    await tester.pump();

    expect(narration.lastContent, contains('partes iguais'));
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(
      tester
          .widget<HugeIcon>(
            find.descendant(
              of: find.byKey(const ValueKey('lesson-narration-toggle')),
              matching: find.byType(HugeIcon),
            ),
          )
          .icon,
      same(HugeIcons.strokeRoundedVolumeMute02),
    );

    await tester.tap(find.byKey(const ValueKey('lesson-narration-toggle')));
    await tester.pump();
    expect(narration.state, LessonNarrationState.paused);
  });

  testWidgets('mantem o indicador de conteudo sempre verde', (tester) async {
    Widget indicators(int currentPage) => MaterialApp(
      home: Scaffold(
        body: LessonPageIndicators(
          currentPage: currentPage,
          statuses: const [
            LessonPageIndicatorStatus.content,
            LessonPageIndicatorStatus.unanswered,
          ],
          onSelected: (_) {},
        ),
      ),
    );

    Color? contentColor() =>
        (tester
                    .widget<AnimatedContainer>(
                      find.descendant(
                        of: find.byKey(
                          const ValueKey('lesson-page-indicator-0'),
                        ),
                        matching: find.byType(AnimatedContainer),
                      ),
                    )
                    .decoration
                as BoxDecoration?)
            ?.color;

    await tester.pumpWidget(indicators(0));
    expect(contentColor(), UiColor.success);
    await tester.pumpWidget(indicators(1));
    await tester.pumpAndSettle();
    expect(contentColor(), UiColor.success);
  });

  testWidgets('usa somente a cor do estado e borda para selecao', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonPageIndicators(
            currentPage: 3,
            statuses: const [
              LessonPageIndicatorStatus.content,
              LessonPageIndicatorStatus.correct,
              LessonPageIndicatorStatus.incorrect,
              LessonPageIndicatorStatus.unanswered,
            ],
            onSelected: (_) {},
          ),
        ),
      ),
    );

    BoxDecoration decorationAt(int index) =>
        tester
                .widget<AnimatedContainer>(
                  find.descendant(
                    of: find.byKey(ValueKey('lesson-page-indicator-$index')),
                    matching: find.byType(AnimatedContainer),
                  ),
                )
                .decoration
            as BoxDecoration;

    expect(decorationAt(0).color, UiColor.success);
    expect(decorationAt(1).color, UiColor.success);
    expect(decorationAt(2).color, UiColor.error);
    expect(decorationAt(3).color, UiColor.outline);
    expect(decorationAt(3).border, isNotNull);
    expect(decorationAt(0).border, isNull);
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
    expect(find.text(question.prompt), findsOneWidget);
    expect(
      tester.widget<Text>(find.text(question.prompt)).style?.color,
      UiColor.science,
    );
    tester.widget<QuestionOption>(find.byType(QuestionOption).first).onTap!();
    expect(selected, question.options.first);

    await tester.pumpWidget(activity(LessonActivityStatus.answeredCorrect));
    await tester.pump();

    final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));
    expect(inkWells.every((item) => item.onTap == null), isTrue);
  });
}

class _FakeLessonNarrationController extends ChangeNotifier
    implements LessonNarrationController {
  @override
  LessonNarrationState state = LessonNarrationState.stopped;
  String? lastContent;

  @override
  Future<void> toggle(String content) async {
    lastContent = content;
    if (state == LessonNarrationState.playing) {
      state = LessonNarrationState.paused;
    } else {
      state = LessonNarrationState.playing;
    }
    notifyListeners();
  }

  @override
  Future<void> stop() async {
    state = LessonNarrationState.stopped;
    notifyListeners();
  }
}
