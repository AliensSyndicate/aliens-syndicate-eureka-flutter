import 'package:flutter/material.dart';
import '../../../models/model_learning_recommendation.dart';
import '../../../l10n/app_strings.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
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
    final color = UiColor.forSubject(recommendation.subject.type);
    return Material(
      color: color,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(UiRadius.card),
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: UiCard.recommendationMinHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(UiSpacing.cardPadding),
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
                        style: UiText.label.copyWith(
                          color: UiColor.background.withValues(alpha: .68),
                        ),
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
