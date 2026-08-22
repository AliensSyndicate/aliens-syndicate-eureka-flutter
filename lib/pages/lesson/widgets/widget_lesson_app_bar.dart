import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_strings.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';

class LessonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LessonAppBar({required this.onClose, this.onReport, super.key});

  final VoidCallback onClose;
  final VoidCallback? onReport;

  @override
  Size get preferredSize => const Size.fromHeight(UiSize.homeAppBarHeight);

  @override
  Widget build(BuildContext context) {
    const double sideWidth = UiSize.touchTarget + (UiSpacing.xxs * 2);

    return AppBar(
      backgroundColor: UiColor.background,
      surfaceTintColor: UiColor.background,
      shadowColor: UiColor.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      forceMaterialTransparency: false,
      foregroundColor: UiColor.textPrimary,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: UiColor.background,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      automaticallyImplyLeading: false,
      centerTitle: true,
      titleSpacing: 0,
      leadingWidth: sideWidth,
      leading: Padding(
        padding: const EdgeInsets.only(left: UiSpacing.xxs),
        child: Center(
          child: SizedBox.square(
            dimension: UiSize.touchTarget,
            child: IconButton(
              tooltip: AppStrings.closeActivity,
              onPressed: onClose,
              icon: UiIcon.close(size: UiSize.iconLg),
            ),
          ),
        ),
      ),
      title: const SizedBox.shrink(),
      actionsPadding: const EdgeInsets.only(right: UiSpacing.xxs),
      actions: [
        if (onReport != null)
          Center(
            child: SizedBox.square(
              dimension: UiSize.touchTarget,
              child: IconButton(
                tooltip: AppStrings.reportError,
                onPressed: onReport,
                icon: UiIcon.report(
                  size: UiSize.iconMd,
                  color: UiColor.textPrimary,
                ),
              ),
            ),
          )
        else
          const SizedBox(width: sideWidth - UiSpacing.xxs),
      ],
    );
  }
}
