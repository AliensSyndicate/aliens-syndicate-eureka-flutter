import 'package:flutter/material.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';

class SocialSkeleton extends StatelessWidget {
  const SocialSkeleton({super.key});
  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(UiSpacing.pageHorizontal),
    itemCount: 4,
    separatorBuilder: (_, _) => const Divider(color: UiColor.divider),
    itemBuilder: (_, _) => const _SkeletonPost(),
  );
}

class _SkeletonPost extends StatelessWidget {
  const _SkeletonPost();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: UiSpacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _Block(
              width: UiSize.avatarMd,
              height: UiSize.avatarMd,
              round: true,
            ),
            const SizedBox(width: UiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Block(width: 110, height: 16),
                  const SizedBox(height: UiSpacing.xs),
                  const _Block(width: 48, height: 12),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: UiSpacing.md),
        const _Block(width: 260, height: 18),
        const SizedBox(height: UiSpacing.xs),
        const _Block(width: 180, height: 14),
      ],
    ),
  );
}

class _Block extends StatelessWidget {
  const _Block({required this.width, required this.height, this.round = false});
  final double width;
  final double height;
  final bool round;
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: UiColor.surfaceElevated,
      borderRadius: BorderRadius.circular(round ? width : UiRadius.sm),
    ),
  );
}
