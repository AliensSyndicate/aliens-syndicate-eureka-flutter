import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_strings.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';

class LessonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LessonAppBar({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  Size get preferredSize => const Size.fromHeight(UiSize.homeAppBarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: UiColor.background,
    surfaceTintColor: UiColor.background,
    shadowColor: UiColor.background,
    elevation: 0,
    scrolledUnderElevation: 0,
    forceMaterialTransparency:
        false, // Alterado para false para respeitar a cor de fundo
    foregroundColor: UiColor.textPrimary,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: UiColor.background,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
    automaticallyImplyLeading: false,
    leadingWidth: UiSize.touchTarget + UiSpacing.xxs,
    leading: Padding(
      padding: const EdgeInsets.only(left: UiSpacing.xxs),
      child: SizedBox.square(
        dimension: UiSize.touchTarget,
        child: IconButton(
          tooltip: AppStrings.closeActivity,
          onPressed: onClose,
          icon: UiIcon.close(size: UiSize.iconLg),
        ),
      ),
    ),
  );
}
