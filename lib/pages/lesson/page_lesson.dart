import 'package:flutter/material.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../controllers/controller_lesson.dart';
import '../../enums/learning_mode.dart';
import '../../l10n/app_strings.dart';
import '../../models/model_lesson.dart';
import '../../services/service_lesson_timer.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_motion.dart';
import '../../ui/ui_spacing.dart';
import 'widgets/widget_lesson_activity.dart';
import 'widgets/widget_lesson_app_bar.dart';
import 'widgets/widget_lesson_description.dart';

class PageLesson extends StatefulWidget {
  const PageLesson({required this.lesson, required this.mode, super.key});
  final Lesson lesson;
  final LearningMode mode;
  @override
  State<PageLesson> createState() => _PageLessonState();
}

class _PageLessonState extends State<PageLesson> {
  late final LessonController controller;
  late final LessonTimerService lessonTimer;
  final textController = TextEditingController();
  final pageController = PageController();
  String answer = '';
  int displayedPageIndex = 0;
  bool started = false;
  bool submitting = false;
  bool feedbackOpen = false;
  bool timeoutPending = false;
  bool timeoutHandled = false;
  bool completed = false;
  Color get subjectColor => UiColor.forSubject(widget.lesson.subject);
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
    lessonTimer = LessonTimerService()..start();
    lessonTimer.addListener(_onTimerChanged);
  }

  @override
  void dispose() {
    lessonTimer.removeListener(_onTimerChanged);
    lessonTimer.dispose();
    pageController.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = started ? controller.completionProgress : 0.0;
    return Scaffold(
      appBar: LessonAppBar(
        progress: progress,
        progressColor: subjectColor,
        remainingTime: lessonTimer,
      ),
      body: SafeArea(bottom: false, child: _lessonPages(context)),
      bottomNavigationBar: _bottomAction(),
    );
  }

  Widget _bottomAction() {
    final currentActivityPage = controller.currentIndex + 1;
    final viewingHistory = started && displayedPageIndex != currentActivityPage;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        UiSpacing.pageHorizontal,
        UiSpacing.sm,
        UiSpacing.pageHorizontal,
        UiSpacing.pageVertical,
      ),
      child: AppButton(
        key: const ValueKey('lesson-bottom-action'),
        label: !started
            ? AppStrings.startActivity
            : viewingHistory
            ? AppStrings.returnToCurrentActivity
            : AppStrings.checkAnswer,
        color: subjectColor,
        onPressed: !started
            ? _startActivity
            : viewingHistory
            ? _showCurrentActivity
            : (answer.trim().isEmpty || submitting || lessonTimer.isExpired)
            ? null
            : _submit,
      ),
    );
  }

  Widget _lessonPages(BuildContext context) => PageView.builder(
    key: const ValueKey('lesson-activities-pager'),
    controller: pageController,
    scrollDirection: Axis.vertical,
    pageSnapping: true,
    physics: const PageScrollPhysics(),
    itemCount: 1 + (started ? controller.visibleQuestions.length : 0),
    onPageChanged: (index) => setState(() => displayedPageIndex = index),
    itemBuilder: (context, pageIndex) {
      if (pageIndex == 0) {
        return Padding(
          key: const ValueKey('lesson-description-page'),
          padding: const EdgeInsets.symmetric(
            horizontal: UiSpacing.pageHorizontal,
            vertical: UiSpacing.pageVertical,
          ),
          child: LessonDescription(
            title: widget.lesson.title,
            description: widget.lesson.summary,
            primaryColor: subjectColor,
            notice: widget.mode != LearningMode.journey
                ? AppStrings.noXpOutsideJourney
                : null,
          ),
        );
      }
      final activityIndex = pageIndex - 1;
      final question = controller.visibleQuestions[activityIndex];
      final isCurrent = activityIndex == controller.currentIndex;
      final result = controller.resultFor(question);
      return LessonActivity(
        key: ValueKey('lesson-activity-${question.id}'),
        question: question,
        position: activityIndex + 1,
        total: controller.totalQuestions,
        primaryColor: subjectColor,
        status: isCurrent
            ? LessonActivityStatus.active
            : result == true
            ? LessonActivityStatus.answeredCorrect
            : LessonActivityStatus.answeredIncorrect,
        interactionEnabled: isCurrent && !submitting && !lessonTimer.isExpired,
        currentAnswer: answer,
        submittedAnswer: controller.answerFor(question),
        textController: isCurrent ? textController : null,
        onOptionSelected: (value) => setState(() => answer = value),
        onTextChanged: (value) => setState(() => answer = value),
      );
    },
  );

  void _startActivity() {
    setState(() {
      started = true;
    });
    _showCurrentActivityAfterLayout();
  }

  void _showCurrentActivity() {
    if (!mounted || !pageController.hasClients) return;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      pageController.jumpToPage(controller.currentIndex + 1);
    } else {
      pageController.animateToPage(
        controller.currentIndex + 1,
        duration: UiMotion.lessonActivityDuration,
        curve: UiMotion.lessonActivityCurve,
      );
    }
  }

  void _showCurrentActivityAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCurrentActivity();
    });
  }

  void _onTimerChanged() {
    if (lessonTimer.isExpired && !timeoutHandled && !completed) {
      _showTimeExpired();
    }
  }

  Future<void> _showTimeExpired() async {
    if (!mounted || timeoutHandled || completed) return;
    if (feedbackOpen || submitting) {
      timeoutPending = true;
      return;
    }
    timeoutHandled = true;
    setState(() {});
    await AppBottomSheet.show<void>(
      context,
      title: AppStrings.lessonTimeUp,
      content: const Text(AppStrings.lessonTimeUpMessage),
      isDismissible: false,
      enableDrag: false,
      actions: [
        AppButton(
          label: AppStrings.finish,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _submit() async {
    if (submitting || lessonTimer.isExpired || answer.trim().isEmpty) return;
    setState(() => submitting = true);
    final question = controller.currentQuestion;
    final correct = await controller.submit(answer);
    if (!mounted) return;
    setState(() => feedbackOpen = true);
    await AppBottomSheet.show<void>(
      context,
      title: correct
          ? AppStrings.correctFeedback
          : AppStrings.incorrectFeedback,
      content: correct
          ? const Text('')
          : Text('${AppStrings.correctAnswer}: ${question.correctAnswer}'),
      isDismissible: false,
      enableDrag: false,
      actions: [
        AppButton(
          label: controller.isLastQuestion
              ? AppStrings.finish
              : AppStrings.nextQuestion,
          color: correct ? UiColor.success : UiColor.error,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
    if (!mounted) return;
    feedbackOpen = false;
    submitting = false;
    if (timeoutPending || lessonTimer.isExpired) {
      timeoutPending = false;
      await _showTimeExpired();
      return;
    }
    if (controller.isLastQuestion) {
      completed = true;
      await _completeLesson();
    } else {
      setState(() {
        controller.next();
        answer = '';
        textController.clear();
      });
      _showCurrentActivityAfterLayout();
    }
  }

  Future<void> _completeLesson() async {
    await controller.complete();
    if (!mounted) return;
    await AppBottomSheet.show<void>(
      context,
      title: widget.mode == LearningMode.simulation
          ? AppStrings.simulationResult
          : AppStrings.lessonComplete,
      content: Column(
        children: [
          Text('${controller.correctAnswers}/${controller.totalQuestions}'),
          if (controller.earnedXp > 0) Text('+${controller.earnedXp} XP'),
          if (widget.mode == LearningMode.simulation) ...[
            const SizedBox(height: UiSpacing.md),
            Text(
              controller.reviewTopics.isEmpty
                  ? AppStrings.strongPerformance
                  : '${AppStrings.reviewSuggestion}: ${controller.reviewTopics.join(', ')}',
            ),
          ],
        ],
      ),
      isDismissible: false,
      enableDrag: false,
      actions: [
        AppButton(
          label: AppStrings.finish,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
    if (mounted) Navigator.pop(context, true);
  }
}
