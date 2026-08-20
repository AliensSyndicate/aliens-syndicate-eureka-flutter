import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../app/navigation/navigation_router.dart';
import '../../controllers/controller_lesson_preparation.dart';
import '../../enums/learning_mode.dart';
import '../../l10n/app_strings.dart';
import '../../models/model_lesson.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_motion.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';
import 'widgets/widget_lesson_campfire.dart';

class PageLessonLoading extends StatefulWidget {
  const PageLessonLoading({
    required this.lesson,
    required this.mode,
    this.controller,
    super.key,
  });

  final Lesson lesson;
  final LearningMode mode;
  final LessonPreparationController? controller;

  @override
  State<PageLessonLoading> createState() => _PageLessonLoadingState();
}

class _PageLessonLoadingState extends State<PageLessonLoading> {
  late final LessonPreparationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        widget.controller ??
        LessonPreparationController(
          loadActivity: ServiceRegistry.content.loadActivity,
        );
    _prepare();
  }

  Future<void> _prepare() async {
    final minimumDuration = Future<void>.delayed(
      UiMotion.lessonLoadingMinimumDuration,
    );
    Lesson? preparedLesson;
    try {
      preparedLesson = await controller.prepare(widget.lesson);
    } on Object {
      preparedLesson = null;
    }
    await minimumDuration;
    if (!mounted) return;

    if (preparedLesson == null) {
      await AppBottomSheet.show<void>(
        context,
        title: widget.lesson.title,
        content: const Text(AppStrings.contentUnavailable),
        actions: [
          AppButton(
            label: AppStrings.finish,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
      if (mounted) context.pop();
      return;
    }

    context.replaceNamed(
      AppRoute.lesson,
      extra: LessonRouteArguments(lesson: preparedLesson, mode: widget.mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compact = textScale > 1.5;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg_loading.png',
            key: const Key('lesson-loading-wallpaper'),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
            excludeFromSemantics: true,
          ),
          SafeArea(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(
                UiSpacing.pageHorizontal,
                UiSpacing.xl,
                UiSpacing.pageHorizontal,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.lessonLoadingTitle,
                    key: const Key('lesson-loading-title'),
                    style: (compact ? UiText.h6 : UiText.h2).copyWith(
                      color: UiColor.textPrimary,
                    ),
                  ),
                  SizedBox(height: compact ? UiSpacing.xs : UiSpacing.lg),
                  const Expanded(child: WidgetLessonCampfire()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
