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
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';

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
    Lesson? lesson;
    try {
      lesson = await controller.prepare(widget.lesson);
    } on Object {
      lesson = null;
    }
    if (!mounted) return;
    if (lesson == null) {
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
      extra: LessonRouteArguments(lesson: lesson, mode: widget.mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = UiColor.forSubject(widget.lesson.subject);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Semantics(
            container: true,
            liveRegion: true,
            label: AppStrings.preparingActivity,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiSpacing.pageHorizontal,
                vertical: UiSpacing.pageVertical,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: CircularProgressIndicator(color: color),
                  ),
                  const SizedBox(height: UiSpacing.xl),
                  Text(
                    AppStrings.preparingActivity,
                    textAlign: TextAlign.center,
                    style: UiText.h4,
                  ),
                  const SizedBox(height: UiSpacing.sm),
                  Text(
                    widget.lesson.title,
                    textAlign: TextAlign.center,
                    style: UiText.p.copyWith(color: UiColor.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
