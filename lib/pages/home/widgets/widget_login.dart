import 'package:flutter/material.dart';

import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_gradient.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({required this.onTap, super.key});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: UiColor.loginBase,
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
        child: Ink(
          decoration: const BoxDecoration(gradient: UiGradient.login),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UiSpacing.lg,
              vertical: UiSpacing.xl,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Criar conta Eureka',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiText.h5.copyWith(
                          color: UiColor.background,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: UiSpacing.xxs),
                      Text(
                        'Salve seu progresso na nuvem, acesse de outros dispositivos e mantenha seus dados seguros.',
                        style: UiText.label.copyWith(
                          color: UiColor.background.withValues(alpha: .85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: UiSpacing.sm),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: UiSize.iconLg,
                  color: UiColor.background,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
