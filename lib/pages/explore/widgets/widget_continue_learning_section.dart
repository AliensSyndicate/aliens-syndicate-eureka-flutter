import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../models/model_lesson.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

/// Seção "Continuar estudando" — lessons acessadas recentemente pelo Explorar.
class ContinueLearningSection extends StatelessWidget {
  const ContinueLearningSection({
    required this.lessons,
    required this.onTap,
    super.key,
  });

  final List<Lesson> lessons;
  final ValueChanged<Lesson> onTap;

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.exploreContinueLearning, style: UiText.h6),
          const SizedBox(height: UiSpacing.sm),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: lessons.take(5).length,
              separatorBuilder: (_, _) => const SizedBox(width: UiSpacing.sm),
              itemBuilder: (_, i) => _RecentLessonChip(
                lesson: lessons[i],
                onTap: () => onTap(lessons[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentLessonChip extends StatelessWidget {
  const _RecentLessonChip({required this.lesson, required this.onTap});

  final Lesson lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = UiColor.forSubject(lesson.subject);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200, minWidth: 120),
        padding: const EdgeInsets.symmetric(
          horizontal: UiSpacing.md,
          vertical: UiSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(UiRadius.card),
          border: Border.all(color: color.withValues(alpha: .3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lesson.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: UiText.small.copyWith(
                color: UiColor.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              AppStrings.schoolYear(lesson.schoolYear),
              style: UiText.small.copyWith(fontSize: 11, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
