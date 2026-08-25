import 'package:flutter/material.dart';

import '../../../app/components/app_button.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/model_question.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class LessonSummary extends StatelessWidget {
  const LessonSummary({
    required this.questions,
    required this.resultFor,
    required this.primaryColor,
    required this.onRetry,
    required this.earnedXp,
    required this.totalXp,
    required this.showXp,
    required this.xpPerCorrectAnswer,
    required this.xpEarnedInCurrentAttemptFor,
    this.onFinish,
    super.key,
  });

  final List<Question> questions;
  final bool? Function(Question question) resultFor;
  final Color primaryColor;
  final VoidCallback onRetry;
  final VoidCallback? onFinish;
  final int earnedXp;
  final int totalXp;
  final bool showXp;
  final int xpPerCorrectAnswer;
  final bool Function(Question question) xpEarnedInCurrentAttemptFor;

  @override
  Widget build(BuildContext context) {
    final correctAnswers = questions
        .where((item) => resultFor(item) == true)
        .length;
    final answeredEntries = questions.indexed
        .where((entry) => resultFor(entry.$2) != null)
        .toList();
    final hasAnsweredActivity = answeredEntries.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.activitiesSummary, style: UiText.h4),
          const SizedBox(height: UiSpacing.sm),
          if (!hasAnsweredActivity)
            Text(AppStrings.summaryRequiresActivity, style: UiText.p)
          else ...[
            Text(AppStrings.activitiesSummaryIntro, style: UiText.p),
            const SizedBox(height: UiSpacing.xs),
            Text(
              AppStrings.activitiesSummaryResult(
                correctAnswers,
                answeredEntries.length,
              ),
              style: UiText.h6,
            ),
            const SizedBox(height: UiSpacing.xl),
          ],
          ...answeredEntries.map((entry) {
            final position = entry.$1 + 1;
            final question = entry.$2;
            final result = resultFor(question);
            final color = switch (result) {
              true => UiColor.success,
              false => UiColor.error,
              null => UiColor.warning,
            };
            final status = switch (result) {
              true => AppStrings.activityCorrect,
              false => AppStrings.activityIncorrect,
              null => AppStrings.activityNotDone,
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: UiSpacing.md),
              child: Semantics(
                label: AppStrings.activityItemSemantics(position, status),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: switch (result) {
                        true => UiIcon.correct(
                          size: UiSize.iconMd,
                          color: color,
                        ),
                        false => UiIcon.incorrect(
                          size: UiSize.iconMd,
                          color: color,
                        ),
                        null => UiIcon.timer(size: UiSize.iconMd, color: color),
                      },
                    ),
                    const SizedBox(width: UiSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.activityItemSummary(position, status),
                            style: UiText.label.copyWith(color: color),
                          ),
                          const SizedBox(height: UiSpacing.xxs),
                          Text(question.prompt, style: UiText.p),
                        ],
                      ),
                    ),
                    if (showXp && result == true) ...[
                      const SizedBox(width: UiSpacing.sm),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UiIcon.diamontXp(size: UiSize.iconSm),
                          const SizedBox(width: UiSpacing.xxs),
                          Text(
                            AppStrings.earnedXpGain(xpPerCorrectAnswer),
                            style: UiText.label.copyWith(color: UiColor.xp),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: UiSpacing.lg),
          if (showXp && hasAnsweredActivity) ...[
            Text(AppStrings.statement, style: UiText.h6),
            const SizedBox(height: UiSpacing.sm),
            ...answeredEntries.map((entry) {
              final position = entry.$1 + 1;
              final question = entry.$2;
              final result = resultFor(question);
              final isCorrect = result == true;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: UiSpacing.xxs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Atividade $position', style: UiText.p),
                    Text(
                      isCorrect
                          ? xpEarnedInCurrentAttemptFor(question)
                                ? AppStrings.earnedXpGain(xpPerCorrectAnswer)
                                : AppStrings.xpAlreadyEarned
                          : AppStrings.earnedXpGain(0),
                      style: UiText.p.copyWith(
                        color: isCorrect ? UiColor.xp : UiColor.textSecondary,
                        fontWeight: isCorrect
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: UiSpacing.xs),
            const Divider(height: 1, thickness: 1, color: UiColor.outline),
            const SizedBox(height: UiSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.lessonGains, style: UiText.p),
                Text(
                  AppStrings.earnedXpGain(earnedXp),
                  style: UiText.p.copyWith(
                    color: UiColor.xp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UiSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.totalXpBalance, style: UiText.p),
                Text(
                  AppStrings.xpValue(totalXp),
                  style: UiText.p.copyWith(
                    color: UiColor.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UiSpacing.sm),
            Text(
              AppStrings.xpOncePerActivity,
              style: UiText.small.copyWith(color: UiColor.textSecondary),
            ),
            const SizedBox(height: UiSpacing.lg),
          ],
          if (hasAnsweredActivity) ...[
            AppButton(
              key: const ValueKey('lesson-summary-finish'),
              label: AppStrings.finish,
              color: primaryColor,
              onPressed: onFinish,
            ),
            const SizedBox(height: UiSpacing.sm),
            AppButton(
              key: const ValueKey('lesson-summary-retry'),
              label: AppStrings.tryAgain,
              color: primaryColor,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
