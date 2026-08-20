import 'package:flutter/material.dart';

import '../../../models/content/model_content_manifest.dart';
import '../../../models/model_lesson.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_gradient.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class ContinueLearningCard extends StatelessWidget {
  const ContinueLearningCard({
    required this.subject,
    required this.lesson,
    required this.progress,
    required this.onTap,
    super.key,
  });
  final SubjectContentManifest subject;
  final Lesson lesson;
  final int progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: UiColor.continueBase,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiRadius.card),
        side: const BorderSide(
          color: UiColor.continueBorder,
          width: UiCard.highlightBorderWidth,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: UiGradient.continueLearning,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: UiCard.continueMinHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.all(UiSpacing.cardPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject.title,
                              style: UiText.h5.copyWith(
                                color: UiColor.background,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: UiSpacing.xxs),
                            Text(
                              lesson.title,
                              style: UiText.label.copyWith(
                                color: UiColor.background.withValues(
                                  alpha: .72,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: UiSpacing.sm),
                      UiIcon.next(
                        size: UiSize.iconLg,
                        color: UiColor.background,
                      ),
                    ],
                  ),
                  const SizedBox(height: UiSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(UiRadius.pill),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: UiSize.progressHeight,
                            backgroundColor: UiColor.background.withValues(
                              alpha: .20,
                            ),
                            valueColor: const AlwaysStoppedAnimation(
                              UiColor.background,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: UiSpacing.sm),
                      Text(
                        '$progress%',
                        style: UiText.h6.copyWith(
                          color: UiColor.background,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
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
