import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_strings.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class LessonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LessonAppBar({
    required this.remainingTime,
    required this.lessonDuration,
    required this.currentPage,
    required this.totalPages,
    super.key,
  });

  final ValueListenable<Duration> remainingTime;
  final Duration lessonDuration;
  final int currentPage;
  final int totalPages;

  @override
  Size get preferredSize => const Size.fromHeight(UiSize.homeAppBarHeight);

  @override
  Widget build(BuildContext context) {
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
          const Spacer(),
          ValueListenableBuilder<Duration>(
            valueListenable: remainingTime,
            builder: (context, value, child) {
              final elapsed = lessonDuration - value;
              final formattedTime = AppStrings.lessonElapsedTime(elapsed);
              return Semantics(
                label: AppStrings.lessonElapsedTimeLabel,
                value: formattedTime,
                child: ExcludeSemantics(
                  child: Text(
                    formattedTime,
                    key: const ValueKey('lesson-elapsed-time'),
                    style: UiText.h6,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: UiSpacing.xxxl),
          Semantics(
            label: AppStrings.lessonPaginationLabel,
            value: AppStrings.lessonPagination(currentPage, totalPages),
            child: ExcludeSemantics(
              child: Text(
                AppStrings.lessonPagination(currentPage, totalPages),
                key: const ValueKey('lesson-pagination'),
                style: UiText.h6,
              ),
            ),
          ),
          const SizedBox(width: UiSpacing.md),
        ],
      ),
    );
  }
}
