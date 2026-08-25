import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({
    required this.onTap,
    this.width = 260.0,
    this.height = 72.0,
    super.key,
  });

  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiRadius.card),
          side: const BorderSide(
            color: UiColor.loginBorder,
            width: UiCard.highlightBorderWidth,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UiSpacing.cardPadding,
              vertical: UiSpacing.xs,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.createEurekaAccount,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                  style: UiText.h6.copyWith(
                    fontSize: 15,
                    color: UiColor.loginBorder,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.saveMyProgress,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                  style: UiText.label.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
