import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../enums/subject_type.dart';
import '../../../l10n/app_strings.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_gradient.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class SubjectLessonsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const SubjectLessonsAppBar({
    required this.title,
    required this.color,
    required this.subject,
    required this.completedLessons,
    required this.totalLessons,
    required this.onBack,
    required this.onReport,
    super.key,
  });

  final String title;
  final Color color;
  final SubjectType subject;
  final int completedLessons;
  final int totalLessons;
  final VoidCallback onBack;
  final VoidCallback onReport;

  @override
  Size get preferredSize => const Size.fromHeight(UiSize.subjectAppBarHeight);

  @override
  Widget build(BuildContext context) {
    final progress = totalLessons == 0 ? 0.0 : completedLessons / totalLessons;
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: UiSize.subjectAppBarHeight,
      titleSpacing: 0,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: color,
      foregroundColor: UiColor.textPrimary,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      flexibleSpace: Ink(
        key: const ValueKey('subject-app-bar-background'),
        decoration: BoxDecoration(gradient: UiGradient.forSubject(subject)),
      ),
      title: Padding(
        padding: const EdgeInsets.fromLTRB(
          UiSpacing.xs,
          0,
          UiSpacing.xs,
          UiSpacing.md,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: AppStrings.back,
                  onPressed: onBack,
                  icon: UiIcon.back(color: UiColor.textPrimary),
                ),
                IconButton(
                  tooltip: AppStrings.reportError,
                  onPressed: onReport,
                  icon: UiIcon.report(color: UiColor.textPrimary),
                  // TODO: criar reporte
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UiText.h4.copyWith(color: UiColor.textPrimary),
                  ),
                  const SizedBox(height: UiSpacing.xs),
                  Container(
                    key: const ValueKey('subject-progress-card'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: UiSpacing.md,
                      vertical: UiSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: UiColor.background.withValues(alpha: .94),
                      borderRadius: BorderRadius.circular(UiRadius.card),
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
                                  backgroundColor: UiColor.textPrimary
                                      .withValues(alpha: .28),
                                  color: color,
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    AppStrings.progressRatio(
                                      completedLessons,
                                      totalLessons,
                                    ),
                                    textAlign: TextAlign.center,
                                    textHeightBehavior:
                                        const TextHeightBehavior(
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
