import 'package:flutter/material.dart';
import '../../ui/ui_card.dart';
import '../../ui/ui_color.dart';

class AppCard extends StatelessWidget {
  const AppCard({required this.child, this.onTap, super.key});
  final Widget child;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(UiCard.padding),
      child: child,
    );
    final decorated = Material(
      color: UiColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiCard.radius),
        side: const BorderSide(
          color: UiColor.outline,
          width: UiCard.borderWidth,
        ),
      ),
      child: onTap == null
          ? content
          : InkWell(
              borderRadius: BorderRadius.circular(UiCard.radius),
              onTap: onTap,
              child: content,
            ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: UiCard.borderWidth),
      child: decorated,
    );
  }
}
