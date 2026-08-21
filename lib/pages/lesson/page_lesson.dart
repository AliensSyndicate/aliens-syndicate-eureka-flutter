import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../controllers/controller_lesson.dart';
import '../../enums/learning_mode.dart';
import '../../enums/question_type.dart';
import '../../enums/subject_type.dart';
import '../../l10n/app_strings.dart';
import '../../models/model_lesson.dart';
import '../../models/model_question.dart';
import '../../services/service_registry.dart';
import '../../services/service_lesson_narration.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_motion.dart';
import '../../ui/ui_spacing.dart';
import 'widgets/exercise_content.dart';
import 'widgets/widget_lesson_activity.dart';
import 'widgets/widget_lesson_app_bar.dart';
import 'widgets/widget_lesson_header.dart';
import 'widgets/widget_lesson_page_indicators.dart';

class PageLesson extends StatefulWidget {
  const PageLesson({required this.lesson, required this.mode, super.key});
  final Lesson lesson;
  final LearningMode mode;
  @override
  State<PageLesson> createState() => _PageLessonState();
}

class _PageLessonState extends State<PageLesson> {
  late final LessonController controller;
  late final PageController pageController;
  late final LessonNarrationService narrationController;
  final Map<String, TextEditingController> textControllers = {};
  bool submitting = false;

  Color get subjectColor => UiColor.forSubject(widget.lesson.subject);
  int get currentPage => controller.currentPage;
  int get totalPages => controller.totalQuestions + 1;

  @override
  void initState() {
    super.initState();
    controller = LessonController(
      lesson: widget.lesson,
      mode: widget.mode,
      answerService: ServiceRegistry.answer,
      scoringService: ServiceRegistry.scoring,
      progressService: ServiceRegistry.progress,
      questionSelectionService: ServiceRegistry.questionSelection,
    );
    pageController = PageController(initialPage: currentPage);
    narrationController = LessonNarrationService();
    for (final question in controller.visibleQuestions) {
      textControllers[question.id] = TextEditingController(
        text: controller.answerFor(question) ?? '',
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    narrationController.dispose();
    for (final item in textControllers.values) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: true,
    onPopInvokedWithResult: (didPop, result) {
      if (didPop && controller.answeredQuestions == controller.totalQuestions) {
        unawaited(controller.complete());
      }
    },
    child: Scaffold(
      appBar: LessonAppBar(
        onClose: () => Navigator.maybePop(context),
        onReport: _reportError,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiSpacing.pageHorizontal,
              ),
              child: LessonPageIndicators(
                currentPage: currentPage,
                statuses: _indicatorStatuses(),
                onSelected: _goToPage,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                UiSpacing.pageHorizontal,
                UiSpacing.lg,
                UiSpacing.pageHorizontal,
                UiSpacing.md,
              ),
              child: LessonHeader(
                subject: _subjectName(widget.lesson.subject),
                title: widget.lesson.title,
                pageLabel: AppStrings.lessonPage(
                  currentPage + 1,
                  totalPages,
                  _pageName(currentPage),
                ),
                subjectColor: subjectColor,
              ),
            ),
            Expanded(
              child: PageView.builder(
                key: const ValueKey('lesson-activities-pager'),
                controller: pageController,
                scrollDirection: Axis.horizontal,
                itemCount: totalPages,
                onPageChanged: (page) {
                  unawaited(controller.selectPage(page));
                  if (page != 0) unawaited(narrationController.stop());
                  setState(() {});
                },
                itemBuilder: (context, index) => index == 0
                    ? _contentPage()
                    : _activityPage(controller.visibleQuestions[index - 1]),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _contentPage() => SingleChildScrollView(
    key: const ValueKey('lesson-description-page'),
    primary: false,
    scrollDirection: Axis.vertical,
    physics: const AlwaysScrollableScrollPhysics(),
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    padding: const EdgeInsets.fromLTRB(
      UiSpacing.pageHorizontal,
      0,
      UiSpacing.pageHorizontal,
      UiSpacing.pageVertical,
    ),
    child: ExerciseContent(
      title: widget.lesson.title,
      description: widget.lesson.summary,
      primaryColor: subjectColor,
      narrationController: narrationController,
      notice: widget.mode != LearningMode.journey
          ? AppStrings.noXpOutsideJourney
          : null,
    ),
  );

  Widget _activityPage(Question question) {
    final result = controller.resultFor(question);
    final answer = controller.answerFor(question) ?? '';
    return SingleChildScrollView(
      key: ValueKey('lesson-activity-page-${question.id}'),
      primary: false,
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: UiSpacing.pageVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LessonActivity(
            question: question,
            position: controller.visibleQuestions.indexOf(question) + 1,
            total: controller.totalQuestions,
            primaryColor: subjectColor,
            status: result == null
                ? LessonActivityStatus.active
                : result
                ? LessonActivityStatus.answeredCorrect
                : LessonActivityStatus.answeredIncorrect,
            interactionEnabled: result == null && !submitting,
            currentAnswer: answer,
            submittedAnswer: result == null ? null : answer,
            textController: textControllers[question.id],
            onOptionSelected: (value) => _saveAnswer(question, value),
            onTextChanged: (value) => _saveAnswer(question, value),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UiSpacing.pageHorizontal,
            ),
            child: AppButton(
              key: ValueKey('verify-${question.id}'),
              label: AppStrings.checkAnswer,
              color: subjectColor,
              isLoading: submitting,
              onPressed:
                  result == null && answer.trim().isNotEmpty && !submitting
                  ? () => _verify(question)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _saveAnswer(Question question, String value) {
    unawaited(controller.saveDraft(question, value));
    setState(() {});
  }

  Future<void> _verify(Question question) async {
    if (submitting || controller.resultFor(question) != null) return;
    setState(() => submitting = true);
    final correct = await controller.submit(
      controller.answerFor(question) ?? '',
    );
    if (!mounted) return;
    setState(() => submitting = false);
    await AppBottomSheet.show<void>(
      context,
      title: correct ? 'Correto!' : 'Incorreto',
      titleColor: correct ? UiColor.success : UiColor.error,
      content: Text(
        correct
            ? 'Muito bem! Continue explorando no seu ritmo.'
            : question.incorrectFeedback,
      ),
    );
  }

  Future<void> _reportError() => AppBottomSheet.show<void>(
    context,
    title: AppStrings.reportError,
    content: Text(
      '${_pageName(currentPage)}\n${AppStrings.reportErrorUnavailable}',
    ),
  );

  void _goToPage(int page) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      pageController.jumpToPage(page);
    } else {
      pageController.animateToPage(
        page,
        duration: UiMotion.lessonActivityDuration,
        curve: UiMotion.lessonActivityCurve,
      );
    }
  }

  List<LessonPageIndicatorStatus> _indicatorStatuses() => [
    LessonPageIndicatorStatus.content,
    ...controller.visibleQuestions.map((question) {
      final result = controller.resultFor(question);
      return result == null
          ? LessonPageIndicatorStatus.unanswered
          : result
          ? LessonPageIndicatorStatus.correct
          : LessonPageIndicatorStatus.incorrect;
    }),
  ];

  String _pageName(int page) => page == 0
      ? AppStrings.lessonContent
      : _activityName(controller.visibleQuestions[page - 1].type);

  String _activityName(QuestionType type) => switch (type) {
    QuestionType.multipleChoice => 'Escolha uma resposta',
    QuestionType.textInput => 'Complete a resposta',
    QuestionType.essay => 'Explique com suas palavras',
    QuestionType.fillBlank => 'Complete os espaços',
    QuestionType.ordering => 'Organize as palavras',
    QuestionType.sequencing => 'Organize a sequência',
    QuestionType.matching => 'Faça as associações',
    QuestionType.memory => 'Jogo da memória',
    QuestionType.trueFalse => 'Verdadeiro ou falso',
    QuestionType.imageChoice => 'Escolha uma imagem',
    QuestionType.wordCompletion => 'Complete a palavra',
  };

  String _subjectName(SubjectType subject) => switch (subject) {
    SubjectType.portuguese => 'Português',
    SubjectType.english => 'Inglês',
    SubjectType.spanish => 'Espanhol',
    SubjectType.mathematics => 'Matemática',
    SubjectType.science => 'Ciências',
    SubjectType.biology => 'Biologia',
    SubjectType.physics => 'Física',
    SubjectType.chemistry => 'Química',
    SubjectType.history => 'História',
    SubjectType.geography => 'Geografia',
    SubjectType.philosophy => 'Filosofia',
    SubjectType.sociology => 'Sociologia',
  };
}
