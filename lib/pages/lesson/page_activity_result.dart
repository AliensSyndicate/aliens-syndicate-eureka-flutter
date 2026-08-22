import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/components/app_button.dart';
import '../../app/navigation/navigation_router.dart';
import '../../l10n/app_strings.dart';
import '../../models/model_activity_result.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';

class PageActivityResult extends StatelessWidget {
  const PageActivityResult({required this.result, super.key});
  final ActivityResult result;

  @override
  Widget build(BuildContext context) {
    final percent = (result.score * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.activityResult)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(UiSpacing.pageHorizontal),
          children: [
            Text('$percent%', style: UiText.h1),
            const SizedBox(height: UiSpacing.xs),
            Text(_message(percent), style: UiText.h5),
            const SizedBox(height: UiSpacing.xxl),
            Text(
              AppStrings.activitiesSummaryResult(
                result.correctAnswers,
                result.totalQuestions,
              ),
              style: UiText.h5,
            ),
            const SizedBox(height: UiSpacing.sm),
            Text(
              AppStrings.activityDuration(result.duration.inMinutes),
              style: UiText.p.copyWith(color: UiColor.textSecondary),
            ),
            if (result.earnedXp > 0) ...[
              const SizedBox(height: UiSpacing.sm),
              Text(
                AppStrings.activityEarnedXp(result.earnedXp),
                style: UiText.p.copyWith(color: UiColor.xp),
              ),
            ],
            if (result.reviewTopics.isNotEmpty) ...[
              const SizedBox(height: UiSpacing.xl),
              Text(
                AppStrings.activityReviewSuggestion,
                style: UiText.p.copyWith(color: UiColor.warning),
              ),
            ],
            const SizedBox(height: UiSpacing.xxl),
            AppButton(
              label: AppStrings.backToHome,
              onPressed: () => context.goNamed(AppRoute.home),
            ),
          ],
        ),
      ),
    );
  }

  static String _message(int percent) => percent >= 90
      ? AppStrings.simulationExcellent
      : percent >= 70
      ? AppStrings.simulationWellDone
      : AppStrings.simulationAlmostThere;
}
