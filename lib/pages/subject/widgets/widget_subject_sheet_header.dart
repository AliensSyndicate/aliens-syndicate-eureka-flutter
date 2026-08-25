import 'package:flutter/material.dart';

import '../../../enums/subject_type.dart';
import '../../../l10n/app_strings.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';
import 'widget_subject_progress_card.dart';

class SubjectSheetHeader extends StatelessWidget {
  const SubjectSheetHeader({
    required this.title,
    required this.color,
    required this.subject,
    required this.schoolYear,
    required this.xp,
    required this.completedLessons,
    required this.totalLessons,
    required this.onClose,
    required this.onReport,
    super.key,
  });

  final String title;
  final Color color;
  final SubjectType subject;
  final int schoolYear;
  final int xp;
  final int completedLessons;
  final int totalLessons;
  final VoidCallback onClose;
  final VoidCallback onReport;

  static const _planetSize = UiSize.subjectHeaderPlanet;

  @override
  Widget build(BuildContext context) => Stack(
    key: const ValueKey('subject-sheet-header'),
    children: [
      Positioned.fill(
        child: Image.asset(
          'assets/images/home.png',
          key: const ValueKey('subject-sheet-header-background'),
          fit: BoxFit.cover,
        ),
      ),
      Positioned(
        right: -20,
        top: 64,
        child: IgnorePointer(
          child: Opacity(
            opacity: .80,
            child: Image.asset(
              'assets/images/${subject.name}.png',
              key: const ValueKey('subject-header-planet'),
              width: _planetSize,
              height: _planetSize,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UiSpacing.sm,
              vertical: UiSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _HeaderAction(
                  tooltip: AppStrings.back,
                  onPressed: onClose,
                  icon: UiIcon.close(color: UiColor.textPrimary),
                ),
                _HeaderAction(
                  tooltip: AppStrings.reportError,
                  onPressed: onReport,
                  icon: UiIcon.report(color: UiColor.textPrimary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UiSpacing.pageHorizontal,
              0,
              UiSpacing.pageHorizontal,
              UiSpacing.headerBottomGap,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: _planetSize * .45),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiText.h3.copyWith(color: UiColor.textPrimary),
                      ),
                      const SizedBox(height: UiSpacing.xs),
                      Text(
                        AppStrings.schoolYearFull(schoolYear),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiText.p,
                      ),
                      const SizedBox(height: UiSpacing.sm),
                      Container(
                        key: const ValueKey('subject-xp-card'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            UiIcon.diamontXp(size: 18),
                            const SizedBox(width: UiSpacing.xxs),
                            Text(AppStrings.xpValue(xp), style: UiText.p),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: UiSpacing.sm),
                SubjectProgressCard(
                  completed: completedLessons,
                  total: totalLessons,
                  color: color,
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: icon,
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(),
    visualDensity: VisualDensity.compact,
  );
}
