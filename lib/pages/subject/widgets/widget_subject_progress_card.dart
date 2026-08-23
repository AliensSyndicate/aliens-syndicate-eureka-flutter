import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class SubjectProgressCard extends StatelessWidget {
  const SubjectProgressCard({
    required this.completed,
    required this.total,
    required this.color,
    super.key,
  });

  final int completed;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Container(
      key: const ValueKey('subject-progress-card'),
      padding: const EdgeInsets.symmetric(
        horizontal: UiSpacing.md,
        vertical: UiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: UiColor.surface,
        borderRadius: BorderRadius.circular(UiRadius.card),
        border: Border.all(color: UiColor.outline, width: UiCard.borderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.completeAllLessons, style: UiText.p),
          const SizedBox(height: UiSpacing.xs),
          SizedBox(
            key: const ValueKey('subject-progress-bar'),
            height: UiCard.progressTagHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(UiRadius.pill),
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: UiColor.textPrimary.withValues(alpha: .28),
                    color: color,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      AppStrings.progressRatio(completed, total),
                      textAlign: TextAlign.center,
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      style: UiText.p.copyWith(
                        color: UiColor.background,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
