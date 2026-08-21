import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_strings.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_size.dart';

class LessonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LessonAppBar({
    required this.onClose,
    required this.onReport,
    required this.indicators,
    super.key,
  });
  final VoidCallback onClose;
  final VoidCallback onReport;
  final Widget indicators;
  @override
  Size get preferredSize => const Size.fromHeight(UiSize.homeAppBarHeight);
  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    forceMaterialTransparency: true,
    foregroundColor: UiColor.textPrimary,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
    automaticallyImplyLeading: false,
    centerTitle: true,
    titleSpacing: 0,
    leading: IconButton(
      tooltip: AppStrings.closeActivity,
      constraints: const BoxConstraints.tightFor(
        width: UiSize.touchTarget,
        height: UiSize.touchTarget,
      ),
      onPressed: onClose,
      icon: UiIcon.close(size: UiSize.iconLg),
    ),
    title: indicators,
    actions: [
      IconButton(
        tooltip: AppStrings.reportError,
        constraints: const BoxConstraints.tightFor(
          width: UiSize.touchTarget,
          height: UiSize.touchTarget,
        ),
        onPressed: onReport,
        icon: UiIcon.report(size: UiSize.iconMd),
      ),
    ],
  );
}
