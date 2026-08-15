import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_radius.dart';
import '../../ui/ui_size.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';

class AppHomeBar extends StatelessWidget implements PreferredSizeWidget {
  const AppHomeBar({
    required this.xp,
    required this.level,
    required this.onXpTap,
    required this.onLevelTap,
    super.key,
  });
  final int xp;
  final int level;
  final VoidCallback onXpTap;
  final VoidCallback onLevelTap;

  @override
  Size get preferredSize => const Size.fromHeight(UiSize.homeAppBarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: UiSize.homeAppBarHeight,
    titleSpacing: UiSpacing.pageHorizontal,
    title: Text(
      AppStrings.appName,
      style: UiText.h3.copyWith(
        color: UiColor.accent,
        fontWeight: FontWeight.w800,
      ),
    ),
    actionsPadding: const EdgeInsets.only(right: UiSpacing.pageHorizontal),
    actions: [
      _NumericButton(
        value: xp,
        semanticLabel: AppStrings.xpLabel,
        onTap: onXpTap,
      ),
      const SizedBox(width: UiSpacing.xs),
      _NumericButton(
        value: level,
        semanticLabel: AppStrings.levelLabel,
        onTap: onLevelTap,
      ),
    ],
  );
}

class _NumericButton extends StatelessWidget {
  const _NumericButton({
    required this.value,
    required this.semanticLabel,
    required this.onTap,
  });
  final int value;
  final String semanticLabel;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    value: '$value',
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(UiRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiRadius.pill),
        child: SizedBox(
          width: UiSize.numericButtonWidth,
          height: UiSize.buttonHeightSm,
          child: Center(
            child: Text(
              '$value',
              style: UiText.h6.copyWith(
                color: UiColor.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
