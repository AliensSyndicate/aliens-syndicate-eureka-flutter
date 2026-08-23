import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../enums/subject_type.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/model_lesson.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_gradient.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class SubjectLessonsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const SubjectLessonsAppBar({
    required this.title,
    required this.color,
    required this.subject,
    required this.schoolYear,
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
  final int xp;
  final Lesson? lastCompletedLesson;

  final VoidCallback onBack;
  final VoidCallback onReport;

  static const _planetSize = 200.0;
  static const _baseHeight = UiSize.subjectAppBarHeight;
  static const _lastLessonExtra = 24.0;

  @override
  Size get preferredSize => Size.fromHeight(
    lastCompletedLesson != null ? _baseHeight + _lastLessonExtra : _baseHeight,
  );

  @override
  Widget build(BuildContext context) {
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
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          Ink(
            key: const ValueKey('subject-app-bar-background'),
            decoration: BoxDecoration(gradient: UiGradient.forSubject(subject)),
          ),
          Positioned(
            right: -40,
            top: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/${subject.name}.png',
                key: const ValueKey('subject-header-planet'),
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
                  const SizedBox(height: UiSpacing.xs),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UiSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: UiText.h4.copyWith(
                                  color: UiColor.textPrimary,
                                ),
                              ),
                              const SizedBox(height: UiSpacing.xs),
                              Text(
                                AppStrings.schoolYearFull(schoolYear),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: UiText.p,
                              ),
                            ],
                          ),
                        ),
                        if (lastCompletedLesson != null) ...[
                          const SizedBox(height: UiSpacing.xs),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: _planetSize * 0.45,
                            ),
                            child: _LastLessonRow(
                              lesson: lastCompletedLesson!,
                              color: color,
                            ),
                          ),
                        ],
                        const SizedBox(height: UiSpacing.xs),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _XpCard(xp: xp),
                        ),
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

class _XpCard extends StatelessWidget {
  const _XpCard({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('subject-xp-card'),
    padding: const EdgeInsets.symmetric(
      horizontal: UiSpacing.md,
      vertical: UiSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: UiColor.background.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(UiRadius.card),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        UiIcon.diamontXp(size: 18),
        const SizedBox(width: UiSpacing.xxs),
        Text(
          AppStrings.xpValue(xp),
          style: UiText.p.copyWith(
            color: UiColor.xp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
