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
    super.key,
  });
  final VoidCallback onClose;
  final VoidCallback onReport;
  @override
  Size get preferredSize => const Size.fromHeight(UiSize.homeAppBarHeight);
  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: UiColor.background,
    foregroundColor: UiColor.textPrimary,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: UiColor.background,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
    automaticallyImplyLeading: false,
    leading: IconButton(
      tooltip: AppStrings.closeActivity,
      constraints: const BoxConstraints.tightFor(
        width: UiSize.touchTarget,
        height: UiSize.touchTarget,
      ),
      onPressed: onClose,
      icon: UiIcon.close(size: UiSize.iconLg),
    ),
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
