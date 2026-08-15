import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../models/model_learning_recommendation.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_gradient.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    required this.recommendation,
    required this.onTap,
    super.key,
  });
  final LearningRecommendation recommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: UiColor.recommendationBase,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiRadius.card),
        side: const BorderSide(
          color: UiColor.recommendationBorder,
          width: UiCard.recommendationBorderWidth,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: const BoxDecoration(gradient: UiGradient.recommendation),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UiSpacing.lg,
              vertical: UiSpacing.xl,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        recommendation.subject.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiText.h5.copyWith(
                          color: UiColor.background,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: UiSpacing.xxs),
                      Text(
                        AppStrings.recommendationReason(
                          recommendation.lesson.title,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: UiText.label.copyWith(color: UiColor.background),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: UiSpacing.sm),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: UiSize.iconLg,
                  color: UiColor.background,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
