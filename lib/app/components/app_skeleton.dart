import 'package:flutter/material.dart';

import '../../ui/ui_color.dart';
import '../../ui/ui_radius.dart';

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    required this.height,
    this.width = double.infinity,
    this.radius = UiRadius.sm,
    super.key,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: UiColor.skeleton,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
