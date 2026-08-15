import 'package:flutter/material.dart';
import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../app/components/app_text_field.dart';
import '../../controllers/controller_lesson.dart';
import '../../enums/learning_mode.dart';
import '../../enums/question_type.dart';
import '../../l10n/app_strings.dart';
import '../../models/model_lesson.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_size.dart';
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
  final textController = TextEditingController();
  String answer = '';
  bool started = false;
  @override
  void initState() {
    super.initState();
    controller = LessonController(
      lesson: widget.lesson,
      mode: widget.mode,
      answerService: ServiceRegistry.answer,
      scoringService: ServiceRegistry.scoring,
      progressService: ServiceRegistry.progress,
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.lesson.title)),
    body: SafeArea(child: started ? _question(context) : _summary(context)),
  );

  Widget _summary(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: UiSpacing.pageHorizontal,
      vertical: UiSpacing.pageVertical,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.lessonSummary,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: UiSpacing.md),
        Text(
          widget.lesson.summary,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const Spacer(),
        if (widget.mode != LearningMode.journey)
          const Padding(
            padding: EdgeInsets.only(bottom: UiSpacing.md),
            child: Text(
              AppStrings.noXpOutsideJourney,
              textAlign: TextAlign.center,
            ),
          ),
        AppButton(
          label: AppStrings.startActivity,
          onPressed: () => setState(() => started = true),
        ),
      ],
    ),
  );

  Widget _question(BuildContext context) {
    final question = controller.currentQuestion;
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: UiSpacing.pageHorizontal,
        vertical: UiSpacing.pageVertical,
      ),
      children: [
        LessonProgressBar(
          value: (controller.currentIndex + 1) / widget.lesson.questions.length,
        ),
        const SizedBox(height: UiSpacing.lg),
        Text(question.prompt, style: Theme.of(context).textTheme.titleLarge),
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
        const SizedBox(height: UiSpacing.lg),
        AppButton(
          label: AppStrings.checkAnswer,
          onPressed: answer.trim().isEmpty ? null : _submit,
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
            Text(
              '${controller.correctAnswers}/${widget.lesson.questions.length}',
            ),
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
