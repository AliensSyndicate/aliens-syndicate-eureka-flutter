import 'package:flutter/material.dart';

import '../../l10n/app_strings.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_radius.dart';
import '../../ui/ui_size.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';

class AppHomeBar extends StatelessWidget implements PreferredSizeWidget {
  const AppHomeBar({required this.xp, required this.onXpTap, super.key});

  final int xp;
  final VoidCallback onXpTap;

  @override
  Size get preferredSize => const Size.fromHeight(UiSize.homeAppBarHeight);

  @override
  Widget build(BuildContext context) => SizedBox(
    height: preferredSize.height,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.pageHorizontal),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UiIcon.logo(size: UiSize.logoSize),
          _BadgeButton(
            text: '$xp',
            textColor: UiColor.text,
            icon: UiIcon.diamontXp(size: UiSize.iconMd),
            semanticLabel: AppStrings.xpLabel,
            onTap: onXpTap,
          ),
        ],
      ),
    ),
  );
}

class _BadgeButton extends StatelessWidget {
  const _BadgeButton({
    required this.text,
    required this.textColor,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final String text;
  final Color textColor;
  final Widget icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    value: text,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(UiRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiRadius.pill),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpacing.sm),
          child: SizedBox(
            height: UiSize.buttonHeightSm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 4),
                Text(
                  text,
                  style: UiText.h6.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
