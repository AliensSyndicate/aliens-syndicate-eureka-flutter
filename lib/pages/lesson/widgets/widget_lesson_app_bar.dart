import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_strings.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';
import 'widget_progress_bar.dart';

class LessonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LessonAppBar({
    required this.progress,
    required this.progressColor,
    required this.remainingTime,
    super.key,
  });

  final double progress;
  final Color progressColor;
  final ValueListenable<Duration> remainingTime;

  @override
  Size get preferredSize => const Size.fromHeight(UiSize.homeAppBarHeight);

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);
    return AppBar(
      backgroundColor: UiColor.background,
      foregroundColor: UiColor.textPrimary,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: UiColor.background,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      automaticallyImplyLeading: false,
      excludeHeaderSemantics: true,
      titleSpacing: UiSpacing.xs,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            tooltip: AppStrings.closeActivity,
            constraints: const BoxConstraints.tightFor(
              width: UiSize.touchTarget,
              height: UiSize.touchTarget,
            ),
            onPressed: () => Navigator.maybePop(context),
            icon: UiIcon.close(size: UiSize.iconLg),
          ),
          const SizedBox(width: UiSpacing.sm),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: LessonProgressBar(
                value: normalizedProgress,
                progressColor: progressColor,
              ),
            ),
          ),
          const SizedBox(width: UiSpacing.lg),
          SizedBox(
            width: UiSize.lessonTimerWidth,
            child: ValueListenableBuilder<Duration>(
              valueListenable: remainingTime,
              builder: (context, value, child) {
                final formattedTime = AppStrings.lessonTime(value);
                return Semantics(
                  label: AppStrings.lessonTimeRemaining,
                  value: formattedTime,
                  child: ExcludeSemantics(
                    child: Text(
                      formattedTime,
                      key: const ValueKey('lesson-remaining-time'),
                      style: UiText.h6,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: UiSpacing.sm),
        ],
      ),
    );
  }
}
