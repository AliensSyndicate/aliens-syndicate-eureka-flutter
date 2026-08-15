import 'package:flutter/material.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/model_lesson.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    required this.lesson,
    required this.onTap,
    this.illustration,
    super.key,
  });

  final Lesson lesson;
  final VoidCallback onTap;

  /// Espaço reservado para a ilustração de cada matéria/lição.
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    final subjectColor = UiColor.forSubject(lesson.subject);
    return Padding(
      padding: const EdgeInsets.only(bottom: UiSpacing.sectionSpacing),
      child: Semantics(
        button: true,
        label: lesson.title,
        child: Material(
          color: subjectColor,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(UiCard.featureRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(UiCard.featureRadius),
            splashColor: UiColor.text.withValues(alpha: .16),
            highlightColor: UiColor.background.withValues(alpha: .08),
            child: SizedBox(
              height: UiCard.featureMinHeight,
              child: Padding(
                padding: const EdgeInsets.all(UiSpacing.xl),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _LessonCopy(lesson: lesson)),
                    if (illustration != null) ...[
                      const SizedBox(width: UiSpacing.md),
                      SizedBox(
                        width: UiCard.featureIllustrationWidth,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: illustration,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonCopy extends StatelessWidget {
  const _LessonCopy({required this.lesson});
  final Lesson lesson;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        lesson.title.toUpperCase(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: UiText.h3.copyWith(
          color: UiColor.background,
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
          height: 1,
        ),
      ),
      const SizedBox(height: UiSpacing.sm),
      Text(
        lesson.summary.toUpperCase(),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: UiText.label.copyWith(
          color: UiColor.background.withValues(alpha: .58),
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
        ),
      ),
      const Spacer(),
      Container(
        height: UiCard.featureActionHeight,
        padding: const EdgeInsets.symmetric(horizontal: UiSpacing.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: UiColor.background,
          borderRadius: BorderRadius.circular(UiRadius.pill),
        ),
        child: Text(
          AppStrings.start.toUpperCase(),
          style: UiText.label.copyWith(
            color: UiColor.text,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    ],
  );
}
