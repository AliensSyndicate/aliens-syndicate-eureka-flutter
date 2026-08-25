import 'package:flutter/material.dart';

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

class SubjectSheetHeader extends StatelessWidget {
  const SubjectSheetHeader({
    required this.title,
    required this.color,
    required this.subject,
    required this.schoolYear,
    required this.xp,
    required this.onClose,
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
  final VoidCallback onClose;
  final VoidCallback onReport;

  static const _planetSize = 200.0;
  static const _lastLessonExtra = 24.0;

  double get height =>
      UiSize.subjectAppBarHeight +
      (lastCompletedLesson == null ? 0 : _lastLessonExtra);

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const ValueKey('subject-sheet-header'),
    height: height,
    child: Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        DecoratedBox(
          key: const ValueKey('subject-sheet-header-background'),
          decoration: BoxDecoration(gradient: UiGradient.forSubject(subject)),
        ),
        Positioned(
          right: -40,
          top: 50,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: AppStrings.back,
                    onPressed: onClose,
                    icon: UiIcon.close(color: UiColor.textPrimary),
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
                padding: const EdgeInsets.symmetric(horizontal: UiSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiText.h4.copyWith(color: UiColor.textPrimary),
                    ),
                    const SizedBox(height: UiSpacing.xs),
                    Text(
                      AppStrings.schoolYearFull(schoolYear),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiText.p,
                    ),
                    if (lastCompletedLesson != null) ...[
                      const SizedBox(height: UiSpacing.xs),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: _planetSize * 0.45,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: color,
                              size: UiSpacing.md,
                            ),
                            const SizedBox(width: UiSpacing.xxs),
                            Flexible(
                              child: Text(
                                lastCompletedLesson!.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: UiText.small.copyWith(
                                  color: UiColor.textPrimary.withValues(
                                    alpha: .85,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: UiSpacing.xs),
                    Container(
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
