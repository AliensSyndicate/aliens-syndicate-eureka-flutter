import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../models/content/model_content_manifest.dart';
import '../../../models/model_lesson.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_gradient.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    required this.subject,
    required this.lesson,
    required this.onTap,
    this.width = 260.0,
    this.height = 92.0,
    super.key,
  });

  final SubjectContentManifest subject;
  final Lesson lesson;
  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: UiColor.recommendationBase,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiRadius.card),
          side: const BorderSide(
            color: UiColor.recommendationBorder,
            width: UiCard.highlightBorderWidth,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: const BoxDecoration(
              gradient: UiGradient.recommendation,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiSpacing.cardPadding,
                vertical: UiSpacing.xs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.recommendationTitle,
                    maxLines: 1,
                    softWrap: false,
                    style: UiText.label.copyWith(
                      fontSize: 14,
                      color: UiColor.background.withValues(alpha: .75),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subject.title,
                    maxLines: 1,
                    softWrap: false,
                    style: UiText.h6.copyWith(
                      fontSize: 17,
                      color: UiColor.background,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lesson.title,
                    maxLines: 1,
                    softWrap: false,
                    style: UiText.label.copyWith(
                      fontSize: 15,
                      color: UiColor.background.withValues(alpha: .80),
                      fontWeight: FontWeight.w500,
                    ),
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
