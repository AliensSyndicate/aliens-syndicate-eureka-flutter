import 'package:eureka/ui/ui_size.dart';
import 'package:flutter/material.dart';

import '../../controllers/controller_lesson_preparation.dart';
import '../../enums/learning_mode.dart';
import '../../l10n/app_strings.dart';
import '../../models/model_lesson.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';
import 'widgets/widget_lesson_campfire.dart';

class PageLessonLoading extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compact = textScale > 1.5;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  UiSpacing.pageHorizontal,
                  UiSpacing.xl,
                  UiSpacing.pageHorizontal,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: UiIcon.logo(size: UiSize.iconMd),
                ),
              ),
              SizedBox(height: compact ? UiSpacing.sm : UiSpacing.xxxl),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UiSpacing.pageHorizontal,
                ),
                child: Text(
                  AppStrings.lessonLoadingTitle,
                  key: const Key('lesson-loading-title'),
                  style: UiText.h2.copyWith(color: UiColor.textPrimary),
                ),
              ),
              SizedBox(height: compact ? UiSpacing.xs : UiSpacing.lg),
              const Expanded(child: WidgetLessonCampfire()),
            ],
          ),
        ),
      ),
    );
  }
}
