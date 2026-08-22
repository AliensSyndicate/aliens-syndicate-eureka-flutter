import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../app/components/app_report_bottom_sheet.dart';
import '../../app/navigation/navigation_router.dart';
import '../../controllers/controller_lesson.dart';
import '../../enums/learning_mode.dart';
import '../../enums/question_type.dart';
import '../../enums/report_context.dart';
import '../../enums/subject_type.dart';
import '../../l10n/app_strings.dart';
import '../../models/model_lesson.dart';
import '../../models/model_activity_result.dart';
import '../../models/model_question.dart';
import '../../models/content/model_content_page.dart';
import '../../services/service_lesson_narration.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_motion.dart';
import '../../ui/ui_size.dart';
import '../../ui/ui_spacing.dart';
import 'widgets/exercise_content.dart';
import 'widgets/widget_lesson_activity.dart';
import 'widgets/widget_lesson_app_bar.dart';
import 'widgets/widget_lesson_header.dart';
import 'widgets/widget_lesson_page_indicators.dart';
import 'widgets/widget_lesson_summary.dart';

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
  final GlobalKey fixedHeaderKey = GlobalKey();
  double fixedHeaderHeight = 0;
  bool submitting = false;
  bool finishing = false;
  late final DateTime startedAt;

  Color get subjectColor => UiColor.forSubject(widget.lesson.subject);
  int get currentPage => controller.currentPage;
  int get totalPages => controller.summaryPage + 1;

  @override
  void initState() {
    super.initState();
    startedAt = DateTime.now();
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
  Widget build(BuildContext context) => Scaffold(
    extendBodyBehindAppBar: true,
    appBar: LessonAppBar(
      onClose: () => Navigator.maybePop(context),
      onReport: _handleAppBarReport,
    ),
    body: Stack(
      children: [
        PageView.builder(
          key: const ValueKey('lesson-activities-pager'),
          controller: pageController,
          scrollDirection: Axis.horizontal,
          itemCount: totalPages,
          onPageChanged: (page) {
            unawaited(controller.selectPage(page));
            unawaited(narrationController.stop());
            setState(() {});
          },
          itemBuilder: (context, index) => _lessonPage(index),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + UiSize.homeAppBarHeight,
          left: 0,
          right: 0,
          child: _fixedHeader(),
        ),
      ],
    ),
  );

  Widget _fixedHeader() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          fixedHeaderKey.currentContext?.findRenderObject() as RenderBox?;
      final height = renderBox?.size.height;
      if (!mounted ||
          height == null ||
          (height - fixedHeaderHeight).abs() < 0.5) {
        return;
      }
      setState(() => fixedHeaderHeight = height);
    });

    return ColoredBox(
      key: fixedHeaderKey,
      color: UiColor.background,
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
          const SizedBox(height: UiSpacing.lg),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UiSpacing.pageHorizontal,
              0,
              UiSpacing.pageHorizontal,
              UiSpacing.lg,
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
        ],
      ),
    );
  }

  Widget _lessonPage(int page) {
    final isSummary = page == controller.summaryPage;
    final isContent = controller.isContentPage(page);
    final question = isContent || isSummary
        ? null
        : controller.visibleQuestions[page - controller.firstQuestionPage];
    return SingleChildScrollView(
      key: isContent
          ? page == 0
                ? const ValueKey('lesson-description-page')
                : ValueKey('lesson-description-page-$page')
          : isSummary
          ? const ValueKey('lesson-summary-page')
          : ValueKey('lesson-activity-page-${question!.id}'),
      primary: false,
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(
        top:
            MediaQuery.paddingOf(context).top +
            UiSize.homeAppBarHeight +
            fixedHeaderHeight,
        bottom: UiSpacing.pageVertical,
      ),
      child: isContent
          ? _contentPage(page)
          : isSummary
          ? _summaryPage()
          : _activityPage(question!),
    );
  }

  Widget _summaryPage() => LessonSummary(
    questions: controller.visibleQuestions,
    resultFor: controller.resultFor,
    primaryColor: subjectColor,
    onRetry: _retryActivities,
    onFinish: controller.canOpenSummary && !finishing ? _finishLesson : null,
  );

  Future<void> _retryActivities() async {
    await controller.retry();
    if (!mounted) return;
    for (final textController in textControllers.values) {
      textController.clear();
    }
    pageController.jumpToPage(controller.currentPage);
    setState(() {});
  }

  Widget _contentPage(int page) {
    final structured = widget.lesson.contentPages.isEmpty
        ? null
        : widget.lesson.contentPages[page];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.pageHorizontal),
      child: ExerciseContent(
        title: structured?.title ?? widget.lesson.title,
        description: _contentDescription(structured),
        primaryColor: subjectColor,
        narrationController: narrationController,
        notice: widget.mode != LearningMode.journey
            ? AppStrings.noXpOutsideJourney
            : null,
      ),
    );
  }

  String _contentDescription(ContentPage? page) {
    if (page == null) return widget.lesson.summary;
    return [
      page.text,
      if (page.keyConcept.trim().isNotEmpty) page.keyConcept,
    ].join('\n\n');
  }

  Widget _activityPage(Question question) {
    final result = controller.resultFor(question);
    final answer = controller.answerFor(question) ?? '';
    return Column(
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
        if (result == null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UiSpacing.pageHorizontal,
            ),
            child: AppButton(
              key: ValueKey('verify-${question.id}'),
              label: AppStrings.checkAnswer,
              color: subjectColor,
              isLoading: submitting,
              onPressed: answer.trim().isNotEmpty && !submitting
                  ? () => _verify(question)
                  : null,
            ),
          ),
      ],
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
      title: correct ? AppStrings.correctFeedback : AppStrings.almostFeedback,
      titleColor: correct ? UiColor.success : UiColor.warning,
      content: Text(
        correct
            ? question.explanation
            : '${AppStrings.correctAnswerValue(question.correctAnswerForFeedback)}\n\n${question.incorrectFeedback}',
      ),
      actions: [
        AppButton(
          label: AppStrings.continueLabel,
          color: correct ? UiColor.success : UiColor.warning,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Future<void> _finishLesson() async {
    if (finishing || !controller.canOpenSummary) return;
    setState(() => finishing = true);
    await controller.complete();
    if (!mounted) return;
    context.pushReplacementNamed(
      AppRoute.activityResult,
      extra: ActivityResultRouteArguments(
        ActivityResult(
          lesson: widget.lesson,
          correctAnswers: controller.correctAnswers,
          totalQuestions: controller.totalQuestions,
          earnedXp: controller.earnedXp,
          duration: DateTime.now().difference(startedAt),
          reviewTopics: controller.reviewTopics,
        ),
      ),
    );
  }

  Future<void> _handleAppBarReport() {
    final page = currentPage;
    if (controller.isContentPage(page)) {
      return AppReportBottomSheet.show(
        context,
        lessonId: widget.lesson.id,
        lessonTitle: widget.lesson.title,
        subjectId: widget.lesson.subject.name,
        pageNumber: page + 1,
        reportContext: ReportContext.lessonContent,
      );
    } else if (page == controller.summaryPage) {
      return AppReportBottomSheet.show(
        context,
        lessonId: widget.lesson.id,
        lessonTitle: widget.lesson.title,
        subjectId: widget.lesson.subject.name,
        pageNumber: page + 1,
        reportContext: ReportContext.subject,
      );
    } else {
      final question = controller.currentQuestion;
      return AppReportBottomSheet.show(
        context,
        lessonId: widget.lesson.id,
        lessonTitle: widget.lesson.title,
        question: question,
        subjectId: widget.lesson.subject.name,
        pageNumber: page + 1,
        reportContext: ReportContext.lessonActivity,
      );
    }
  }

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
    ...List.filled(
      controller.contentPageCount,
      LessonPageIndicatorStatus.content,
    ),
    ...controller.visibleQuestions.map((question) {
      final result = controller.resultFor(question);
      return result == null
          ? LessonPageIndicatorStatus.unanswered
          : result
          ? LessonPageIndicatorStatus.correct
          : LessonPageIndicatorStatus.incorrect;
    }),
    controller.canOpenSummary
        ? LessonPageIndicatorStatus.summary
        : LessonPageIndicatorStatus.summaryDisabled,
  ];

  String _pageName(int page) {
    if (controller.isContentPage(page)) {
      return widget.lesson.contentPages.isEmpty
          ? AppStrings.lessonContent
          : widget.lesson.contentPages[page].title;
    }
    if (page == controller.summaryPage) return AppStrings.activitiesSummary;
    return _activityName(
      controller.visibleQuestions[page - controller.firstQuestionPage].type,
    );
  }

  String _activityName(QuestionType type) => AppStrings.activityName(type);

  String _subjectName(SubjectType subject) => AppStrings.subjectName(subject);
}
