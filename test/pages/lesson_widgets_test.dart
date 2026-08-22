import 'package:eureka/data/seed/seed_content.dart';
import 'package:eureka/l10n/app_strings.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_activity.dart';
import 'package:eureka/pages/lesson/widgets/exercise_content.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_feedback_card.dart';
import 'package:eureka/pages/lesson/widgets/widget_question_option.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_page_indicators.dart';
import 'package:eureka/pages/lesson/widgets/widget_lesson_summary.dart';
import 'package:eureka/services/service_lesson_narration.dart';
import 'package:eureka/ui/ui_color.dart';
import 'package:eureka/ui/ui_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

void main() {
  testWidgets('resumo mostra atividade pendente como nao feito em warning', (
    tester,
  ) async {
    final question = modelMultipleChoiceLesson.questions.first;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonSummary(
            questions: [question],
            resultFor: (_) => null,
            primaryColor: UiColor.science,
            onRetry: () {},
          ),
        ),
      ),
    );

    final status = find.text('Atividade 1 · ${AppStrings.activityNotDone}');
    expect(status, findsOneWidget);
    expect(tester.widget<Text>(status).style?.color, UiColor.warning);
  });

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

  testWidgets('mantem todas as paginas de conteudo verdes', (tester) async {
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

  testWidgets('usa tamanho e cor para indicar a pagina atual sem borda', (
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
    expect(decorationAt(3).border, isNull);
    expect(decorationAt(0).border, isNull);
  });

  testWidgets('indicadores se adaptam sem overflow em largura reduzida', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 83,
              child: LessonPageIndicators(
                currentPage: 0,
                statuses: List.filled(7, LessonPageIndicatorStatus.unanswered),
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
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
      UiColor.textPrimary,
    );
    tester.widget<QuestionOption>(find.byType(QuestionOption).first).onTap!();
    expect(selected, question.options.first);

    await tester.pumpWidget(activity(LessonActivityStatus.answeredCorrect));
    await tester.pump();

    final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));
    expect(inkWells.every((item) => item.onTap == null), isTrue);
  });

  testWidgets('card reutilizavel mostra erro e sucesso no corpo', (
    tester,
  ) async {
    var reported = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              LessonFeedbackCard(
                status: LessonFeedbackStatus.error,
                title: AppStrings.incorrectTitle,
                message: AppStrings.correctAnswerValue('3/4'),
                explanation: 'O todo foi dividido em quatro partes iguais.',
                onReport: () => reported = true,
              ),
              LessonFeedbackCard(
                status: LessonFeedbackStatus.success,
                title: AppStrings.correctTitle,
                onReport: () => reported = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text(AppStrings.incorrectTitle), findsOneWidget);
    expect(find.text(AppStrings.correctTitle), findsOneWidget);
    expect(find.text(AppStrings.correctAnswer), findsOneWidget);
    expect(find.text('3/4'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text(AppStrings.correctAnswer)).style,
      UiText.label.copyWith(color: UiColor.error),
    );
    expect(tester.widget<Text>(find.text('3/4')).style, UiText.p);
    expect(find.text(AppStrings.answerExplanation), findsOneWidget);
    expect(
      find.text('O todo foi dividido em quatro partes iguais.'),
      findsOneWidget,
    );
    expect(find.byTooltip(AppStrings.reportError), findsNWidgets(2));
    expect(find.byType(BottomSheet), findsNothing);

    await tester.tap(find.byTooltip(AppStrings.reportError).first);
    expect(reported, isTrue);
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
