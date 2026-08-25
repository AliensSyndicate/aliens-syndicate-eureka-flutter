import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

enum LessonFeedbackStatus { success, error }

class LessonFeedbackCard extends StatelessWidget {
  const LessonFeedbackCard({
    required this.status,
    required this.title,
    this.explanation,
    this.message,
    this.onReport,
    this.earnedXp,
    this.xpAlreadyEarned = false,
    super.key,
  });

  final LessonFeedbackStatus status;
  final String title;
  final String? message;
  final String? explanation;
  final VoidCallback? onReport;
  final int? earnedXp;
  final bool xpAlreadyEarned;

  @override
  Widget build(BuildContext context) {
    final success = status == LessonFeedbackStatus.success;
    final color = success ? UiColor.success : UiColor.error;

    return Semantics(
      liveRegion: true,
      container: true,
      label:
          '$title ${earnedXp == null ? '' : AppStrings.earnedXpGain(earnedXp!)} '
          '${xpAlreadyEarned ? AppStrings.xpAlreadyEarned : ''} '
          '${message ?? ''} ${explanation ?? ''}',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: UiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      success
                          ? UiIcon.correct(color: color, size: UiSize.iconMd)
                          : UiIcon.incorrect(color: color, size: UiSize.iconMd),
                      const SizedBox(width: UiSpacing.xs),
                      Flexible(
                        child: Text(
                          title,
                          style: UiText.h6.copyWith(color: color),
                        ),
                      ),
                    ],
                  ),
                ),
                if (success && (earnedXp != null || xpAlreadyEarned)) ...[
                  const SizedBox(width: UiSpacing.sm),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UiIcon.diamontXp(size: UiSize.iconMd),
                      const SizedBox(width: UiSpacing.xxs),
                      Text(
                        xpAlreadyEarned
                            ? AppStrings.xpAlreadyEarned
                            : AppStrings.earnedXpGain(earnedXp!),
                        style: UiText.h6.copyWith(color: UiColor.xp),
                      ),
                    ],
                  ),
                ],
                if (onReport != null) ...[
                  const SizedBox(width: UiSpacing.xs),
                  IconButton(
                    onPressed: onReport,
                    tooltip: AppStrings.reportError,
                    icon: UiIcon.report(size: UiSize.iconMd),
                  ),
                ],
              ],
            ),
            if (message?.trim().isNotEmpty == true) ...[
              const SizedBox(height: UiSpacing.sm),
              Text(
                _messageLabel,
                style: UiText.label.copyWith(color: UiColor.error),
              ),
              const SizedBox(height: UiSpacing.xxs),
              Text(_messageValue, style: UiText.p),
            ],
            if (!success && explanation?.trim().isNotEmpty == true) ...[
              const SizedBox(height: UiSpacing.sm),
              Text(
                AppStrings.answerExplanation,
                style: UiText.label.copyWith(color: UiColor.error),
              ),
              const SizedBox(height: UiSpacing.xxs),
              Text(explanation!, style: UiText.p),
            ],
          ],
        ),
      ),
    );
  }

  String get _messageLabel {
    final separator = message?.indexOf('\n') ?? -1;
    return separator < 0 ? message ?? '' : message!.substring(0, separator);
  }

  String get _messageValue {
    final separator = message?.indexOf('\n') ?? -1;
    return separator < 0 ? '' : message!.substring(separator + 1);
  }
}
