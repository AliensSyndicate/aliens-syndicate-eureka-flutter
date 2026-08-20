import 'package:flutter/material.dart';

import '../../../app/components/app_skeleton.dart';
import '../../../l10n/app_strings.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_spacing.dart';

class HomeCardsSkeleton extends StatelessWidget {
  const HomeCardsSkeleton({super.key});

  static const subjectCount = 3;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: AppStrings.loadingContent,
      child: ExcludeSemantics(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: UiSpacing.pageHorizontal,
            vertical: UiSpacing.pageVertical,
          ),
          children: [
            const _SectionTitleSkeleton(width: 238),
            const SizedBox(height: UiSpacing.sm),
            const _CardSkeleton(
              key: ValueKey('home-feature-skeleton'),
              height: UiCard.continueMinHeight,
            ),
            const SizedBox(height: UiSpacing.sectionSpacing),
            const _SectionTitleSkeleton(width: 104),
            const SizedBox(height: UiSpacing.sm),
            for (var index = 0; index < subjectCount; index++) ...[
              _CardSkeleton(
                key: ValueKey('home-subject-skeleton-$index'),
                height: UiCard.subjectHeight,
              ),
              if (index < subjectCount - 1)
                const SizedBox(height: UiSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitleSkeleton extends StatelessWidget {
  const _SectionTitleSkeleton({this.width = 220});

  final double width;

  @override
  Widget build(BuildContext context) =>
      AppSkeleton(height: 29, width: width, radius: UiRadius.xs);
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({required this.height, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: UiColor.skeleton,
        borderRadius: BorderRadius.circular(UiRadius.card),
        border: Border.all(
          color: UiColor.skeleton,
          width: UiCard.highlightBorderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: const AppSkeleton(height: double.infinity, radius: UiRadius.card),
    );
  }
}
