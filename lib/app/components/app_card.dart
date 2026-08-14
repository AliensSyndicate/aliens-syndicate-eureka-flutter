import 'package:flutter/material.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_radius.dart';

class AppCard extends StatelessWidget {
  const AppCard({required this.child, this.onTap, super.key});
  final Widget child;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(UiSpacing.md),
      child: child,
    );
    return Card(
      child: onTap == null
          ? content
          : InkWell(
              borderRadius: BorderRadius.circular(UiRadius.md),
              onTap: onTap,
              child: content,
            ),
    );
  }
}
