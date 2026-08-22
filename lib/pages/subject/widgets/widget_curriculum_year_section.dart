import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../models/content/model_content_manifest.dart';
import '../../../models/model_lesson.dart';
import '../../../services/service_registry.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class CurriculumYearSection extends StatelessWidget {
  const CurriculumYearSection({
    required this.year,
    required this.color,
    required this.completedLessonIds,
    required this.onLessonTap,
    super.key,
  });

  final SubjectSchoolYearManifest year;
  final Color color;
  final Set<String> completedLessonIds;
  final ValueChanged<Lesson> onLessonTap;

  @override
  Widget build(BuildContext context) {
    final completedLessons = year.lessons
        .where((lesson) => completedLessonIds.contains(lesson.id))
        .length;

    return Padding(
      padding: const EdgeInsets.only(bottom: UiSpacing.sectionSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(year.title, style: UiText.h5)),
              _FractionProgressTag(
                completed: completedLessons,
                total: year.lessons.length,
              ),
            ],
          ),
          const SizedBox(height: UiSpacing.sm),
          Container(
            key: ValueKey('curriculum-content-${year.id}'),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(UiRadius.card),
              border: Border.all(
                color: UiColor.outline,
                width: UiCard.borderWidth,
              ),
            ),
            child: Column(
              children: year.lessons.indexed.expand((entry) {
                final (index, lesson) = entry;
                return [
                  _ContentItem(
                    lesson: lesson,
                    color: color,
                    isCompleted: completedLessonIds.contains(lesson.id),
                    onTap: () => onLessonTap(lesson),
                  ),
                  if (index < year.lessons.length - 1)
                    const Divider(height: 1, thickness: 1),
                ];
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentItem extends StatelessWidget {
  const _ContentItem({
    required this.lesson,
    required this.color,
    required this.isCompleted,
    required this.onTap,
  });

  final Lesson lesson;
  final Color color;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final totalPages = ServiceRegistry.content.pageCountForLesson(lesson);
    final completedPages = isCompleted ? totalPages : 0;

    return Semantics(
      button: true,
      label: AppStrings.lessonSemantics(lesson.title, isCompleted),
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: UiCard.subjectHeight),
          child: Row(
            children: [
              const SizedBox(width: UiSpacing.md),
              _StatusIcon(isCompleted: isCompleted, color: color),
              const SizedBox(width: UiSpacing.sm),
              Expanded(child: Text(lesson.title, style: UiText.p)),
              const SizedBox(width: UiSpacing.sm),
              _FractionProgressTag(
                completed: completedPages,
                total: totalPages,
              ),
              const SizedBox(width: UiSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.isCompleted, required this.color});

  final bool isCompleted;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: UiSpacing.md,
    height: UiSpacing.md,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isCompleted ? color : Colors.transparent,
      border: Border.all(color: color, width: UiCard.borderWidth),
    ),
    child: isCompleted
        ? UiIcon.check(size: UiSpacing.md, color: UiColor.background)
        : null,
  );
}

class _FractionProgressTag extends StatelessWidget {
  const _FractionProgressTag({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) => Text(
    AppStrings.progressRatio(completed, total),
    style: UiText.p.copyWith(
      color: UiColor.textSecondary,
      fontWeight: FontWeight.w800,
    ),
  );
}
