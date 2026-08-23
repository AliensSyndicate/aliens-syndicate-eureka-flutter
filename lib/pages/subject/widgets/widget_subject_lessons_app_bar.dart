import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../enums/subject_type.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/model_lesson.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_gradient.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class SubjectLessonsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const SubjectLessonsAppBar({
    required this.title,
    required this.color,
    required this.subject,
    required this.schoolYear,
    required this.completedLessons,
    required this.totalLessons,
    required this.xp,
    required this.onBack,
    required this.onReport,
    this.lastCompletedLesson,
    super.key,
  });

  final String title;
  final Color color;
  final SubjectType subject;
  final int schoolYear;
  final int completedLessons;
  final int totalLessons;
  final int xp;
  final Lesson? lastCompletedLesson;

  final VoidCallback onBack;
  final VoidCallback onReport;

  static const _planetSize = 200.0;
  static const _baseHeight = 164.0;
  static const _lastLessonExtra = 22.0;

  @override
  Size get preferredSize => Size.fromHeight(
    lastCompletedLesson != null ? _baseHeight + _lastLessonExtra : _baseHeight,
  );

  @override
  Widget build(BuildContext context) {
    final progress = totalLessons == 0 ? 0.0 : completedLessons / totalLessons;

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      titleSpacing: 0,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: color,
      foregroundColor: UiColor.textPrimary,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      flexibleSpace: Stack(
        key: const ValueKey('subject-app-bar-background'),
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          Ink(
            decoration: BoxDecoration(gradient: UiGradient.forSubject(subject)),
          ),
          Positioned(
            right: -40,
            bottom: -48,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/${subject.name}.png',
                width: _planetSize,
                height: _planetSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpacing.xs),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        tooltip: AppStrings.back,
                        onPressed: onBack,
                        icon: UiIcon.back(color: UiColor.textPrimary),
                      ),
                      IconButton(
                        tooltip: AppStrings.reportError,
                        onPressed: onReport,
                        icon: UiIcon.report(color: UiColor.textPrimary),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: UiSpacing.sm,
                      right: _planetSize * 0.55,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: UiText.h4.copyWith(color: UiColor.textPrimary),
                        ),
                        Text(
                          AppStrings.schoolYear(schoolYear),
                          style: UiText.label.copyWith(
                            color: UiColor.textPrimary.withValues(alpha: .75),
                          ),
                        ),
                        if (lastCompletedLesson != null) ...[
                          const SizedBox(height: UiSpacing.xxs),
                          _LastLessonRow(
                            lesson: lastCompletedLesson!,
                            color: color,
                          ),
                        ],
                        const SizedBox(height: UiSpacing.xs),
                        _ProgressBar(
                          progress: progress,
                          completed: completedLessons,
                          total: totalLessons,
                          color: color,
                        ),
                        const SizedBox(height: UiSpacing.xxs),
                        _XpBadge(xp: xp),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LastLessonRow extends StatelessWidget {
  const _LastLessonRow({required this.lesson, required this.color});

  final Lesson lesson;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(Icons.check_circle_rounded, color: color, size: UiSpacing.md),
      const SizedBox(width: UiSpacing.xxs),
      Flexible(
        child: Text(
          lesson.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: UiText.small.copyWith(
            color: UiColor.textPrimary.withValues(alpha: .85),
          ),
        ),
      ),
    ],
  );
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.progress,
    required this.completed,
    required this.total,
    required this.color,
  });

  final double progress;
  final int completed;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(UiRadius.pill),
          child: LinearProgressIndicator(
            key: const ValueKey('subject-progress-bar'),
            value: progress,
            minHeight: UiCard.progressTagHeight,
            backgroundColor: UiColor.textPrimary.withValues(alpha: .22),
            color: color,
          ),
        ),
      ),
      const SizedBox(width: UiSpacing.xs),
      Text(
        AppStrings.progressRatio(completed, total),
        style: UiText.small.copyWith(
          color: UiColor.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _XpBadge extends StatelessWidget {
  const _XpBadge({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      UiIcon.diamontXp(size: 18),
      const SizedBox(width: UiSpacing.xxs),
      Text(
        AppStrings.xpValue(xp),
        style: UiText.small.copyWith(
          color: UiColor.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
