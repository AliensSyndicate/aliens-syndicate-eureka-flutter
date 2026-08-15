import 'package:eureka/ui/ui_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../app/components/app_text_field.dart';
import '../../controllers/controller_lesson.dart';
import '../../enums/learning_mode.dart';
import '../../enums/question_type.dart';
import '../../l10n/app_strings.dart';
import '../../models/model_lesson.dart';
import '../../services/service_lesson_timer.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_size.dart';
import '../../ui/ui_spacing.dart';
import 'widgets/widget_progress_bar.dart';
import 'widgets/widget_question_option.dart';

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
  String answer = '';
  bool started = false;
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
  }

  @override
  void dispose() {
    lessonTimer.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = started
        ? (controller.currentIndex + 1) / controller.totalQuestions
        : 0.0;
    return Scaffold(
      appBar: LessonHeader(
        progress: progress,
        progressColor: subjectColor,
        remainingTime: lessonTimer,
      ),
      body: SafeArea(
        bottom: false,
        child: started ? _question(context) : _summary(context),
      ),
      bottomNavigationBar: _bottomAction(),
    );
  }

  Widget _bottomAction() => SafeArea(
    top: false,
    minimum: const EdgeInsets.fromLTRB(
      UiSpacing.pageHorizontal,
      UiSpacing.sm,
      UiSpacing.pageHorizontal,
      UiSpacing.pageVertical,
    ),
    child: AppButton(
      key: const ValueKey('lesson-bottom-action'),
      label: started ? AppStrings.checkAnswer : AppStrings.startActivity,
      color: subjectColor,
      onPressed: started
          ? (answer.trim().isEmpty ? null : _submit)
          : () => setState(() => started = true),
    ),
  );

  Widget _summary(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(
      horizontal: UiSpacing.pageHorizontal,
      vertical: UiSpacing.pageVertical,
    ),
    children: [
      Text(
        widget.lesson.title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: subjectColor),
      ),
      const SizedBox(height: UiSpacing.md),
      Text(widget.lesson.summary, style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: UiSpacing.xxl),
      if (widget.mode != LearningMode.journey)
        const Text(AppStrings.noXpOutsideJourney, textAlign: TextAlign.center),
    ],
  );

  Widget _question(BuildContext context) {
    final question = controller.currentQuestion;
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: UiSpacing.pageHorizontal,
        vertical: UiSpacing.pageVertical,
      ),
      children: [
        Text(
          widget.lesson.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: subjectColor),
        ),
        const SizedBox(height: UiSpacing.md),
        Text(
          widget.lesson.summary,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: UiSpacing.xxl),
        Text(
          question.prompt,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: subjectColor),
        ),
        const SizedBox(height: UiSpacing.lg),
        if (question.type == QuestionType.multipleChoice)
          ...question.options.map(
            (option) => QuestionOption(
              label: option,
              selected: answer == option,
              onTap: () => setState(() => answer = option),
            ),
          )
        else
          AppTextField(
            hint: AppStrings.correctAnswer,
            controller: textController,
            showSearchIcon: false,
            onChanged: (value) => setState(() => answer = value),
          ),
      ],
    );
  }

  Future<void> _submit() async {
    final question = controller.currentQuestion;
    final correct = await controller.submit(answer);
    if (!mounted) return;
    await AppBottomSheet.show<void>(
      context,
      title: correct
          ? AppStrings.correctFeedback
          : AppStrings.incorrectFeedback,
      content: correct
          ? const Icon(Icons.celebration_rounded, size: UiSize.buttonHeightLg)
          : Text('${AppStrings.correctAnswer}: ${question.correctAnswer}'),
      actions: [
        AppButton(
          label: controller.isLastQuestion
              ? AppStrings.finish
              : AppStrings.nextQuestion,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
    if (!mounted) return;
    if (controller.isLastQuestion) {
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
        actions: [
          AppButton(
            label: AppStrings.finish,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
      if (mounted) Navigator.pop(context, true);
    } else {
      setState(() {
        controller.next();
        answer = '';
        textController.clear();
      });
    }
  }
}

class LessonHeader extends StatelessWidget implements PreferredSizeWidget {
  const LessonHeader({
    required this.progress,
    required this.progressColor,
    required this.remainingTime,
    super.key,
  });

  final double progress;
  final Color progressColor;
  final ValueListenable<Duration> remainingTime;

  @override
  Size get preferredSize => const Size.fromHeight(UiSize.homeAppBarHeight);

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);
    final percentage = '${(normalizedProgress * 100).round()}%';
    return AppBar(
      backgroundColor: UiColor.background,
      foregroundColor: UiColor.textPrimary,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: UiColor.background,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      automaticallyImplyLeading: false,
      excludeHeaderSemantics: true,
      titleSpacing: UiSpacing.xs,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            tooltip: AppStrings.closeActivity,
            constraints: const BoxConstraints.tightFor(
              width: UiSize.touchTarget,
              height: UiSize.touchTarget,
            ),
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.close_rounded, size: UiSize.iconLg),
          ),
          const SizedBox(width: UiSpacing.sm),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: LessonProgressBar(
                value: normalizedProgress,
                progressColor: progressColor,
              ),
            ),
          ),
          const SizedBox(width: UiSpacing.sm),
          SizedBox(
            width: UiSize.buttonHeightSm,
            child: Text(
              percentage,
              key: const ValueKey('lesson-progress-percentage'),
              textAlign: TextAlign.end,
              style: UiText.h6.copyWith(color: progressColor),
            ),
          ),
          const SizedBox(width: UiSpacing.sm),
          ValueListenableBuilder<Duration>(
            valueListenable: remainingTime,
            builder: (context, value, child) {
              final formattedTime = AppStrings.lessonTime(value);
              return Semantics(
                label: AppStrings.lessonTimeRemaining,
                value: formattedTime,
                child: ExcludeSemantics(
                  child: Text(
                    formattedTime,
                    key: const ValueKey('lesson-remaining-time'),
                    style: UiText.h6,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: UiSpacing.sm),
        ],
      ),
    );
  }
}
