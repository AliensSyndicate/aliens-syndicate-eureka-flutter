import 'package:flutter/material.dart';

import '../../../app/components/app_skeleton.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';

/// Skeleton de carregamento para a lista de resultados do Explorar.
///
/// Exibe 5 linhas para evitar spinner gigante no centro da tela.
class ExploreSkeleton extends StatelessWidget {
  const ExploreSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.symmetric(
      horizontal: UiSpacing.pageHorizontal,
      vertical: UiSpacing.md,
    ),
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: 5,
    separatorBuilder: (_, _) => const SizedBox(height: UiSpacing.lg),
    itemBuilder: (_, _) => const _SkeletonItem(),
  );
}

class _SkeletonItem extends StatelessWidget {
  const _SkeletonItem();

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Ícone da matéria (placeholder circular)
      AppSkeleton(height: UiSize.iconLg, width: UiSize.iconLg),
      const SizedBox(width: UiSpacing.md),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSkeleton(height: 16, width: double.infinity),
            const SizedBox(height: UiSpacing.xxs),
            AppSkeleton(height: 12, width: 140),
            const SizedBox(height: UiSpacing.xxs),
            AppSkeleton(height: 12, width: 200),
          ],
        ),
      ),
    ],
  );
}
