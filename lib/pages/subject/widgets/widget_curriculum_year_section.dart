import 'package:flutter/material.dart';

import '../../../models/content/model_content_manifest.dart';
import '../../../models/model_lesson.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';
import '../../../ui/ui_trail.dart';

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
    final completed = year.lessons
        .where((lesson) => completedLessonIds.contains(lesson.id))
        .length;
    final progress = year.lessons.isEmpty
        ? 0
        : ((completed / year.lessons.length) * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: UiSpacing.sectionSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(year.title, style: UiText.h5)),
              _ProgressTag(progress: progress, color: color),
            ],
          ),
          const SizedBox(height: UiSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(UiRadius.pill),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: UiSpacing.xxs,
              backgroundColor: UiColor.surfaceElevated,
              color: color,
            ),
          ),
          const SizedBox(height: UiSpacing.sm),
          ...year.lessons.indexed.map((entry) {
            final (index, lesson) = entry;
            return _TrailItem(
              lesson: lesson,
              color: color,
              isCompleted: completedLessonIds.contains(lesson.id),
              isLast: index == year.lessons.length - 1,
              onTap: () => onLessonTap(lesson),
            );
          }),
        ],
      ),
    );
  }
}

class _TrailItem extends StatelessWidget {
  const _TrailItem({
    required this.lesson,
    required this.color,
    required this.isCompleted,
    required this.isLast,
    required this.onTap,
  });

  final Lesson lesson;
  final Color color;
  final bool isCompleted, isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${lesson.title}, ${isCompleted ? 'concluído' : '0 por cento'}',
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UiRadius.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: UiTrail.itemMinHeight),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: UiTrail.nodeSize,
              height: UiTrail.itemMinHeight,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  if (!isLast)
                    Positioned(
                      top: UiTrail.nodeSize,
                      bottom: 0,
                      child: Container(
                        width: UiTrail.connectorWidth,
                        color: color.withValues(alpha: .55),
                      ),
                    ),
                  Container(
                    width: UiTrail.nodeSize,
                    height: UiTrail.nodeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? color : UiColor.background,
                      border: Border.all(
                        color: color,
                        width: UiTrail.nodeBorderWidth,
                      ),
                    ),
                    child: isCompleted
                        ? Icon(
                            Icons.check_rounded,
                            size: UiSpacing.md,
                            color: UiColor.background,
                          )
                        : Center(
                            child: Container(
                              width: UiSpacing.xs,
                              height: UiSpacing.xs,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: UiSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: UiSpacing.md),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(lesson.title, style: UiText.p),
                ),
              ),
            ),
            const SizedBox(width: UiSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(bottom: UiSpacing.md),
              child: Align(
                alignment: Alignment.topCenter,
                child: _ProgressTag(
                  progress: isCompleted ? 100 : 0,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProgressTag extends StatelessWidget {
  const _ProgressTag({required this.progress, required this.color});
  final int progress;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    height: UiTrail.progressTagHeight,
    padding: const EdgeInsets.symmetric(horizontal: UiSpacing.sm),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(UiRadius.pill),
    ),
    child: Text(
      '$progress%',
      style: UiText.label.copyWith(color: color, fontWeight: FontWeight.w800),
    ),
  );
}
